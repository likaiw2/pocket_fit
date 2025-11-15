import 'package:flutter/material.dart';
import 'package:pocket_fit/models/activity_record.dart';
import 'package:pocket_fit/services/database_service.dart';
import 'package:pocket_fit/models/sensor_data.dart';

class ActivityHistoryPage extends StatefulWidget {
  const ActivityHistoryPage({super.key});

  @override
  State<ActivityHistoryPage> createState() => _ActivityHistoryPageState();
}

class _ActivityHistoryPageState extends State<ActivityHistoryPage> {
  final _databaseService = DatabaseService();
  List<ActivityRecord> _activityRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivityRecords();
  }

  /// 加载活动记录
  Future<void> _loadActivityRecords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 获取最近30天的活动记录
      final endTime = DateTime.now();
      final startTime = endTime.subtract(const Duration(days: 30));
      
      final records = await _databaseService.getActivityRecords(
        startTime: startTime,
        endTime: endTime,
      );

      setState(() {
        _activityRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      print('ActivityHistoryPage: 加载活动记录失败 - $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动历史'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activityRecords.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadActivityRecords,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _activityRecords.length,
                      itemBuilder: (context, index) {
                        final record = _activityRecords[index];
                        return _buildActivityCard(record);
                      },
                    ),
                  ),
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            '暂无活动记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '完成挑战后会在这里显示',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 活动卡片
  Widget _buildActivityCard(ActivityRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
            children: [
              // 活动类型图标
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getActivityColor(record.activityType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.activityType.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 15),
              // 活动信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.activityType.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(record.startTime),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // 完成次数
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getActivityColor(record.activityType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${record.count}次',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getActivityColor(record.activityType),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 详细信息
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.timer_outlined,
                label: '${record.durationInMinutes.toStringAsFixed(1)}分钟',
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              _buildInfoChip(
                icon: Icons.speed,
                label: '${record.confidence.toStringAsFixed(0)}%',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 信息标签
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取活动类型颜色
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.jumping:
        return Colors.orange;
      case ActivityType.squatting:
        return Colors.red;
      case ActivityType.waving:
        return Colors.blue;
      case ActivityType.shaking:
        return Colors.purple;
      case ActivityType.walking:
        return Colors.green;
      case ActivityType.running:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (targetDate == today) {
      dateStr = '今天';
    } else if (targetDate == yesterday) {
      dateStr = '昨天';
    } else {
      dateStr = '${dateTime.month}月${dateTime.day}日';
    }

    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$dateStr $hour:$minute';
  }
}

