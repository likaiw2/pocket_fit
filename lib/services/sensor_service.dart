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
  static const int _bufferSize = 100; // 保存最近100个数据点
  static const Duration _samplingInterval = Duration(milliseconds: 100); // 采样间隔

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

    // 限制采样频率
    if (_lastAccelerometerSample != null &&
        now.difference(_lastAccelerometerSample!) < _samplingInterval) {
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

    // 分析运动状态
    _analyzeMotionState();
  }

  /// 处理陀螺仪事件
  void _onGyroscopeEvent(GyroscopeEvent event) {
    final now = DateTime.now();

    // 限制采样频率
    if (_lastGyroscopeSample != null &&
        now.difference(_lastGyroscopeSample!) < _samplingInterval) {
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
  }

  /// 添加数据到缓冲区（维护固定大小的滑动窗口）
  void _addToBuffer(Queue<SensorData> buffer, SensorData data) {
    buffer.add(data);
    if (buffer.length > _bufferSize) {
      buffer.removeFirst();
    }
  }

  /// 分析运动状态
  void _analyzeMotionState() {
    if (_accelerometerBuffer.length < 20) {
      // 数据不足，无法分析
      return;
    }

    // 计算加速度计数据的方差
    final magnitudes = _accelerometerBuffer.map((d) => d.magnitude).toList();
    final stats = _calculateStatistics(magnitudes);

    // 根据方差判断运动状态
    // 方差阈值需要根据实际测试调整
    const double stillThreshold = 2.0; // 静止阈值
    const double movingThreshold = 10.0; // 运动阈值

    MotionState state;
    if (stats['variance']! < stillThreshold) {
      state = MotionState.still;
    } else if (stats['variance']! > movingThreshold) {
      state = MotionState.moving;
    } else {
      state = MotionState.unknown;
    }

    final motionStats = MotionStatistics(
      variance: stats['variance']!,
      mean: stats['mean']!,
      stdDeviation: stats['stdDeviation']!,
      state: state,
      timestamp: DateTime.now(),
    );

    _motionStateController.add(motionStats);
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
      'samplingInterval': _samplingInterval.inMilliseconds,
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

