import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pocket_fit/models/sensor_data.dart';
import 'package:pocket_fit/models/training_data.dart';
import 'package:pocket_fit/services/sensor_service.dart';
import 'package:uuid/uuid.dart';

/// 数据采集服务
class DataCollectionService {
  static final DataCollectionService _instance = DataCollectionService._internal();
  factory DataCollectionService() => _instance;
  DataCollectionService._internal();

  final SensorService _sensorService = SensorService();
  final Uuid _uuid = const Uuid();

  // 采集状态
  bool _isCollecting = false;
  ActivityType? _currentActivityType;
  int _targetRepetitions = 0;
  DateTime? _collectionStartTime;
  
  // 数据缓冲区
  final List<SensorDataPoint> _dataBuffer = [];
  SensorData? _latestAccel;
  SensorData? _latestGyro;
  
  // Stream 订阅
  StreamSubscription<SensorData>? _accelSubscription;
  StreamSubscription<SensorData>? _gyroSubscription;

  // 采集状态 Stream
  final StreamController<bool> _collectingController = StreamController<bool>.broadcast();
  Stream<bool> get collectingStream => _collectingController.stream;

  // 数据点计数 Stream
  final StreamController<int> _dataPointCountController = StreamController<int>.broadcast();
  Stream<int> get dataPointCountStream => _dataPointCountController.stream;

  bool get isCollecting => _isCollecting;
  int get dataPointCount => _dataBuffer.length;

  /// 开始采集数据
  Future<void> startCollection({
    required ActivityType activityType,
    required int targetRepetitions,
  }) async {
    if (_isCollecting) {
      print('DataCollectionService: 已经在采集中');
      return;
    }

    print('DataCollectionService: 开始采集 - ${activityType.displayName}, 目标${targetRepetitions}次');

    _isCollecting = true;
    _currentActivityType = activityType;
    _targetRepetitions = targetRepetitions;
    _collectionStartTime = DateTime.now();
    _dataBuffer.clear();
    _latestAccel = null;
    _latestGyro = null;

    // 确保传感器服务运行
    if (!_sensorService.isRunning) {
      await _sensorService.start();
    }

    // 订阅传感器数据（使用运动时的采样频率）
    _accelSubscription = _sensorService.accelerometerStream.listen((data) {
      _latestAccel = data;
      _tryAddDataPoint();
    });

    _gyroSubscription = _sensorService.gyroscopeStream.listen((data) {
      _latestGyro = data;
      _tryAddDataPoint();
    });

    _collectingController.add(true);
    _dataPointCountController.add(0);
  }

  /// 尝试添加数据点（当加速度和陀螺仪数据都有时）
  void _tryAddDataPoint() {
    if (_latestAccel != null && _latestGyro != null) {
      final dataPoint = SensorDataPoint.fromSensorData(
        accel: _latestAccel!,
        gyro: _latestGyro!,
      );
      
      _dataBuffer.add(dataPoint);
      _dataPointCountController.add(_dataBuffer.length);
      
      // 清空缓存，等待下一对数据
      _latestAccel = null;
      _latestGyro = null;
    }
  }

  /// 停止采集并保存数据
  Future<TrainingDataSet?> stopCollection() async {
    if (!_isCollecting) {
      print('DataCollectionService: 没有正在进行的采集');
      return null;
    }

    print('DataCollectionService: 停止采集 - 共采集${_dataBuffer.length}个数据点');

    // 取消订阅
    await _accelSubscription?.cancel();
    await _gyroSubscription?.cancel();
    _accelSubscription = null;
    _gyroSubscription = null;

    // 创建数据集
    final dataSet = TrainingDataSet(
      id: _uuid.v4(),
      collectionTime: _collectionStartTime!,
      activityType: _currentActivityType!,
      repetitionCount: _targetRepetitions,
      dataPoints: List.from(_dataBuffer),
      samplingFrequency: 10, // 运动时的采样频率
    );

    // 保存到文件
    await _saveDataSet(dataSet);

    // 重置状态
    _isCollecting = false;
    _currentActivityType = null;
    _targetRepetitions = 0;
    _collectionStartTime = null;
    _dataBuffer.clear();

    _collectingController.add(false);

    return dataSet;
  }

  /// 保存数据集到文件
  Future<void> _saveDataSet(TrainingDataSet dataSet) async {
    try {
      final directory = await _getDataDirectory();

      // 保存元信息为 TXT
      final metaFile = File('${directory.path}/${dataSet.fileName}_meta.txt');
      await metaFile.writeAsString(_generateMetaInfo(dataSet));
      print('DataCollectionService: 元信息已保存 - ${metaFile.path}');

      // 保存数据为 CSV
      final csvFile = File('${directory.path}/${dataSet.fileName}_data.csv');
      await csvFile.writeAsString(_generateCsvData(dataSet));
      print('DataCollectionService: CSV 数据已保存 - ${csvFile.path}');

    } catch (e) {
      print('DataCollectionService: 保存数据失败 - $e');
    }
  }

  /// 生成元信息文本
  String _generateMetaInfo(TrainingDataSet dataSet) {
    final buffer = StringBuffer();
    buffer.writeln('=== 训练数据集元信息 ===');
    buffer.writeln('');
    buffer.writeln('数据集ID: ${dataSet.id}');
    buffer.writeln('采集时间: ${dataSet.collectionTime.toIso8601String()}');
    buffer.writeln('运动类型: ${dataSet.activityType.displayName} (${dataSet.activityType.name})');
    buffer.writeln('目标次数: ${dataSet.repetitionCount}');
    buffer.writeln('采样频率: ${dataSet.samplingFrequency}Hz');
    buffer.writeln('数据点数: ${dataSet.dataPoints.length}');
    buffer.writeln('持续时间: ${dataSet.duration.toStringAsFixed(2)}秒');
    buffer.writeln('');
    buffer.writeln('数据文件: ${dataSet.fileName}_data.csv');
    buffer.writeln('');
    buffer.writeln('=== 数据格式说明 ===');
    buffer.writeln('CSV 列: timestamp, accelX, accelY, accelZ, gyroX, gyroY, gyroZ');
    buffer.writeln('- timestamp: 时间戳（毫秒）');
    buffer.writeln('- accelX/Y/Z: 加速度计三轴数据（m/s²）');
    buffer.writeln('- gyroX/Y/Z: 陀螺仪三轴数据（rad/s）');
    return buffer.toString();
  }

  /// 生成 CSV 数据（纯数据，无注释）
  String _generateCsvData(TrainingDataSet dataSet) {
    final buffer = StringBuffer();

    // 表头
    buffer.writeln(SensorDataPoint.csvHeader());

    // 数据行
    for (final point in dataSet.dataPoints) {
      buffer.writeln(point.toCsvRow());
    }

    return buffer.toString();
  }

  /// 获取数据存储目录
  Future<Directory> _getDataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${appDir.path}/training_data');

    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    return dataDir;
  }

  /// 获取所有已保存的数据集
  Future<List<FileSystemEntity>> getAllDataFiles() async {
    try {
      final directory = await _getDataDirectory();
      final files = directory.listSync();

      // 按修改时间排序（最新的在前）
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

      return files;
    } catch (e) {
      print('DataCollectionService: 获取数据文件失败 - $e');
      return [];
    }
  }

  /// 获取数据集数量
  Future<int> getDataSetCount() async {
    final files = await getAllDataFiles();
    // 每个数据集有2个文件（JSON和CSV），所以除以2
    return files.where((f) => f.path.endsWith('.json')).length;
  }

  /// 获取数据存储路径（用于显示给用户）
  Future<String> getDataDirectoryPath() async {
    final directory = await _getDataDirectory();
    return directory.path;
  }

  /// 删除所有数据
  Future<void> clearAllData() async {
    try {
      final directory = await _getDataDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
        print('DataCollectionService: 所有数据已清除');
      }
    } catch (e) {
      print('DataCollectionService: 清除数据失败 - $e');
    }
  }

  /// 释放资源
  void dispose() {
    _accelSubscription?.cancel();
    _gyroSubscription?.cancel();
    _collectingController.close();
    _dataPointCountController.close();
  }
}

