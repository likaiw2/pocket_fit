import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/pages/data_collection_session_page.dart';
import 'package:pocket_fit/pages/data_management_page.dart';

/// 数据采集页面 - 选择运动类型
class DataCollectionPage extends StatelessWidget {
  const DataCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练数据采集'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DataManagementPage(),
                ),
              );
            },
            tooltip: '数据管理',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明卡片
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '数据采集说明',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• 选择要采集的运动类型\n'
                        '• 按照提示完成指定次数的动作\n'
                        '• 完成后点击"结束采集"按钮\n'
                        '• 数据将自动保存为CSV和JSON格式',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 运动类型选择
              const Text(
                '选择运动类型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _buildActivityCard(
                      context,
                      type: ActivityType.jumping,
                      minTarget: 10,
                      maxTarget: 30,
                      color: Colors.orange,
                    ),
                    _buildActivityCard(
                      context,
                      type: ActivityType.squatting,
                      minTarget: 10,
                      maxTarget: 30,
                      color: Colors.purple,
                    ),
                    _buildActivityCard(
                      context,
                      type: ActivityType.waving,
                      minTarget: 15,
                      maxTarget: 40,
                      color: Colors.green,
                    ),
                    _buildActivityCard(
                      context,
                      type: ActivityType.shaking,
                      minTarget: 15,
                      maxTarget: 40,
                      color: Colors.red,
                    ),
                    _buildActivityCard(
                      context,
                      type: ActivityType.figureEight,
                      minTarget: 10,
                      maxTarget: 30,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context, {
    required ActivityType type,
    required int minTarget,
    required int maxTarget,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          // 生成随机目标次数
          final random = Random();
          final target = minTarget + random.nextInt(maxTarget - minTarget + 1);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DataCollectionSessionPage(
                activityType: type,
                targetRepetitions: target,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color.withOpacity(0.9),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  type.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 6),
                Text(
                  type.displayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  '$minTarget-$maxTarget次',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

