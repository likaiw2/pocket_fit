import 'dart:async';
import 'dart:math';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/models/activity_record.dart';
import 'package:pocket_fit/services/sensor_service.dart';
import 'package:pocket_fit/services/feedback_service.dart';
import 'package:pocket_fit/services/statistics_service.dart';

/// 活动识别服务
/// 基于传感器数据识别具体的运动类型（跳跃、深蹲、挥手等）
class ActivityRecognitionService {
  static final ActivityRecognitionService _instance = ActivityRecognitionService._internal();
  factory ActivityRecognitionService() => _instance;
  ActivityRecognitionService._internal();

  final _sensorService = SensorService();
  final _feedbackService = FeedbackService();
  final _statisticsService = StatisticsService();

  // 挑战会话跟踪
  DateTime? _challengeStartTime;
  ActivityType? _currentChallengeType;

  // 数据流控制器
  final _activityController = StreamController<ActivityRecognitionResult>.broadcast();
  Stream<ActivityRecognitionResult> get activityStream => _activityController.stream;

  // 运动计数控制器
  final _activityCountController = StreamController<Map<ActivityType, int>>.broadcast();
  Stream<Map<ActivityType, int>> get activityCountStream => _activityCountController.stream;

  // 传感器数据订阅
  StreamSubscription<SensorData>? _accelSubscription;
  StreamSubscription<SensorData>? _gyroSubscription;

  // 数据缓冲区（用于分析）
  final List<SensorData> _accelBuffer = [];
  final List<SensorData> _gyroBuffer = [];
  static const int _bufferSize = 20; // 缓冲区大小（减小以降低延迟）

  // 当前识别的活动类型
  ActivityType _currentActivity = ActivityType.idle;
  
  // 运动计数
  final Map<ActivityType, int> _activityCounts = {
    ActivityType.jumping: 0,
    ActivityType.squatting: 0,
    ActivityType.waving: 0,
    ActivityType.shaking: 0,
  };

  // 运动检测状态
  bool _isJumpingDetected = false;
  bool _isSquattingDetected = false;
  bool _isWavingDetected = false;
  bool _isShakingDetected = false;
  double _lastAccelMagnitude = 0.0;
  
  // 定时器
  Timer? _analysisTimer;

  /// 启动活动识别
  Future<void> start() async {
    print('ActivityRecognitionService: 启动活动识别服务');

    // 确保传感器服务已启动
    await _sensorService.start();

    // 订阅传感器数据
    _accelSubscription = _sensorService.accelerometerStream.listen(_onAccelerometerData);
    _gyroSubscription = _sensorService.gyroscopeStream.listen(_onGyroscopeData);

    // 启动定时分析（每100ms分析一次）
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _analyzeActivity();
    });

    print('ActivityRecognitionService: 活动识别服务已启动');
  }

  /// 停止活动识别
  void stop() {
    print('ActivityRecognitionService: 停止活动识别服务');
    
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
    _analysisTimer?.cancel();
    
    _accelBuffer.clear();
    _gyroBuffer.clear();

    print('ActivityRecognitionService: 活动识别服务已停止');
  }

  /// 处理加速度计数据
  void _onAccelerometerData(SensorData data) {
    _accelBuffer.add(data);
    if (_accelBuffer.length > _bufferSize) {
      _accelBuffer.removeAt(0);
    }
  }

  /// 处理陀螺仪数据
  void _onGyroscopeData(SensorData data) {
    _gyroBuffer.add(data);
    if (_gyroBuffer.length > _bufferSize) {
      _gyroBuffer.removeAt(0);
    }
  }

  /// 分析活动类型
  void _analyzeActivity() {
    // 使用滑动窗口：只取最近的 15 个数据点（约 1.5 秒）
    // 这样可以快速响应动作的开始和结束
    final windowSize = min(15, min(_accelBuffer.length, _gyroBuffer.length));

    if (windowSize < 10) {
      return; // 数据不足
    }

    final accelWindow = _accelBuffer.sublist(_accelBuffer.length - windowSize);
    final gyroWindow = _gyroBuffer.sublist(_gyroBuffer.length - windowSize);

    // 计算加速度特征
    final accelMagnitudes = accelWindow.map((d) => d.magnitude).toList();
    final accelStats = _calculateStatistics(accelMagnitudes);

    // 计算陀螺仪特征
    final gyroMagnitudes = gyroWindow.map((d) => d.magnitude).toList();
    final gyroStats = _calculateStatistics(gyroMagnitudes);

    // 调试日志：定期输出传感器数据（每5秒）
    if (DateTime.now().millisecondsSinceEpoch % 5000 < 200) {
      print('ActivityRecognitionService: 传感器数据 - 加速度方差: ${accelStats['variance']!.toStringAsFixed(2)}, 陀螺仪方差: ${gyroStats['variance']!.toStringAsFixed(2)}, 陀螺仪均值: ${gyroStats['mean']!.toStringAsFixed(2)}');
    }

    // 获取最新的加速度值
    final latestAccel = _accelBuffer.last;
    final currentAccelMagnitude = latestAccel.magnitude;

    // 识别活动类型
    ActivityType detectedActivity = ActivityType.idle;
    double confidence = 0.0;

    // 1. 检测跳跃 - 加速度突然增大（起跳）或减小（落地）
    if (_detectJumping(accelStats, currentAccelMagnitude)) {
      detectedActivity = ActivityType.jumping;
      confidence = 0.85;
    }
    // 2. 检测深蹲 - Z轴加速度周期性变化
    else if (_detectSquatting(accelStats, latestAccel)) {
      detectedActivity = ActivityType.squatting;
      confidence = 0.80;
    }
    // 3. 检测挥手 - 陀螺仪高频率旋转
    else if (_detectWaving(gyroStats)) {
      detectedActivity = ActivityType.waving;
      confidence = 0.75;
    }
    // 4. 检测摇晃 - 加速度和陀螺仪都有高频变化
    else if (_detectShaking(accelStats, gyroStats)) {
      detectedActivity = ActivityType.shaking;
      confidence = 0.70;
    }
    // 5. 检测走路/跑步 - 周期性的加速度变化
    else if (_detectWalkingOrRunning(accelStats)) {
      if (accelStats['variance']! > 8.0) {
        detectedActivity = ActivityType.running;
        confidence = 0.75;
      } else {
        detectedActivity = ActivityType.walking;
        confidence = 0.70;
      }
    }

    // 更新当前活动
    if (detectedActivity != _currentActivity) {
      _currentActivity = detectedActivity;
      
      final result = ActivityRecognitionResult(
        activityType: detectedActivity,
        confidence: confidence,
        timestamp: DateTime.now(),
        features: {
          'accel_mean': accelStats['mean']!,
          'accel_variance': accelStats['variance']!,
          'gyro_mean': gyroStats['mean']!,
          'gyro_variance': gyroStats['variance']!,
        },
      );
      
      _activityController.add(result);
      print('ActivityRecognitionService: 识别到活动 - ${detectedActivity.displayName} (置信度: ${(confidence * 100).toStringAsFixed(1)}%)');
    }

    _lastAccelMagnitude = currentAccelMagnitude;
  }

  /// 检测跳跃
  bool _detectJumping(Map<String, double> accelStats, double currentMagnitude) {
    // 跳跃特征：加速度突然增大（起跳）或突然减小（落地）
    final magnitudeChange = (currentMagnitude - _lastAccelMagnitude).abs();

    if (magnitudeChange > 15.0 && !_isJumpingDetected) {
      _isJumpingDetected = true;
      _incrementActivityCount(ActivityType.jumping);

      // 400ms后重置检测状态（缩短冷却时间以提高响应速度）
      Future.delayed(const Duration(milliseconds: 400), () {
        _isJumpingDetected = false;
      });

      return true;
    }

    return false;
  }

  /// 检测深蹲
  bool _detectSquatting(Map<String, double> accelStats, SensorData latestAccel) {
    // 深蹲特征：Z轴加速度周期性变化（上下运动）
    final zVariance = _calculateZAxisVariance();

    if (zVariance > 3.0 && zVariance < 10.0 && !_isSquattingDetected) {
      _isSquattingDetected = true;
      _incrementActivityCount(ActivityType.squatting);

      // 700ms后重置检测状态（缩短冷却时间）
      Future.delayed(const Duration(milliseconds: 700), () {
        _isSquattingDetected = false;
      });

      return true;
    }

    return false;
  }

  /// 检测挥手
  bool _detectWaving(Map<String, double> gyroStats) {
    // 挥手特征：陀螺仪高频率旋转
    // 降低阈值，使其更容易触发
    if (gyroStats['variance']! > 3.0 && gyroStats['mean']! > 1.5 && !_isWavingDetected) {
      _isWavingDetected = true;
      _incrementActivityCount(ActivityType.waving);

      print('ActivityRecognitionService: 挥手检测 - 陀螺仪方差: ${gyroStats['variance']!.toStringAsFixed(2)}, 均值: ${gyroStats['mean']!.toStringAsFixed(2)}');

      // 500ms后重置检测状态（缩短冷却时间）
      Future.delayed(const Duration(milliseconds: 500), () {
        _isWavingDetected = false;
      });

      return true;
    }

    return false;
  }

  /// 检测摇晃
  bool _detectShaking(Map<String, double> accelStats, Map<String, double> gyroStats) {
    // 摇晃特征：加速度和陀螺仪都有高频变化
    // 降低阈值，使其更容易触发
    if (accelStats['variance']! > 8.0 && gyroStats['variance']! > 2.0 && !_isShakingDetected) {
      _isShakingDetected = true;
      _incrementActivityCount(ActivityType.shaking);

      print('ActivityRecognitionService: 摇晃检测 - 加速度方差: ${accelStats['variance']!.toStringAsFixed(2)}, 陀螺仪方差: ${gyroStats['variance']!.toStringAsFixed(2)}');

      // 400ms后重置检测状态（缩短冷却时间）
      Future.delayed(const Duration(milliseconds: 400), () {
        _isShakingDetected = false;
      });

      return true;
    }

    return false;
  }

  /// 检测走路或跑步
  bool _detectWalkingOrRunning(Map<String, double> accelStats) {
    // 走路/跑步特征：周期性的加速度变化
    return accelStats['variance']! > 2.0 && accelStats['variance']! < 15.0;
  }

  /// 计算Z轴方差
  double _calculateZAxisVariance() {
    if (_accelBuffer.length < 10) return 0.0;
    
    final zValues = _accelBuffer.map((d) => d.z).toList();
    final mean = zValues.reduce((a, b) => a + b) / zValues.length;
    final variance = zValues.map((z) => pow(z - mean, 2)).reduce((a, b) => a + b) / zValues.length;
    
    return variance;
  }

  /// 计算统计数据
  Map<String, double> _calculateStatistics(List<double> values) {
    if (values.isEmpty) {
      return {'mean': 0.0, 'variance': 0.0, 'stdDeviation': 0.0};
    }

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;
    final stdDeviation = sqrt(variance);

    return {
      'mean': mean,
      'variance': variance,
      'stdDeviation': stdDeviation,
    };
  }

  /// 增加活动计数
  void _incrementActivityCount(ActivityType type) {
    if (_activityCounts.containsKey(type)) {
      _activityCounts[type] = _activityCounts[type]! + 1;
      _activityCountController.add(Map.from(_activityCounts));
      print('ActivityRecognitionService: ${type.displayName} 计数 +1 (总计: ${_activityCounts[type]})');

      // 提供反馈
      _feedbackService.activityCountFeedback(type);
    }
  }

  /// 重置活动计数
  void resetCounts() {
    // 保存之前的挑战记录（如果有）
    _saveChallengeRecord();

    _activityCounts.updateAll((key, value) => 0);
    _activityCountController.add(Map.from(_activityCounts));
    print('ActivityRecognitionService: 活动计数已重置');
  }

  /// 开始新挑战
  void startChallenge(ActivityType type) {
    _challengeStartTime = DateTime.now();
    _currentChallengeType = type;
    resetCounts();
  }

  /// 完成挑战
  void completeChallenge() {
    _saveChallengeRecord();
    _challengeStartTime = null;
    _currentChallengeType = null;
  }

  /// 保存挑战记录
  void _saveChallengeRecord() async {
    if (_challengeStartTime != null && _currentChallengeType != null) {
      final count = _activityCounts[_currentChallengeType] ?? 0;

      // 只保存有效的记录（至少完成1次）
      if (count > 0) {
        final record = ActivityRecord(
          activityType: _currentChallengeType!,
          startTime: _challengeStartTime!,
          endTime: DateTime.now(),
          count: count,
          confidence: 80.0, // 挑战模式下的平均置信度
        );

        try {
          await _statisticsService.saveActivityRecord(record);
          print('ActivityRecognitionService: 活动记录已保存 - '
              '${record.activityType.displayName} x${record.count}');
        } catch (e) {
          print('ActivityRecognitionService: 保存活动记录失败 - $e');
        }
      }
    }
  }

  /// 获取当前活动计数
  Map<ActivityType, int> get activityCounts => Map.from(_activityCounts);

  /// 获取当前活动类型
  ActivityType get currentActivity => _currentActivity;

  /// 释放资源
  void dispose() {
    stop();
    _activityController.close();
    _activityCountController.close();
  }
}

