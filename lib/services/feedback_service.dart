import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:pocket_fit/models/sensor_data.dart';

/// 多模态反馈服务
/// 提供声音、震动、视觉等多种反馈方式
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // 反馈设置（从设置页面读取）
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _visualEnabled = true;

  // 音量设置
  double _volume = 0.5;

  /// 设置反馈开关
  void setFeedbackSettings({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? visualEnabled,
  }) {
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (vibrationEnabled != null) _vibrationEnabled = vibrationEnabled;
    if (visualEnabled != null) _visualEnabled = visualEnabled;
  }

  /// 设置音量 (0.0 - 1.0)
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);
  }

  /// 运动计数反馈
  /// 每次成功识别运动时调用
  Future<void> activityCountFeedback(ActivityType activityType) async {
    print('FeedbackService: 运动计数反馈 - ${activityType.displayName}');
    
    // 声音反馈
    if (_soundEnabled) {
      await _playSystemSound();
    }
    
    // 震动反馈 - 短促震动
    if (_vibrationEnabled) {
      await _vibrateShort();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  /// 挑战完成反馈
  /// 完成挑战时调用
  Future<void> challengeCompleteFeedback() async {
    print('FeedbackService: 挑战完成反馈');
    
    // 声音反馈 - 成功音效
    if (_soundEnabled) {
      await _playSuccessSound();
    }
    
    // 震动反馈 - 成功震动模式
    if (_vibrationEnabled) {
      await _vibrateSuccess();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// 挑战失败反馈
  /// 挑战失败时调用
  Future<void> challengeFailFeedback() async {
    print('FeedbackService: 挑战失败反馈');
    
    // 声音反馈 - 失败音效
    if (_soundEnabled) {
      await _playFailSound();
    }
    
    // 震动反馈 - 失败震动模式
    if (_vibrationEnabled) {
      await _vibrateFail();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// 倒计时反馈
  /// 倒计时每秒调用
  Future<void> countdownFeedback(int count) async {
    print('FeedbackService: 倒计时反馈 - $count');
    
    // 声音反馈
    if (_soundEnabled) {
      await _playSystemSound();
    }
    
    // 震动反馈
    if (_vibrationEnabled) {
      await _vibrateShort();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// 挑战开始反馈
  /// 挑战开始时调用
  Future<void> challengeStartFeedback() async {
    print('FeedbackService: 挑战开始反馈');
    
    // 声音反馈
    if (_soundEnabled) {
      await _playStartSound();
    }
    
    // 震动反馈
    if (_vibrationEnabled) {
      await _vibrateStart();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// 里程碑反馈
  /// 达到进度里程碑时调用（如50%、75%）
  Future<void> milestoneFeedback(double progress) async {
    print('FeedbackService: 里程碑反馈 - ${(progress * 100).toInt()}%');
    
    // 声音反馈
    if (_soundEnabled) {
      await _playMilestoneSound();
    }
    
    // 震动反馈
    if (_vibrationEnabled) {
      await _vibrateMilestone();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// 鼓励反馈
  /// 用户表现良好时调用
  Future<void> encouragementFeedback() async {
    print('FeedbackService: 鼓励反馈');
    
    // 声音反馈
    if (_soundEnabled) {
      await _playSystemSound();
    }
    
    // 震动反馈
    if (_vibrationEnabled) {
      await _vibrateShort();
    }
    
    // 触觉反馈
    if (_visualEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  // ==================== 私有方法 ====================

  /// 播放系统音效（用于计数）
  Future<void> _playSystemSound() async {
    try {
      // 使用系统音效作为临时替代
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('FeedbackService: 播放系统音效失败 - $e');
    }
  }

  /// 播放成功音效
  Future<void> _playSuccessSound() async {
    try {
      // 尝试播放自定义音效，如果不存在则使用系统音效
      // await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      
      // 临时使用系统音效
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('FeedbackService: 播放成功音效失败 - $e');
    }
  }

  /// 播放失败音效
  Future<void> _playFailSound() async {
    try {
      // await _audioPlayer.play(AssetSource('sounds/fail.mp3'));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('FeedbackService: 播放失败音效失败 - $e');
    }
  }

  /// 播放倒计时音效
  Future<void> _playCountdownSound() async {
    try {
      // await _audioPlayer.play(AssetSource('sounds/countdown.mp3'));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('FeedbackService: 播放倒计时音效失败 - $e');
    }
  }

  /// 播放开始音效
  Future<void> _playStartSound() async {
    try {
      // await _audioPlayer.play(AssetSource('sounds/start.mp3'));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 50));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 50));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('FeedbackService: 播放开始音效失败 - $e');
    }
  }

  /// 播放里程碑音效
  Future<void> _playMilestoneSound() async {
    try {
      // await _audioPlayer.play(AssetSource('sounds/milestone.mp3'));
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 100));
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      print('FeedbackService: 播放里程碑音效失败 - $e');
    }
  }

  /// 短促震动
  Future<void> _vibrateShort() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 50);
      }
    } catch (e) {
      print('FeedbackService: 震动失败 - $e');
    }
  }

  /// 成功震动模式
  Future<void> _vibrateSuccess() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 震动模式：短-停-短-停-长
        await Vibration.vibrate(pattern: [0, 100, 50, 100, 50, 300]);
      }
    } catch (e) {
      print('FeedbackService: 成功震动失败 - $e');
    }
  }

  /// 失败震动模式
  Future<void> _vibrateFail() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 震动模式：长-停-长
        await Vibration.vibrate(pattern: [0, 300, 100, 300]);
      }
    } catch (e) {
      print('FeedbackService: 失败震动失败 - $e');
    }
  }

  /// 开始震动模式
  Future<void> _vibrateStart() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 震动模式：短-短-短-长
        await Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50, 50, 200]);
      }
    } catch (e) {
      print('FeedbackService: 开始震动失败 - $e');
    }
  }

  /// 里程碑震动模式
  Future<void> _vibrateMilestone() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // 震动模式：中-停-中
        await Vibration.vibrate(pattern: [0, 150, 100, 150]);
      }
    } catch (e) {
      print('FeedbackService: 里程碑震动失败 - $e');
    }
  }

  /// 释放资源
  void dispose() {
    _audioPlayer.dispose();
  }
}

