import 'package:flutter/material.dart';

/// 语言服务 - 管理应用的多语言支持
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  // 当前语言
  String _currentLanguage = 'zh'; // 'zh' 或 'en'
  
  // 语言变化通知
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('zh');

  /// 获取当前语言
  String get currentLanguage => _currentLanguage;

  /// 设置语言
  void setLanguage(String language) {
    if (language != 'zh' && language != 'en') {
      language = 'zh'; // 默认中文
    }
    _currentLanguage = language;
    languageNotifier.value = language;
    print('LocalizationService: 语言已切换到 $language');
  }

  /// 获取翻译文本
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  /// 翻译字典
  static const Map<String, Map<String, String>> _translations = {
    'zh': {
      // 通用
      'app_name': 'PocketFit',
      'ok': '确定',
      'cancel': '取消',
      'delete': '删除',
      'confirm': '确认',
      'save': '保存',
      'back': '返回',
      'settings': '设置',
      'close': '关闭',
      
      // 主页
      'home_title': '首页',
      'start_challenge': '开始挑战',
      'sedentary_status': '久坐状态',
      'sedentary_time': '久坐时间',
      'activity_records': '运动记录',
      'daily_stats': '今日统计',
      'no_sedentary': '暂无久坐',
      'minutes': '分钟',
      
      // 运动类型
      'jumping': '跳跃',
      'squatting': '深蹲',
      'waving': '挥手',
      'shaking': '摇晃',
      'figure_eight': '八字绕圈',
      'walking': '走路',
      'running': '跑步',
      'idle': '静止',
      
      // 挑战页面
      'challenge_title': '运动挑战',
      'select_activity': '选择运动类型',
      'target_count': '目标次数',
      'current_count': '当前次数',
      'start': '开始',
      'stop': '停止',
      'challenge_complete': '挑战完成！',
      'challenge_failed': '挑战失败',
      'preparing': '准备中...',
      'countdown': '倒计时',
      
      // 设置页面
      'settings_title': '设置',
      'settings_subtitle': '个性化你的体验',
      'goal_settings': '目标设置',
      'daily_activity_goal': '每日活动目标',
      'daily_activity_goal_subtitle': '每天需要完成的活动时长',
      'reminder_interval': '提醒间隔',
      'reminder_interval_subtitle': '久坐多久后提醒',
      'notification_settings': '通知设置',
      'enable_notifications': '启用通知',
      'enable_notifications_subtitle': '接收活动提醒',
      'enable_vibration': '振动反馈',
      'enable_vibration_subtitle': '活动时提供触觉反馈',
      'enable_sound': '声音反馈',
      'enable_sound_subtitle': '活动时播放音效',
      'detection_settings': '检测设置',
      'detection_sensitivity': '检测灵敏度',
      'detection_sensitivity_subtitle': '调整运动检测的敏感度',
      'sensitivity_low': '低',
      'sensitivity_medium': '中',
      'sensitivity_high': '高',
      'dl_detection': '深度学习检测',
      'dl_detection_subtitle': '使用AI模型识别运动类型和计数',
      'dl_enabled': '已启用深度学习检测 - 使用AI模型识别运动',
      'dl_disabled': '已禁用深度学习检测 - 使用传统算法识别运动',
      'language': '语言',
      'language_subtitle': '选择应用显示语言',
      'chinese': '中文',
      'english': 'English',
      'language_changed_zh': '语言已切换到中文',
      'language_changed_en': 'Language changed to English',
      'data_management': '数据管理',
      'training_data': '训练数据采集',
      'training_data_subtitle': '采集传感器数据用于机器学习',
      'view_update_log': '查看更新日志',
      'update_log_title': '更新日志',
      'update_log_failed': '无法加载更新日志',
      'about': '关于',
      'version': '版本',
      'developed_by': 'Developed by',
      'developer_name': 'PocketFit Team (now Diode only)',
      
      // 统计页面
      'statistics_title': '统计',
      'today': '今天',
      'this_week': '本周',
      'this_month': '本月',
      'total_activities': '总运动次数',
      'total_duration': '总运动时长',
      'sedentary_duration': '久坐时长',
      'activity_breakdown': '运动分布',
      'no_data': '暂无数据',
      'times': '次',
      'hours': '小时',
      
      // 训练数据采集
      'training_data_title': '训练数据采集',
      'collect_data': '采集数据',
      'data_list': '数据列表',
      'start_collection': '开始采集',
      'stop_collection': '停止采集',
      'collecting': '采集中...',
      'collection_complete': '采集完成',
      'delete_data': '删除数据',
      'delete_confirm': '确认删除',
      'delete_message': '确定要删除这条数据吗？',
      'clear_all': '清空所有',
      'clear_all_confirm': '确定要清空所有数据吗？',

      // 更新日志（已在设置页面部分定义）
      'loading': '加载中...',
      'load_failed': '加载失败',
      
      // 通知消息
      'sedentary_warning': '久坐提醒',
      'sedentary_warning_message': '您已久坐 {minutes} 分钟，该活动一下了！',
      'sedentary_critical': '严重久坐警告',
      'sedentary_critical_message': '您已久坐 {minutes} 分钟，请立即起身活动！',
      
      // 反馈消息
      'activity_detected': '检测到运动',
      'count_increased': '计数 +1',
      'milestone_50': '已完成 50%',
      'milestone_75': '已完成 75%',
      'challenge_success': '挑战成功！',
    },
    'en': {
      // Common
      'app_name': 'PocketFit',
      'ok': 'OK',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm': 'Confirm',
      'save': 'Save',
      'back': 'Back',
      'settings': 'Settings',
      'close': 'Close',
      
      // Home
      'home_title': 'Home',
      'start_challenge': 'Start Challenge',
      'sedentary_status': 'Sedentary Status',
      'sedentary_time': 'Sedentary Time',
      'activity_records': 'Activity Records',
      'daily_stats': 'Daily Statistics',
      'no_sedentary': 'No Sedentary',
      'minutes': 'minutes',
      
      // Activity Types
      'jumping': 'Jumping',
      'squatting': 'Squatting',
      'waving': 'Waving',
      'shaking': 'Shaking',
      'figure_eight': 'Figure Eight',
      'walking': 'Walking',
      'running': 'Running',
      'idle': 'Idle',
      
      // Challenge Page
      'challenge_title': 'Activity Challenge',
      'select_activity': 'Select Activity Type',
      'target_count': 'Target Count',
      'current_count': 'Current Count',
      'start': 'Start',
      'stop': 'Stop',
      'challenge_complete': 'Challenge Complete!',
      'challenge_failed': 'Challenge Failed',
      'preparing': 'Preparing...',
      'countdown': 'Countdown',
      
      // Settings Page
      'settings_title': 'Settings',
      'settings_subtitle': 'Personalize your experience',
      'goal_settings': 'Goal Settings',
      'daily_activity_goal': 'Daily Activity Goal',
      'daily_activity_goal_subtitle': 'Daily activity duration target',
      'reminder_interval': 'Reminder Interval',
      'reminder_interval_subtitle': 'Remind after sitting for',
      'notification_settings': 'Notification Settings',
      'enable_notifications': 'Enable Notifications',
      'enable_notifications_subtitle': 'Receive activity reminders',
      'enable_vibration': 'Vibration Feedback',
      'enable_vibration_subtitle': 'Provide haptic feedback during activities',
      'enable_sound': 'Sound Feedback',
      'enable_sound_subtitle': 'Play sound effects during activities',
      'detection_settings': 'Detection Settings',
      'detection_sensitivity': 'Detection Sensitivity',
      'detection_sensitivity_subtitle': 'Adjust motion detection sensitivity',
      'sensitivity_low': 'Low',
      'sensitivity_medium': 'Medium',
      'sensitivity_high': 'High',
      'dl_detection': 'Deep Learning Detection',
      'dl_detection_subtitle': 'Use AI model for activity recognition and counting',
      'dl_enabled': 'Deep Learning Detection Enabled - Using AI Model',
      'dl_disabled': 'Deep Learning Detection Disabled - Using Traditional Algorithm',
      'language': 'Language',
      'language_subtitle': 'Select app display language',
      'chinese': '中文',
      'english': 'English',
      'language_changed_zh': 'Language changed to Chinese',
      'language_changed_en': 'Language changed to English',
      'data_management': 'Data Management',
      'training_data': 'Training Data Collection',
      'training_data_subtitle': 'Collect sensor data for machine learning',
      'view_update_log': 'View Update Log',
      'update_log_title': 'Update Log',
      'update_log_failed': 'Failed to load update log',
      'about': 'About',
      'version': 'Version',
      'developed_by': 'Developed by',
      'developer_name': 'PocketFit Team (now Diode only)',
      
      // Statistics Page
      'statistics_title': 'Statistics',
      'today': 'Today',
      'this_week': 'This Week',
      'this_month': 'This Month',
      'total_activities': 'Total Activities',
      'total_duration': 'Total Duration',
      'sedentary_duration': 'Sedentary Duration',
      'activity_breakdown': 'Activity Breakdown',
      'no_data': 'No Data',
      'times': 'times',
      'hours': 'hours',
      
      // Training Data Collection
      'training_data_title': 'Training Data Collection',
      'collect_data': 'Collect Data',
      'data_list': 'Data List',
      'start_collection': 'Start Collection',
      'stop_collection': 'Stop Collection',
      'collecting': 'Collecting...',
      'collection_complete': 'Collection Complete',
      'delete_data': 'Delete Data',
      'delete_confirm': 'Confirm Delete',
      'delete_message': 'Are you sure you want to delete this data?',
      'clear_all': 'Clear All',
      'clear_all_confirm': 'Are you sure you want to clear all data?',

      // Update Log (already defined in Settings Page section)
      'loading': 'Loading...',
      'load_failed': 'Load Failed',
      
      // Notification Messages
      'sedentary_warning': 'Sedentary Warning',
      'sedentary_warning_message': 'You have been sedentary for {minutes} minutes. Time to move!',
      'sedentary_critical': 'Critical Sedentary Warning',
      'sedentary_critical_message': 'You have been sedentary for {minutes} minutes. Please move immediately!',
      
      // Feedback Messages
      'activity_detected': 'Activity Detected',
      'count_increased': 'Count +1',
      'milestone_50': '50% Complete',
      'milestone_75': '75% Complete',
      'challenge_success': 'Challenge Success!',
    },
  };
}

