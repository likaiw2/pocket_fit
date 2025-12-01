import 'dart:async';
import 'dart:math';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/models/activity_record.dart';
import 'package:pocket_fit/services/sensor_service.dart';
import 'package:pocket_fit/services/feedback_service.dart';
import 'package:pocket_fit/services/statistics_service.dart';
import 'package:pocket_fit/services/ml_inference_service.dart';
import 'package:pocket_fit/services/settings_service.dart';

/// 活动识别服务
/// 基于传感器数据识别具体的运动类型（跳跃、深蹲、挥手等）
class ActivityRecognitionService {
  static final ActivityRecognitionService _instance = ActivityRecognitionService._internal();
  factory ActivityRecognitionService() => _instance;
  ActivityRecognitionService._internal();

  final _sensorService = SensorService();
  final _feedbackService = FeedbackService();
  final _statisticsService = StatisticsService();
  final _mlService = MLInferenceService();
  final _settingsService = SettingsService();

  // ML 检测相关
  bool _useDLDetection = false;
  String? _lastMLActivity;
  int _lastMLCount = 0;

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
    ActivityType.figureEight: 0,
  };

  // 运动检测状态
  bool _isJumpingDetected = false;
  bool _isSquattingDetected = false;
  bool _isWavingDetected = false;
  bool _isShakingDetected = false;
  bool _isFigureEightDetected = false;
  double _lastAccelMagnitude = 0.0;

  // 八字形检测相关
  List<double> _gyroXHistory = [];
  List<double> _gyroYHistory = [];
  int _figureEightCycleCount = 0;
  DateTime? _lastFigureEightTime;
  
  // 定时器
  Timer? _analysisTimer;

  /// 启动活动识别
  Future<void> start() async {
    print('ActivityRecognitionService: 启动活动识别服务');

    // 确保传感器服务已启动
    await _sensorService.start();

    // 初始化设置服务并加载 DL 检测设置
    await _settingsService.initialize();
    _useDLDetection = await _settingsService.getUseDLDetection();
    print('ActivityRecognitionService: DL检测模式 = $_useDLDetection');

    // 如果启用了 DL 检测，初始化 ML 服务
    if (_useDLDetection) {
      try {
        await _mlService.initialize();
        print('ActivityRecognitionService: ML服务初始化成功');
      } catch (e) {
        print('ActivityRecognitionService: ML服务初始化失败 - $e');
        _useDLDetection = false; // 回退到传统方法
      }
    }

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

    // 如果启用了 DL 检测，将数据添加到 ML 服务
    if (_useDLDetection && _gyroBuffer.isNotEmpty) {
      final latestGyro = _gyroBuffer.last;
      _mlService.addSensorData(
        data.x, data.y, data.z,
        latestGyro.x, latestGyro.y, latestGyro.z,
      );
    }
  }

  /// 处理陀螺仪数据
  void _onGyroscopeData(SensorData data) {
    _gyroBuffer.add(data);
    if (_gyroBuffer.length > _bufferSize) {
      _gyroBuffer.removeAt(0);
    }

    // 如果启用了 DL 检测，将数据添加到 ML 服务
    if (_useDLDetection && _accelBuffer.isNotEmpty) {
      final latestAccel = _accelBuffer.last;
      _mlService.addSensorData(
        latestAccel.x, latestAccel.y, latestAccel.z,
        data.x, data.y, data.z,
      );
    }
  }

  /// 分析活动类型
  void _analyzeActivity() {
    // 如果启用了 DL 检测，使用 ML 服务
    if (_useDLDetection) {
      _analyzeActivityWithML();
      return;
    }

    // 否则使用传统算法
    _analyzeActivityTraditional();
  }

  /// 使用 ML 模型分析活动
  void _analyzeActivityWithML() {
    // 尝试预测活动类型
    final mlActivity = _mlService.predictActivity();

    if (mlActivity != null) {
      // 计算计数
      final count = _mlService.countRepetitions(mlActivity);

      // 检查是否有新的活动或计数变化
      if (mlActivity != _lastMLActivity || count != _lastMLCount) {
        _lastMLActivity = mlActivity;
        _lastMLCount = count;

        // 转换 ML 活动类型到 ActivityType
        final activityType = _mlActivityToActivityType(mlActivity);

        if (activityType != _currentActivity) {
          _currentActivity = activityType;

          final result = ActivityRecognitionResult(
            activityType: activityType,
            confidence: 0.92, // ML 模型的验证准确率
            timestamp: DateTime.now(),
            features: {
              'ml_count': count.toDouble(),
            },
          );

          _activityController.add(result);
          print('ActivityRecognitionService: ML识别到活动 - ${activityType.displayName} (计数: $count)');
        }

        // 更新计数
        if (count > (_activityCounts[activityType] ?? 0)) {
          _activityCounts[activityType] = count;
          _activityCountController.add(Map.from(_activityCounts));

          // 触发反馈
          _feedbackService.activityCountFeedback(activityType);
        }
      }
    }
  }

  /// 将 ML 活动类型转换为 ActivityType
  ActivityType _mlActivityToActivityType(String mlActivity) {
    switch (mlActivity) {
      case 'jumping':
        return ActivityType.jumping;
      case 'squatting':
        return ActivityType.squatting;
      case 'waving':
        return ActivityType.waving;
      case 'shaking':
        return ActivityType.shaking;
      case 'figureEight':
        return ActivityType.figureEight;
      default:
        return ActivityType.idle;
    }
  }

  /// 使用传统算法分析活动
  void _analyzeActivityTraditional() {
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

    // 获取最新的陀螺仪值
    final latestGyro = _gyroBuffer.last;

    // 识别活动类型
    ActivityType detectedActivity = ActivityType.idle;
    double confidence = 0.0;

    // 1. 检测跳跃 - 加速度突然增大（起跳）或减小（落地）
    if (_detectJumping(accelStats, currentAccelMagnitude)) {
      detectedActivity = ActivityType.jumping;
      confidence = 0.85;
    }
    // 2. 检测八字形绕圈 - 陀螺仪多轴连续旋转（优先级提高，在深蹲之前）
    else if (_detectFigureEight(accelStats, gyroStats, latestGyro)) {
      detectedActivity = ActivityType.figureEight;
      confidence = 0.78;
    }
    // 3. 检测深蹲 - Z轴加速度周期性变化
    else if (_detectSquatting(accelStats, latestAccel)) {
      detectedActivity = ActivityType.squatting;
      confidence = 0.80;
    }
    // 4. 检测挥手 - 陀螺仪高频率旋转
    else if (_detectWaving(gyroStats)) {
      detectedActivity = ActivityType.waving;
      confidence = 0.75;
    }
    // 5. 检测摇晃 - 加速度和陀螺仪都有高频变化
    else if (_detectShaking(accelStats, gyroStats)) {
      detectedActivity = ActivityType.shaking;
      confidence = 0.70;
    }
    // 6. 检测走路/跑步 - 周期性的加速度变化
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

  /// 检测八字形绕圈
  bool _detectFigureEight(Map<String, double> accelStats, Map<String, double> gyroStats, SensorData latestGyro) {
    // 八字形特征：
    // 1. 陀螺仪在X和Y轴上都有明显的旋转（形成平面内的圆周运动）
    // 2. 旋转方向会周期性变化（形成"8"字）
    // 3. 加速度相对稳定（不像摇晃那样剧烈）
    // 4. X和Y轴方差要相对平衡（八字形是对称的）

    // 记录陀螺仪X和Y轴的历史数据
    _gyroXHistory.add(latestGyro.x);
    _gyroYHistory.add(latestGyro.y);

    // 保持历史数据在合理范围内（约2秒的数据）
    if (_gyroXHistory.length > 20) {
      _gyroXHistory.removeAt(0);
      _gyroYHistory.removeAt(0);
    }

    // 需要足够的历史数据
    if (_gyroXHistory.length < 15) {
      return false;
    }

    // 计算X和Y轴的方差
    final xVariance = _calculateVariance(_gyroXHistory);
    final yVariance = _calculateVariance(_gyroYHistory);

    // 八字形特征检测：
    // 1. X和Y轴都有明显的旋转（方差 > 4.0）
    final isXYRotating = xVariance > 4.0 && yVariance > 4.0;

    // 2. X和Y轴方差要相对平衡（差异不超过2.2倍，八字形是对称的）
    final varianceRatio = xVariance > yVariance ? xVariance / yVariance : yVariance / xVariance;
    final isBalanced = varianceRatio < 2.2;

    // 3. 陀螺仪总体方差要高（> 6.0，八字形需要明显的旋转）
    final isGyroHigh = gyroStats['variance']! > 6.0;

    // 4. 加速度方差适中（8.0 - 25.0，有运动但不是纯粹的摇晃）
    final isAccelModerate = accelStats['variance']! > 8.0 && accelStats['variance']! < 25.0;

    if (isXYRotating && isBalanced && isGyroHigh && isAccelModerate && !_isFigureEightDetected) {
      _isFigureEightDetected = true;
      _incrementActivityCount(ActivityType.figureEight);

      print('ActivityRecognitionService: 八字形检测 - X方差: ${xVariance.toStringAsFixed(2)}, Y方差: ${yVariance.toStringAsFixed(2)}, '
            '陀螺仪方差: ${gyroStats['variance']!.toStringAsFixed(2)}, 加速度方差: ${accelStats['variance']!.toStringAsFixed(2)}');

      // 800ms后重置检测状态（八字形动作相对较慢）
      Future.delayed(const Duration(milliseconds: 800), () {
        _isFigureEightDetected = false;
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

  /// 计算方差（通用方法）
  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) / values.length;

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

