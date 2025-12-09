import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'PocketFit'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @back.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get back;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  /// No description provided for @homeTitle.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homeTitle;

  /// No description provided for @goodMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好'**
  String get goodEvening;

  /// No description provided for @stayActive.
  ///
  /// In zh, this message translates to:
  /// **'让我们一起保持活力！'**
  String get stayActive;

  /// No description provided for @currentlyActive.
  ///
  /// In zh, this message translates to:
  /// **'正在活动中'**
  String get currentlyActive;

  /// No description provided for @criticalSedentaryWarning.
  ///
  /// In zh, this message translates to:
  /// **'严重久坐警告！'**
  String get criticalSedentaryWarning;

  /// No description provided for @sedentaryReminder.
  ///
  /// In zh, this message translates to:
  /// **'久坐提醒'**
  String get sedentaryReminder;

  /// No description provided for @currentlyStill.
  ///
  /// In zh, this message translates to:
  /// **'当前静止'**
  String get currentlyStill;

  /// No description provided for @statusGood.
  ///
  /// In zh, this message translates to:
  /// **'状态良好'**
  String get statusGood;

  /// No description provided for @detectingMotion.
  ///
  /// In zh, this message translates to:
  /// **'正在检测您的运动状态...'**
  String get detectingMotion;

  /// No description provided for @startChallenge.
  ///
  /// In zh, this message translates to:
  /// **'开始挑战'**
  String get startChallenge;

  /// No description provided for @viewHistory.
  ///
  /// In zh, this message translates to:
  /// **'查看历史'**
  String get viewHistory;

  /// No description provided for @sensorTest.
  ///
  /// In zh, this message translates to:
  /// **'传感器测试'**
  String get sensorTest;

  /// No description provided for @sedentaryStatus.
  ///
  /// In zh, this message translates to:
  /// **'久坐状态'**
  String get sedentaryStatus;

  /// No description provided for @sedentaryTime.
  ///
  /// In zh, this message translates to:
  /// **'久坐时间'**
  String get sedentaryTime;

  /// No description provided for @activityRecords.
  ///
  /// In zh, this message translates to:
  /// **'运动记录'**
  String get activityRecords;

  /// No description provided for @dailyStats.
  ///
  /// In zh, this message translates to:
  /// **'今日统计'**
  String get dailyStats;

  /// No description provided for @todayGoal.
  ///
  /// In zh, this message translates to:
  /// **'今日目标'**
  String get todayGoal;

  /// No description provided for @activeDuration.
  ///
  /// In zh, this message translates to:
  /// **'活动时长'**
  String get activeDuration;

  /// No description provided for @completedActivities.
  ///
  /// In zh, this message translates to:
  /// **'完成活动'**
  String get completedActivities;

  /// No description provided for @noSedentary.
  ///
  /// In zh, this message translates to:
  /// **'暂无久坐'**
  String get noSedentary;

  /// No description provided for @minutes.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get seconds;

  /// No description provided for @features.
  ///
  /// In zh, this message translates to:
  /// **'功能介绍'**
  String get features;

  /// No description provided for @sedentaryDetection.
  ///
  /// In zh, this message translates to:
  /// **'久坐检测'**
  String get sedentaryDetection;

  /// No description provided for @sedentaryDetectionDesc.
  ///
  /// In zh, this message translates to:
  /// **'自动检测久坐时间，及时提醒'**
  String get sedentaryDetectionDesc;

  /// No description provided for @activityRecognition.
  ///
  /// In zh, this message translates to:
  /// **'运动识别'**
  String get activityRecognition;

  /// No description provided for @activityRecognitionDesc.
  ///
  /// In zh, this message translates to:
  /// **'智能识别多种运动类型'**
  String get activityRecognitionDesc;

  /// No description provided for @dataStatistics.
  ///
  /// In zh, this message translates to:
  /// **'数据统计'**
  String get dataStatistics;

  /// No description provided for @dataStatisticsDesc.
  ///
  /// In zh, this message translates to:
  /// **'详细记录您的运动数据'**
  String get dataStatisticsDesc;

  /// No description provided for @justStartedStill.
  ///
  /// In zh, this message translates to:
  /// **'刚刚开始静止'**
  String get justStartedStill;

  /// No description provided for @stillForMinutes.
  ///
  /// In zh, this message translates to:
  /// **'已静止 {minutes} 分钟'**
  String stillForMinutes(Object minutes);

  /// No description provided for @sedentaryForMinutes.
  ///
  /// In zh, this message translates to:
  /// **'已久坐 {minutes} 分钟，建议活动'**
  String sedentaryForMinutes(Object minutes);

  /// No description provided for @sedentaryOverHour.
  ///
  /// In zh, this message translates to:
  /// **'已久坐超过 1 小时！'**
  String get sedentaryOverHour;

  /// No description provided for @keepActive.
  ///
  /// In zh, this message translates to:
  /// **'保持活力，继续加油！'**
  String get keepActive;

  /// No description provided for @todayOverview.
  ///
  /// In zh, this message translates to:
  /// **'今日概览'**
  String get todayOverview;

  /// No description provided for @daysStreak.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天连续'**
  String daysStreak(Object days);

  /// No description provided for @activeTime.
  ///
  /// In zh, this message translates to:
  /// **'活动时间'**
  String get activeTime;

  /// No description provided for @times.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get times;

  /// No description provided for @quickStart.
  ///
  /// In zh, this message translates to:
  /// **'快速开始'**
  String get quickStart;

  /// No description provided for @startActivity.
  ///
  /// In zh, this message translates to:
  /// **'开始活动'**
  String get startActivity;

  /// No description provided for @activityHistory.
  ///
  /// In zh, this message translates to:
  /// **'活动历史'**
  String get activityHistory;

  /// No description provided for @coreFeatures.
  ///
  /// In zh, this message translates to:
  /// **'核心功能'**
  String get coreFeatures;

  /// No description provided for @smartDetection.
  ///
  /// In zh, this message translates to:
  /// **'智能检测'**
  String get smartDetection;

  /// No description provided for @smartDetectionDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用手机传感器自动检测久坐行为'**
  String get smartDetectionDesc;

  /// No description provided for @interactiveChallenge.
  ///
  /// In zh, this message translates to:
  /// **'互动挑战'**
  String get interactiveChallenge;

  /// No description provided for @interactiveChallengeDesc.
  ///
  /// In zh, this message translates to:
  /// **'完成有趣的动作挑战，保持身体活力'**
  String get interactiveChallengeDesc;

  /// No description provided for @multimodalFeedback.
  ///
  /// In zh, this message translates to:
  /// **'多模态反馈'**
  String get multimodalFeedback;

  /// No description provided for @multimodalFeedbackDesc.
  ///
  /// In zh, this message translates to:
  /// **'声音、震动、视觉多重反馈引导'**
  String get multimodalFeedbackDesc;

  /// No description provided for @activityStatistics.
  ///
  /// In zh, this message translates to:
  /// **'活动统计'**
  String get activityStatistics;

  /// No description provided for @viewHealthData.
  ///
  /// In zh, this message translates to:
  /// **'查看你的健康数据'**
  String get viewHealthData;

  /// No description provided for @day.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get day;

  /// No description provided for @week.
  ///
  /// In zh, this message translates to:
  /// **'周'**
  String get week;

  /// No description provided for @month.
  ///
  /// In zh, this message translates to:
  /// **'月'**
  String get month;

  /// No description provided for @periodOverview.
  ///
  /// In zh, this message translates to:
  /// **'本{period}概览'**
  String periodOverview(Object period);

  /// No description provided for @totalActivity.
  ///
  /// In zh, this message translates to:
  /// **'总活动'**
  String get totalActivity;

  /// No description provided for @completionCount.
  ///
  /// In zh, this message translates to:
  /// **'完成次数'**
  String get completionCount;

  /// No description provided for @sedentaryWarning.
  ///
  /// In zh, this message translates to:
  /// **'久坐提醒'**
  String get sedentaryWarning;

  /// No description provided for @noActivityData.
  ///
  /// In zh, this message translates to:
  /// **'暂无活动数据'**
  String get noActivityData;

  /// No description provided for @activityTypeDistribution.
  ///
  /// In zh, this message translates to:
  /// **'活动类型分布'**
  String get activityTypeDistribution;

  /// No description provided for @timesWithPercentage.
  ///
  /// In zh, this message translates to:
  /// **'{count}次 ({percentage}%)'**
  String timesWithPercentage(Object count, Object percentage);

  /// No description provided for @noActivityRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无活动记录'**
  String get noActivityRecords;

  /// No description provided for @dailyStatistics.
  ///
  /// In zh, this message translates to:
  /// **'每日统计'**
  String get dailyStatistics;

  /// No description provided for @achieved.
  ///
  /// In zh, this message translates to:
  /// **'✓ 达标'**
  String get achieved;

  /// No description provided for @notAchieved.
  ///
  /// In zh, this message translates to:
  /// **'未达标'**
  String get notAchieved;

  /// No description provided for @activity.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get activity;

  /// No description provided for @count.
  ///
  /// In zh, this message translates to:
  /// **'次数'**
  String get count;

  /// No description provided for @activityRate.
  ///
  /// In zh, this message translates to:
  /// **'活动率'**
  String get activityRate;

  /// No description provided for @today.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In zh, this message translates to:
  /// **'昨天'**
  String get yesterday;

  /// No description provided for @noTimelineData.
  ///
  /// In zh, this message translates to:
  /// **'暂无时间线数据'**
  String get noTimelineData;

  /// No description provided for @timelineDescription.
  ///
  /// In zh, this message translates to:
  /// **'完成一些活动挑战后，这里会显示你的活动时间线'**
  String get timelineDescription;

  /// No description provided for @activityTimeline.
  ///
  /// In zh, this message translates to:
  /// **'活动时间线'**
  String get activityTimeline;

  /// No description provided for @showingRecentRecords.
  ///
  /// In zh, this message translates to:
  /// **'显示最近 {count} 条记录（共 {total} 条）'**
  String showingRecentRecords(Object count, Object total);

  /// No description provided for @sedentary.
  ///
  /// In zh, this message translates to:
  /// **'久坐'**
  String get sedentary;

  /// No description provided for @criticalSedentary.
  ///
  /// In zh, this message translates to:
  /// **'严重久坐'**
  String get criticalSedentary;

  /// No description provided for @interrupted.
  ///
  /// In zh, this message translates to:
  /// **'已中断'**
  String get interrupted;

  /// No description provided for @activityChallenge.
  ///
  /// In zh, this message translates to:
  /// **'活动挑战'**
  String get activityChallenge;

  /// No description provided for @selectChallenge.
  ///
  /// In zh, this message translates to:
  /// **'选择挑战'**
  String get selectChallenge;

  /// No description provided for @challengeDescription.
  ///
  /// In zh, this message translates to:
  /// **'完成指定次数的动作来挑战自己！'**
  String get challengeDescription;

  /// No description provided for @jumpingChallenge.
  ///
  /// In zh, this message translates to:
  /// **'原地跳跃{count}次'**
  String jumpingChallenge(Object count);

  /// No description provided for @squattingChallenge.
  ///
  /// In zh, this message translates to:
  /// **'深蹲{count}次'**
  String squattingChallenge(Object count);

  /// No description provided for @wavingChallenge.
  ///
  /// In zh, this message translates to:
  /// **'挥手{count}次'**
  String wavingChallenge(Object count);

  /// No description provided for @shakingChallenge.
  ///
  /// In zh, this message translates to:
  /// **'摇晃手机{count}次'**
  String shakingChallenge(Object count);

  /// No description provided for @figureEightChallenge.
  ///
  /// In zh, this message translates to:
  /// **'八字形绕圈{count}次'**
  String figureEightChallenge(Object count);

  /// No description provided for @preparingStart.
  ///
  /// In zh, this message translates to:
  /// **'准备开始'**
  String get preparingStart;

  /// No description provided for @challenge.
  ///
  /// In zh, this message translates to:
  /// **'挑战'**
  String get challenge;

  /// No description provided for @currentAction.
  ///
  /// In zh, this message translates to:
  /// **'当前动作'**
  String get currentAction;

  /// No description provided for @confidence.
  ///
  /// In zh, this message translates to:
  /// **'置信度'**
  String get confidence;

  /// No description provided for @cancelChallenge.
  ///
  /// In zh, this message translates to:
  /// **'取消挑战'**
  String get cancelChallenge;

  /// No description provided for @congratulations.
  ///
  /// In zh, this message translates to:
  /// **'恭喜！'**
  String get congratulations;

  /// No description provided for @challengeCompleted.
  ///
  /// In zh, this message translates to:
  /// **'恭喜你完成了 {activity} 挑战！'**
  String challengeCompleted(Object activity);

  /// No description provided for @tryAgain.
  ///
  /// In zh, this message translates to:
  /// **'再来一次'**
  String get tryAgain;

  /// No description provided for @backToHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get backToHome;

  /// No description provided for @gyroscope.
  ///
  /// In zh, this message translates to:
  /// **'陀螺仪 (Gyroscope)'**
  String get gyroscope;

  /// No description provided for @accelerometer.
  ///
  /// In zh, this message translates to:
  /// **'加速度计 (Accelerometer)'**
  String get accelerometer;

  /// No description provided for @currentState.
  ///
  /// In zh, this message translates to:
  /// **'当前状态'**
  String get currentState;

  /// No description provided for @still.
  ///
  /// In zh, this message translates to:
  /// **'静止'**
  String get still;

  /// No description provided for @moving.
  ///
  /// In zh, this message translates to:
  /// **'运动中'**
  String get moving;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @variance.
  ///
  /// In zh, this message translates to:
  /// **'方差'**
  String get variance;

  /// No description provided for @mean.
  ///
  /// In zh, this message translates to:
  /// **'均值'**
  String get mean;

  /// No description provided for @stdDeviation.
  ///
  /// In zh, this message translates to:
  /// **'标准差'**
  String get stdDeviation;

  /// No description provided for @xAxis.
  ///
  /// In zh, this message translates to:
  /// **'X 轴'**
  String get xAxis;

  /// No description provided for @yAxis.
  ///
  /// In zh, this message translates to:
  /// **'Y 轴'**
  String get yAxis;

  /// No description provided for @zAxis.
  ///
  /// In zh, this message translates to:
  /// **'Z 轴'**
  String get zAxis;

  /// No description provided for @magnitudeSquared.
  ///
  /// In zh, this message translates to:
  /// **'模² (x²+y²+z²)'**
  String get magnitudeSquared;

  /// No description provided for @waitingForData.
  ///
  /// In zh, this message translates to:
  /// **'等待数据...'**
  String get waitingForData;

  /// No description provided for @historicalData.
  ///
  /// In zh, this message translates to:
  /// **'历史数据'**
  String get historicalData;

  /// No description provided for @range.
  ///
  /// In zh, this message translates to:
  /// **'范围'**
  String get range;

  /// No description provided for @bufferInfo.
  ///
  /// In zh, this message translates to:
  /// **'缓冲区信息'**
  String get bufferInfo;

  /// No description provided for @accelerometerBuffer.
  ///
  /// In zh, this message translates to:
  /// **'加速度计缓冲区'**
  String get accelerometerBuffer;

  /// No description provided for @gyroscopeBuffer.
  ///
  /// In zh, this message translates to:
  /// **'陀螺仪缓冲区'**
  String get gyroscopeBuffer;

  /// No description provided for @dataPoints.
  ///
  /// In zh, this message translates to:
  /// **'数据点'**
  String get dataPoints;

  /// No description provided for @bufferSize.
  ///
  /// In zh, this message translates to:
  /// **'缓冲区大小'**
  String get bufferSize;

  /// No description provided for @samplingRate.
  ///
  /// In zh, this message translates to:
  /// **'采样率'**
  String get samplingRate;

  /// No description provided for @perSecond.
  ///
  /// In zh, this message translates to:
  /// **'/秒'**
  String get perSecond;

  /// No description provided for @samplingInterval.
  ///
  /// In zh, this message translates to:
  /// **'采样间隔'**
  String get samplingInterval;

  /// No description provided for @samplingConfig.
  ///
  /// In zh, this message translates to:
  /// **'采样频率配置'**
  String get samplingConfig;

  /// No description provided for @stillFrequency.
  ///
  /// In zh, this message translates to:
  /// **'静止频率'**
  String get stillFrequency;

  /// No description provided for @unknownFrequency.
  ///
  /// In zh, this message translates to:
  /// **'未知频率'**
  String get unknownFrequency;

  /// No description provided for @movingFrequency.
  ///
  /// In zh, this message translates to:
  /// **'运动频率'**
  String get movingFrequency;

  /// No description provided for @recordsWillShowHere.
  ///
  /// In zh, this message translates to:
  /// **'完成挑战后会在这里显示'**
  String get recordsWillShowHere;

  /// No description provided for @loadingFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载活动记录失败'**
  String get loadingFailed;

  /// No description provided for @jumping.
  ///
  /// In zh, this message translates to:
  /// **'跳跃'**
  String get jumping;

  /// No description provided for @squatting.
  ///
  /// In zh, this message translates to:
  /// **'深蹲'**
  String get squatting;

  /// No description provided for @waving.
  ///
  /// In zh, this message translates to:
  /// **'挥手'**
  String get waving;

  /// No description provided for @shaking.
  ///
  /// In zh, this message translates to:
  /// **'摇晃'**
  String get shaking;

  /// No description provided for @figureEight.
  ///
  /// In zh, this message translates to:
  /// **'八字形'**
  String get figureEight;

  /// No description provided for @walking.
  ///
  /// In zh, this message translates to:
  /// **'行走'**
  String get walking;

  /// No description provided for @running.
  ///
  /// In zh, this message translates to:
  /// **'跑步'**
  String get running;

  /// No description provided for @idle.
  ///
  /// In zh, this message translates to:
  /// **'静止'**
  String get idle;

  /// No description provided for @jumpingDesc.
  ///
  /// In zh, this message translates to:
  /// **'原地跳跃'**
  String get jumpingDesc;

  /// No description provided for @squattingDesc.
  ///
  /// In zh, this message translates to:
  /// **'深蹲运动'**
  String get squattingDesc;

  /// No description provided for @wavingDesc.
  ///
  /// In zh, this message translates to:
  /// **'挥动手臂'**
  String get wavingDesc;

  /// No description provided for @shakingDesc.
  ///
  /// In zh, this message translates to:
  /// **'摇晃手机'**
  String get shakingDesc;

  /// No description provided for @figureEightDesc.
  ///
  /// In zh, this message translates to:
  /// **'手腕八字绕圈'**
  String get figureEightDesc;

  /// No description provided for @walkingDesc.
  ///
  /// In zh, this message translates to:
  /// **'正常步行'**
  String get walkingDesc;

  /// No description provided for @runningDesc.
  ///
  /// In zh, this message translates to:
  /// **'快速跑步'**
  String get runningDesc;

  /// No description provided for @idleDesc.
  ///
  /// In zh, this message translates to:
  /// **'保持静止状态'**
  String get idleDesc;

  /// No description provided for @recognizing.
  ///
  /// In zh, this message translates to:
  /// **'正在识别...'**
  String get recognizing;

  /// No description provided for @challengeTitle.
  ///
  /// In zh, this message translates to:
  /// **'运动挑战'**
  String get challengeTitle;

  /// No description provided for @selectActivity.
  ///
  /// In zh, this message translates to:
  /// **'选择运动类型'**
  String get selectActivity;

  /// No description provided for @targetCount.
  ///
  /// In zh, this message translates to:
  /// **'目标次数'**
  String get targetCount;

  /// No description provided for @currentCount.
  ///
  /// In zh, this message translates to:
  /// **'当前次数'**
  String get currentCount;

  /// No description provided for @start.
  ///
  /// In zh, this message translates to:
  /// **'开始'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get stop;

  /// No description provided for @challengeComplete.
  ///
  /// In zh, this message translates to:
  /// **'挑战完成！'**
  String get challengeComplete;

  /// No description provided for @challengeFailed.
  ///
  /// In zh, this message translates to:
  /// **'挑战失败'**
  String get challengeFailed;

  /// No description provided for @preparing.
  ///
  /// In zh, this message translates to:
  /// **'准备中...'**
  String get preparing;

  /// No description provided for @countdown.
  ///
  /// In zh, this message translates to:
  /// **'倒计时'**
  String get countdown;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'个性化你的体验'**
  String get settingsSubtitle;

  /// No description provided for @goalSettings.
  ///
  /// In zh, this message translates to:
  /// **'目标设置'**
  String get goalSettings;

  /// No description provided for @dailyActivityGoal.
  ///
  /// In zh, this message translates to:
  /// **'每日活动目标'**
  String get dailyActivityGoal;

  /// No description provided for @dailyActivityGoalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'每天需要完成的活动时长'**
  String get dailyActivityGoalSubtitle;

  /// No description provided for @reminderInterval.
  ///
  /// In zh, this message translates to:
  /// **'提醒间隔'**
  String get reminderInterval;

  /// No description provided for @reminderIntervalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'久坐多久后提醒'**
  String get reminderIntervalSubtitle;

  /// No description provided for @notificationSettings.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationSettings;

  /// No description provided for @enableNotifications.
  ///
  /// In zh, this message translates to:
  /// **'启用通知'**
  String get enableNotifications;

  /// No description provided for @enableNotificationsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'接收活动提醒'**
  String get enableNotificationsSubtitle;

  /// No description provided for @enableVibration.
  ///
  /// In zh, this message translates to:
  /// **'振动反馈'**
  String get enableVibration;

  /// No description provided for @enableVibrationSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'活动时提供触觉反馈'**
  String get enableVibrationSubtitle;

  /// No description provided for @enableSound.
  ///
  /// In zh, this message translates to:
  /// **'声音反馈'**
  String get enableSound;

  /// No description provided for @enableSoundSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'活动时播放音效'**
  String get enableSoundSubtitle;

  /// No description provided for @activitySettings.
  ///
  /// In zh, this message translates to:
  /// **'活动设置'**
  String get activitySettings;

  /// No description provided for @detectionSettings.
  ///
  /// In zh, this message translates to:
  /// **'检测设置'**
  String get detectionSettings;

  /// No description provided for @detectionSensitivity.
  ///
  /// In zh, this message translates to:
  /// **'检测灵敏度'**
  String get detectionSensitivity;

  /// No description provided for @detectionSensitivitySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'调整运动检测的敏感度'**
  String get detectionSensitivitySubtitle;

  /// No description provided for @sensitivityLow.
  ///
  /// In zh, this message translates to:
  /// **'低'**
  String get sensitivityLow;

  /// No description provided for @sensitivityMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get sensitivityMedium;

  /// No description provided for @sensitivityHigh.
  ///
  /// In zh, this message translates to:
  /// **'高'**
  String get sensitivityHigh;

  /// No description provided for @dlDetection.
  ///
  /// In zh, this message translates to:
  /// **'深度学习检测'**
  String get dlDetection;

  /// No description provided for @dlDetectionSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用AI模型识别运动类型和计数'**
  String get dlDetectionSubtitle;

  /// No description provided for @dlEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已启用深度学习检测 - 使用AI模型识别运动'**
  String get dlEnabled;

  /// No description provided for @dlDisabled.
  ///
  /// In zh, this message translates to:
  /// **'已禁用深度学习检测 - 使用传统算法识别运动'**
  String get dlDisabled;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择应用显示语言'**
  String get languageSubtitle;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageChangedZh.
  ///
  /// In zh, this message translates to:
  /// **'语言已切换到中文'**
  String get languageChangedZh;

  /// No description provided for @languageChangedEn.
  ///
  /// In zh, this message translates to:
  /// **'Language changed to English'**
  String get languageChangedEn;

  /// No description provided for @dataManagement.
  ///
  /// In zh, this message translates to:
  /// **'数据管理'**
  String get dataManagement;

  /// No description provided for @trainingData.
  ///
  /// In zh, this message translates to:
  /// **'训练数据采集'**
  String get trainingData;

  /// No description provided for @trainingDataSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'采集传感器数据用于机器学习'**
  String get trainingDataSubtitle;

  /// No description provided for @viewUpdateLog.
  ///
  /// In zh, this message translates to:
  /// **'查看更新日志'**
  String get viewUpdateLog;

  /// No description provided for @updateLogTitle.
  ///
  /// In zh, this message translates to:
  /// **'更新日志'**
  String get updateLogTitle;

  /// No description provided for @updateLogFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法加载更新日志'**
  String get updateLogFailed;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// No description provided for @developedBy.
  ///
  /// In zh, this message translates to:
  /// **'开发者'**
  String get developedBy;

  /// No description provided for @developerName.
  ///
  /// In zh, this message translates to:
  /// **'PocketFit Team (now Diode only)'**
  String get developerName;

  /// No description provided for @statisticsTitle.
  ///
  /// In zh, this message translates to:
  /// **'统计'**
  String get statisticsTitle;

  /// No description provided for @thisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In zh, this message translates to:
  /// **'本月'**
  String get thisMonth;

  /// No description provided for @totalActivities.
  ///
  /// In zh, this message translates to:
  /// **'总运动次数'**
  String get totalActivities;

  /// No description provided for @totalDuration.
  ///
  /// In zh, this message translates to:
  /// **'总运动时长'**
  String get totalDuration;

  /// No description provided for @sedentaryDuration.
  ///
  /// In zh, this message translates to:
  /// **'久坐时长'**
  String get sedentaryDuration;

  /// No description provided for @activityBreakdown.
  ///
  /// In zh, this message translates to:
  /// **'运动分布'**
  String get activityBreakdown;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// No description provided for @hours.
  ///
  /// In zh, this message translates to:
  /// **'小时'**
  String get hours;

  /// No description provided for @trainingDataTitle.
  ///
  /// In zh, this message translates to:
  /// **'训练数据采集'**
  String get trainingDataTitle;

  /// No description provided for @collectData.
  ///
  /// In zh, this message translates to:
  /// **'采集数据'**
  String get collectData;

  /// No description provided for @dataList.
  ///
  /// In zh, this message translates to:
  /// **'数据列表'**
  String get dataList;

  /// No description provided for @startCollection.
  ///
  /// In zh, this message translates to:
  /// **'开始采集'**
  String get startCollection;

  /// No description provided for @stopCollection.
  ///
  /// In zh, this message translates to:
  /// **'停止采集'**
  String get stopCollection;

  /// No description provided for @selectActivityType.
  ///
  /// In zh, this message translates to:
  /// **'选择运动类型'**
  String get selectActivityType;

  /// No description provided for @targetReps.
  ///
  /// In zh, this message translates to:
  /// **'目标次数'**
  String get targetReps;

  /// No description provided for @collecting.
  ///
  /// In zh, this message translates to:
  /// **'采集中...'**
  String get collecting;

  /// No description provided for @collectionComplete.
  ///
  /// In zh, this message translates to:
  /// **'采集完成'**
  String get collectionComplete;

  /// No description provided for @exportData.
  ///
  /// In zh, this message translates to:
  /// **'导出数据'**
  String get exportData;

  /// No description provided for @clearAll.
  ///
  /// In zh, this message translates to:
  /// **'清空所有'**
  String get clearAll;

  /// No description provided for @clearAllConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空所有数据吗？'**
  String get clearAllConfirm;

  /// No description provided for @dataCollectionInstructions.
  ///
  /// In zh, this message translates to:
  /// **'数据采集说明'**
  String get dataCollectionInstructions;

  /// No description provided for @dataCollectionStep1.
  ///
  /// In zh, this message translates to:
  /// **'• 选择要采集的运动类型'**
  String get dataCollectionStep1;

  /// No description provided for @dataCollectionStep2.
  ///
  /// In zh, this message translates to:
  /// **'• 按照提示完成指定次数的动作'**
  String get dataCollectionStep2;

  /// No description provided for @dataCollectionStep3.
  ///
  /// In zh, this message translates to:
  /// **'• 完成后点击\"结束采集\"按钮'**
  String get dataCollectionStep3;

  /// No description provided for @dataCollectionStep4.
  ///
  /// In zh, this message translates to:
  /// **'• 数据将自动保存为CSV和JSON格式'**
  String get dataCollectionStep4;

  /// No description provided for @selectActivityTypeTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择运动类型'**
  String get selectActivityTypeTitle;

  /// No description provided for @timesRange.
  ///
  /// In zh, this message translates to:
  /// **'{min}-{max}次'**
  String timesRange(Object max, Object min);

  /// No description provided for @collectionSession.
  ///
  /// In zh, this message translates to:
  /// **'采集 - {activity}'**
  String collectionSession(Object activity);

  /// No description provided for @pleaseComplete.
  ///
  /// In zh, this message translates to:
  /// **'请完成 {count} 次动作'**
  String pleaseComplete(Object count);

  /// No description provided for @waitingToStart.
  ///
  /// In zh, this message translates to:
  /// **'等待开始'**
  String get waitingToStart;

  /// No description provided for @ready.
  ///
  /// In zh, this message translates to:
  /// **'准备就绪'**
  String get ready;

  /// No description provided for @samplingFrequency.
  ///
  /// In zh, this message translates to:
  /// **'采样频率: 10Hz'**
  String get samplingFrequency;

  /// No description provided for @tipWhenCollecting.
  ///
  /// In zh, this message translates to:
  /// **'完成动作后，点击下方按钮结束采集'**
  String get tipWhenCollecting;

  /// No description provided for @tipWhenReady.
  ///
  /// In zh, this message translates to:
  /// **'准备好后，点击下方按钮开始采集'**
  String get tipWhenReady;

  /// No description provided for @endCollection.
  ///
  /// In zh, this message translates to:
  /// **'结束采集'**
  String get endCollection;

  /// No description provided for @confirmEndCollection.
  ///
  /// In zh, this message translates to:
  /// **'确认结束采集'**
  String get confirmEndCollection;

  /// No description provided for @dataPointsCollected.
  ///
  /// In zh, this message translates to:
  /// **'已采集 {count} 个数据点\n确定要结束采集吗？'**
  String dataPointsCollected(Object count);

  /// No description provided for @collectionCompleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'采集完成'**
  String get collectionCompleteTitle;

  /// No description provided for @activityTypeLabel.
  ///
  /// In zh, this message translates to:
  /// **'运动类型: {activity}'**
  String activityTypeLabel(Object activity);

  /// No description provided for @targetCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'目标次数: {count}'**
  String targetCountLabel(Object count);

  /// No description provided for @dataPointsLabel.
  ///
  /// In zh, this message translates to:
  /// **'数据点数: {count}'**
  String dataPointsLabel(Object count);

  /// No description provided for @durationLabel.
  ///
  /// In zh, this message translates to:
  /// **'持续时间: {duration}秒'**
  String durationLabel(Object duration);

  /// No description provided for @dataSavedMessage.
  ///
  /// In zh, this message translates to:
  /// **'数据已保存为 CSV 和 JSON 格式'**
  String get dataSavedMessage;

  /// No description provided for @done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get done;

  /// No description provided for @dataManagementTitle.
  ///
  /// In zh, this message translates to:
  /// **'数据管理'**
  String get dataManagementTitle;

  /// No description provided for @clearAllData.
  ///
  /// In zh, this message translates to:
  /// **'清除所有数据'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In zh, this message translates to:
  /// **'此操作将删除所有已采集的数据，无法恢复！'**
  String get clearAllDataConfirm;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @allDataCleared.
  ///
  /// In zh, this message translates to:
  /// **'所有数据已清除'**
  String get allDataCleared;

  /// No description provided for @noDataYet.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noDataYet;

  /// No description provided for @startCollectingData.
  ///
  /// In zh, this message translates to:
  /// **'开始采集训练数据吧！'**
  String get startCollectingData;

  /// No description provided for @datasets.
  ///
  /// In zh, this message translates to:
  /// **'数据集'**
  String get datasets;

  /// No description provided for @totalFiles.
  ///
  /// In zh, this message translates to:
  /// **'文件总数'**
  String get totalFiles;

  /// No description provided for @metadataFile.
  ///
  /// In zh, this message translates to:
  /// **'元信息文件'**
  String get metadataFile;

  /// No description provided for @csvDataFile.
  ///
  /// In zh, this message translates to:
  /// **'CSV 数据文件'**
  String get csvDataFile;

  /// No description provided for @view.
  ///
  /// In zh, this message translates to:
  /// **'查看'**
  String get view;

  /// No description provided for @copyPath.
  ///
  /// In zh, this message translates to:
  /// **'复制路径'**
  String get copyPath;

  /// No description provided for @filePathCopied.
  ///
  /// In zh, this message translates to:
  /// **'文件路径已复制到剪贴板'**
  String get filePathCopied;

  /// No description provided for @copyFailed.
  ///
  /// In zh, this message translates to:
  /// **'复制失败: {error}'**
  String copyFailed(Object error);

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @deleteDatasetConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个数据集吗？\n（包括元信息和CSV数据文件）'**
  String get deleteDatasetConfirm;

  /// No description provided for @datasetDeleted.
  ///
  /// In zh, this message translates to:
  /// **'数据集已删除'**
  String get datasetDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败: {error}'**
  String deleteFailed(Object error);

  /// No description provided for @metadata.
  ///
  /// In zh, this message translates to:
  /// **'元信息'**
  String get metadata;

  /// No description provided for @readFileFailed.
  ///
  /// In zh, this message translates to:
  /// **'读取文件失败: {error}'**
  String readFileFailed(Object error);

  /// No description provided for @sedentaryWarningMessage.
  ///
  /// In zh, this message translates to:
  /// **'您已久坐 {minutes} 分钟，该活动一下了！'**
  String sedentaryWarningMessage(Object minutes);

  /// No description provided for @sedentaryWarningChannel.
  ///
  /// In zh, this message translates to:
  /// **'久坐提醒'**
  String get sedentaryWarningChannel;

  /// No description provided for @sedentaryWarningChannelDesc.
  ///
  /// In zh, this message translates to:
  /// **'提醒您已经久坐一段时间，建议起身活动'**
  String get sedentaryWarningChannelDesc;

  /// No description provided for @sedentaryWarningTitle.
  ///
  /// In zh, this message translates to:
  /// **'⚠️ 久坐提醒'**
  String get sedentaryWarningTitle;

  /// No description provided for @sedentaryWarningBody.
  ///
  /// In zh, this message translates to:
  /// **'您已经久坐 {minutes} 分钟了，建议起身活动一下！'**
  String sedentaryWarningBody(Object minutes);

  /// No description provided for @sedentaryCritical.
  ///
  /// In zh, this message translates to:
  /// **'严重久坐警告'**
  String get sedentaryCritical;

  /// No description provided for @sedentaryCriticalMessage.
  ///
  /// In zh, this message translates to:
  /// **'您已久坐 {minutes} 分钟！请立即起身活动！'**
  String sedentaryCriticalMessage(Object minutes);

  /// No description provided for @sedentaryCriticalChannel.
  ///
  /// In zh, this message translates to:
  /// **'严重久坐警告'**
  String get sedentaryCriticalChannel;

  /// No description provided for @sedentaryCriticalChannelDesc.
  ///
  /// In zh, this message translates to:
  /// **'您已经久坐很长时间，强烈建议立即起身活动'**
  String get sedentaryCriticalChannelDesc;

  /// No description provided for @sedentaryCriticalTitle.
  ///
  /// In zh, this message translates to:
  /// **'🚨 严重久坐警告！'**
  String get sedentaryCriticalTitle;

  /// No description provided for @sedentaryCriticalBody.
  ///
  /// In zh, this message translates to:
  /// **'您已经久坐超过 {minutes} 分钟了！请立即起身活动！'**
  String sedentaryCriticalBody(Object minutes);

  /// No description provided for @sedentaryCriticalBigText.
  ///
  /// In zh, this message translates to:
  /// **'您已经久坐超过 {minutes} 分钟了！长时间久坐对健康不利，请立即起身活动，做一些简单的伸展运动。'**
  String sedentaryCriticalBigText(Object minutes);

  /// No description provided for @activityDetectedChannel.
  ///
  /// In zh, this message translates to:
  /// **'活动检测'**
  String get activityDetectedChannel;

  /// No description provided for @activityDetectedChannelDesc.
  ///
  /// In zh, this message translates to:
  /// **'检测到您开始活动'**
  String get activityDetectedChannelDesc;

  /// No description provided for @activityDetectedTitle.
  ///
  /// In zh, this message translates to:
  /// **'🟢 活动检测'**
  String get activityDetectedTitle;

  /// No description provided for @activityDetectedBody.
  ///
  /// In zh, this message translates to:
  /// **'太棒了！检测到您开始活动，继续保持！'**
  String get activityDetectedBody;

  /// No description provided for @activityDetected.
  ///
  /// In zh, this message translates to:
  /// **'检测到运动'**
  String get activityDetected;

  /// No description provided for @countIncreased.
  ///
  /// In zh, this message translates to:
  /// **'计数增加'**
  String get countIncreased;

  /// No description provided for @milestone50.
  ///
  /// In zh, this message translates to:
  /// **'已完成50%！'**
  String get milestone50;

  /// No description provided for @milestone75.
  ///
  /// In zh, this message translates to:
  /// **'已完成75%！'**
  String get milestone75;

  /// No description provided for @milestone100.
  ///
  /// In zh, this message translates to:
  /// **'挑战完成！'**
  String get milestone100;

  /// No description provided for @keepGoing.
  ///
  /// In zh, this message translates to:
  /// **'继续加油！'**
  String get keepGoing;

  /// No description provided for @almostThere.
  ///
  /// In zh, this message translates to:
  /// **'快要完成了！'**
  String get almostThere;

  /// No description provided for @excellent.
  ///
  /// In zh, this message translates to:
  /// **'太棒了！'**
  String get excellent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
