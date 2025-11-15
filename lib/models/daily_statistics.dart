import 'package:pocket_fit/models/sensor_data.dart';

/// 每日统计数据模型
class DailyStatistics {
  final int? id; // 数据库ID
  final DateTime date; // 日期（只保留年月日）
  final int totalActivityCount; // 总运动次数
  final double totalActivityDuration; // 总运动时长（分钟）
  final double totalSedentaryDuration; // 总久坐时长（分钟）
  final int sedentaryWarningCount; // 久坐警告次数
  final int sedentaryCriticalCount; // 严重久坐次数
  final Map<ActivityType, int> activityBreakdown; // 各类运动次数分布

  DailyStatistics({
    this.id,
    required this.date,
    this.totalActivityCount = 0,
    this.totalActivityDuration = 0.0,
    this.totalSedentaryDuration = 0.0,
    this.sedentaryWarningCount = 0,
    this.sedentaryCriticalCount = 0,
    Map<ActivityType, int>? activityBreakdown,
  }) : activityBreakdown = activityBreakdown ?? {};

  /// 获取标准化的日期（只保留年月日）
  static DateTime normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// 活动率（活动时长 / (活动时长 + 久坐时长)）
  double get activityRate {
    final total = totalActivityDuration + totalSedentaryDuration;
    if (total == 0) return 0.0;
    return totalActivityDuration / total;
  }

  /// 活动率百分比
  double get activityRatePercentage => activityRate * 100;

  /// 是否达到每日活动目标（假设目标是30分钟）
  bool get meetsActivityGoal => totalActivityDuration >= 30;

  /// 转换为 Map（用于数据库存储）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'total_activity_count': totalActivityCount,
      'total_activity_duration': totalActivityDuration,
      'total_sedentary_duration': totalSedentaryDuration,
      'sedentary_warning_count': sedentaryWarningCount,
      'sedentary_critical_count': sedentaryCriticalCount,
      'activity_breakdown': _encodeActivityBreakdown(),
    };
  }

  /// 从 Map 创建（用于数据库读取）
  factory DailyStatistics.fromMap(Map<String, dynamic> map) {
    return DailyStatistics(
      id: map['id'] as int?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      totalActivityCount: map['total_activity_count'] as int,
      totalActivityDuration: map['total_activity_duration'] as double,
      totalSedentaryDuration: map['total_sedentary_duration'] as double,
      sedentaryWarningCount: map['sedentary_warning_count'] as int,
      sedentaryCriticalCount: map['sedentary_critical_count'] as int,
      activityBreakdown: _decodeActivityBreakdown(map['activity_breakdown'] as String?),
    );
  }

  /// 编码活动分布为字符串
  String _encodeActivityBreakdown() {
    return activityBreakdown.entries
        .map((e) => '${e.key.name}:${e.value}')
        .join(',');
  }

  /// 解码活动分布字符串
  static Map<ActivityType, int> _decodeActivityBreakdown(String? encoded) {
    if (encoded == null || encoded.isEmpty) return {};
    
    final result = <ActivityType, int>{};
    for (final pair in encoded.split(',')) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final type = ActivityType.values.firstWhere(
          (e) => e.name == parts[0],
          orElse: () => ActivityType.unknown,
        );
        final count = int.tryParse(parts[1]) ?? 0;
        result[type] = count;
      }
    }
    return result;
  }

  /// 复制并修改
  DailyStatistics copyWith({
    int? id,
    DateTime? date,
    int? totalActivityCount,
    double? totalActivityDuration,
    double? totalSedentaryDuration,
    int? sedentaryWarningCount,
    int? sedentaryCriticalCount,
    Map<ActivityType, int>? activityBreakdown,
  }) {
    return DailyStatistics(
      id: id ?? this.id,
      date: date ?? this.date,
      totalActivityCount: totalActivityCount ?? this.totalActivityCount,
      totalActivityDuration: totalActivityDuration ?? this.totalActivityDuration,
      totalSedentaryDuration: totalSedentaryDuration ?? this.totalSedentaryDuration,
      sedentaryWarningCount: sedentaryWarningCount ?? this.sedentaryWarningCount,
      sedentaryCriticalCount: sedentaryCriticalCount ?? this.sedentaryCriticalCount,
      activityBreakdown: activityBreakdown ?? this.activityBreakdown,
    );
  }

  @override
  String toString() {
    return 'DailyStatistics(date: ${date.toString().split(' ')[0]}, '
        'activities: $totalActivityCount, '
        'activityDuration: ${totalActivityDuration.toStringAsFixed(1)}min, '
        'sedentaryDuration: ${totalSedentaryDuration.toStringAsFixed(1)}min)';
  }
}

