import 'package:flutter/material.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/services/sensor_service.dart';

class SensorTestPage extends StatefulWidget {
  const SensorTestPage({super.key});

  @override
  State<SensorTestPage> createState() => _SensorTestPageState();
}

class _SensorTestPageState extends State<SensorTestPage> {
  final SensorService _sensorService = SensorService();

  // 当前传感器数据
  SensorData? _currentAccelerometer;
  SensorData? _currentGyroscope;
  MotionStatistics? _currentMotionStats;

  // 数据历史（用于简单的图表显示）
  final List<double> _accelerometerHistory = [];
  final List<double> _gyroscopeHistory = [];
  static const int _historyLength = 50;

  @override
  void initState() {
    super.initState();
    _startSensorService();
  }

  Future<void> _startSensorService() async {
    await _sensorService.start();

    // 监听加速度计数据
    _sensorService.accelerometerStream.listen((data) {
      if (mounted) {
        setState(() {
          _currentAccelerometer = data;
          _accelerometerHistory.add(data.magnitude);
          if (_accelerometerHistory.length > _historyLength) {
            _accelerometerHistory.removeAt(0);
          }
        });
      }
    });

    // 监听陀螺仪数据
    _sensorService.gyroscopeStream.listen((data) {
      if (mounted) {
        setState(() {
          _currentGyroscope = data;
          _gyroscopeHistory.add(data.magnitude);
          if (_gyroscopeHistory.length > _historyLength) {
            _gyroscopeHistory.removeAt(0);
          }
        });
      }
    });

    // 监听运动状态
    _sensorService.motionStateStream.listen((stats) {
      if (mounted) {
        setState(() {
          _currentMotionStats = stats;
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('传感器测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _sensorService.clearBuffers();
              setState(() {
                _accelerometerHistory.clear();
                _gyroscopeHistory.clear();
                _currentAccelerometer = null;
                _currentGyroscope = null;
                _currentMotionStats = null;
              });
            },
          ),
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 运动状态卡片
              _buildMotionStateCard(),
              const SizedBox(height: 20),

              // 陀螺仪数据
              _buildSensorCard(
                title: '陀螺仪 (Gyroscope)',
                icon: Icons.rotate_right,
                color: Colors.purple,
                data: _currentGyroscope,
                history: _gyroscopeHistory,
              ),
              const SizedBox(height: 20),

              // 加速度计数据
              _buildSensorCard(
                title: '加速度计 (Accelerometer)',
                icon: Icons.speed,
                color: Colors.blue,
                data: _currentAccelerometer,
                history: _accelerometerHistory,
              ),
              const SizedBox(height: 20),

              // 缓冲区信息
              _buildBufferInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // 运动状态卡片
  Widget _buildMotionStateCard() {
    final stats = _currentMotionStats;
    final state = stats?.state ?? MotionState.unknown;

    Color stateColor;
    IconData stateIcon;
    String stateText;

    switch (state) {
      case MotionState.still:
        stateColor = Colors.green;
        stateIcon = Icons.airline_seat_recline_normal;
        stateText = '静止';
        break;
      case MotionState.moving:
        stateColor = Colors.orange;
        stateIcon = Icons.directions_run;
        stateText = '运动中';
        break;
      case MotionState.unknown:
        stateColor = Colors.grey;
        stateIcon = Icons.help_outline;
        stateText = '未知';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(stateIcon, color: stateColor, size: 32),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前状态',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stateText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: stateColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (stats != null) ...[
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('方差', stats.variance.toStringAsFixed(2)),
                _buildStatItem('均值', stats.mean.toStringAsFixed(2)),
                _buildStatItem('标准差', stats.stdDeviation.toStringAsFixed(2)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // 传感器数据卡片
  Widget _buildSensorCard({
    required String title,
    required IconData icon,
    required Color color,
    required SensorData? data,
    required List<double> history,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (data != null) ...[
            _buildDataRow('X 轴', data.x, color),
            const SizedBox(height: 8),
            _buildDataRow('Y 轴', data.y, color),
            const SizedBox(height: 8),
            _buildDataRow('Z 轴', data.z, color),
            const SizedBox(height: 8),
            _buildDataRow('模² (x²+y²+z²)', data.magnitudeSquared, color, isBold: true),
            const SizedBox(height: 15),
            // 简单的历史数据可视化
            _buildSimpleChart(history, color),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '等待数据...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, double value, Color color,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value.toStringAsFixed(3),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? color : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  // 简单的图表显示
  Widget _buildSimpleChart(List<double> history, Color color) {
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = history.reduce((a, b) => a > b ? a : b);
    final minValue = history.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和数值范围
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '历史数据',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '范围: ${minValue.toStringAsFixed(2)} - ${maxValue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            size: Size(double.infinity, 80),
            painter: _ChartPainter(
              data: history,
              color: color,
              minValue: minValue,
              maxValue: maxValue,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 显示当前值
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '当前值: ${history.last.toStringAsFixed(3)}',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '数据点: ${history.length}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 缓冲区信息卡片
  Widget _buildBufferInfoCard() {
    final stats = _sensorService.getBufferStats();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Colors.teal, size: 24),
              const SizedBox(width: 10),
              Text(
                '缓冲区信息',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildInfoRow('加速度计缓冲区',
              '${stats['accelerometerBufferSize']} / ${stats['maxBufferSize']}'),
          const SizedBox(height: 8),
          _buildInfoRow('陀螺仪缓冲区',
              '${stats['gyroscopeBufferSize']} / ${stats['maxBufferSize']}'),
          const SizedBox(height: 8),
          _buildInfoRow('当前采样间隔', '${stats['currentSamplingInterval']} ms'),
          const SizedBox(height: 8),
          _buildInfoRow('运动状态', _getMotionStateText(stats['motionState'])),
          const SizedBox(height: 12),
          Text('采样频率配置', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildInfoRow('  静止频率', '${stats['stillInterval']} ms (0.5 Hz)'),
          const SizedBox(height: 8),
          _buildInfoRow('  未知频率', '${stats['unknownInterval']} ms (1 Hz)'),
          const SizedBox(height: 8),
          _buildInfoRow('  运动频率', '${stats['movingInterval']} ms (10 Hz)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  /// 获取运动状态的中文文本
  String _getMotionStateText(String? stateString) {
    if (stateString == null) return '未知';

    if (stateString.contains('still')) {
      return '🟢 静止';
    } else if (stateString.contains('moving')) {
      return '🔴 运动中';
    } else {
      return '⚪ 未知';
    }
  }
}

// 简单的图表绘制器
class _ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double minValue;
  final double maxValue;

  _ChartPainter({
    required this.data,
    required this.color,
    required this.minValue,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    if (data.length == 1) {
      // 只有一个数据点，绘制一个点在中间
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), 4, pointPaint);
      return;
    }

    final range = maxValue - minValue;
    final step = size.width / (data.length - 1);

    // 1. 绘制网格线（水平参考线）
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 绘制3条水平网格线（顶部、中间、底部）
    for (int i = 0; i <= 2; i++) {
      final y = (size.height / 2) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // 2. 绘制折线
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // 3. 绘制数据点（每隔几个点显示一个）
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 只显示最后一个点和它的数值
    if (data.isNotEmpty) {
      final i = data.length - 1;
      final x = i * step;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);

      // 绘制圆点
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // 绘制数值标签
      textPainter.text = TextSpan(
        text: data[i].toStringAsFixed(2),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      // 计算文本位置（避免超出边界）
      double textX = x - textPainter.width / 2;
      double textY = y - textPainter.height - 6;

      // 边界检查
      if (textX < 0) textX = 0;
      if (textX + textPainter.width > size.width) {
        textX = size.width - textPainter.width;
      }
      if (textY < 0) textY = y + 6;

      textPainter.paint(canvas, Offset(textX, textY));
    }

    // 4. 绘制最大值和最小值标记（如果有明显差异）
    if (range > 0.1) {
      // 找到最大值和最小值的位置
      int maxIndex = 0;
      int minIndex = 0;
      for (int i = 0; i < data.length; i++) {
        if (data[i] == maxValue) maxIndex = i;
        if (data[i] == minValue) minIndex = i;
      }

      // 绘制最大值标记
      if (maxIndex != data.length - 1) {
        final x = maxIndex * step;
        final y = size.height - (range > 0 ? (maxValue - minValue) / range : 0.5) * size.height;

        canvas.drawCircle(Offset(x, y), 3, pointPaint);

        textPainter.text = TextSpan(
          text: 'max',
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 9,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height - 4));
      }

      // 绘制最小值标记
      if (minIndex != data.length - 1) {
        final x = minIndex * step;
        final y = size.height;

        canvas.drawCircle(Offset(x, y), 3, pointPaint);

        textPainter.text = TextSpan(
          text: 'min',
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 9,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 2));
      }
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => true;
}

