import 'package:shared_preferences/shared_preferences.dart';

/// 设置服务
/// 管理应用的所有设置项，使用 SharedPreferences 持久化存储
class SettingsService {
  // 单例模式
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // SharedPreferences 实例
  SharedPreferences? _prefs;

  // 设置键
  static const String _keyDailyActivityGoal = 'daily_activity_goal';
  static const String _keyReminderInterval = 'reminder_interval';
  static const String _keySensitivity = 'sensitivity';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keySoundEnabled = 'sound_enabled';
  static const String _keyUseDLDetection = 'use_dl_detection';
  static const String _keyLanguage = 'language';

  // 默认值
  static const int _defaultDailyActivityGoal = 30; // 30分钟
  static const int _defaultReminderInterval = 30; // 30分钟
  static const double _defaultSensitivity = 0.5; // 中等灵敏度
  static const bool _defaultNotificationsEnabled = true;
  static const bool _defaultVibrationEnabled = true;
  static const bool _defaultSoundEnabled = true;
  static const bool _defaultUseDLDetection = false; // 默认使用传统方法
  static const String _defaultLanguage = 'zh'; // 默认中文

  /// 初始化服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('SettingsService: 初始化完成');
  }

  /// 确保 SharedPreferences 已初始化
  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // ==================== 目标设置 ====================

  /// 获取每日活动目标（分钟）
  Future<int> getDailyActivityGoal() async {
    final p = await prefs;
    return p.getInt(_keyDailyActivityGoal) ?? _defaultDailyActivityGoal;
  }

  /// 设置每日活动目标（分钟）
  Future<void> setDailyActivityGoal(int minutes) async {
    final p = await prefs;
    await p.setInt(_keyDailyActivityGoal, minutes);
    print('SettingsService: 每日活动目标已设置为 $minutes 分钟');
  }

  // ==================== 提醒设置 ====================

  /// 获取提醒间隔（分钟）
  Future<int> getReminderInterval() async {
    final p = await prefs;
    return p.getInt(_keyReminderInterval) ?? _defaultReminderInterval;
  }

  /// 设置提醒间隔（分钟）
  Future<void> setReminderInterval(int minutes) async {
    final p = await prefs;
    await p.setInt(_keyReminderInterval, minutes);
    print('SettingsService: 提醒间隔已设置为 $minutes 分钟');
  }

  // ==================== 检测灵敏度 ====================

  /// 获取检测灵敏度（0-1）
  Future<double> getSensitivity() async {
    final p = await prefs;
    return p.getDouble(_keySensitivity) ?? _defaultSensitivity;
  }

  /// 设置检测灵敏度（0-1）
  Future<void> setSensitivity(double value) async {
    final p = await prefs;
    await p.setDouble(_keySensitivity, value);
    print('SettingsService: 检测灵敏度已设置为 $value');
  }

  // ==================== 通知设置 ====================

  /// 获取通知开关状态
  Future<bool> getNotificationsEnabled() async {
    final p = await prefs;
    return p.getBool(_keyNotificationsEnabled) ?? _defaultNotificationsEnabled;
  }

  /// 设置通知开关状态
  Future<void> setNotificationsEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_keyNotificationsEnabled, enabled);
    print('SettingsService: 通知已${enabled ? '启用' : '禁用'}');
  }

  /// 获取振动开关状态
  Future<bool> getVibrationEnabled() async {
    final p = await prefs;
    return p.getBool(_keyVibrationEnabled) ?? _defaultVibrationEnabled;
  }

  /// 设置振动开关状态
  Future<void> setVibrationEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_keyVibrationEnabled, enabled);
    print('SettingsService: 振动已${enabled ? '启用' : '禁用'}');
  }

  /// 获取声音开关状态
  Future<bool> getSoundEnabled() async {
    final p = await prefs;
    return p.getBool(_keySoundEnabled) ?? _defaultSoundEnabled;
  }

  /// 设置声音开关状态
  Future<void> setSoundEnabled(bool enabled) async {
    final p = await prefs;
    await p.setBool(_keySoundEnabled, enabled);
    print('SettingsService: 声音已${enabled ? '启用' : '禁用'}');
  }

  // ==================== 深度学习检测 ====================

  /// 获取深度学习检测开关状态
  Future<bool> getUseDLDetection() async {
    final p = await prefs;
    return p.getBool(_keyUseDLDetection) ?? _defaultUseDLDetection;
  }

  /// 设置深度学习检测开关状态
  Future<void> setUseDLDetection(bool enabled) async {
    final p = await prefs;
    await p.setBool(_keyUseDLDetection, enabled);
    print('SettingsService: 深度学习检测已${enabled ? '启用' : '禁用'}');
  }

  // ==================== 批量操作 ====================

  /// 重置所有设置为默认值
  Future<void> resetToDefaults() async {
    await setDailyActivityGoal(_defaultDailyActivityGoal);
    await setReminderInterval(_defaultReminderInterval);
    await setSensitivity(_defaultSensitivity);
    await setNotificationsEnabled(_defaultNotificationsEnabled);
    await setVibrationEnabled(_defaultVibrationEnabled);
    await setSoundEnabled(_defaultSoundEnabled);
    await setUseDLDetection(_defaultUseDLDetection);
    print('SettingsService: 所有设置已重置为默认值');
  }

  // ==================== 语言设置 ====================

  /// 获取语言设置
  Future<String> getLanguage() async {
    final p = await prefs;
    return p.getString(_keyLanguage) ?? _defaultLanguage;
  }

  /// 设置语言
  Future<void> setLanguage(String language) async {
    final p = await prefs;
    await p.setString(_keyLanguage, language);
    print('SettingsService: 语言已设置为 $language');
  }

  // ==================== 其他 ====================

  /// 获取所有设置的摘要
  Future<Map<String, dynamic>> getAllSettings() async {
    return {
      'dailyActivityGoal': await getDailyActivityGoal(),
      'reminderInterval': await getReminderInterval(),
      'sensitivity': await getSensitivity(),
      'notificationsEnabled': await getNotificationsEnabled(),
      'vibrationEnabled': await getVibrationEnabled(),
      'soundEnabled': await getSoundEnabled(),
      'useDLDetection': await getUseDLDetection(),
      'language': await getLanguage(),
    };
  }
}

