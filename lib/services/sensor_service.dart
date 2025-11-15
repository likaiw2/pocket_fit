import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:pocket_fit/models/sensor_data.dart';

/// 传感器服务类
/// 负责管理传感器数据采集、缓存和基本分析
class SensorService {
  // 单例模式
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  // 传感器数据流订阅
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  // 数据缓冲区（使用队列实现滑动窗口）
  final Queue<SensorData> _accelerometerBuffer = Queue();
  final Queue<SensorData> _gyroscopeBuffer = Queue();

  // 缓冲区大小配置
  static const int _bufferSize = 10; // 缓冲区大小

  // 动态采样间隔配置
  static const Duration _stillSamplingInterval = Duration(milliseconds: 2000); // 静止状态：2秒一次 (0.5 Hz)
  static const Duration _unknownSamplingInterval = Duration(milliseconds: 1000); // 未知状态：1秒一次 (1 Hz)
  static const Duration _movingSamplingInterval = Duration(milliseconds: 100); // 运动状态：0.1秒一次 (10 Hz)

  // 当前采样间隔（根据运动状态动态调整）
  Duration _currentSamplingInterval = Duration(milliseconds: 1000); // 初始使用未知状态频率

  // 数据流控制器
  final _accelerometerController = StreamController<SensorData>.broadcast();
  final _gyroscopeController = StreamController<SensorData>.broadcast();
  final _motionStateController = StreamController<MotionStatistics>.broadcast();
  final _sedentaryDurationController = StreamController<Duration>.broadcast();

  // 公开的数据流
  Stream<SensorData> get accelerometerStream => _accelerometerController.stream;
  Stream<SensorData> get gyroscopeStream => _gyroscopeController.stream;
  Stream<MotionStatistics> get motionStateStream => _motionStateController.stream;
  Stream<Duration> get sedentaryDurationStream => _sedentaryDurationController.stream;

  // 服务状态
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // 当前运动状态
  MotionState _currentMotionState = MotionState.unknown;
  MotionState get currentMotionState => _currentMotionState;

  // 最后一次采样时间
  DateTime? _lastAccelerometerSample;
  DateTime? _lastGyroscopeSample;

  // 久坐检测相关
  DateTime? _sedentaryStartTime; // 静止状态开始时间
  Duration _currentSedentaryDuration = Duration.zero; // 当前久坐时长
  Timer? _sedentaryTimer; // 久坐时长更新定时器

  // 久坐阈值配置
  static const Duration sedentaryWarningThreshold = Duration(minutes: 30); // 久坐警告阈值
  static const Duration sedentaryCriticalThreshold = Duration(minutes: 60); // 严重久坐阈值
  static const Duration activityResetThreshold = Duration(minutes: 1); // 活动多久后重置久坐计时

  // 久坐警告状态
  bool _hasWarningTriggered = false;
  bool _hasCriticalTriggered = false;

  // 活动检测相关
  DateTime? _activityStartTime; // 活动开始时间

  // 获取当前久坐时长
  Duration get currentSedentaryDuration => _currentSedentaryDuration;

  /// 启动传感器监听
  Future<void> start() async {
    if (_isRunning) {
      print('SensorService: 服务已在运行中');
      return;
    }

    print('SensorService: 启动传感器服务');
    _isRunning = true;

    // 订阅加速度计
    _accelerometerSubscription = accelerometerEventStream().listen(
      _onAccelerometerEvent,
      onError: (error) {
        print('SensorService: 加速度计错误 - $error');
      },
    );

    // 订阅陀螺仪
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      _onGyroscopeEvent,
      onError: (error) {
        print('SensorService: 陀螺仪错误 - $error');
      },
    );

    print('SensorService: 传感器服务已启动');
  }

  /// 停止传感器监听
  Future<void> stop() async {
    if (!_isRunning) {
      print('SensorService: 服务未运行');
      return;
    }

    print('SensorService: 停止传感器服务');
    _isRunning = false;

    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;

    // 停止久坐计时器
    _sedentaryTimer?.cancel();
    _sedentaryTimer = null;

    print('SensorService: 传感器服务已停止');
  }

  /// 处理加速度计事件
  void _onAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // 限制采样频率（根据当前运动状态动态调整）
    if (_lastAccelerometerSample != null &&
        now.difference(_lastAccelerometerSample!) < _currentSamplingInterval) {
      return;
    }
    _lastAccelerometerSample = now;

    final data = SensorData(
      timestamp: now,
      x: event.x,
      y: event.y,
      z: event.z,
      type: SensorType.accelerometer,
    );

    // 添加到缓冲区
    _addToBuffer(_accelerometerBuffer, data);

    // 发送数据到流
    _accelerometerController.add(data);
  }

  /// 处理陀螺仪事件
  void _onGyroscopeEvent(GyroscopeEvent event) {
    final now = DateTime.now();

    // 限制采样频率（根据当前运动状态动态调整）
    if (_lastGyroscopeSample != null &&
        now.difference(_lastGyroscopeSample!) < _currentSamplingInterval) {
      return;
    }
    _lastGyroscopeSample = now;

    final data = SensorData(
      timestamp: now,
      x: event.x,
      y: event.y,
      z: event.z,
      type: SensorType.gyroscope,
    );

    // 添加到缓冲区
    _addToBuffer(_gyroscopeBuffer, data);

    // 发送数据到流
    _gyroscopeController.add(data);

    // 分析运动状态（改为使用陀螺仪数据）
    _analyzeMotionState();
  }

  /// 添加数据到缓冲区（维护固定大小的滑动窗口）
  void _addToBuffer(Queue<SensorData> buffer, SensorData data) {
    buffer.add(data);
    if (buffer.length > _bufferSize) {
      buffer.removeFirst();
    }
  }

  /// 分析运动状态（改为主要使用陀螺仪）
  void _analyzeMotionState() {
    // 需要足够的陀螺仪数据
    if (_gyroscopeBuffer.length < 10) {
      // 数据不足时，只在第一次广播"检测中"状态
      if (_currentMotionState == MotionState.unknown && _gyroscopeBuffer.isEmpty) {
        final motionStats = MotionStatistics(
          variance: 0.0,
          mean: 0.0,
          stdDeviation: 0.0,
          state: MotionState.unknown,
          timestamp: DateTime.now(),
        );
        _motionStateController.add(motionStats);
      }
      return;
    }

    // 使用陀螺仪数据判断运动状态
    // 陀螺仪测量角速度，静止时接近0，更适合检测"是否在移动"
    // 注意：这里使用 magnitudeSquared (x² + y² + z²) 而不是 magnitude (√(x² + y² + z²))
    // 使用平方值可以避免开方运算，提高性能，且对比较大小没有影响
    final gyroMagnitudes = _gyroscopeBuffer.map((d) => d.magnitudeSquared).toList();
    final gyroStats = _calculateStatistics(gyroMagnitudes);

    // 陀螺仪阈值（基于 magnitude² = x² + y² + z²）
    // 静止时陀螺仪值接近0，所以阈值设置较小
    const double stillThreshold = 0.1; // 静止阈值（非常小的旋转）
    const double movingThreshold = 0.3; // 运动阈值（明显的旋转）

    MotionState state;

    // 使用均值而不是方差，因为陀螺仪静止时接近0
    final gyroMean = gyroStats['mean']!;

    if (gyroMean < stillThreshold) {
      state = MotionState.still;
    } else if (gyroMean > movingThreshold) {
      state = MotionState.moving;
    } else {
      state = MotionState.unknown;
    }

    // 辅助判断：如果加速度计数据也可用，结合判断
    if (_accelerometerBuffer.length >= 10) {
      // 加速度计也使用 magnitudeSquared
      final accelMagnitudes = _accelerometerBuffer.map((d) => d.magnitudeSquared).toList();
      final accelStats = _calculateStatistics(accelMagnitudes);

      // 如果加速度计方差很大（说明有剧烈运动），即使陀螺仪显示静止，也判断为运动
      // 注意：因为使用的是 magnitude²，所以阈值也需要相应调整
      const double accelMovingThreshold = 15.0;
      if (accelStats['variance']! > accelMovingThreshold) {
        state = MotionState.moving;
      }
    }

    // 动态调整采样频率
    _updateSamplingInterval(state);

    final motionStats = MotionStatistics(
      variance: gyroStats['variance']!,
      mean: gyroStats['mean']!,
      stdDeviation: gyroStats['stdDeviation']!,
      state: state,
      timestamp: DateTime.now(),
    );

    _motionStateController.add(motionStats);
  }

  /// 根据运动状态动态调整采样频率
  void _updateSamplingInterval(MotionState newState) {
    // 如果状态没有变化，不需要调整
    if (newState == _currentMotionState) {
      return;
    }

    final oldState = _currentMotionState;
    _currentMotionState = newState;

    Duration newInterval;
    switch (newState) {
      case MotionState.still:
        newInterval = _stillSamplingInterval; // 静止：2秒一次 (0.5 Hz)
        break;
      case MotionState.moving:
        newInterval = _movingSamplingInterval; // 运动：0.1秒一次 (10 Hz)
        break;
      case MotionState.unknown:
        newInterval = _unknownSamplingInterval; // 未知：1秒一次 (1 Hz)
        break;
    }

    if (newInterval != _currentSamplingInterval) {
      _currentSamplingInterval = newInterval;
      print('SensorService: 采样频率已调整 - $oldState -> $newState, 间隔: ${newInterval.inMilliseconds}ms');
    }

    // 处理久坐检测逻辑
    _handleSedentaryDetection(oldState, newState);
  }

  /// 处理久坐检测逻辑
  void _handleSedentaryDetection(MotionState oldState, MotionState newState) {
    final now = DateTime.now();

    // 状态从非静止变为静止 - 开始久坐计时
    if (oldState != MotionState.still && newState == MotionState.still) {
      _startSedentaryTimer(now);
    }
    // 状态从静止变为运动 - 检查是否需要重置久坐计时
    else if (oldState == MotionState.still && newState == MotionState.moving) {
      _activityStartTime = now;
      print('SensorService: 检测到活动开始');
    }
    // 状态从运动变为静止 - 检查活动时长是否足够重置久坐
    else if (oldState == MotionState.moving && newState == MotionState.still) {
      if (_activityStartTime != null) {
        final activityDuration = now.difference(_activityStartTime!);
        if (activityDuration >= activityResetThreshold) {
          // 活动时间足够长，重置久坐计时
          _resetSedentaryTimer();
          print('SensorService: 活动时长 ${activityDuration.inSeconds}秒，久坐计时已重置');
        } else {
          // 活动时间太短，继续之前的久坐计时
          print('SensorService: 活动时长 ${activityDuration.inSeconds}秒（不足${activityResetThreshold.inMinutes}分钟），继续久坐计时');
        }
      }
      _activityStartTime = null;
    }
  }

  /// 开始久坐计时
  void _startSedentaryTimer(DateTime startTime) {
    _sedentaryStartTime = startTime;
    _hasWarningTriggered = false;
    _hasCriticalTriggered = false;

    print('SensorService: 开始久坐计时 - ${startTime.toString()}');

    // 启动定时器，每秒更新一次久坐时长
    _sedentaryTimer?.cancel();
    _sedentaryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateSedentaryDuration();
    });
  }

  /// 更新久坐时长
  void _updateSedentaryDuration() {
    if (_sedentaryStartTime == null) return;

    final now = DateTime.now();
    _currentSedentaryDuration = now.difference(_sedentaryStartTime!);

    // 广播久坐时长更新
    _sedentaryDurationController.add(_currentSedentaryDuration);

    // 检查是否达到警告阈值
    if (!_hasWarningTriggered && _currentSedentaryDuration >= sedentaryWarningThreshold) {
      _hasWarningTriggered = true;
      print('SensorService: ⚠️ 久坐警告 - 已静止 ${_currentSedentaryDuration.inMinutes} 分钟');
      // TODO: 触发久坐警告事件
    }

    // 检查是否达到严重阈值
    if (!_hasCriticalTriggered && _currentSedentaryDuration >= sedentaryCriticalThreshold) {
      _hasCriticalTriggered = true;
      print('SensorService: 🚨 严重久坐警告 - 已静止 ${_currentSedentaryDuration.inMinutes} 分钟');
      // TODO: 触发严重久坐警告事件
    }
  }

  /// 重置久坐计时
  void _resetSedentaryTimer() {
    _sedentaryTimer?.cancel();
    _sedentaryTimer = null;
    _sedentaryStartTime = null;
    _currentSedentaryDuration = Duration.zero;
    _hasWarningTriggered = false;
    _hasCriticalTriggered = false;
    _activityStartTime = null;

    // 广播久坐时长重置
    _sedentaryDurationController.add(Duration.zero);

    print('SensorService: 久坐计时已重置');
  }

  /// 计算统计数据（均值、方差、标准差）
  Map<String, double> _calculateStatistics(List<double> values) {
    if (values.isEmpty) {
      return {'mean': 0.0, 'variance': 0.0, 'stdDeviation': 0.0};
    }

    // 计算均值
    final mean = values.reduce((a, b) => a + b) / values.length;

    // 计算方差
    final variance = values
            .map((value) => pow(value - mean, 2))
            .reduce((a, b) => a + b) /
        values.length;

    // 计算标准差
    final stdDeviation = sqrt(variance);

    return {
      'mean': mean,
      'variance': variance,
      'stdDeviation': stdDeviation,
    };
  }

  /// 获取当前加速度计缓冲区数据
  List<SensorData> get accelerometerBuffer => _accelerometerBuffer.toList();

  /// 获取当前陀螺仪缓冲区数据
  List<SensorData> get gyroscopeBuffer => _gyroscopeBuffer.toList();

  /// 清空缓冲区
  void clearBuffers() {
    _accelerometerBuffer.clear();
    _gyroscopeBuffer.clear();
    print('SensorService: 缓冲区已清空');
  }

  /// 获取缓冲区统计信息
  Map<String, dynamic> getBufferStats() {
    return {
      'accelerometerBufferSize': _accelerometerBuffer.length,
      'gyroscopeBufferSize': _gyroscopeBuffer.length,
      'maxBufferSize': _bufferSize,
      'currentSamplingInterval': _currentSamplingInterval.inMilliseconds,
      'motionState': _currentMotionState.toString(),
      'stillInterval': _stillSamplingInterval.inMilliseconds,
      'unknownInterval': _unknownSamplingInterval.inMilliseconds,
      'movingInterval': _movingSamplingInterval.inMilliseconds,
      'sedentaryDuration': _currentSedentaryDuration.inSeconds,
      'isSedentary': _sedentaryStartTime != null,
      'sedentaryWarningThreshold': sedentaryWarningThreshold.inMinutes,
      'sedentaryCriticalThreshold': sedentaryCriticalThreshold.inMinutes,
    };
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
    await _accelerometerController.close();
    await _gyroscopeController.close();
    await _motionStateController.close();
    await _sedentaryDurationController.close();
    _accelerometerBuffer.clear();
    _gyroscopeBuffer.clear();
    _sedentaryTimer?.cancel();
    print('SensorService: 资源已释放');
  }
}

