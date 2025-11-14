import 'dart:math';

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

