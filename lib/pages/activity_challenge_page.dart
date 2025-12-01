import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/services/activity_recognition_service.dart';
import 'package:pocket_fit/services/feedback_service.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';

/// 活动挑战页面
class ActivityChallengePage extends StatefulWidget {
  const ActivityChallengePage({super.key});

  @override
  State<ActivityChallengePage> createState() => _ActivityChallengePageState();
}

class _ActivityChallengePageState extends State<ActivityChallengePage> with SingleTickerProviderStateMixin {
  final _recognitionService = ActivityRecognitionService();
  final _feedbackService = FeedbackService();

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  // 订阅
  StreamSubscription<ActivityRecognitionResult>? _activitySubscription;
  StreamSubscription<Map<ActivityType, int>>? _countSubscription;

  // 当前状态
  ActivityType _currentActivity = ActivityType.idle;
  double _currentConfidence = 0.0;
  Map<ActivityType, int> _activityCounts = {};
  
  // 挑战状态
  bool _isChallengeActive = false;
  ActivityType? _challengeType;
  int _challengeTarget = 10;
  int _challengeProgress = 0;
  double _lastMilestoneProgress = 0.0; // 上次里程碑进度（0.0-1.0）

  // 倒计时
  Timer? _countdownTimer;
  int _countdown = 3;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _initializeRecognition();
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    _countSubscription?.cancel();
    _countdownTimer?.cancel();
    _animationController.dispose();
    _recognitionService.stop();
    super.dispose();
  }

  /// 初始化识别服务
  Future<void> _initializeRecognition() async {
    await _recognitionService.start();
    
    // 订阅活动识别结果
    _activitySubscription = _recognitionService.activityStream.listen((result) {
      setState(() {
        _currentActivity = result.activityType;
        _currentConfidence = result.confidence;
      });
    });

    // 订阅活动计数
    _countSubscription = _recognitionService.activityCountStream.listen((counts) {
      setState(() {
        _activityCounts = counts;

        // 更新挑战进度
        if (_isChallengeActive && _challengeType != null) {
          final oldProgress = _challengeProgress;
          _challengeProgress = counts[_challengeType] ?? 0;

          // 检查里程碑（50%, 75%）
          if (oldProgress != _challengeProgress) {
            _checkMilestone();

            // 播放计数动画
            _animationController.forward(from: 0.0);
          }

          // 检查是否完成挑战
          if (_challengeProgress >= _challengeTarget) {
            _completeChallenge();
          }
        }
      });
    });
  }

  /// 开始挑战
  void _startChallenge(ActivityType type, int target) {
    setState(() {
      _challengeType = type;
      _challengeTarget = target;
      _isCountingDown = true;
      _countdown = 3;
      _lastMilestoneProgress = 0;
    });

    // 开始新挑战（会自动重置计数）
    _recognitionService.startChallenge(type);

    // 倒计时
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 倒计时反馈
      _feedbackService.countdownFeedback(_countdown);

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
          _isChallengeActive = true;
          _challengeProgress = 0;
        });

        // 挑战开始反馈
        _feedbackService.challengeStartFeedback();
      }
    });
  }

  /// 检查里程碑
  void _checkMilestone() {
    final progress = _challengeProgress / _challengeTarget;

    // 50% 里程碑
    if (progress >= 0.5 && _lastMilestoneProgress < 0.5) {
      _lastMilestoneProgress = 0.5;
      _feedbackService.milestoneFeedback(0.5);
      _showMilestoneSnackBar('已完成 50%！继续加油！💪');
    }
    // 75% 里程碑
    else if (progress >= 0.75 && _lastMilestoneProgress < 0.75) {
      _lastMilestoneProgress = 0.75;
      _feedbackService.milestoneFeedback(0.75);
      _showMilestoneSnackBar('已完成 75%！快要成功了！🔥');
    }
  }

  /// 显示里程碑提示
  void _showMilestoneSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 完成挑战
  void _completeChallenge() {
    setState(() {
      _isChallengeActive = false;
    });

    // 保存挑战记录
    _recognitionService.completeChallenge();

    // 挑战完成反馈
    _feedbackService.challengeCompleteFeedback();

    // 显示完成对话框
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('🎉 ${l10n.congratulations}', style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.challengeCompleted(_challengeType?.getDisplayName(context) ?? ''),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '${l10n.completionCount}: $_challengeProgress / $_challengeTarget',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _recognitionService.resetCounts();
            },
            child: Text(l10n.tryAgain),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.backToHome),
          ),
        ],
      ),
    );
  }

  /// 取消挑战
  void _cancelChallenge() {
    setState(() {
      _isChallengeActive = false;
      _challengeType = null;
      _countdownTimer?.cancel();
      _isCountingDown = false;
    });

    // 取消挑战也保存记录（如果有进度）
    _recognitionService.completeChallenge();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activityChallenge),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
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
          child: _isCountingDown
              ? _buildCountdownView()
              : _isChallengeActive
                  ? _buildChallengeView()
                  : _buildChallengeSelection(),
        ),
      ),
    );
  }

  /// 倒计时视图
  Widget _buildCountdownView() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.preparingStart,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade700,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '${_challengeType?.getDisplayName(context)} ${l10n.challenge}',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  /// 挑战进行中视图
  Widget _buildChallengeView() {
    final l10n = AppLocalizations.of(context);
    final progress = _challengeProgress / _challengeTarget;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 当前识别的活动
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    l10n.currentAction,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentActivity.emoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _currentActivity.getDisplayName(context),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentConfidence > 0) ...[
                    const SizedBox(height: 5),
                    Text(
                      '${l10n.confidence}: ${(_currentConfidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // 挑战进度
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_challengeType?.getDisplayName(context)} ${l10n.challenge}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // 添加动画效果到计数显示
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Text(
                              '$_challengeProgress / $_challengeTarget',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 添加动画效果到进度条
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          tween: Tween<double>(begin: 0, end: progress),
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 20,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                value >= 1.0 ? Colors.green : Colors.blue.shade700,
                              ),
                            );
                          },
                        ),
                      ),
                      // 进度百分比文字
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // 取消按钮
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _cancelChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.cancelChallenge,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 挑战选择视图
  Widget _buildChallengeSelection() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectChallenge,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.challengeDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),

          _buildChallengeCard(
            type: ActivityType.jumping,
            target: 10,
            description: l10n.jumpingChallenge(10),
            color: Colors.orange,
          ),
          const SizedBox(height: 15),

          _buildChallengeCard(
            type: ActivityType.squatting,
            target: 15,
            description: l10n.squattingChallenge(15),
            color: Colors.purple,
          ),
          const SizedBox(height: 15),

          _buildChallengeCard(
            type: ActivityType.waving,
            target: 20,
            description: l10n.wavingChallenge(20),
            color: Colors.teal,
          ),
          const SizedBox(height: 15),

          _buildChallengeCard(
            type: ActivityType.shaking,
            target: 30,
            description: l10n.shakingChallenge(30),
            color: Colors.pink,
          ),
          const SizedBox(height: 15),

          _buildChallengeCard(
            type: ActivityType.figureEight,
            target: 12,
            description: l10n.figureEightChallenge(12),
            color: Colors.indigo,
          ),
        ],
      ),
    );
  }

  /// 挑战卡片
  Widget _buildChallengeCard({
    required ActivityType type,
    required int target,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _startChallenge(type, target),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.getDisplayName(context),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

