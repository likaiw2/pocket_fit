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

  // 公开的数据流
  Stream<SensorData> get accelerometerStream => _accelerometerController.stream;
  Stream<SensorData> get gyroscopeStream => _gyroscopeController.stream;
  Stream<MotionStatistics> get motionStateStream => _motionStateController.stream;

  // 服务状态
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  // 当前运动状态
  MotionState _currentMotionState = MotionState.unknown;
  MotionState get currentMotionState => _currentMotionState;

  // 最后一次采样时间
  DateTime? _lastAccelerometerSample;
  DateTime? _lastGyroscopeSample;

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
    };
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
    await _accelerometerController.close();
    await _gyroscopeController.close();
    await _motionStateController.close();
    _accelerometerBuffer.clear();
    _gyroscopeBuffer.clear();
    print('SensorService: 资源已释放');
  }
}

