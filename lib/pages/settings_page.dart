import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_fit/services/notification_service.dart';
import 'package:pocket_fit/services/settings_service.dart';
import 'package:pocket_fit/services/feedback_service.dart';
import 'package:pocket_fit/services/localization_service.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';
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
  final _localizationService = LocalizationService();

  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  double _dailyActivityGoal = 30.0; // 分钟
  double _reminderInterval = 30.0; // 分钟
  double _sensitivity = 0.5; // 0-1
  bool _useDLDetection = false; // 深度学习检测
  String _language = 'zh'; // 语言设置
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
      final useDLDetection = await _settingsService.getUseDLDetection();
      final language = await _settingsService.getLanguage();

      if (mounted) {
        setState(() {
          _dailyActivityGoal = dailyGoal.toDouble();
          _reminderInterval = reminderInterval.toDouble();
          _sensitivity = sensitivity;
          _notificationsEnabled = notificationsEnabled;
          _vibrationEnabled = vibrationEnabled;
          _soundEnabled = soundEnabled;
          _useDLDetection = useDLDetection;
          _language = language;
          _isLoading = false;
        });

        // 同步到本地化服务
        _localizationService.setLanguage(language);

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
      debugPrint('SettingsPage: 加载设置失败 - $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 显示更新日志
  Future<void> _showUpdateLog() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // 从 assets 加载更新日志
      final updateLog = await rootBundle.loadString('update_summary.txt');

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.history, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(l10n.updateLogTitle),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Text(
                updateLog,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('加载更新日志失败: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.updateLogFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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

    return ValueListenableBuilder<String>(
      valueListenable: _localizationService.languageNotifier,
      builder: (context, language, child) {
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
                      l10n.settingsTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.settingsSubtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // 目标设置
                _buildSectionTitle(l10n.goalSettings),
                const SizedBox(height: 15),
                _buildSliderCard(
                  icon: Icons.flag,
                  title: l10n.dailyActivityGoal,
                  subtitle: l10n.dailyActivityGoalSubtitle,
                  value: _dailyActivityGoal,
                  min: 10,
                  max: 120,
                  divisions: 22,
                  unit: l10n.minutes,
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
                _buildSectionTitle(l10n.notificationSettings),
                const SizedBox(height: 15),
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: l10n.enableNotifications,
                  subtitle: l10n.enableNotificationsSubtitle,
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
                  title: l10n.enableVibration,
                  subtitle: l10n.enableVibrationSubtitle,
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
                  title: l10n.enableSound,
                  subtitle: l10n.enableSoundSubtitle,
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
                _buildSectionTitle(l10n.activitySettings),
                const SizedBox(height: 15),
                _buildSliderCard(
                  icon: Icons.timer,
                  title: l10n.reminderInterval,
                  subtitle: l10n.reminderIntervalSubtitle,
                  value: _reminderInterval,
                  min: 15,
                  max: 120,
                  divisions: 7,
                  unit: l10n.minutes,
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
                  title: l10n.detectionSensitivity,
                  subtitle: l10n.detectionSensitivitySubtitle,
                  value: _sensitivity,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  unit: '',
                  displayValue: _getSensitivityLabel(_sensitivity, l10n),
                  onChanged: (value) async {
                    setState(() {
                      _sensitivity = value;
                    });
                    await _settingsService.setSensitivity(value);
                  },
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                _buildSwitchTile(
                  icon: Icons.psychology,
                  title: l10n.dlDetection,
                  subtitle: l10n.dlDetectionSubtitle,
                  value: _useDLDetection,
                  onChanged: (value) async {
                    setState(() {
                      _useDLDetection = value;
                    });
                    await _settingsService.setUseDLDetection(value);

                    // 显示提示
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? l10n.dlEnabled : l10n.dlDisabled
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 12),
                _buildLanguageSelector(l10n),
                const SizedBox(height: 12),
                _buildNavigationCard(
                  icon: Icons.science,
                  title: l10n.trainingData,
                  subtitle: l10n.trainingDataSubtitle,
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
                _buildSectionTitle(l10n.about),
                const SizedBox(height: 15),
                _buildNavigationCard(
                  icon: Icons.info,
                  title: l10n.version,
                  subtitle: '2.1.0',
                  color: Colors.indigo,
                  onTap: _showUpdateLog,
                ),
                const SizedBox(height: 12),
                _buildInfoTile(
                  icon: Icons.code,
                  title: l10n.developedBy,
                  subtitle: l10n.developerName,
                  color: Colors.pink,
                ),
              ],
            ),
          ),
        ),
      ),
        );
      },
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

  String _getSensitivityLabel(double value, AppLocalizations l10n) {
    if (value < 0.3) return l10n.sensitivityLow;
    if (value < 0.7) return l10n.sensitivityMedium;
    return l10n.sensitivityHigh;
  }

  Widget _buildLanguageSelector(AppLocalizations l10n) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.language, color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.languageSubtitle,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: 'zh',
                  label: Text(l10n.chinese),
                ),
                ButtonSegment<String>(
                  value: 'en',
                  label: Text(l10n.english),
                ),
              ],
              selected: {_language},
              onSelectionChanged: (Set<String> newSelection) async {
                final newLanguage = newSelection.first;
                setState(() {
                  _language = newLanguage;
                });

                // 保存到设置
                await _settingsService.setLanguage(newLanguage);

                // 更新本地化服务
                _localizationService.setLanguage(newLanguage);

                // 显示提示
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newLanguage == 'zh' ? l10n.languageChangedZh : l10n.languageChangedEn
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
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

