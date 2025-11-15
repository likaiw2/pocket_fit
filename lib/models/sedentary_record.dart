/// 久坐记录模型
class SedentaryRecord {
  final int? id; // 数据库ID
  final DateTime startTime; // 开始时间
  final DateTime endTime; // 结束时间
  final bool wasInterrupted; // 是否被中断（用户主动活动）
  final String? interruptionReason; // 中断原因

  SedentaryRecord({
    this.id,
    required this.startTime,
    required this.endTime,
    this.wasInterrupted = false,
    this.interruptionReason,
  });

  /// 持续时长（秒）
  int get durationInSeconds => endTime.difference(startTime).inSeconds;

  /// 持续时长（分钟）
  double get durationInMinutes => durationInSeconds / 60.0;

  /// 持续时长（小时）
  double get durationInHours => durationInMinutes / 60.0;

  /// 是否达到警告阈值（30分钟）
  bool get isWarningLevel => durationInMinutes >= 30;

  /// 是否达到严重阈值（60分钟）
  bool get isCriticalLevel => durationInMinutes >= 60;

  /// 转换为 Map（用于数据库存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'was_interrupted': wasInterrupted ? 1 : 0,
      'interruption_reason': interruptionReason,
    };
  }

  /// 从 Map 创建（用于数据库读取）
  factory SedentaryRecord.fromMap(Map<String, dynamic> map) {
    return SedentaryRecord(
      id: map['id'] as int?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time'] as int),
      wasInterrupted: (map['was_interrupted'] as int) == 1,
      interruptionReason: map['interruption_reason'] as String?,
    );
  }

  /// 复制并修改
  SedentaryRecord copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? wasInterrupted,
    String? interruptionReason,
  }) {
    return SedentaryRecord(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      wasInterrupted: wasInterrupted ?? this.wasInterrupted,
      interruptionReason: interruptionReason ?? this.interruptionReason,
    );
  }

  @override
  String toString() {
    return 'SedentaryRecord(id: $id, duration: ${durationInMinutes.toStringAsFixed(1)}min, '
        'interrupted: $wasInterrupted)';
  }
}

