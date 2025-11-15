import 'package:pocket_fit/models/activity_record.dart';
import 'package:pocket_fit/models/sedentary_record.dart';
import 'package:pocket_fit/models/daily_statistics.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/services/database_service.dart';

/// 统计服务
class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  final _databaseService = DatabaseService();

  // ==================== 记录保存 ====================

  /// 保存运动记录
  Future<void> saveActivityRecord(ActivityRecord record) async {
    await _databaseService.insertActivityRecord(record);
    await _updateDailyStatistics(record.startTime);
  }

  /// 保存久坐记录
  Future<void> saveSedentaryRecord(SedentaryRecord record) async {
    await _databaseService.insertSedentaryRecord(record);
    await _updateDailyStatistics(record.startTime);
  }

  // ==================== 每日统计更新 ====================

  /// 更新每日统计
  Future<void> _updateDailyStatistics(DateTime date) async {
    final normalizedDate = DailyStatistics.normalizeDate(date);
    final startOfDay = normalizedDate;
    final endOfDay = normalizedDate.add(const Duration(days: 1));

    // 获取当天的所有记录
    final activityRecords = await _databaseService.getActivityRecords(
      startTime: startOfDay,
      endTime: endOfDay,
    );

    final sedentaryRecords = await _databaseService.getSedentaryRecords(
      startTime: startOfDay,
      endTime: endOfDay,
    );

    // 计算统计数据
    int totalActivityCount = 0;
    double totalActivityDuration = 0.0;
    final activityBreakdown = <ActivityType, int>{};

    for (final record in activityRecords) {
      totalActivityCount += record.count;
      totalActivityDuration += record.durationInMinutes;
      
      activityBreakdown[record.activityType] = 
          (activityBreakdown[record.activityType] ?? 0) + record.count;
    }

    double totalSedentaryDuration = 0.0;
    int sedentaryWarningCount = 0;
    int sedentaryCriticalCount = 0;

    for (final record in sedentaryRecords) {
      totalSedentaryDuration += record.durationInMinutes;
      if (record.isCriticalLevel) {
        sedentaryCriticalCount++;
      } else if (record.isWarningLevel) {
        sedentaryWarningCount++;
      }
    }

    // 创建或更新统计数据
    final stats = DailyStatistics(
      date: normalizedDate,
      totalActivityCount: totalActivityCount,
      totalActivityDuration: totalActivityDuration,
      totalSedentaryDuration: totalSedentaryDuration,
      sedentaryWarningCount: sedentaryWarningCount,
      sedentaryCriticalCount: sedentaryCriticalCount,
      activityBreakdown: activityBreakdown,
    );

    await _databaseService.upsertDailyStatistics(stats);
  }

  // ==================== 统计查询 ====================

  /// 获取今日统计
  Future<DailyStatistics> getTodayStatistics() async {
    final today = DailyStatistics.normalizeDate(DateTime.now());
    final stats = await _databaseService.getDailyStatistics(today);
    
    if (stats == null) {
      // 如果没有统计数据，返回空统计
      return DailyStatistics(date: today);
    }
    
    return stats;
  }

  /// 获取本周统计
  Future<List<DailyStatistics>> getWeekStatistics() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return await _databaseService.getDailyStatisticsRange(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  /// 获取本月统计
  Future<List<DailyStatistics>> getMonthStatistics() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return await _databaseService.getDailyStatisticsRange(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// 获取最近N天统计
  Future<List<DailyStatistics>> getRecentStatistics({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    
    return await _databaseService.getDailyStatisticsRange(
      startDate: startDate,
      endDate: now,
    );
  }

  // ==================== 汇总统计 ====================

  /// 计算总体统计
  Future<Map<String, dynamic>> getOverallStatistics() async {
    final allStats = await _databaseService.getDailyStatisticsRange(
      startDate: DateTime(2020, 1, 1), // 从很早开始
      endDate: DateTime.now(),
    );

    if (allStats.isEmpty) {
      return {
        'totalDays': 0,
        'totalActivityCount': 0,
        'totalActivityDuration': 0.0,
        'totalSedentaryDuration': 0.0,
        'averageActivityDuration': 0.0,
        'averageSedentaryDuration': 0.0,
        'totalWarnings': 0,
        'totalCriticals': 0,
      };
    }

    int totalActivityCount = 0;
    double totalActivityDuration = 0.0;
    double totalSedentaryDuration = 0.0;
    int totalWarnings = 0;
    int totalCriticals = 0;

    for (final stats in allStats) {
      totalActivityCount += stats.totalActivityCount;
      totalActivityDuration += stats.totalActivityDuration;
      totalSedentaryDuration += stats.totalSedentaryDuration;
      totalWarnings += stats.sedentaryWarningCount;
      totalCriticals += stats.sedentaryCriticalCount;
    }

    return {
      'totalDays': allStats.length,
      'totalActivityCount': totalActivityCount,
      'totalActivityDuration': totalActivityDuration,
      'totalSedentaryDuration': totalSedentaryDuration,
      'averageActivityDuration': totalActivityDuration / allStats.length,
      'averageSedentaryDuration': totalSedentaryDuration / allStats.length,
      'totalWarnings': totalWarnings,
      'totalCriticals': totalCriticals,
    };
  }

  /// 获取活动类型分布（最近N天）
  Future<Map<ActivityType, int>> getActivityTypeDistribution({int days = 7}) async {
    final stats = await getRecentStatistics(days: days);
    final distribution = <ActivityType, int>{};

    for (final dayStat in stats) {
      for (final entry in dayStat.activityBreakdown.entries) {
        distribution[entry.key] = (distribution[entry.key] ?? 0) + entry.value;
      }
    }

    return distribution;
  }

  /// 获取活动趋势（最近N天的每日活动时长）
  Future<List<Map<String, dynamic>>> getActivityTrend({int days = 7}) async {
    final stats = await getRecentStatistics(days: days);
    
    return stats.map((stat) => {
      'date': stat.date,
      'activityDuration': stat.totalActivityDuration,
      'sedentaryDuration': stat.totalSedentaryDuration,
      'activityCount': stat.totalActivityCount,
    }).toList();
  }

  /// 获取久坐警告趋势（最近N天）
  Future<List<Map<String, dynamic>>> getSedentaryWarningTrend({int days = 7}) async {
    final stats = await getRecentStatistics(days: days);
    
    return stats.map((stat) => {
      'date': stat.date,
      'warningCount': stat.sedentaryWarningCount,
      'criticalCount': stat.sedentaryCriticalCount,
    }).toList();
  }

  // ==================== 目标达成 ====================

  /// 检查今日是否达成活动目标
  Future<bool> isTodayGoalMet({double goalMinutes = 30.0}) async {
    final today = await getTodayStatistics();
    return today.totalActivityDuration >= goalMinutes;
  }

  /// 获取本周目标达成天数
  Future<int> getWeekGoalMetDays({double goalMinutes = 30.0}) async {
    final weekStats = await getWeekStatistics();
    return weekStats.where((stat) => stat.totalActivityDuration >= goalMinutes).length;
  }

  /// 获取连续达成目标天数
  Future<int> getConsecutiveGoalMetDays({double goalMinutes = 30.0}) async {
    final recentStats = await getRecentStatistics(days: 30);
    
    int consecutive = 0;
    for (final stat in recentStats.reversed) {
      if (stat.totalActivityDuration >= goalMinutes) {
        consecutive++;
      } else {
        break;
      }
    }
    
    return consecutive;
  }

  // ==================== 数据清理 ====================

  /// 清理旧数据
  Future<void> cleanOldData({int keepDays = 90}) async {
    await _databaseService.cleanOldData(keepDays: keepDays);
  }
}

