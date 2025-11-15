import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_fit/pages/sensor_test_page.dart';
import 'package:pocket_fit/services/sensor_service.dart';
import 'package:pocket_fit/models/sensor_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sensorService = SensorService();

  // 实时数据
  Duration _currentSedentaryDuration = Duration.zero;
  MotionState _currentMotionState = MotionState.unknown;

  // 模拟数据 - 后续会连接到实际的数据源
  int _activeMinutesToday = 15;
  int _sedentaryMinutesToday = 120;
  int _completedActivities = 3;
  int _currentStreak = 5;

  // Stream 订阅
  StreamSubscription<Duration>? _sedentaryDurationSubscription;
  StreamSubscription<MotionStatistics>? _motionStateSubscription;

  @override
  void initState() {
    super.initState();
    _initSensorService();
  }

  @override
  void dispose() {
    _sedentaryDurationSubscription?.cancel();
    _motionStateSubscription?.cancel();
    super.dispose();
  }

  /// 初始化传感器服务
  Future<void> _initSensorService() async {
    // 启动传感器服务
    await _sensorService.start();

    // 订阅久坐时长流
    _sedentaryDurationSubscription = _sensorService.sedentaryDurationStream.listen((duration) {
      setState(() {
        _currentSedentaryDuration = duration;
      });
    });

    // 订阅运动状态流
    _motionStateSubscription = _sensorService.motionStateStream.listen((stats) {
      setState(() {
        _currentMotionState = stats.state;
      });
    });
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部欢迎区域
                _buildWelcomeSection(),
                const SizedBox(height: 20),

                // 当前久坐时长卡片（醒目显示）
                _buildCurrentSedentaryCard(),
                const SizedBox(height: 20),

                // 今日统计卡片
                _buildTodayStatsCard(),
                const SizedBox(height: 25),
                
                // 快速操作按钮
                _buildQuickActions(),
                const SizedBox(height: 25),
                
                // 功能介绍
                _buildFeaturesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 欢迎区域
  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    String greeting = '早上好';
    if (hour >= 12 && hour < 18) {
      greeting = '下午好';
    } else if (hour >= 18) {
      greeting = '晚上好';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.favorite,
              color: Colors.red.shade400,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '让我们一起保持活力！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 当前久坐时长卡片
  Widget _buildCurrentSedentaryCard() {
    final minutes = _currentSedentaryDuration.inMinutes;
    final seconds = _currentSedentaryDuration.inSeconds % 60;

    // 根据久坐时长确定颜色和提示
    Color cardColor;
    Color textColor;
    String statusText;
    IconData statusIcon;

    if (_currentMotionState == MotionState.moving) {
      cardColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      statusText = '正在活动中';
      statusIcon = Icons.directions_run;
    } else if (minutes >= 60) {
      cardColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      statusText = '严重久坐警告！';
      statusIcon = Icons.warning_amber_rounded;
    } else if (minutes >= 30) {
      cardColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      statusText = '久坐提醒';
      statusIcon = Icons.notifications_active;
    } else if (_currentMotionState == MotionState.still) {
      cardColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      statusText = '当前静止';
      statusIcon = Icons.event_seat;
    } else {
      cardColor = Colors.grey.shade50;
      textColor = Colors.grey.shade700;
      statusText = '检测中...';
      statusIcon = Icons.sensors;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                statusIcon,
                color: textColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMotionStateDescription(),
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      '$minutes',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '分钟',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      seconds.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '秒',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (minutes >= 30) ...[
            const SizedBox(height: 15),
            Text(
              minutes >= 60
                  ? '🚨 您已久坐超过1小时，建议立即起身活动！'
                  : '⚠️ 您已久坐${minutes}分钟，建议起身活动一下',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 获取运动状态描述
  String _getMotionStateDescription() {
    switch (_currentMotionState) {
      case MotionState.still:
        final minutes = _currentSedentaryDuration.inMinutes;
        if (minutes == 0) {
          return '刚刚开始静止';
        } else if (minutes < 30) {
          return '已静止 $minutes 分钟';
        } else if (minutes < 60) {
          return '已久坐 $minutes 分钟，建议活动';
        } else {
          return '已久坐超过 1 小时！';
        }
      case MotionState.moving:
        return '保持活力，继续加油！';
      case MotionState.unknown:
        return '正在检测您的运动状态...';
    }
  }

  // 今日统计卡片
  Widget _buildTodayStatsCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日概览',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_currentStreak 天连续',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.directions_run,
                  label: '活动时间',
                  value: '$_activeMinutesToday',
                  unit: '分钟',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.event_seat,
                  label: '久坐时间',
                  value: '$_sedentaryMinutesToday',
                  unit: '分钟',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: '完成活动',
                  value: '$_completedActivities',
                  unit: '次',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  label: '今日目标',
                  value: '${(_completedActivities / 5 * 100).toInt()}',
                  unit: '%',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
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
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 快速操作按钮
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速开始',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.play_circle_filled,
                label: '开始活动',
                color: Colors.blue,
                onTap: () {
                  // TODO: 导航到活动页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('活动功能即将推出！')),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: '活动历史',
                color: Colors.purple,
                onTap: () {
                  // TODO: 导航到历史页面
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('历史功能即将推出！')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 功能介绍
  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '核心功能',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        _buildFeatureCard(
          icon: Icons.sensors,
          title: '智能检测',
          description: '使用手机传感器自动检测久坐行为',
          color: Colors.teal,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SensorTestPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.gesture,
          title: '互动挑战',
          description: '完成有趣的动作挑战，保持身体活力',
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.vibration,
          title: '多模态反馈',
          description: '声音、震动、视觉多重反馈引导',
          color: Colors.pink,
        ),
      ],
    );
  }

  // 功能卡片
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
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
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

