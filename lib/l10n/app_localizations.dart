import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用国际化类
/// 
/// 使用方法：
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.homeTitle);
/// ```
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  /// 获取当前上下文的本地化实例
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// 加载语言文件
  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    
    return true;
  }

  /// 翻译方法
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // ==================== 通用 ====================
  String get appName => translate('appName');
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get back => translate('back');
  String get close => translate('close');
  String get loading => translate('loading');
  String get loadFailed => translate('loadFailed');

  // ==================== 主页 ====================
  String get homeTitle => translate('homeTitle');
  String get goodMorning => translate('goodMorning');
  String get goodAfternoon => translate('goodAfternoon');
  String get goodEvening => translate('goodEvening');
  String get stayActive => translate('stayActive');
  String get currentlyActive => translate('currentlyActive');
  String get criticalSedentaryWarning => translate('criticalSedentaryWarning');
  String get sedentaryReminder => translate('sedentaryReminder');
  String get currentlyStill => translate('currentlyStill');
  String get statusGood => translate('statusGood');
  String get detectingMotion => translate('detectingMotion');
  String get startChallenge => translate('startChallenge');
  String get viewHistory => translate('viewHistory');
  String get sensorTest => translate('sensorTest');
  String get sedentaryStatus => translate('sedentaryStatus');
  String get sedentaryTime => translate('sedentaryTime');
  String get activityRecords => translate('activityRecords');
  String get dailyStats => translate('dailyStats');
  String get todayGoal => translate('todayGoal');
  String get activeDuration => translate('activeDuration');
  String get completedActivities => translate('completedActivities');
  String get noSedentary => translate('noSedentary');
  String get minutes => translate('minutes');
  String get seconds => translate('seconds');
  String get features => translate('features');
  String get sedentaryDetection => translate('sedentaryDetection');
  String get sedentaryDetectionDesc => translate('sedentaryDetectionDesc');
  String get activityRecognition => translate('activityRecognition');
  String get activityRecognitionDesc => translate('activityRecognitionDesc');
  String get dataStatistics => translate('dataStatistics');
  String get dataStatisticsDesc => translate('dataStatisticsDesc');
  String get justStartedStill => translate('justStartedStill');
  String stillForMinutes(int minutes) => translate('stillForMinutes').replaceAll('{minutes}', minutes.toString());
  String sedentaryForMinutes(int minutes) => translate('sedentaryForMinutes').replaceAll('{minutes}', minutes.toString());
  String get sedentaryOverHour => translate('sedentaryOverHour');
  String get keepActive => translate('keepActive');
  String get todayOverview => translate('todayOverview');
  String daysStreak(int days) => translate('daysStreak').replaceAll('{days}', days.toString());
  String get activeTime => translate('activeTime');
  String get quickStart => translate('quickStart');
  String get startActivity => translate('startActivity');
  String get activityHistory => translate('activityHistory');
  String get coreFeatures => translate('coreFeatures');
  String get smartDetection => translate('smartDetection');
  String get smartDetectionDesc => translate('smartDetectionDesc');
  String get interactiveChallenge => translate('interactiveChallenge');
  String get interactiveChallengeDesc => translate('interactiveChallengeDesc');
  String get multimodalFeedback => translate('multimodalFeedback');
  String get multimodalFeedbackDesc => translate('multimodalFeedbackDesc');

  // ==================== 统计页面 ====================
  String get activityStatistics => translate('activityStatistics');
  String get viewHealthData => translate('viewHealthData');
  String get day => translate('day');
  String get week => translate('week');
  String get month => translate('month');
  String periodOverview(String period) => translate('periodOverview').replaceAll('{period}', period);
  String get totalActivity => translate('totalActivity');
  String get completionCount => translate('completionCount');
  String get sedentaryWarning => translate('sedentaryWarning');
  String get noActivityData => translate('noActivityData');
  String get activityTypeDistribution => translate('activityTypeDistribution');
  String timesWithPercentage(int count, String percentage) =>
      translate('timesWithPercentage')
          .replaceAll('{count}', count.toString())
          .replaceAll('{percentage}', percentage);
  String get noActivityRecords => translate('noActivityRecords');
  String get dailyStatistics => translate('dailyStatistics');
  String get achieved => translate('achieved');
  String get notAchieved => translate('notAchieved');
  String get activity => translate('activity');
  String get count => translate('count');
  String get activityRate => translate('activityRate');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get noTimelineData => translate('noTimelineData');
  String get timelineDescription => translate('timelineDescription');
  String get activityTimeline => translate('activityTimeline');
  String showingRecentRecords(int count, int total) =>
      translate('showingRecentRecords')
          .replaceAll('{count}', count.toString())
          .replaceAll('{total}', total.toString());
  String get sedentary => translate('sedentary');
  String get criticalSedentary => translate('criticalSedentary');
  String get interrupted => translate('interrupted');
  String get statisticsTitle => translate('statisticsTitle');
  String get times => translate('times');

  // ==================== 挑战页面 ====================
  String get activityChallenge => translate('activityChallenge');
  String get selectChallenge => translate('selectChallenge');
  String get challengeDescription => translate('challengeDescription');
  String jumpingChallenge(int count) => translate('jumpingChallenge').replaceAll('{count}', count.toString());
  String squattingChallenge(int count) => translate('squattingChallenge').replaceAll('{count}', count.toString());
  String wavingChallenge(int count) => translate('wavingChallenge').replaceAll('{count}', count.toString());
  String shakingChallenge(int count) => translate('shakingChallenge').replaceAll('{count}', count.toString());
  String figureEightChallenge(int count) => translate('figureEightChallenge').replaceAll('{count}', count.toString());
  String get preparingStart => translate('preparingStart');
  String get challenge => translate('challenge');
  String get currentAction => translate('currentAction');
  String get confidence => translate('confidence');
  String get cancelChallenge => translate('cancelChallenge');
  String get congratulations => translate('congratulations');
  String challengeCompleted(String activity) => translate('challengeCompleted').replaceAll('{activity}', activity);
  String get tryAgain => translate('tryAgain');
  String get backToHome => translate('backToHome');

  // ==================== 传感器测试页面 ====================
  String get gyroscope => translate('gyroscope');
  String get accelerometer => translate('accelerometer');
  String get currentState => translate('currentState');
  String get still => translate('still');
  String get moving => translate('moving');
  String get unknown => translate('unknown');
  String get variance => translate('variance');
  String get mean => translate('mean');
  String get stdDeviation => translate('stdDeviation');
  String get xAxis => translate('xAxis');
  String get yAxis => translate('yAxis');
  String get zAxis => translate('zAxis');
  String get magnitudeSquared => translate('magnitudeSquared');
  String get waitingForData => translate('waitingForData');
  String get historicalData => translate('historicalData');
  String get range => translate('range');
  String get bufferInfo => translate('bufferInfo');
  String get accelerometerBuffer => translate('accelerometerBuffer');
  String get gyroscopeBuffer => translate('gyroscopeBuffer');
  String get dataPoints => translate('dataPoints');
  String get bufferSize => translate('bufferSize');
  String get samplingRate => translate('samplingRate');
  String get perSecond => translate('perSecond');
  String get samplingInterval => translate('samplingInterval');
  String get samplingConfig => translate('samplingConfig');
  String get stillFrequency => translate('stillFrequency');
  String get unknownFrequency => translate('unknownFrequency');
  String get movingFrequency => translate('movingFrequency');

  // ==================== 活动历史页面 ====================
  String get recordsWillShowHere => translate('recordsWillShowHere');
  String get loadingFailed => translate('loadingFailed');

  // ==================== 运动类型 ====================
  String get jumping => translate('jumping');
  String get squatting => translate('squatting');
  String get waving => translate('waving');
  String get shaking => translate('shaking');
  String get figureEight => translate('figureEight');
  String get walking => translate('walking');
  String get running => translate('running');
  String get idle => translate('idle');
  String get jumpingDesc => translate('jumpingDesc');
  String get squattingDesc => translate('squattingDesc');
  String get wavingDesc => translate('wavingDesc');
  String get shakingDesc => translate('shakingDesc');
  String get figureEightDesc => translate('figureEightDesc');
  String get walkingDesc => translate('walkingDesc');
  String get runningDesc => translate('runningDesc');
  String get idleDesc => translate('idleDesc');
  String get recognizing => translate('recognizing');

  // ==================== 挑战页面 ====================
  String get challengeTitle => translate('challengeTitle');
  String get selectActivity => translate('selectActivity');
  String get targetCount => translate('targetCount');
  String get currentCount => translate('currentCount');
  String get start => translate('start');
  String get stop => translate('stop');
  String get challengeComplete => translate('challengeComplete');
  String get challengeFailed => translate('challengeFailed');
  String get preparing => translate('preparing');
  String get countdown => translate('countdown');

  // ==================== 设置页面 ====================
  String get settingsTitle => translate('settingsTitle');
  String get settingsSubtitle => translate('settingsSubtitle');
  String get goalSettings => translate('goalSettings');
  String get dailyActivityGoal => translate('dailyActivityGoal');
  String get dailyActivityGoalSubtitle => translate('dailyActivityGoalSubtitle');
  String get reminderInterval => translate('reminderInterval');
  String get reminderIntervalSubtitle => translate('reminderIntervalSubtitle');
  String get notificationSettings => translate('notificationSettings');
  String get enableNotifications => translate('enableNotifications');
  String get enableNotificationsSubtitle => translate('enableNotificationsSubtitle');
  String get enableVibration => translate('enableVibration');
  String get enableVibrationSubtitle => translate('enableVibrationSubtitle');
  String get enableSound => translate('enableSound');
  String get enableSoundSubtitle => translate('enableSoundSubtitle');
  String get activitySettings => translate('activitySettings');
  String get detectionSettings => translate('detectionSettings');
  String get detectionSensitivity => translate('detectionSensitivity');
  String get detectionSensitivitySubtitle => translate('detectionSensitivitySubtitle');
  String get sensitivityLow => translate('sensitivityLow');
  String get sensitivityMedium => translate('sensitivityMedium');
  String get sensitivityHigh => translate('sensitivityHigh');
  String get dlDetection => translate('dlDetection');
  String get dlDetectionSubtitle => translate('dlDetectionSubtitle');
  String get dlEnabled => translate('dlEnabled');
  String get dlDisabled => translate('dlDisabled');
  String get language => translate('language');
  String get languageSubtitle => translate('languageSubtitle');
  String get chinese => translate('chinese');
  String get english => translate('english');
  String get languageChangedZh => translate('languageChangedZh');
  String get languageChangedEn => translate('languageChangedEn');
  String get dataManagement => translate('dataManagement');
  String get trainingData => translate('trainingData');
  String get trainingDataSubtitle => translate('trainingDataSubtitle');
  String get viewUpdateLog => translate('viewUpdateLog');
  String get updateLogTitle => translate('updateLogTitle');
  String get updateLogFailed => translate('updateLogFailed');
  String get about => translate('about');
  String get version => translate('version');
  String get developedBy => translate('developedBy');
  String get developerName => translate('developerName');

  // ==================== 通知消息 ====================
  String get sedentaryWarningChannel => translate('sedentaryWarningChannel');
  String get sedentaryWarningChannelDesc => translate('sedentaryWarningChannelDesc');
  String get sedentaryWarningTitle => translate('sedentaryWarningTitle');
  String sedentaryWarningBody(int minutes) => translate('sedentaryWarningBody').replaceAll('{minutes}', minutes.toString());
  String get sedentaryCriticalChannel => translate('sedentaryCriticalChannel');
  String get sedentaryCriticalChannelDesc => translate('sedentaryCriticalChannelDesc');
  String get sedentaryCriticalTitle => translate('sedentaryCriticalTitle');
  String sedentaryCriticalBody(int minutes) => translate('sedentaryCriticalBody').replaceAll('{minutes}', minutes.toString());
  String sedentaryCriticalBigText(int minutes) => translate('sedentaryCriticalBigText').replaceAll('{minutes}', minutes.toString());
  String get activityDetectedChannel => translate('activityDetectedChannel');
  String get activityDetectedChannelDesc => translate('activityDetectedChannelDesc');
  String get activityDetectedTitle => translate('activityDetectedTitle');
  String get activityDetectedBody => translate('activityDetectedBody');
}

/// 本地化代理
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['zh', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

