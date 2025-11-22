import 'package:flutter/material.dart';
import 'package:pocket_fit/services/notification_service.dart';
import 'package:pocket_fit/services/settings_service.dart';
import 'package:pocket_fit/services/feedback_service.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/pages/data_collection_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 服务实例
  final _notificationService = NotificationService();
  final _settingsService = SettingsService();
  final _feedbackService = FeedbackService();

  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  double _dailyActivityGoal = 30.0; // 分钟
  double _reminderInterval = 30.0; // 分钟
  double _sensitivity = 0.5; // 0-1
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 异步加载设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  /// 加载所有设置
  Future<void> _loadSettings() async {
    try {
      // 确保 SettingsService 已初始化
      await _settingsService.initialize();

      // 从设置服务加载
      final dailyGoal = await _settingsService.getDailyActivityGoal();
      final reminderInterval = await _settingsService.getReminderInterval();
      final sensitivity = await _settingsService.getSensitivity();
      final notificationsEnabled = await _settingsService.getNotificationsEnabled();
      final vibrationEnabled = await _settingsService.getVibrationEnabled();
      final soundEnabled = await _settingsService.getSoundEnabled();

      if (mounted) {
        setState(() {
          _dailyActivityGoal = dailyGoal.toDouble();
          _reminderInterval = reminderInterval.toDouble();
          _sensitivity = sensitivity;
          _notificationsEnabled = notificationsEnabled;
          _vibrationEnabled = vibrationEnabled;
          _soundEnabled = soundEnabled;
          _isLoading = false;
        });

        // 同步到通知服务
        _notificationService.notificationsEnabled = notificationsEnabled;
        _notificationService.vibrationEnabled = vibrationEnabled;
        _notificationService.soundEnabled = soundEnabled;

        // 同步到反馈服务
        _feedbackService.setFeedbackSettings(
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
        );
      }
    } catch (e) {
      print('SettingsPage: 加载设置失败 - $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

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
                // 标题
                Text(
                  '设置',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '个性化你的体验',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // 目标设置
                _buildSectionTitle('目标设置'),
                const SizedBox(height: 15),
                _buildSliderCard(
                  icon: Icons.flag,
                  title: '每日活动目标',
                  subtitle: '每天需要完成的活动时长',
                  value: _dailyActivityGoal,
                  min: 10,
                  max: 120,
                  divisions: 22,
                  unit: '分钟',
                  onChanged: (value) async {
                    setState(() {
                      _dailyActivityGoal = value;
                    });
                    await _settingsService.setDailyActivityGoal(value.toInt());
                  },
                  color: Colors.amber,
                ),
                const SizedBox(height: 30),

                // 通知设置
                _buildSectionTitle('通知设置'),
                const SizedBox(height: 15),
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: '启用通知',
                  subtitle: '接收活动提醒',
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _notificationsEnabled = value;
                      _notificationService.notificationsEnabled = value;
                    });
                    await _settingsService.setNotificationsEnabled(value);
                  },
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  icon: Icons.vibration,
                  title: '振动反馈',
                  subtitle: '活动时提供触觉反馈',
                  value: _vibrationEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _vibrationEnabled = value;
                      _notificationService.vibrationEnabled = value;
                    });
                    // 同步到反馈服务
                    _feedbackService.setFeedbackSettings(vibrationEnabled: value);
                    await _settingsService.setVibrationEnabled(value);
                    // 测试振动
                    if (value) {
                      _notificationService.vibrate(duration: 100);
                    }
                  },
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: '声音提示',
                  subtitle: '播放提示音效',
                  value: _soundEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _soundEnabled = value;
                      _notificationService.soundEnabled = value;
                    });
                    // 同步到反馈服务
                    _feedbackService.setFeedbackSettings(soundEnabled: value);
                    await _settingsService.setSoundEnabled(value);
                    // 测试声音（播放系统音效）
                    if (value) {
                      await _feedbackService.activityCountFeedback(ActivityType.jumping);
                    }
                  },
                  color: Colors.orange,
                ),
                const SizedBox(height: 30),

                // 活动设置
                _buildSectionTitle('活动设置'),
                const SizedBox(height: 15),
                _buildSliderCard(
                  icon: Icons.timer,
                  title: '提醒间隔',
                  subtitle: '久坐多久后提醒',
                  value: _reminderInterval,
                  min: 15,
                  max: 120,
                  divisions: 7,
                  unit: '分钟',
                  onChanged: (value) async {
                    setState(() {
                      _reminderInterval = value;
                    });
                    await _settingsService.setReminderInterval(value.toInt());
                  },
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildSliderCard(
                  icon: Icons.tune,
                  title: '检测灵敏度',
                  subtitle: '运动检测的敏感程度',
                  value: _sensitivity,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  unit: '',
                  displayValue: _getSensitivityLabel(_sensitivity),
                  onChanged: (value) async {
                    setState(() {
                      _sensitivity = value;
                    });
                    await _settingsService.setSensitivity(value);
                  },
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                _buildNavigationCard(
                  icon: Icons.science,
                  title: '训练数据采集',
                  subtitle: '采集传感器数据用于机器学习',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataCollectionPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // About
                _buildSectionTitle('about'),
                const SizedBox(height: 15),
                _buildInfoTile(
                  icon: Icons.info,
                  title: 'Version',
                  subtitle: '1.0.0',
                  color: Colors.indigo,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.code,
                  title: 'Developed by',
                  subtitle: 'PocketFit Team (now Diode only)',
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    return Container(
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
            child: Icon(icon, color: color, size: 24),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    String? displayValue,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return Container(
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                displayValue ?? '${value.toInt()}$unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
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
            child: Icon(icon, color: color, size: 24),
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
                  subtitle,
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
    );
  }

  String _getSensitivityLabel(double value) {
    if (value < 0.3) return '低';
    if (value < 0.7) return '中';
    return '高';
  }

  Widget _buildNavigationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

