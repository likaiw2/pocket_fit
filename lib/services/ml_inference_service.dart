import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// ML 推理服务 - 使用深度学习模型识别运动类型和计数
class MLInferenceService {
  static final MLInferenceService _instance = MLInferenceService._internal();
  factory MLInferenceService() => _instance;
  MLInferenceService._internal();

  // TFLite 解释器
  Interpreter? _interpreter;
  
  // 模型元数据
  Map<String, dynamic>? _metadata;
  Map<String, dynamic>? _countingConfig;
  
  // 模型参数
  int _windowSize = 50;
  List<String> _classes = [];
  Map<String, String> _classNames = {};
  
  // 数据缓冲区
  final List<List<double>> _dataBuffer = [];
  
  // 计数相关
  final Map<String, int> _activityCounts = {};
  final Map<String, List<double>> _magnitudeHistory = {};
  String? _currentActivity;
  int _lastPeakIndex = 0;

  /// 初始化 ML 服务
  Future<void> initialize() async {
    try {
      print('MLInferenceService: 开始初始化...');
      
      // 1. 加载模型
      _interpreter = await Interpreter.fromAsset(
        'assets/trained_models/activity_recognition.tflite',
      );
      print('MLInferenceService: 模型加载成功');
      
      // 2. 加载元数据
      final metadataJson = await rootBundle.loadString(
        'assets/trained_models/activity_recognition_metadata.json',
      );
      _metadata = json.decode(metadataJson);
      
      _windowSize = _metadata!['window_size'] ?? 50;
      _classes = List<String>.from(_metadata!['classes'] ?? []);
      _classNames = Map<String, String>.from(_metadata!['class_names'] ?? {});
      
      print('MLInferenceService: 元数据加载成功');
      print('  - 窗口大小: $_windowSize');
      print('  - 运动类型: $_classes');
      
      // 3. 加载计数配置
      final countingConfigJson = await rootBundle.loadString(
        'assets/trained_models/counting_config.json',
      );
      _countingConfig = json.decode(countingConfigJson);
      print('MLInferenceService: 计数配置加载成功');
      
      // 4. 初始化计数器
      for (var activity in _classes) {
        _activityCounts[activity] = 0;
        _magnitudeHistory[activity] = [];
      }
      
      print('MLInferenceService: 初始化完成');
    } catch (e) {
      print('MLInferenceService: 初始化失败 - $e');
      rethrow;
    }
  }

  /// 添加传感器数据
  void addSensorData(double accelX, double accelY, double accelZ,
      double gyroX, double gyroY, double gyroZ) {
    // 添加到缓冲区
    _dataBuffer.add([accelX, accelY, accelZ, gyroX, gyroY, gyroZ]);
    
    // 保持窗口大小
    if (_dataBuffer.length > _windowSize) {
      _dataBuffer.removeAt(0);
    }
  }

  /// 运行推理 - 识别运动类型
  String? predictActivity() {
    if (_interpreter == null || _dataBuffer.length < _windowSize) {
      return null;
    }
    
    try {
      // 准备输入数据 [1, 50, 6]
      var input = List.generate(1, (i) => 
        List.generate(_windowSize, (j) => 
          List<double>.from(_dataBuffer[j])
        )
      );
      
      // 准备输出数据 [1, num_classes]
      var output = List.filled(1, List.filled(_classes.length, 0.0))
          .map((e) => List<double>.from(e))
          .toList();
      
      // 运行推理
      _interpreter!.run(input, output);
      
      // 获取预测结果
      var probabilities = output[0];
      var maxIndex = 0;
      var maxProb = probabilities[0];
      
      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIndex = i;
        }
      }
      
      // 置信度阈值
      if (maxProb > 0.6) {
        _currentActivity = _classes[maxIndex];
        return _currentActivity;
      }
      
      return null;
    } catch (e) {
      print('MLInferenceService: 推理失败 - $e');
      return null;
    }
  }

  /// 计数 - 使用峰值检测
  int countRepetitions(String activityType) {
    if (_countingConfig == null || _dataBuffer.length < 10) {
      return 0;
    }
    
    try {
      // 获取该运动的配置
      var config = _countingConfig!['activities'][activityType];
      if (config == null) return 0;
      
      String primarySensor = config['primary_sensor'];
      double threshold = config['threshold'].toDouble();
      int minDistance = config['min_distance'];

      // 计算传感器幅值
      List<double> magnitudes = [];
      for (var data in _dataBuffer) {
        double magnitude;
        if (primarySensor == 'accelerometer') {
          magnitude = sqrt(data[0] * data[0] + data[1] * data[1] + data[2] * data[2]);
        } else {
          // gyroscope
          magnitude = sqrt(data[3] * data[3] + data[4] * data[4] + data[5] * data[5]);
        }
        magnitudes.add(magnitude);
      }

      // 峰值检测
      int count = 0;
      for (int i = minDistance; i < magnitudes.length - minDistance; i++) {
        // 检查是否为局部最大值
        bool isPeak = true;
        for (int j = i - minDistance; j <= i + minDistance; j++) {
          if (j != i && magnitudes[j] >= magnitudes[i]) {
            isPeak = false;
            break;
          }
        }

        // 检查是否超过阈值
        if (isPeak && magnitudes[i] > threshold) {
          // 避免重复计数
          if (i - _lastPeakIndex >= minDistance) {
            count++;
            _lastPeakIndex = i;
          }
        }
      }

      return count;
    } catch (e) {
      print('MLInferenceService: 计数失败 - $e');
      return 0;
    }
  }

  /// 获取运动类型的中文名称
  String? getActivityName(String? activityType) {
    if (activityType == null) return null;
    return _classNames[activityType];
  }

  /// 重置计数器
  void resetCounter() {
    _activityCounts.clear();
    _magnitudeHistory.clear();
    _lastPeakIndex = 0;
    for (var activity in _classes) {
      _activityCounts[activity] = 0;
      _magnitudeHistory[activity] = [];
    }
  }

  /// 清空数据缓冲区
  void clearBuffer() {
    _dataBuffer.clear();
    _lastPeakIndex = 0;
  }

  /// 获取当前识别的运动类型
  String? get currentActivity => _currentActivity;

  /// 获取支持的运动类型列表
  List<String> get supportedActivities => _classes;

  /// 释放资源
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _dataBuffer.clear();
    _activityCounts.clear();
    _magnitudeHistory.clear();
    print('MLInferenceService: 资源已释放');
  }
}

