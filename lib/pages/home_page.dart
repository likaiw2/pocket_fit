import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_fit/pages/sensor_test_page.dart';
import 'package:pocket_fit/pages/activity_challenge_page.dart';
import 'package:pocket_fit/pages/activity_history_page.dart';
import 'package:pocket_fit/services/sensor_service.dart';
import 'package:pocket_fit/services/statistics_service.dart';
import 'package:pocket_fit/services/settings_service.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/models/daily_statistics.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _sensorService = SensorService();
  final _statisticsService = StatisticsService();
  final _settingsService = SettingsService();

  // 实时数据
  Duration _currentSedentaryDuration = Duration.zero;
  MotionState _currentMotionState = MotionState.unknown;

  // 今日统计数据
  DailyStatistics? _todayStats;
  bool _isLoadingStats = true;

  // 用户设置
  int _dailyActivityGoal = 30; // 默认30分钟

  // Stream 订阅
  StreamSubscription<Duration>? _sedentaryDurationSubscription;
  StreamSubscription<MotionStatistics>? _motionStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _initSensorService();
    _loadTodayStatistics();
  }

  /// 加载用户设置
  Future<void> _loadSettings() async {
    final goal = await _settingsService.getDailyActivityGoal();
    setState(() {
      _dailyActivityGoal = goal;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sedentaryDurationSubscription?.cancel();
    _motionStateSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 当应用从后台返回前台时，重新订阅 Stream
    if (state == AppLifecycleState.resumed) {
      print('HomePage: 应用恢复，重新订阅 Stream');
      _resubscribeStreams();
      _loadTodayStatistics();
    }
  }

  /// 初始化传感器服务
  Future<void> _initSensorService() async {
    // 启动传感器服务
    await _sensorService.start();

    // 订阅 Stream
    _subscribeToStreams();
  }

  /// 订阅传感器数据流
  void _subscribeToStreams() {
    // 订阅久坐时长流
    _sedentaryDurationSubscription = _sensorService.sedentaryDurationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _currentSedentaryDuration = duration;
        });
      }
    });

    // 订阅运动状态流
    _motionStateSubscription = _sensorService.motionStateStream.listen((stats) {
      if (mounted) {
        setState(() {
          _currentMotionState = stats.state;
        });
      }
    });
  }

  /// 重新订阅传感器数据流
  void _resubscribeStreams() {
    // 取消旧的订阅
    _sedentaryDurationSubscription?.cancel();
    _motionStateSubscription?.cancel();

    // 重新订阅
    _subscribeToStreams();
  }

  /// 加载今日统计数据
  Future<void> _loadTodayStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats = await _statisticsService.getTodayStatistics();
      setState(() {
        _todayStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      print('HomePage: 加载今日统计失败 - $e');
      setState(() {
        _isLoadingStats = false;
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
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    String greeting = l10n.goodMorning;
    if (hour >= 12 && hour < 18) {
      greeting = l10n.goodAfternoon;
    } else if (hour >= 18) {
      greeting = l10n.goodEvening;
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
              l10n.stayActive,
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
    final l10n = AppLocalizations.of(context);
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
      statusText = l10n.currentlyActive;
      statusIcon = Icons.directions_run;
    } else if (minutes >= 60) {
      cardColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      statusText = l10n.criticalSedentaryWarning;
      statusIcon = Icons.warning_amber_rounded;
    } else if (minutes >= 30) {
      cardColor = Colors.orange.shade50;
      textColor = Colors.orange.shade700;
      statusText = l10n.sedentaryReminder;
      statusIcon = Icons.notifications_active;
    } else if (_currentMotionState == MotionState.still) {
      cardColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      statusText = l10n.currentlyStill;
      statusIcon = Icons.event_seat;
    } else {
      cardColor = Colors.grey.shade50;
      textColor = Colors.grey.shade700;
      statusText = l10n.detectingMotion;
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
                      l10n.minutes,
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
                      l10n.seconds,
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
    final l10n = AppLocalizations.of(context);
    switch (_currentMotionState) {
      case MotionState.still:
        final minutes = _currentSedentaryDuration.inMinutes;
        if (minutes == 0) {
          return l10n.justStartedStill;
        } else if (minutes < 30) {
          return l10n.stillForMinutes(minutes);
        } else if (minutes < 60) {
          return l10n.sedentaryForMinutes(minutes);
        } else {
          return l10n.sedentaryOverHour;
        }
      case MotionState.moving:
        return l10n.keepActive;
      case MotionState.unknown:
        return l10n.detectingMotion;
    }
  }

  // 今日统计卡片
  Widget _buildTodayStatsCard() {
    final l10n = AppLocalizations.of(context);

    if (_isLoadingStats) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // 从数据库获取的真实数据
    final activeMinutes = _todayStats?.totalActivityDuration.toInt() ?? 0;
    // 久坐时间 = 数据库中已保存的记录 + 当前正在进行的久坐时长
    final sedentaryMinutes = (_todayStats?.totalSedentaryDuration.toInt() ?? 0) +
                             _currentSedentaryDuration.inMinutes;
    final completedActivities = _todayStats?.totalActivityCount ?? 0;
    // 使用用户设置的目标值计算进度
    final goalProgress = _dailyActivityGoal > 0
        ? (activeMinutes / _dailyActivityGoal * 100).clamp(0, 100).toInt()
        : 0;

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
                l10n.todayOverview,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              FutureBuilder<int>(
                future: _statisticsService.getConsecutiveGoalMetDays(),
                builder: (context, snapshot) {
                  final streak = snapshot.data ?? 0;
                  return Container(
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
                          l10n.daysStreak(streak),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.directions_run,
                  label: l10n.activeTime,
                  value: '$activeMinutes',
                  unit: l10n.minutes,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.event_seat,
                  label: l10n.sedentaryTime,
                  value: '$sedentaryMinutes',
                  unit: l10n.minutes,
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
                  label: l10n.completedActivities,
                  value: '$completedActivities',
                  unit: l10n.times,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  label: l10n.todayGoal,
                  value: '$goalProgress',
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickStart,
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
                label: l10n.startActivity,
                color: Colors.blue,
                onTap: () {
                  // 导航到活动挑战页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivityChallengePage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildActionButton(
                icon: Icons.history,
                label: l10n.activityHistory,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivityHistoryPage(),
                    ),
                  ).then((_) {
                    // 从历史页面返回时刷新统计数据
                    _loadTodayStatistics();
                  });
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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.coreFeatures,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 15),
        _buildFeatureCard(
          icon: Icons.sensors,
          title: l10n.smartDetection,
          description: l10n.smartDetectionDesc,
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
          title: l10n.interactiveChallenge,
          description: l10n.interactiveChallengeDesc,
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.vibration,
          title: l10n.multimodalFeedback,
          description: l10n.multimodalFeedbackDesc,
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

