import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/services/data_collection_service.dart';
import 'package:pocket_fit/l10n/app_localizations.dart';

/// 数据采集会话页面 - 实际采集数据
class DataCollectionSessionPage extends StatefulWidget {
  final ActivityType activityType;
  final int targetRepetitions;

  const DataCollectionSessionPage({
    super.key,
    required this.activityType,
    required this.targetRepetitions,
  });

  @override
  State<DataCollectionSessionPage> createState() => _DataCollectionSessionPageState();
}

class _DataCollectionSessionPageState extends State<DataCollectionSessionPage> {
  final DataCollectionService _collectionService = DataCollectionService();

  bool _isCollecting = false;
  bool _isReady = false;
  int _dataPointCount = 0;
  StreamSubscription? _collectingSubscription;
  StreamSubscription? _dataPointSubscription;

  @override
  void initState() {
    super.initState();

    // 监听采集状态
    _collectingSubscription = _collectionService.collectingStream.listen((isCollecting) {
      if (mounted) {
        setState(() {
          _isCollecting = isCollecting;
        });
      }
    });

    // 监听数据点计数
    _dataPointSubscription = _collectionService.dataPointCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _dataPointCount = count;
        });
      }
    });

    // 不自动开始采集，等待用户准备
  }

  @override
  void dispose() {
    _collectingSubscription?.cancel();
    _dataPointSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startCollection() async {
    setState(() {
      _isReady = true;
    });
    await _collectionService.startCollection(
      activityType: widget.activityType,
      targetRepetitions: widget.targetRepetitions,
    );
  }

  Future<void> _stopCollection() async {
    final l10n = AppLocalizations.of(context)!;

    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmEndCollection),
        content: Text(l10n.dataPointsCollected(_dataPointCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 停止采集
    final dataSet = await _collectionService.stopCollection();

    if (!mounted) return;

    if (dataSet != null) {
      final l10n = AppLocalizations.of(context)!;

      // 显示成功对话框
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.collectionCompleteTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.activityTypeLabel(dataSet.activityType.getDisplayName(context))),
              Text(l10n.targetCountLabel(dataSet.repetitionCount)),
              Text(l10n.dataPointsLabel(dataSet.dataPoints.length)),
              Text(l10n.durationLabel(dataSet.duration.toStringAsFixed(1))),
              const SizedBox(height: 8),
              Text(
                l10n.dataSavedMessage,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回上一页
              },
              child: Text(l10n.done),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.collectionSession(widget.activityType.getDisplayName(context))),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 运动图标
              Text(
                widget.activityType.emoji,
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 24),

              // 运动名称
              Text(
                widget.activityType.getDisplayName(context),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 目标次数
              Text(
                l10n.pleaseComplete(widget.targetRepetitions),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 48),

              // 采集状态卡片
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // 采集状态指示器
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isCollecting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (_isReady)
                            const Icon(Icons.pause_circle, color: Colors.orange)
                          else
                            const Icon(Icons.stop_circle, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _isCollecting ? l10n.collecting : (_isReady ? l10n.ready : l10n.waitingToStart),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isCollecting ? Colors.green : (_isReady ? Colors.orange : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 数据点计数
                      Text(
                        '$_dataPointCount',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        l10n.dataPoints,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 采样频率提示
                      Text(
                        l10n.samplingFrequency,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // 提示文本
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isCollecting
                          ? l10n.tipWhenCollecting
                          : l10n.tipWhenReady,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // 开始/结束采集按钮
              if (!_isCollecting && !_isReady)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _isReady = true;
                      });
                      _startCollection();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      l10n.startCollection,
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: _isCollecting ? _stopCollection : null,
                    icon: const Icon(Icons.stop),
                    label: Text(
                      l10n.endCollection,
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

