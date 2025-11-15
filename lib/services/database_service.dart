import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pocket_fit/models/activity_record.dart';
import 'package:pocket_fit/models/sedentary_record.dart';
import 'package:pocket_fit/models/daily_statistics.dart';
import 'package:pocket_fit/models/sensor_data.dart';

/// 数据库服务
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'pocket_fit.db');

    print('DatabaseService: 初始化数据库 - $path');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    print('DatabaseService: 创建数据库表');

    // 运动记录表
    await db.execute('''
      CREATE TABLE activity_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_type TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        count INTEGER NOT NULL,
        confidence REAL NOT NULL,
        metadata TEXT
      )
    ''');

    // 久坐记录表
    await db.execute('''
      CREATE TABLE sedentary_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        was_interrupted INTEGER NOT NULL,
        interruption_reason TEXT
      )
    ''');

    // 每日统计表
    await db.execute('''
      CREATE TABLE daily_statistics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date INTEGER NOT NULL UNIQUE,
        total_activity_count INTEGER NOT NULL,
        total_activity_duration REAL NOT NULL,
        total_sedentary_duration REAL NOT NULL,
        sedentary_warning_count INTEGER NOT NULL,
        sedentary_critical_count INTEGER NOT NULL,
        activity_breakdown TEXT
      )
    ''');

    // 创建索引
    await db.execute('CREATE INDEX idx_activity_start_time ON activity_records(start_time)');
    await db.execute('CREATE INDEX idx_sedentary_start_time ON sedentary_records(start_time)');
    await db.execute('CREATE INDEX idx_daily_date ON daily_statistics(date)');

    print('DatabaseService: 数据库表创建完成');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('DatabaseService: 升级数据库 - $oldVersion -> $newVersion');
    // 未来版本升级时在这里处理
  }

  // ==================== 运动记录操作 ====================

  /// 插入运动记录
  Future<int> insertActivityRecord(ActivityRecord record) async {
    final db = await database;
    final id = await db.insert('activity_records', record.toMap());
    print('DatabaseService: 插入运动记录 - ID: $id, ${record.activityType.displayName}');
    return id;
  }

  /// 获取运动记录（按时间范围）
  Future<List<ActivityRecord>> getActivityRecords({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startTime != null && endTime != null) {
      whereClause = 'start_time >= ? AND start_time <= ?';
      whereArgs = [startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch];
    } else if (startTime != null) {
      whereClause = 'start_time >= ?';
      whereArgs = [startTime.millisecondsSinceEpoch];
    } else if (endTime != null) {
      whereClause = 'start_time <= ?';
      whereArgs = [endTime.millisecondsSinceEpoch];
    }
    
    final maps = await db.query(
      'activity_records',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'start_time DESC',
    );
    
    return maps.map((map) => ActivityRecord.fromMap(map)).toList();
  }

  /// 删除运动记录
  Future<int> deleteActivityRecord(int id) async {
    final db = await database;
    return await db.delete('activity_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 久坐记录操作 ====================

  /// 插入久坐记录
  Future<int> insertSedentaryRecord(SedentaryRecord record) async {
    final db = await database;
    final id = await db.insert('sedentary_records', record.toMap());
    print('DatabaseService: 插入久坐记录 - ID: $id, 时长: ${record.durationInMinutes.toStringAsFixed(1)}分钟');
    return id;
  }

  /// 获取久坐记录（按时间范围）
  Future<List<SedentaryRecord>> getSedentaryRecords({
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startTime != null && endTime != null) {
      whereClause = 'start_time >= ? AND start_time <= ?';
      whereArgs = [startTime.millisecondsSinceEpoch, endTime.millisecondsSinceEpoch];
    } else if (startTime != null) {
      whereClause = 'start_time >= ?';
      whereArgs = [startTime.millisecondsSinceEpoch];
    } else if (endTime != null) {
      whereClause = 'start_time <= ?';
      whereArgs = [endTime.millisecondsSinceEpoch];
    }
    
    final maps = await db.query(
      'sedentary_records',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'start_time DESC',
    );
    
    return maps.map((map) => SedentaryRecord.fromMap(map)).toList();
  }

  /// 删除久坐记录
  Future<int> deleteSedentaryRecord(int id) async {
    final db = await database;
    return await db.delete('sedentary_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== 每日统计操作 ====================

  /// 插入或更新每日统计
  Future<int> upsertDailyStatistics(DailyStatistics stats) async {
    final db = await database;
    
    // 尝试更新
    final updated = await db.update(
      'daily_statistics',
      stats.toMap(),
      where: 'date = ?',
      whereArgs: [stats.date.millisecondsSinceEpoch],
    );
    
    if (updated > 0) {
      print('DatabaseService: 更新每日统计 - ${stats.date.toString().split(' ')[0]}');
      return updated;
    }
    
    // 如果没有更新，则插入
    final id = await db.insert('daily_statistics', stats.toMap());
    print('DatabaseService: 插入每日统计 - ${stats.date.toString().split(' ')[0]}');
    return id;
  }

  /// 获取每日统计（按日期）
  Future<DailyStatistics?> getDailyStatistics(DateTime date) async {
    final db = await database;
    final normalizedDate = DailyStatistics.normalizeDate(date);
    
    final maps = await db.query(
      'daily_statistics',
      where: 'date = ?',
      whereArgs: [normalizedDate.millisecondsSinceEpoch],
    );
    
    if (maps.isEmpty) return null;
    return DailyStatistics.fromMap(maps.first);
  }

  /// 获取每日统计（按时间范围）
  Future<List<DailyStatistics>> getDailyStatisticsRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    final normalizedStart = DailyStatistics.normalizeDate(startDate);
    final normalizedEnd = DailyStatistics.normalizeDate(endDate);
    
    final maps = await db.query(
      'daily_statistics',
      where: 'date >= ? AND date <= ?',
      whereArgs: [normalizedStart.millisecondsSinceEpoch, normalizedEnd.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => DailyStatistics.fromMap(map)).toList();
  }

  /// 删除每日统计
  Future<int> deleteDailyStatistics(DateTime date) async {
    final db = await database;
    final normalizedDate = DailyStatistics.normalizeDate(date);
    return await db.delete(
      'daily_statistics',
      where: 'date = ?',
      whereArgs: [normalizedDate.millisecondsSinceEpoch],
    );
  }

  // ==================== 清理操作 ====================

  /// 清理旧数据（保留最近N天）
  Future<void> cleanOldData({int keepDays = 90}) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(Duration(days: keepDays));
    final cutoffMillis = cutoffTime.millisecondsSinceEpoch;
    
    final activityDeleted = await db.delete(
      'activity_records',
      where: 'start_time < ?',
      whereArgs: [cutoffMillis],
    );
    
    final sedentaryDeleted = await db.delete(
      'sedentary_records',
      where: 'start_time < ?',
      whereArgs: [cutoffMillis],
    );
    
    final statsDeleted = await db.delete(
      'daily_statistics',
      where: 'date < ?',
      whereArgs: [cutoffMillis],
    );
    
    print('DatabaseService: 清理旧数据 - 活动记录: $activityDeleted, '
        '久坐记录: $sedentaryDeleted, 统计数据: $statsDeleted');
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    print('DatabaseService: 数据库已关闭');
  }
}

