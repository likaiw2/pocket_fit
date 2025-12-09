// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'PocketFit';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get save => '保存';

  @override
  String get back => '返回';

  @override
  String get close => '关闭';

  @override
  String get loading => '加载中...';

  @override
  String get loadFailed => '加载失败';

  @override
  String get homeTitle => '首页';

  @override
  String get goodMorning => '早上好';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get goodEvening => '晚上好';

  @override
  String get stayActive => '让我们一起保持活力！';

  @override
  String get currentlyActive => '正在活动中';

  @override
  String get criticalSedentaryWarning => '严重久坐警告！';

  @override
  String get sedentaryReminder => '久坐提醒';

  @override
  String get currentlyStill => '当前静止';

  @override
  String get statusGood => '状态良好';

  @override
  String get detectingMotion => '正在检测您的运动状态...';

  @override
  String get startChallenge => '开始挑战';

  @override
  String get viewHistory => '查看历史';

  @override
  String get sensorTest => '传感器测试';

  @override
  String get sedentaryStatus => '久坐状态';

  @override
  String get sedentaryTime => '久坐时间';

  @override
  String get activityRecords => '运动记录';

  @override
  String get dailyStats => '今日统计';

  @override
  String get todayGoal => '今日目标';

  @override
  String get activeDuration => '活动时长';

  @override
  String get completedActivities => '完成活动';

  @override
  String get noSedentary => '暂无久坐';

  @override
  String get minutes => '分钟';

  @override
  String get seconds => '秒';

  @override
  String get features => '功能介绍';

  @override
  String get sedentaryDetection => '久坐检测';

  @override
  String get sedentaryDetectionDesc => '自动检测久坐时间，及时提醒';

  @override
  String get activityRecognition => '运动识别';

  @override
  String get activityRecognitionDesc => '智能识别多种运动类型';

  @override
  String get dataStatistics => '数据统计';

  @override
  String get dataStatisticsDesc => '详细记录您的运动数据';

  @override
  String get justStartedStill => '刚刚开始静止';

  @override
  String stillForMinutes(Object minutes) {
    return '已静止 $minutes 分钟';
  }

  @override
  String sedentaryForMinutes(Object minutes) {
    return '已久坐 $minutes 分钟，建议活动';
  }

  @override
  String get sedentaryOverHour => '已久坐超过 1 小时！';

  @override
  String get keepActive => '保持活力，继续加油！';

  @override
  String get todayOverview => '今日概览';

  @override
  String daysStreak(Object days) {
    return '$days 天连续';
  }

  @override
  String get activeTime => '活动时间';

  @override
  String get times => '次';

  @override
  String get quickStart => '快速开始';

  @override
  String get startActivity => '开始活动';

  @override
  String get activityHistory => '活动历史';

  @override
  String get coreFeatures => '核心功能';

  @override
  String get smartDetection => '智能检测';

  @override
  String get smartDetectionDesc => '使用手机传感器自动检测久坐行为';

  @override
  String get interactiveChallenge => '互动挑战';

  @override
  String get interactiveChallengeDesc => '完成有趣的动作挑战，保持身体活力';

  @override
  String get multimodalFeedback => '多模态反馈';

  @override
  String get multimodalFeedbackDesc => '声音、震动、视觉多重反馈引导';

  @override
  String get activityStatistics => '活动统计';

  @override
  String get viewHealthData => '查看你的健康数据';

  @override
  String get day => '日';

  @override
  String get week => '周';

  @override
  String get month => '月';

  @override
  String periodOverview(Object period) {
    return '本$period概览';
  }

  @override
  String get totalActivity => '总活动';

  @override
  String get completionCount => '完成次数';

  @override
  String get sedentaryWarning => '久坐提醒';

  @override
  String get noActivityData => '暂无活动数据';

  @override
  String get activityTypeDistribution => '活动类型分布';

  @override
  String timesWithPercentage(Object count, Object percentage) {
    return '$count次 ($percentage%)';
  }

  @override
  String get noActivityRecords => '暂无活动记录';

  @override
  String get dailyStatistics => '每日统计';

  @override
  String get achieved => '✓ 达标';

  @override
  String get notAchieved => '未达标';

  @override
  String get activity => '活动';

  @override
  String get count => '次数';

  @override
  String get activityRate => '活动率';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get noTimelineData => '暂无时间线数据';

  @override
  String get timelineDescription => '完成一些活动挑战后，这里会显示你的活动时间线';

  @override
  String get activityTimeline => '活动时间线';

  @override
  String showingRecentRecords(Object count, Object total) {
    return '显示最近 $count 条记录（共 $total 条）';
  }

  @override
  String get sedentary => '久坐';

  @override
  String get criticalSedentary => '严重久坐';

  @override
  String get interrupted => '已中断';

  @override
  String get activityChallenge => '活动挑战';

  @override
  String get selectChallenge => '选择挑战';

  @override
  String get challengeDescription => '完成指定次数的动作来挑战自己！';

  @override
  String jumpingChallenge(Object count) {
    return '原地跳跃$count次';
  }

  @override
  String squattingChallenge(Object count) {
    return '深蹲$count次';
  }

  @override
  String wavingChallenge(Object count) {
    return '挥手$count次';
  }

  @override
  String shakingChallenge(Object count) {
    return '摇晃手机$count次';
  }

  @override
  String figureEightChallenge(Object count) {
    return '八字形绕圈$count次';
  }

  @override
  String get preparingStart => '准备开始';

  @override
  String get challenge => '挑战';

  @override
  String get currentAction => '当前动作';

  @override
  String get confidence => '置信度';

  @override
  String get cancelChallenge => '取消挑战';

  @override
  String get congratulations => '恭喜！';

  @override
  String challengeCompleted(Object activity) {
    return '恭喜你完成了 $activity 挑战！';
  }

  @override
  String get tryAgain => '再来一次';

  @override
  String get backToHome => '返回首页';

  @override
  String get gyroscope => '陀螺仪 (Gyroscope)';

  @override
  String get accelerometer => '加速度计 (Accelerometer)';

  @override
  String get currentState => '当前状态';

  @override
  String get still => '静止';

  @override
  String get moving => '运动中';

  @override
  String get unknown => '未知';

  @override
  String get variance => '方差';

  @override
  String get mean => '均值';

  @override
  String get stdDeviation => '标准差';

  @override
  String get xAxis => 'X 轴';

  @override
  String get yAxis => 'Y 轴';

  @override
  String get zAxis => 'Z 轴';

  @override
  String get magnitudeSquared => '模² (x²+y²+z²)';

  @override
  String get waitingForData => '等待数据...';

  @override
  String get historicalData => '历史数据';

  @override
  String get range => '范围';

  @override
  String get bufferInfo => '缓冲区信息';

  @override
  String get accelerometerBuffer => '加速度计缓冲区';

  @override
  String get gyroscopeBuffer => '陀螺仪缓冲区';

  @override
  String get dataPoints => '数据点';

  @override
  String get bufferSize => '缓冲区大小';

  @override
  String get samplingRate => '采样率';

  @override
  String get perSecond => '/秒';

  @override
  String get samplingInterval => '采样间隔';

  @override
  String get samplingConfig => '采样频率配置';

  @override
  String get stillFrequency => '静止频率';

  @override
  String get unknownFrequency => '未知频率';

  @override
  String get movingFrequency => '运动频率';

  @override
  String get recordsWillShowHere => '完成挑战后会在这里显示';

  @override
  String get loadingFailed => '加载活动记录失败';

  @override
  String get jumping => '跳跃';

  @override
  String get squatting => '深蹲';

  @override
  String get waving => '挥手';

  @override
  String get shaking => '摇晃';

  @override
  String get figureEight => '八字形';

  @override
  String get walking => '行走';

  @override
  String get running => '跑步';

  @override
  String get idle => '静止';

  @override
  String get jumpingDesc => '原地跳跃';

  @override
  String get squattingDesc => '深蹲运动';

  @override
  String get wavingDesc => '挥动手臂';

  @override
  String get shakingDesc => '摇晃手机';

  @override
  String get figureEightDesc => '手腕八字绕圈';

  @override
  String get walkingDesc => '正常步行';

  @override
  String get runningDesc => '快速跑步';

  @override
  String get idleDesc => '保持静止状态';

  @override
  String get recognizing => '正在识别...';

  @override
  String get challengeTitle => '运动挑战';

  @override
  String get selectActivity => '选择运动类型';

  @override
  String get targetCount => '目标次数';

  @override
  String get currentCount => '当前次数';

  @override
  String get start => '开始';

  @override
  String get stop => '停止';

  @override
  String get challengeComplete => '挑战完成！';

  @override
  String get challengeFailed => '挑战失败';

  @override
  String get preparing => '准备中...';

  @override
  String get countdown => '倒计时';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSubtitle => '个性化你的体验';

  @override
  String get goalSettings => '目标设置';

  @override
  String get dailyActivityGoal => '每日活动目标';

  @override
  String get dailyActivityGoalSubtitle => '每天需要完成的活动时长';

  @override
  String get reminderInterval => '提醒间隔';

  @override
  String get reminderIntervalSubtitle => '久坐多久后提醒';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get enableNotifications => '启用通知';

  @override
  String get enableNotificationsSubtitle => '接收活动提醒';

  @override
  String get enableVibration => '振动反馈';

  @override
  String get enableVibrationSubtitle => '活动时提供触觉反馈';

  @override
  String get enableSound => '声音反馈';

  @override
  String get enableSoundSubtitle => '活动时播放音效';

  @override
  String get activitySettings => '活动设置';

  @override
  String get detectionSettings => '检测设置';

  @override
  String get detectionSensitivity => '检测灵敏度';

  @override
  String get detectionSensitivitySubtitle => '调整运动检测的敏感度';

  @override
  String get sensitivityLow => '低';

  @override
  String get sensitivityMedium => '中';

  @override
  String get sensitivityHigh => '高';

  @override
  String get dlDetection => '深度学习检测';

  @override
  String get dlDetectionSubtitle => '使用AI模型识别运动类型和计数';

  @override
  String get dlEnabled => '已启用深度学习检测 - 使用AI模型识别运动';

  @override
  String get dlDisabled => '已禁用深度学习检测 - 使用传统算法识别运动';

  @override
  String get language => '语言';

  @override
  String get languageSubtitle => '选择应用显示语言';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get languageChangedZh => '语言已切换到中文';

  @override
  String get languageChangedEn => 'Language changed to English';

  @override
  String get dataManagement => '数据管理';

  @override
  String get trainingData => '训练数据采集';

  @override
  String get trainingDataSubtitle => '采集传感器数据用于机器学习';

  @override
  String get viewUpdateLog => '查看更新日志';

  @override
  String get updateLogTitle => '更新日志';

  @override
  String get updateLogFailed => '无法加载更新日志';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get developedBy => '开发者';

  @override
  String get developerName => 'PocketFit Team (now Diode only)';

  @override
  String get statisticsTitle => '统计';

  @override
  String get thisWeek => '本周';

  @override
  String get thisMonth => '本月';

  @override
  String get totalActivities => '总运动次数';

  @override
  String get totalDuration => '总运动时长';

  @override
  String get sedentaryDuration => '久坐时长';

  @override
  String get activityBreakdown => '运动分布';

  @override
  String get noData => '暂无数据';

  @override
  String get hours => '小时';

  @override
  String get trainingDataTitle => '训练数据采集';

  @override
  String get collectData => '采集数据';

  @override
  String get dataList => '数据列表';

  @override
  String get startCollection => '开始采集';

  @override
  String get stopCollection => '停止采集';

  @override
  String get selectActivityType => '选择运动类型';

  @override
  String get targetReps => '目标次数';

  @override
  String get collecting => '采集中...';

  @override
  String get collectionComplete => '采集完成';

  @override
  String get exportData => '导出数据';

  @override
  String get clearAll => '清空所有';

  @override
  String get clearAllConfirm => '确定要清空所有数据吗？';

  @override
  String get dataCollectionInstructions => '数据采集说明';

  @override
  String get dataCollectionStep1 => '• 选择要采集的运动类型';

  @override
  String get dataCollectionStep2 => '• 按照提示完成指定次数的动作';

  @override
  String get dataCollectionStep3 => '• 完成后点击\"结束采集\"按钮';

  @override
  String get dataCollectionStep4 => '• 数据将自动保存为CSV和JSON格式';

  @override
  String get selectActivityTypeTitle => '选择运动类型';

  @override
  String timesRange(Object max, Object min) {
    return '$min-$max次';
  }

  @override
  String collectionSession(Object activity) {
    return '采集 - $activity';
  }

  @override
  String pleaseComplete(Object count) {
    return '请完成 $count 次动作';
  }

  @override
  String get waitingToStart => '等待开始';

  @override
  String get ready => '准备就绪';

  @override
  String get samplingFrequency => '采样频率: 10Hz';

  @override
  String get tipWhenCollecting => '完成动作后，点击下方按钮结束采集';

  @override
  String get tipWhenReady => '准备好后，点击下方按钮开始采集';

  @override
  String get endCollection => '结束采集';

  @override
  String get confirmEndCollection => '确认结束采集';

  @override
  String dataPointsCollected(Object count) {
    return '已采集 $count 个数据点\n确定要结束采集吗？';
  }

  @override
  String get collectionCompleteTitle => '采集完成';

  @override
  String activityTypeLabel(Object activity) {
    return '运动类型: $activity';
  }

  @override
  String targetCountLabel(Object count) {
    return '目标次数: $count';
  }

  @override
  String dataPointsLabel(Object count) {
    return '数据点数: $count';
  }

  @override
  String durationLabel(Object duration) {
    return '持续时间: $duration秒';
  }

  @override
  String get dataSavedMessage => '数据已保存为 CSV 和 JSON 格式';

  @override
  String get done => '完成';

  @override
  String get dataManagementTitle => '数据管理';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get clearAllDataConfirm => '此操作将删除所有已采集的数据，无法恢复！';

  @override
  String get clear => '清除';

  @override
  String get allDataCleared => '所有数据已清除';

  @override
  String get noDataYet => '暂无数据';

  @override
  String get startCollectingData => '开始采集训练数据吧！';

  @override
  String get datasets => '数据集';

  @override
  String get totalFiles => '文件总数';

  @override
  String get metadataFile => '元信息文件';

  @override
  String get csvDataFile => 'CSV 数据文件';

  @override
  String get view => '查看';

  @override
  String get copyPath => '复制路径';

  @override
  String get filePathCopied => '文件路径已复制到剪贴板';

  @override
  String copyFailed(Object error) {
    return '复制失败: $error';
  }

  @override
  String get confirmDelete => '确认删除';

  @override
  String get deleteDatasetConfirm => '确定要删除这个数据集吗？\n（包括元信息和CSV数据文件）';

  @override
  String get datasetDeleted => '数据集已删除';

  @override
  String deleteFailed(Object error) {
    return '删除失败: $error';
  }

  @override
  String get metadata => '元信息';

  @override
  String readFileFailed(Object error) {
    return '读取文件失败: $error';
  }

  @override
  String sedentaryWarningMessage(Object minutes) {
    return '您已久坐 $minutes 分钟，该活动一下了！';
  }

  @override
  String get sedentaryWarningChannel => '久坐提醒';

  @override
  String get sedentaryWarningChannelDesc => '提醒您已经久坐一段时间，建议起身活动';

  @override
  String get sedentaryWarningTitle => '⚠️ 久坐提醒';

  @override
  String sedentaryWarningBody(Object minutes) {
    return '您已经久坐 $minutes 分钟了，建议起身活动一下！';
  }

  @override
  String get sedentaryCritical => '严重久坐警告';

  @override
  String sedentaryCriticalMessage(Object minutes) {
    return '您已久坐 $minutes 分钟！请立即起身活动！';
  }

  @override
  String get sedentaryCriticalChannel => '严重久坐警告';

  @override
  String get sedentaryCriticalChannelDesc => '您已经久坐很长时间，强烈建议立即起身活动';

  @override
  String get sedentaryCriticalTitle => '🚨 严重久坐警告！';

  @override
  String sedentaryCriticalBody(Object minutes) {
    return '您已经久坐超过 $minutes 分钟了！请立即起身活动！';
  }

  @override
  String sedentaryCriticalBigText(Object minutes) {
    return '您已经久坐超过 $minutes 分钟了！长时间久坐对健康不利，请立即起身活动，做一些简单的伸展运动。';
  }

  @override
  String get activityDetectedChannel => '活动检测';

  @override
  String get activityDetectedChannelDesc => '检测到您开始活动';

  @override
  String get activityDetectedTitle => '🟢 活动检测';

  @override
  String get activityDetectedBody => '太棒了！检测到您开始活动，继续保持！';

  @override
  String get activityDetected => '检测到运动';

  @override
  String get countIncreased => '计数增加';

  @override
  String get milestone50 => '已完成50%！';

  @override
  String get milestone75 => '已完成75%！';

  @override
  String get milestone100 => '挑战完成！';

  @override
  String get keepGoing => '继续加油！';

  @override
  String get almostThere => '快要完成了！';

  @override
  String get excellent => '太棒了！';
}
