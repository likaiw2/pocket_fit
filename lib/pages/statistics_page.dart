import 'package:flutter/material.dart';
import 'package:pocket_fit/models/daily_statistics.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/models/activity_record.dart';
import 'package:pocket_fit/models/sedentary_record.dart';
import 'package:pocket_fit/services/statistics_service.dart';
import 'package:pocket_fit/services/database_service.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _statisticsService = StatisticsService();
  final _databaseService = DatabaseService();
  String _selectedPeriod = '周';

  // 统计数据
  DailyStatistics? _todayStats;
  List<DailyStatistics> _periodStats = [];
  Map<String, dynamic>? _overallStats;
  Map<ActivityType, int>? _activityDistribution;

  // 时间线数据
  List<ActivityRecord> _activityRecords = [];
  List<SedentaryRecord> _sedentaryRecords = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// 加载统计数据
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载今日统计
      final today = await _statisticsService.getTodayStatistics();

      // 根据选择的时间段加载数据
      List<DailyStatistics> periodStats;
      DateTime startTime;
      DateTime endTime = DateTime.now();

      if (_selectedPeriod == '日') {
        periodStats = [today];
        startTime = DateTime(endTime.year, endTime.month, endTime.day);
      } else if (_selectedPeriod == '周') {
        periodStats = await _statisticsService.getWeekStatistics();
        startTime = endTime.subtract(const Duration(days: 7));
      } else {
        periodStats = await _statisticsService.getMonthStatistics();
        startTime = endTime.subtract(const Duration(days: 30));
      }

      // 加载总体统计
      final overall = await _statisticsService.getOverallStatistics();

      // 加载活动分布
      final distribution = await _statisticsService.getActivityTypeDistribution(
        days: _selectedPeriod == '日' ? 1 : (_selectedPeriod == '周' ? 7 : 30),
      );

      // 加载时间线数据
      final activityRecords = await _databaseService.getActivityRecords(
        startTime: startTime,
        endTime: endTime,
      );

      final sedentaryRecords = await _databaseService.getSedentaryRecords(
        startTime: startTime,
        endTime: endTime,
      );

      setState(() {
        _todayStats = today;
        _periodStats = periodStats;
        _overallStats = overall;
        _activityDistribution = distribution;
        _activityRecords = activityRecords;
        _sedentaryRecords = sedentaryRecords;
        _isLoading = false;
      });
    } catch (e) {
      print('StatisticsPage: 加载统计数据失败 - $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          '活动统计',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '查看你的健康数据',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 时间段选择
                        _buildPeriodSelector(),
                        const SizedBox(height: 25),

                        // 总览卡片
                        _buildOverviewCard(),
                        const SizedBox(height: 20),

                        // 活动分布
                        _buildActivityDistribution(),
                        const SizedBox(height: 20),

                        // 时间线视图
                        _buildTimeline(),
                        const SizedBox(height: 20),

                        // 详细数据列表
                        _buildDetailsList(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // 时间段选择器
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['日', '周', '月'].map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadStatistics(); // 重新加载数据
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 总览卡片
  Widget _buildOverviewCard() {
    // 计算总计
    double totalActivityDuration = 0;
    int totalActivityCount = 0;
    double totalSedentaryDuration = 0;
    int totalWarnings = 0;

    for (final stat in _periodStats) {
      totalActivityDuration += stat.totalActivityDuration;
      totalActivityCount += stat.totalActivityCount;
      totalSedentaryDuration += stat.totalSedentaryDuration;
      totalWarnings += stat.sedentaryWarningCount + stat.sedentaryCriticalCount;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本$_selectedPeriod概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.directions_run,
                  label: '总活动',
                  value: totalActivityDuration.toStringAsFixed(0),
                  unit: '分钟',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.check_circle,
                  label: '完成次数',
                  value: totalActivityCount.toString(),
                  unit: '次',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.event_seat,
                  label: '久坐时长',
                  value: totalSedentaryDuration.toStringAsFixed(0),
                  unit: '分钟',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildOverviewItem(
                  icon: Icons.warning,
                  label: '久坐警告',
                  value: totalWarnings.toString(),
                  unit: '次',
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: color.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // 活动分布卡片
  Widget _buildActivityDistribution() {
    if (_activityDistribution == null || _activityDistribution!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              '暂无活动数据',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // 计算总数
    final total = _activityDistribution!.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活动类型分布',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          ..._activityDistribution!.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${entry.key.emoji} ${entry.key.displayName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${entry.value}次 (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 详细数据列表
  Widget _buildDetailsList() {
    if (_periodStats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              '暂无活动记录',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '每日统计',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        ..._periodStats.map((stat) {
          final dateStr = _formatDate(stat.date);
          final activityRate = stat.activityRate * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: stat.meetsActivityGoal ? Colors.green.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stat.meetsActivityGoal ? '✓ 达标' : '未达标',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: stat.meetsActivityGoal ? Colors.green.shade700 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          '活动',
                          '${stat.totalActivityDuration.toStringAsFixed(0)}分钟',
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '次数',
                          '${stat.totalActivityCount}次',
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          '活动率',
                          '${activityRate.toStringAsFixed(0)}%',
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '今天';
    } else if (targetDate == yesterday) {
      return '昨天';
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  // 时间线视图
  Widget _buildTimeline() {
    if (_activityRecords.isEmpty && _sedentaryRecords.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.timeline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '暂无时间线数据',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '完成一些活动挑战后，这里会显示你的活动时间线',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 合并活动和久坐记录，按时间排序
    List<Map<String, dynamic>> timelineEvents = [];

    for (final record in _activityRecords) {
      timelineEvents.add({
        'type': 'activity',
        'time': record.startTime,
        'data': record,
      });
    }

    for (final record in _sedentaryRecords) {
      timelineEvents.add({
        'type': 'sedentary',
        'time': record.startTime,
        'data': record,
      });
    }

    // 按时间倒序排序（最新的在前）
    timelineEvents.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 10),
              Text(
                '活动时间线',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...timelineEvents.take(20).map((event) {
            if (event['type'] == 'activity') {
              return _buildActivityTimelineItem(event['data'] as ActivityRecord);
            } else {
              return _buildSedentaryTimelineItem(event['data'] as SedentaryRecord);
            }
          }),
          if (timelineEvents.length > 20)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  '显示最近 20 条记录（共 ${timelineEvents.length} 条）',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 活动时间线项
  Widget _buildActivityTimelineItem(ActivityRecord record) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MM月dd日');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          // 时间线指示器
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // 图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(record.activityType),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      record.activityType.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${record.count}次',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(record.startTime)} ${timeFormat.format(record.startTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${record.durationInMinutes.toStringAsFixed(1)}分钟',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 久坐时间线项
  Widget _buildSedentaryTimelineItem(SedentaryRecord record) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('MM月dd日');

    MaterialColor colorMaterial = Colors.orange;
    IconData icon = Icons.event_seat;
    String statusText = '久坐';

    if (record.isCriticalLevel) {
      colorMaterial = Colors.red;
      icon = Icons.warning;
      statusText = '严重久坐';
    } else if (record.isWarningLevel) {
      colorMaterial = Colors.orange;
      icon = Icons.warning_amber;
      statusText = '久坐警告';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorMaterial.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorMaterial.shade200, width: 1),
      ),
      child: Row(
        children: [
          // 时间线指示器
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: colorMaterial,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          // 图标
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorMaterial,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorMaterial,
                      ),
                    ),
                    if (record.wasInterrupted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '已中断',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${dateFormat.format(record.startTime)} ${timeFormat.format(record.startTime)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.timer, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${record.durationInMinutes.toStringAsFixed(1)}分钟',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取活动图标
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.jumping:
        return Icons.fitness_center;
      case ActivityType.squatting:
        return Icons.accessibility_new;
      case ActivityType.waving:
        return Icons.waving_hand;
      case ActivityType.shaking:
        return Icons.vibration;
      case ActivityType.walking:
        return Icons.directions_walk;
      case ActivityType.running:
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }

}

