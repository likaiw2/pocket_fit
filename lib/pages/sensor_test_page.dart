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

              // 加速度计数据
              _buildSensorCard(
                title: '加速度计 (Accelerometer)',
                icon: Icons.speed,
                color: Colors.blue,
                data: _currentAccelerometer,
                history: _accelerometerHistory,
              ),
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
            _buildDataRow('模', data.magnitude, color, isBold: true),
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
        Text(
          '历史数据',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            size: Size(double.infinity, 60),
            painter: _ChartPainter(
              data: history,
              color: color,
              minValue: minValue,
              maxValue: maxValue,
            ),
          ),
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
          _buildInfoRow('采样间隔', '${stats['samplingInterval']} ms'),
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

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final range = maxValue - minValue;
    final step = size.width / (data.length - 1);

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

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => true;
}

