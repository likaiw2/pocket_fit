import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

/// 通知服务 - 处理久坐提醒通知和振动反馈
class NotificationService {
  // 单例模式
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // 通知插件实例
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // 通知设置
  bool _notificationsEnabled = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;

  // 通知 ID
  static const int _sedentaryWarningNotificationId = 1;
  static const int _sedentaryCriticalNotificationId = 2;

  /// 初始化通知服务
  Future<void> initialize() async {
    // Android 初始化设置
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 初始化设置
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 初始化设置
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // 初始化插件
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 请求 Android 13+ 的通知权限
    await _requestPermissions();

    print('NotificationService: 通知服务已初始化');
  }

  /// 请求通知权限
  Future<void> _requestPermissions() async {
    // Android 13+ 需要请求通知权限
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    // iOS 请求权限
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// 通知点击回调
  void _onNotificationTapped(NotificationResponse response) {
    print('NotificationService: 通知被点击 - ${response.payload}');
    // TODO: 处理通知点击事件（例如：导航到特定页面）
  }

  /// 显示久坐警告通知（30分钟）
  Future<void> showSedentaryWarning(int minutes) async {
    if (!_notificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      'sedentary_warning',
      '久坐提醒',
      channelDescription: '提醒您已经久坐一段时间，建议起身活动',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF9800), // 橙色
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _sedentaryWarningNotificationId,
      '⚠️ 久坐提醒',
      '您已经久坐 $minutes 分钟了，建议起身活动一下！',
      details,
      payload: 'sedentary_warning',
    );

    // 触发振动
    if (_vibrationEnabled) {
      await _vibratePattern([0, 200, 100, 200]); // 短-停-短
    }

    print('NotificationService: 已显示久坐警告通知 - $minutes 分钟');
  }

  /// 显示严重久坐警告通知（60分钟）
  Future<void> showSedentaryCritical(int minutes) async {
    if (!_notificationsEnabled) return;

    final androidDetails = AndroidNotificationDetails(
      'sedentary_critical',
      '严重久坐警告',
      channelDescription: '您已经久坐很长时间，强烈建议立即起身活动',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFF44336), // 红色
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        '您已经久坐超过 $minutes 分钟了！长时间久坐对健康不利，请立即起身活动，做一些简单的伸展运动。',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _sedentaryCriticalNotificationId,
      '🚨 严重久坐警告！',
      '您已经久坐超过 $minutes 分钟了！请立即起身活动！',
      details,
      payload: 'sedentary_critical',
    );

    // 触发更强烈的振动
    if (_vibrationEnabled) {
      await _vibratePattern([0, 300, 200, 300, 200, 300]); // 长-停-长-停-长
    }

    print('NotificationService: 已显示严重久坐警告通知 - $minutes 分钟');
  }

  /// 显示活动检测通知
  Future<void> showActivityDetected() async {
    if (!_notificationsEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      'activity_detected',
      '活动检测',
      channelDescription: '检测到您开始活动',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50), // 绿色
      enableVibration: false,
      playSound: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      '🟢 活动检测',
      '太棒了！检测到您开始活动，继续保持！',
      details,
      payload: 'activity_detected',
    );

    print('NotificationService: 已显示活动检测通知');
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('NotificationService: 已取消所有通知');
  }

  /// 取消特定通知
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
    print('NotificationService: 已取消通知 ID: $id');
  }

  /// 触发振动模式
  Future<void> _vibratePattern(List<int> pattern) async {
    if (!_vibrationEnabled) return;

    // 检查设备是否支持振动
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      // 检查是否支持自定义振动模式
      final hasCustomVibrations = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomVibrations == true) {
        await Vibration.vibrate(pattern: pattern);
      } else {
        // 不支持自定义模式，使用默认振动
        await Vibration.vibrate(duration: 500);
      }
    }
  }

  /// 触发简单振动
  Future<void> vibrate({int duration = 200}) async {
    if (!_vibrationEnabled) return;

    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(duration: duration);
    }
  }

  /// 停止振动
  Future<void> stopVibration() async {
    await Vibration.cancel();
  }

  // Getters 和 Setters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;

  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    print('NotificationService: 通知已${value ? "启用" : "禁用"}');
  }

  set vibrationEnabled(bool value) {
    _vibrationEnabled = value;
    print('NotificationService: 振动已${value ? "启用" : "禁用"}');
  }

  set soundEnabled(bool value) {
    _soundEnabled = value;
    print('NotificationService: 声音已${value ? "启用" : "禁用"}');
  }
}

