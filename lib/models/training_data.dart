import 'package:pocket_fit/models/sensor_data.dart';

/// 传感器数据点（包含加速度和陀螺仪）
class SensorDataPoint {
  final DateTime timestamp;
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;

  SensorDataPoint({
    required this.timestamp,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
  });

  /// 从 SensorData 创建
  factory SensorDataPoint.fromSensorData({
    required SensorData accel,
    required SensorData gyro,
  }) {
    return SensorDataPoint(
      timestamp: accel.timestamp,
      accelX: accel.x,
      accelY: accel.y,
      accelZ: accel.z,
      gyroX: gyro.x,
      gyroY: gyro.y,
      gyroZ: gyro.z,
    );
  }

  /// 转换为 Map（用于 JSON）
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'accelX': accelX,
      'accelY': accelY,
      'accelZ': accelZ,
      'gyroX': gyroX,
      'gyroY': gyroY,
      'gyroZ': gyroZ,
    };
  }

  /// 从 Map 创建
  factory SensorDataPoint.fromJson(Map<String, dynamic> json) {
    return SensorDataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      accelX: json['accelX'],
      accelY: json['accelY'],
      accelZ: json['accelZ'],
      gyroX: json['gyroX'],
      gyroY: json['gyroY'],
      gyroZ: json['gyroZ'],
    );
  }

  /// 转换为 CSV 行
  String toCsvRow() {
    return '${timestamp.millisecondsSinceEpoch},$accelX,$accelY,$accelZ,$gyroX,$gyroY,$gyroZ';
  }

  /// CSV 表头
  static String csvHeader() {
    return 'timestamp,accelX,accelY,accelZ,gyroX,gyroY,gyroZ';
  }
}

/// 训练数据集（一次采集的完整数据）
class TrainingDataSet {
  final String id; // 唯一标识符
  final DateTime collectionTime; // 采集时间
  final ActivityType activityType; // 动作类型
  final int repetitionCount; // 动作重复次数
  final List<SensorDataPoint> dataPoints; // 时间序列数据
  final int samplingFrequency; // 采样频率（Hz）

  TrainingDataSet({
    required this.id,
    required this.collectionTime,
    required this.activityType,
    required this.repetitionCount,
    required this.dataPoints,
    this.samplingFrequency = 10, // 默认10Hz（运动时的采样频率）
  });

  /// 生成文件名（包含元信息）
  String get fileName {
    final timeStr = collectionTime.toIso8601String().replaceAll(':', '-').split('.')[0];
    return '${activityType.name}_${repetitionCount}reps_${timeStr}_${id.substring(0, 8)}';
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionTime': collectionTime.toIso8601String(),
      'activityType': activityType.name,
      'repetitionCount': repetitionCount,
      'samplingFrequency': samplingFrequency,
      'dataPointsCount': dataPoints.length,
      'dataPoints': dataPoints.map((dp) => dp.toJson()).toList(),
    };
  }

  /// 从 JSON 创建
  factory TrainingDataSet.fromJson(Map<String, dynamic> json) {
    return TrainingDataSet(
      id: json['id'],
      collectionTime: DateTime.parse(json['collectionTime']),
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == json['activityType'],
        orElse: () => ActivityType.unknown,
      ),
      repetitionCount: json['repetitionCount'],
      samplingFrequency: json['samplingFrequency'] ?? 10,
      dataPoints: (json['dataPoints'] as List)
          .map((dp) => SensorDataPoint.fromJson(dp))
          .toList(),
    );
  }

  /// 转换为 CSV 格式
  String toCsv() {
    final buffer = StringBuffer();
    
    // 元信息
    buffer.writeln('# Training Data Set');
    buffer.writeln('# ID: $id');
    buffer.writeln('# Collection Time: ${collectionTime.toIso8601String()}');
    buffer.writeln('# Activity Type: ${activityType.displayName} (${activityType.name})');
    buffer.writeln('# Repetition Count: $repetitionCount');
    buffer.writeln('# Sampling Frequency: ${samplingFrequency}Hz');
    buffer.writeln('# Data Points: ${dataPoints.length}');
    buffer.writeln('#');
    
    // 数据表头
    buffer.writeln(SensorDataPoint.csvHeader());
    
    // 数据行
    for (final point in dataPoints) {
      buffer.writeln(point.toCsvRow());
    }
    
    return buffer.toString();
  }

  /// 获取持续时间（秒）
  double get duration {
    if (dataPoints.isEmpty) return 0.0;
    final start = dataPoints.first.timestamp;
    final end = dataPoints.last.timestamp;
    return end.difference(start).inMilliseconds / 1000.0;
  }
}

