// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PocketFit';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get loadFailed => 'Load Failed';

  @override
  String get homeTitle => 'Home';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get goodAfternoon => 'Good Afternoon';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get stayActive => 'Let\'s stay active together!';

  @override
  String get currentlyActive => 'Currently Active';

  @override
  String get criticalSedentaryWarning => 'Critical Sedentary Warning!';

  @override
  String get sedentaryReminder => 'Sedentary Reminder';

  @override
  String get currentlyStill => 'Currently Still';

  @override
  String get statusGood => 'Status Good';

  @override
  String get detectingMotion => 'Detecting your motion status...';

  @override
  String get startChallenge => 'Start Challenge';

  @override
  String get viewHistory => 'View History';

  @override
  String get sensorTest => 'Sensor Test';

  @override
  String get sedentaryStatus => 'Sedentary Status';

  @override
  String get sedentaryTime => 'Sedentary Time';

  @override
  String get activityRecords => 'Activity Records';

  @override
  String get dailyStats => 'Daily Statistics';

  @override
  String get todayGoal => 'Today\'s Goal';

  @override
  String get activeDuration => 'Active Duration';

  @override
  String get completedActivities => 'Completed Activities';

  @override
  String get noSedentary => 'No Sedentary';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'seconds';

  @override
  String get features => 'Features';

  @override
  String get sedentaryDetection => 'Sedentary Detection';

  @override
  String get sedentaryDetectionDesc =>
      'Auto-detect sedentary time with timely reminders';

  @override
  String get activityRecognition => 'Activity Recognition';

  @override
  String get activityRecognitionDesc =>
      'Intelligently recognize various activity types';

  @override
  String get dataStatistics => 'Data Statistics';

  @override
  String get dataStatisticsDesc => 'Detailed records of your activity data';

  @override
  String get justStartedStill => 'Just started being still';

  @override
  String stillForMinutes(Object minutes) {
    return 'Still for $minutes minutes';
  }

  @override
  String sedentaryForMinutes(Object minutes) {
    return 'Sedentary for $minutes minutes, suggest moving';
  }

  @override
  String get sedentaryOverHour => 'Sedentary for over 1 hour!';

  @override
  String get keepActive => 'Keep active, keep going!';

  @override
  String get todayOverview => 'Today\'s Overview';

  @override
  String daysStreak(Object days) {
    return '$days days streak';
  }

  @override
  String get activeTime => 'Active Time';

  @override
  String get times => 'times';

  @override
  String get quickStart => 'Quick Start';

  @override
  String get startActivity => 'Start Activity';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get coreFeatures => 'Core Features';

  @override
  String get smartDetection => 'Smart Detection';

  @override
  String get smartDetectionDesc =>
      'Auto-detect sedentary behavior using phone sensors';

  @override
  String get interactiveChallenge => 'Interactive Challenge';

  @override
  String get interactiveChallengeDesc =>
      'Complete fun action challenges to stay active';

  @override
  String get multimodalFeedback => 'Multimodal Feedback';

  @override
  String get multimodalFeedbackDesc =>
      'Sound, vibration, and visual feedback guidance';

  @override
  String get activityStatistics => 'Activity Statistics';

  @override
  String get viewHealthData => 'View your health data';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String periodOverview(Object period) {
    return 'This $period Overview';
  }

  @override
  String get totalActivity => 'Total Activity';

  @override
  String get completionCount => 'Completion Count';

  @override
  String get sedentaryWarning => 'Sedentary Warning';

  @override
  String get noActivityData => 'No activity data';

  @override
  String get activityTypeDistribution => 'Activity Type Distribution';

  @override
  String timesWithPercentage(Object count, Object percentage) {
    return '$count times ($percentage%)';
  }

  @override
  String get noActivityRecords => 'No Activity Records';

  @override
  String get dailyStatistics => 'Daily Statistics';

  @override
  String get achieved => '✓ Achieved';

  @override
  String get notAchieved => 'Not Achieved';

  @override
  String get activity => 'Activity';

  @override
  String get count => 'Count';

  @override
  String get activityRate => 'Activity Rate';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noTimelineData => 'No timeline data';

  @override
  String get timelineDescription =>
      'Complete some activity challenges and your activity timeline will appear here';

  @override
  String get activityTimeline => 'Activity Timeline';

  @override
  String showingRecentRecords(Object count, Object total) {
    return 'Showing recent $count records (total $total)';
  }

  @override
  String get sedentary => 'Sedentary';

  @override
  String get criticalSedentary => 'Critical Sedentary';

  @override
  String get interrupted => 'Interrupted';

  @override
  String get activityChallenge => 'Activity Challenge';

  @override
  String get selectChallenge => 'Select Challenge';

  @override
  String get challengeDescription =>
      'Complete the specified number of actions to challenge yourself!';

  @override
  String jumpingChallenge(Object count) {
    return 'Jump $count times';
  }

  @override
  String squattingChallenge(Object count) {
    return 'Squat $count times';
  }

  @override
  String wavingChallenge(Object count) {
    return 'Wave $count times';
  }

  @override
  String shakingChallenge(Object count) {
    return 'Shake phone $count times';
  }

  @override
  String figureEightChallenge(Object count) {
    return 'Figure-eight $count times';
  }

  @override
  String get preparingStart => 'Get Ready';

  @override
  String get challenge => 'Challenge';

  @override
  String get currentAction => 'Current Action';

  @override
  String get confidence => 'Confidence';

  @override
  String get cancelChallenge => 'Cancel Challenge';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String challengeCompleted(Object activity) {
    return 'Congratulations on completing the $activity challenge!';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get gyroscope => 'Gyroscope';

  @override
  String get accelerometer => 'Accelerometer';

  @override
  String get currentState => 'Current State';

  @override
  String get still => 'Still';

  @override
  String get moving => 'Moving';

  @override
  String get unknown => 'Unknown';

  @override
  String get variance => 'Variance';

  @override
  String get mean => 'Mean';

  @override
  String get stdDeviation => 'Std Dev';

  @override
  String get xAxis => 'X Axis';

  @override
  String get yAxis => 'Y Axis';

  @override
  String get zAxis => 'Z Axis';

  @override
  String get magnitudeSquared => 'Magnitude² (x²+y²+z²)';

  @override
  String get waitingForData => 'Waiting for data...';

  @override
  String get historicalData => 'Historical Data';

  @override
  String get range => 'Range';

  @override
  String get bufferInfo => 'Buffer Info';

  @override
  String get accelerometerBuffer => 'Accelerometer Buffer';

  @override
  String get gyroscopeBuffer => 'Gyroscope Buffer';

  @override
  String get dataPoints => 'Data Points';

  @override
  String get bufferSize => 'Buffer Size';

  @override
  String get samplingRate => 'Sampling Rate';

  @override
  String get perSecond => '/sec';

  @override
  String get samplingInterval => 'Sampling Interval';

  @override
  String get samplingConfig => 'Sampling Rate Config';

  @override
  String get stillFrequency => 'Still Frequency';

  @override
  String get unknownFrequency => 'Unknown Frequency';

  @override
  String get movingFrequency => 'Moving Frequency';

  @override
  String get recordsWillShowHere =>
      'Records will show here after completing challenges';

  @override
  String get loadingFailed => 'Failed to load activity records';

  @override
  String get jumping => 'Jumping';

  @override
  String get squatting => 'Squatting';

  @override
  String get waving => 'Waving';

  @override
  String get shaking => 'Shaking';

  @override
  String get figureEight => 'Figure Eight';

  @override
  String get walking => 'Walking';

  @override
  String get running => 'Running';

  @override
  String get idle => 'Idle';

  @override
  String get jumpingDesc => 'Jump in place';

  @override
  String get squattingDesc => 'Squat exercise';

  @override
  String get wavingDesc => 'Wave arms';

  @override
  String get shakingDesc => 'Shake phone';

  @override
  String get figureEightDesc => 'Wrist figure-eight motion';

  @override
  String get walkingDesc => 'Normal walking';

  @override
  String get runningDesc => 'Fast running';

  @override
  String get idleDesc => 'Stay still';

  @override
  String get recognizing => 'Recognizing...';

  @override
  String get challengeTitle => 'Activity Challenge';

  @override
  String get selectActivity => 'Select Activity Type';

  @override
  String get targetCount => 'Target Count';

  @override
  String get currentCount => 'Current Count';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get challengeComplete => 'Challenge Complete!';

  @override
  String get challengeFailed => 'Challenge Failed';

  @override
  String get preparing => 'Preparing...';

  @override
  String get countdown => 'Countdown';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Personalize your experience';

  @override
  String get goalSettings => 'Goal Settings';

  @override
  String get dailyActivityGoal => 'Daily Activity Goal';

  @override
  String get dailyActivityGoalSubtitle => 'Daily activity duration target';

  @override
  String get reminderInterval => 'Reminder Interval';

  @override
  String get reminderIntervalSubtitle => 'Remind after sitting for';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get enableNotificationsSubtitle => 'Receive activity reminders';

  @override
  String get enableVibration => 'Vibration Feedback';

  @override
  String get enableVibrationSubtitle =>
      'Provide haptic feedback during activities';

  @override
  String get enableSound => 'Sound Feedback';

  @override
  String get enableSoundSubtitle => 'Play sound effects during activities';

  @override
  String get activitySettings => 'Activity Settings';

  @override
  String get detectionSettings => 'Detection Settings';

  @override
  String get detectionSensitivity => 'Detection Sensitivity';

  @override
  String get detectionSensitivitySubtitle =>
      'Adjust motion detection sensitivity';

  @override
  String get sensitivityLow => 'Low';

  @override
  String get sensitivityMedium => 'Medium';

  @override
  String get sensitivityHigh => 'High';

  @override
  String get dlDetection => 'Deep Learning Detection';

  @override
  String get dlDetectionSubtitle =>
      'Use AI model for activity recognition and counting';

  @override
  String get dlEnabled => 'Deep Learning Detection Enabled - Using AI Model';

  @override
  String get dlDisabled =>
      'Deep Learning Detection Disabled - Using Traditional Algorithm';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Select app display language';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get languageChangedZh => 'Language changed to Chinese';

  @override
  String get languageChangedEn => 'Language changed to English';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get trainingData => 'Training Data Collection';

  @override
  String get trainingDataSubtitle => 'Collect sensor data for machine learning';

  @override
  String get viewUpdateLog => 'View Update Log';

  @override
  String get updateLogTitle => 'Update Log';

  @override
  String get updateLogFailed => 'Failed to load update log';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get developedBy => 'Developed by';

  @override
  String get developerName => 'PocketFit Team (now Diode only)';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get totalActivities => 'Total Activities';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get sedentaryDuration => 'Sedentary Duration';

  @override
  String get activityBreakdown => 'Activity Breakdown';

  @override
  String get noData => 'No Data';

  @override
  String get hours => 'hours';

  @override
  String get trainingDataTitle => 'Training Data Collection';

  @override
  String get collectData => 'Collect Data';

  @override
  String get dataList => 'Data List';

  @override
  String get startCollection => 'Start Collection';

  @override
  String get stopCollection => 'Stop Collection';

  @override
  String get selectActivityType => 'Select Activity Type';

  @override
  String get targetReps => 'Target Reps';

  @override
  String get collecting => 'Collecting...';

  @override
  String get collectionComplete => 'Collection Complete';

  @override
  String get exportData => 'Export Data';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearAllConfirm => 'Are you sure you want to clear all data?';

  @override
  String get dataCollectionInstructions => 'Data Collection Instructions';

  @override
  String get dataCollectionStep1 => '• Select the activity type to collect';

  @override
  String get dataCollectionStep2 =>
      '• Complete the specified number of actions as prompted';

  @override
  String get dataCollectionStep3 =>
      '• Click the \\\"End Collection\\\" button when done';

  @override
  String get dataCollectionStep4 =>
      '• Data will be automatically saved in CSV and JSON formats';

  @override
  String get selectActivityTypeTitle => 'Select Activity Type';

  @override
  String timesRange(Object max, Object min) {
    return '$min-$max times';
  }

  @override
  String collectionSession(Object activity) {
    return 'Collection - $activity';
  }

  @override
  String pleaseComplete(Object count) {
    return 'Please complete $count actions';
  }

  @override
  String get waitingToStart => 'Waiting to Start';

  @override
  String get ready => 'Ready';

  @override
  String get samplingFrequency => 'Sampling Frequency: 10Hz';

  @override
  String get tipWhenCollecting =>
      'After completing the actions, click the button below to end collection';

  @override
  String get tipWhenReady =>
      'When ready, click the button below to start collection';

  @override
  String get endCollection => 'End Collection';

  @override
  String get confirmEndCollection => 'Confirm End Collection';

  @override
  String dataPointsCollected(Object count) {
    return 'Collected $count data points\nAre you sure you want to end collection?';
  }

  @override
  String get collectionCompleteTitle => 'Collection Complete';

  @override
  String activityTypeLabel(Object activity) {
    return 'Activity Type: $activity';
  }

  @override
  String targetCountLabel(Object count) {
    return 'Target Count: $count';
  }

  @override
  String dataPointsLabel(Object count) {
    return 'Data Points: $count';
  }

  @override
  String durationLabel(Object duration) {
    return 'Duration: ${duration}s';
  }

  @override
  String get dataSavedMessage => 'Data saved in CSV and JSON formats';

  @override
  String get done => 'Done';

  @override
  String get dataManagementTitle => 'Data Management';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataConfirm =>
      'This operation will delete all collected data and cannot be undone!';

  @override
  String get clear => 'Clear';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String get noDataYet => 'No Data Yet';

  @override
  String get startCollectingData => 'Start collecting training data!';

  @override
  String get datasets => 'Datasets';

  @override
  String get totalFiles => 'Total Files';

  @override
  String get metadataFile => 'Metadata File';

  @override
  String get csvDataFile => 'CSV Data File';

  @override
  String get view => 'View';

  @override
  String get copyPath => 'Copy Path';

  @override
  String get filePathCopied => 'File path copied to clipboard';

  @override
  String copyFailed(Object error) {
    return 'Copy failed: $error';
  }

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteDatasetConfirm =>
      'Are you sure you want to delete this dataset?\n(Including metadata and CSV data files)';

  @override
  String get datasetDeleted => 'Dataset deleted';

  @override
  String deleteFailed(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get metadata => 'Metadata';

  @override
  String readFileFailed(Object error) {
    return 'Failed to read file: $error';
  }

  @override
  String sedentaryWarningMessage(Object minutes) {
    return 'You\'ve been sitting for $minutes minutes. Time to move!';
  }

  @override
  String get sedentaryWarningChannel => 'Sedentary Reminder';

  @override
  String get sedentaryWarningChannelDesc =>
      'Reminds you when you\'ve been sitting for a while';

  @override
  String get sedentaryWarningTitle => '⚠️ Sedentary Reminder';

  @override
  String sedentaryWarningBody(Object minutes) {
    return 'You\'ve been sitting for $minutes minutes, time to get up and move!';
  }

  @override
  String get sedentaryCritical => 'Critical Sedentary Warning';

  @override
  String sedentaryCriticalMessage(Object minutes) {
    return 'You\'ve been sitting for $minutes minutes! Please get up now!';
  }

  @override
  String get sedentaryCriticalChannel => 'Critical Sedentary Warning';

  @override
  String get sedentaryCriticalChannelDesc =>
      'Strong reminder to get up and move after prolonged sitting';

  @override
  String get sedentaryCriticalTitle => '🚨 Critical Sedentary Warning!';

  @override
  String sedentaryCriticalBody(Object minutes) {
    return 'You\'ve been sitting for over $minutes minutes! Please get up immediately!';
  }

  @override
  String sedentaryCriticalBigText(Object minutes) {
    return 'You\'ve been sitting for over $minutes minutes! Prolonged sitting is harmful to your health. Please get up immediately and do some simple stretching exercises.';
  }

  @override
  String get activityDetectedChannel => 'Activity Detection';

  @override
  String get activityDetectedChannelDesc =>
      'Notifies when activity is detected';

  @override
  String get activityDetectedTitle => '🟢 Activity Detected';

  @override
  String get activityDetectedBody => 'Great! Activity detected, keep it up!';

  @override
  String get activityDetected => 'Activity Detected';

  @override
  String get countIncreased => 'Count Increased';

  @override
  String get milestone50 => '50% Complete!';

  @override
  String get milestone75 => '75% Complete!';

  @override
  String get milestone100 => 'Challenge Complete!';

  @override
  String get keepGoing => 'Keep Going!';

  @override
  String get almostThere => 'Almost There!';

  @override
  String get excellent => 'Excellent!';
}
