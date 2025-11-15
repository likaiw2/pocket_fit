import 'package:pocket_fit/models/sensor_data.dart';

/// 运动记录模型
class ActivityRecord {
  final int? id; // 数据库ID
  final ActivityType activityType; // 运动类型
  final DateTime startTime; // 开始时间
  final DateTime endTime; // 结束时间
  final int count; // 运动次数
  final double confidence; // 平均置信度
  final Map<String, dynamic>? metadata; // 额外元数据

  ActivityRecord({
    this.id,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.count,
    required this.confidence,
    this.metadata,
  });

  /// 持续时长（秒）
  int get durationInSeconds => endTime.difference(startTime).inSeconds;

  /// 持续时长（分钟）
  double get durationInMinutes => durationInSeconds / 60.0;

  /// 转换为 Map（用于数据库存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType.name,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'count': count,
      'confidence': confidence,
      'metadata': metadata?.toString(),
    };
  }

  /// 从 Map 创建（用于数据库读取）
  factory ActivityRecord.fromMap(Map<String, dynamic> map) {
    return ActivityRecord(
      id: map['id'] as int?,
      activityType: ActivityType.values.firstWhere(
        (e) => e.name == map['activity_type'],
        orElse: () => ActivityType.unknown,
      ),
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      count: map['count'] as int,
      confidence: map['confidence'] as double,
      metadata: null, // 简化处理，暂不解析
    );
  }

  /// 复制并修改
  ActivityRecord copyWith({
    int? id,
    ActivityType? activityType,
    DateTime? startTime,
    DateTime? endTime,
    int? count,
    double? confidence,
    Map<String, dynamic>? metadata,
  }) {
    return ActivityRecord(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      count: count ?? this.count,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'ActivityRecord(id: $id, type: ${activityType.displayName}, '
        'count: $count, duration: ${durationInMinutes.toStringAsFixed(1)}min)';
  }
}

