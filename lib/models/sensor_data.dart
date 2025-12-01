import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';

/// 传感器数据模型
class SensorData {
  final DateTime timestamp;
  final double x;
  final double y;
  final double z;
  final SensorType type;

  SensorData({
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
    required this.type,
  });

  /// 计算向量的模（magnitude）- 真实的向量长度
  double get magnitude => _calculateMagnitude(x, y, z);

  /// 计算向量模的平方（用于性能优化的比较）
  double get magnitudeSquared => x * x + y * y + z * z;

  /// 计算向量模（开平方根）
  static double _calculateMagnitude(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  @override
  String toString() {
    return 'SensorData(type: $type, x: ${x.toStringAsFixed(2)}, '
        'y: ${y.toStringAsFixed(2)}, z: ${z.toStringAsFixed(2)}, '
        'magnitude: ${magnitude.toStringAsFixed(2)})';
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'x': x,
      'y': y,
      'z': z,
      'type': type.toString(),
      'magnitude': magnitude,
    };
  }

  /// 从 Map 创建
  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      x: map['x'],
      y: map['y'],
      z: map['z'],
      type: SensorType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
    );
  }
}

/// 传感器类型
enum SensorType {
  accelerometer, // 加速度计
  gyroscope, // 陀螺仪
}

/// 运动状态
enum MotionState {
  still, // 静止
  moving, // 运动中
  unknown, // 未知
}

/// 活动类型（具体的运动类型）
enum ActivityType {
  idle, // 空闲/静止
  walking, // 走路
  running, // 跑步
  jumping, // 跳跃
  squatting, // 深蹲
  waving, // 挥手
  shaking, // 摇晃手机
  figureEight, // 八字形绕圈
  unknown, // 未知
}

/// 活动类型扩展 - 提供友好的显示名称和描述
extension ActivityTypeExtension on ActivityType {
  /// 获取活动的显示名称（已弃用，请使用 getDisplayName(context)）
  @Deprecated('Use getDisplayName(context) instead for i18n support')
  String get displayName {
    switch (this) {
      case ActivityType.idle:
        return '静止';
      case ActivityType.walking:
        return '走路';
      case ActivityType.running:
        return '跑步';
      case ActivityType.jumping:
        return '跳跃';
      case ActivityType.squatting:
        return '深蹲';
      case ActivityType.waving:
        return '挥手';
      case ActivityType.shaking:
        return '摇晃';
      case ActivityType.figureEight:
        return '八字绕圈';
      case ActivityType.unknown:
        return '未知';
    }
  }

  /// 获取活动的描述（已弃用，请使用 getDescription(context)）
  @Deprecated('Use getDescription(context) instead for i18n support')
  String get description {
    switch (this) {
      case ActivityType.idle:
        return '保持静止状态';
      case ActivityType.walking:
        return '正常步行';
      case ActivityType.running:
        return '快速跑步';
      case ActivityType.jumping:
        return '原地跳跃';
      case ActivityType.squatting:
        return '深蹲运动';
      case ActivityType.waving:
        return '挥动手臂';
      case ActivityType.shaking:
        return '摇晃手机';
      case ActivityType.figureEight:
        return '手腕八字绕圈';
      case ActivityType.unknown:
        return '正在识别...';
    }
  }

  /// 获取活动的图标
  String get emoji {
    switch (this) {
      case ActivityType.idle:
        return '🧘';
      case ActivityType.walking:
        return '🚶';
      case ActivityType.running:
        return '🏃';
      case ActivityType.jumping:
        return '🦘';
      case ActivityType.squatting:
        return '🏋️';
      case ActivityType.waving:
        return '👋';
      case ActivityType.shaking:
        return '📱';
      case ActivityType.figureEight:
        return '∞';
      case ActivityType.unknown:
        return '❓';
    }
  }

  /// 获取国际化的显示名称
  String getDisplayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ActivityType.idle:
        return l10n.idle;
      case ActivityType.walking:
        return l10n.walking;
      case ActivityType.running:
        return l10n.running;
      case ActivityType.jumping:
        return l10n.jumping;
      case ActivityType.squatting:
        return l10n.squatting;
      case ActivityType.waving:
        return l10n.waving;
      case ActivityType.shaking:
        return l10n.shaking;
      case ActivityType.figureEight:
        return l10n.figureEight;
      case ActivityType.unknown:
        return l10n.unknown;
    }
  }

  /// 获取国际化的描述
  String getDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ActivityType.idle:
        return l10n.idleDesc;
      case ActivityType.walking:
        return l10n.walkingDesc;
      case ActivityType.running:
        return l10n.runningDesc;
      case ActivityType.jumping:
        return l10n.jumpingDesc;
      case ActivityType.squatting:
        return l10n.squattingDesc;
      case ActivityType.waving:
        return l10n.wavingDesc;
      case ActivityType.shaking:
        return l10n.shakingDesc;
      case ActivityType.figureEight:
        return l10n.figureEightDesc;
      case ActivityType.unknown:
        return l10n.recognizing;
    }
  }
}

/// 运动统计数据
class MotionStatistics {
  final double variance; // 方差
  final double mean; // 平均值
  final double stdDeviation; // 标准差
  final MotionState state; // 运动状态
  final DateTime timestamp;

  MotionStatistics({
    required this.variance,
    required this.mean,
    required this.stdDeviation,
    required this.state,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'MotionStatistics(state: $state, variance: ${variance.toStringAsFixed(4)}, '
        'mean: ${mean.toStringAsFixed(2)}, stdDev: ${stdDeviation.toStringAsFixed(2)})';
  }
}

/// 活动识别结果
class ActivityRecognitionResult {
  final ActivityType activityType; // 识别到的活动类型
  final double confidence; // 置信度 (0.0 - 1.0)
  final DateTime timestamp;
  final Map<String, double>? features; // 可选的特征数据（用于调试）

  ActivityRecognitionResult({
    required this.activityType,
    required this.confidence,
    required this.timestamp,
    this.features,
  });

  @override
  String toString() {
    return 'ActivityRecognitionResult(type: ${activityType.displayName}, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'timestamp: $timestamp)';
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'activityType': activityType.toString(),
      'confidence': confidence,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'features': features,
    };
  }
}

