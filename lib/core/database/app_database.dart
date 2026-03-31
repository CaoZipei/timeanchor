import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'tables.dart';
import '../utils/app_logger.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [AppUsageRecords, UserLabels, RecordLabelMappings, DailyStats, Goals, PinnedLabels, GoalTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // 插入预设标签
      await _insertPresetLabels();
    },
    onUpgrade: (m, oldVersion, newVersion) async {
      // 从v1升级到v2：添加launchCount列和totalLaunchCount列
      if (oldVersion == 1) {
        await m.addColumn(appUsageRecords, appUsageRecords.launchCount);
        await m.addColumn(dailyStats, dailyStats.totalLaunchCount);
      }
      // 从v2升级到v3：添加 DailyStats.date 的 UNIQUE 约束
      // SQLite 不支持直接修改列约束，需要重建表
      if (oldVersion == 2) {
        print('🔄 Migrating from v2 to v3: Fixing DailyStats date uniqueness...');
        // 备份旧数据
        final oldData = await select(dailyStats).get();
        
        // 删除旧表
        await m.drop(dailyStats);
        
        // 创建新表（带 UNIQUE 约束）
        await m.createAll();
        
        // 恢复数据（但要去重，只保留最新的记录）
        final uniqueData = <String, DailyStat>{};
        for (final stat in oldData) {
          final dateKey = DateFormat('yyyy-MM-dd').format(stat.date);
          if (!uniqueData.containsKey(dateKey) || stat.updatedAt.isAfter(uniqueData[dateKey]!.updatedAt)) {
            uniqueData[dateKey] = stat;
          }
        }
        
        // 批量插入
        for (final stat in uniqueData.values) {
          await into(dailyStats).insertOnConflictUpdate(
            DailyStatsCompanion(
              date: Value(stat.date),
              totalScreenTime: Value(stat.totalScreenTime),
              effectiveTime: Value(stat.effectiveTime),
              entertainTime: Value(stat.entertainTime),
              unlabeledTime: Value(stat.unlabeledTime),
              appCount: Value(stat.appCount),
              totalLaunchCount: Value(stat.totalLaunchCount),
              updatedAt: Value(stat.updatedAt),
            ),
          );
        }
        AppLogger.info('Migration complete: ${uniqueData.length} unique daily stats preserved', 'DB');
      }
      if (oldVersion == 3) {
        AppLogger.info('Migrating from v3 to v4: Adding goalId column and Goals table...', 'DB');
        await m.addColumn(appUsageRecords, appUsageRecords.goalId);
        await m.create(goals);
        AppLogger.info('Migration complete: goalId column and Goals table added', 'DB');
      }
      if (oldVersion == 4) {
        AppLogger.info('Migrating from v4 to v5: Adding PinnedLabels table...', 'DB');
        await m.create(pinnedLabels);
        AppLogger.info('Migration complete: PinnedLabels table added', 'DB');
      }
      if (oldVersion == 5) {
        AppLogger.info('Migrating from v5 to v6: Adding GoalTemplates table...', 'DB');
        await m.create(goalTemplates);
        AppLogger.info('Migration complete: GoalTemplates table added', 'DB');
      }
      if (oldVersion == 6) {
        AppLogger.info('Migrating from v6 to v7: Adding completed and userNote columns...', 'DB');
        await m.addColumn(goals, goals.completed);
        await m.addColumn(goals, goals.userNote);
        AppLogger.info('Migration complete: completed and userNote columns added', 'DB');
      }
      if (oldVersion == 7) {
        AppLogger.info('Migrating from v7 to v8: Adding aiReviewText and aiReviewFeedback columns...', 'DB');
        await m.addColumn(goals, goals.aiReviewText);
        await m.addColumn(goals, goals.aiReviewFeedback);
        AppLogger.info('Migration complete: aiReviewText and aiReviewFeedback columns added', 'DB');
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'looksee_db');
  }

  // ===== 预设标签 =====
  Future<void> _insertPresetLabels() async {
    final presets = [
      UserLabelsCompanion.insert(
        name: '学习',
        emoji: '📚',
        color: 0xFF4A90D9,
        isPreset: const Value(true),
        isEffective: const Value(true),
        sortOrder: const Value(0),
      ),
      UserLabelsCompanion.insert(
        name: '工作',
        emoji: '💻',
        color: 0xFF7C4DFF,
        isPreset: const Value(true),
        isEffective: const Value(true),
        sortOrder: const Value(1),
      ),
      UserLabelsCompanion.insert(
        name: '网课',
        emoji: '🎓',
        color: 0xFF00ACC1,
        isPreset: const Value(true),
        isEffective: const Value(true),
        sortOrder: const Value(2),
      ),
      UserLabelsCompanion.insert(
        name: '运动',
        emoji: '🏃',
        color: 0xFF43A047,
        isPreset: const Value(true),
        isEffective: const Value(true),
        sortOrder: const Value(3),
      ),
      UserLabelsCompanion.insert(
        name: '休息',
        emoji: '😴',
        color: 0xFF78909C,
        isPreset: const Value(true),
        isEffective: const Value(false),
        sortOrder: const Value(4),
      ),
      UserLabelsCompanion.insert(
        name: '娱乐',
        emoji: '🎮',
        color: 0xFFFF7043,
        isPreset: const Value(true),
        isEffective: const Value(false),
        sortOrder: const Value(5),
      ),
      UserLabelsCompanion.insert(
        name: '社交',
        emoji: '💬',
        color: 0xFFEC407A,
        isPreset: const Value(true),
        isEffective: const Value(false),
        sortOrder: const Value(6),
      ),
      UserLabelsCompanion.insert(
        name: '购物',
        emoji: '🛒',
        color: 0xFFFFB300,
        isPreset: const Value(true),
        isEffective: const Value(false),
        sortOrder: const Value(7),
      ),
      UserLabelsCompanion.insert(
        name: '刷视频',
        emoji: '📺',
        color: 0xFFFF5252,
        isPreset: const Value(true),
        isEffective: const Value(false),
        sortOrder: const Value(8),
      ),
      UserLabelsCompanion.insert(
        name: '其他',
        emoji: '✨',
        color: 0xFF9E9E9E,
        isPreset: const Value(true),
        isEffective: const Value(false),
        sortOrder: const Value(9),
      ),
    ];
    await batch((b) => b.insertAll(userLabels, presets));
  }

  // ===== 使用记录 CRUD =====

  /// 获取所有记录（用于数据导出）
  Future<List<AppUsageRecord>> getAllRecords() {
    return (select(appUsageRecords)
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  Future<List<AppUsageRecord>> getRecordsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appUsageRecords)
      ..where((t) => t.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  /// 只返回 UsageStats 来源的记录（goalId == null）
  /// 用于时间轴展示和增量同步逻辑，避免与目标监控记录混淆
  Future<List<AppUsageRecord>> getUsageStatsRecordsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(appUsageRecords)
      ..where((t) => t.date.isBetweenValues(start, end) & t.goalId.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  Future<void> clearRecordsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    await (delete(appUsageRecords)
      ..where((t) => t.date.isBetweenValues(start, end)))
        .go();
    AppLogger.debug('Cleared records for ${date.toIso8601String()}', 'DB');
  }

  Future<int> insertRecord(AppUsageRecordsCompanion record) =>
      into(appUsageRecords).insert(record);

  /// ✅ 改进：插入前检查重复，避免相同的 startTime 和 endTime 被重复插入
  Future<void> insertRecords(List<AppUsageRecordsCompanion> records) async {
    if (records.isEmpty) return;
    
    // 只查 UsageStats 来源记录（goalId == null）做去重检查
    // 避免目标监控记录（goalId != null）干扰去重逻辑
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final existingRecords = await getUsageStatsRecordsByDate(startOfDay);
    
    // 构建去重集合
    final existingKey = <String>{};
    for (final r in existingRecords) {
      // 使用 packageName + startTime + endTime 作为唯一标识
      existingKey.add('${r.packageName}::${r.startTime}::${r.endTime}');
    }
    
    // 筛选出不重复的新记录
    final uniqueRecords = <AppUsageRecordsCompanion>[];
    for (final r in records) {
      final key = '${r.packageName.value}::${r.startTime.value}::${r.endTime.value}';
      if (!existingKey.contains(key)) {
        uniqueRecords.add(r);
        existingKey.add(key); // 添加到去重集合，防止同一批内重复
      } else {
        AppLogger.debug('Skipping duplicate record: $key', 'DB');
      }
    }
    
    if (uniqueRecords.isNotEmpty) {
      await batch((b) => b.insertAll(appUsageRecords, uniqueRecords));
      AppLogger.debug('Inserted ${uniqueRecords.length}/${records.length} records (${records.length - uniqueRecords.length} duplicates skipped)', 'DB');
    } else {
      AppLogger.debug('All records are duplicates, skipped', 'DB');
    }
  }

  // ===== 标签 CRUD =====
  Future<List<UserLabel>> getAllLabels() =>
      (select(userLabels)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();

  Stream<List<UserLabel>> watchAllLabels() =>
      (select(userLabels)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).watch();

  Future<int> insertLabel(UserLabelsCompanion label) =>
      into(userLabels).insert(label);

  Future<bool> updateLabel(UserLabel label) =>
      update(userLabels).replace(label);

  Future<int> deleteLabel(int id) =>
      (delete(userLabels)..where((t) => t.id.equals(id))).go();

  // ===== 标签关联 =====
  Future<int> tagRecord({
    required int recordId,
    required int labelId,
    String? note,
  }) async {
    // ✅ 先删除该记录的所有旧标签（一个记录只能有一个标签）
    await (delete(recordLabelMappings)
      ..where((t) => t.recordId.equals(recordId)))
        .go();
    
    // ✅ 然后插入新标签
    return into(recordLabelMappings).insert(
      RecordLabelMappingsCompanion.insert(
        recordId: recordId,
        labelId: labelId,
        note: Value(note),
        taggedAt: DateTime.now(),
      ),
    );
  }

  Future<List<RecordLabelMapping>> getLabelsByRecord(int recordId) {
    return (select(recordLabelMappings)
      ..where((t) => t.recordId.equals(recordId)))
        .get();
  }

  /// 批量查询多个记录的标签映射（解决 N+1 查询问题）
  Future<List<RecordLabelMapping>> getAllLabelMappingsByRecordIds(List<int> recordIds) {
    if (recordIds.isEmpty) return Future.value([]);
    return (select(recordLabelMappings)
      ..where((t) => t.recordId.isIn(recordIds)))
        .get();
  }

  /// 批量查询指定日期内所有记录的标签映射(解决N+1查询问题)
  Future<List<RecordLabelMapping>> getAllLabelMappingsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final rows = await (select(recordLabelMappings).join([
      innerJoin(appUsageRecords, appUsageRecords.id.equalsExp(recordLabelMappings.recordId)),
    ])
      ..where(appUsageRecords.startTime.isBetweenValues(
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      )))
        .get();

    return rows.map((row) => row.readTable(recordLabelMappings)).toList();
  }

  // ===== 统计 =====
  // 获取当日统计数据（返回所有标签的时长分配）
  Future<Map<String, int>> getDurationByLabel(DateTime date) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      // ✅ 只统计 UsageStats 来源记录（goalId == null），避免目标监控记录重复计入时长
      final allRecords = await (select(appUsageRecords)
        ..where((t) => t.date.isBetweenValues(start, end) & t.goalId.isNull()))
          .get();

      if (allRecords.isEmpty) {
        AppLogger.debug('No records for ${date.toIso8601String()}', 'DB');
        return {};
      }

      AppLogger.debug('Found ${allRecords.length} records for ${date.toIso8601String()}', 'DB');

      // 获取已打标签的记录
      final labeledMappings = await (select(recordLabelMappings).join([
        innerJoin(userLabels, userLabels.id.equalsExp(recordLabelMappings.labelId)),
      ])
        ..where(recordLabelMappings.recordId.isIn(allRecords.map((r) => r.id).toList())))
          .get();

      final result = <String, int>{};
      final labeledRecordIds = <int>{};

      AppLogger.debug('Found ${labeledMappings.length} label mappings', 'DB');

      // 统计已打标签的时长（只取每个记录的第一个标签）
      for (final row in labeledMappings) {
        final label = row.readTable(userLabels);
        final mapping = row.readTable(recordLabelMappings);
        
        // ✅ 跳过已计算过的记录（防止多标签重复计算）
        if (labeledRecordIds.contains(mapping.recordId)) {
          continue;
        }
        labeledRecordIds.add(mapping.recordId);
        
        final record = allRecords.firstWhere((r) => r.id == mapping.recordId);
        result[label.name] = (result[label.name] ?? 0) + record.duration;
      }

      // 统计未打标签的时长放入"其他"
      final unlabeledDuration = allRecords
          .where((r) => !labeledRecordIds.contains(r.id))
          .fold(0, (s, r) => s + r.duration);
      if (unlabeledDuration > 0) {
        result['其他'] = (result['其他'] ?? 0) + unlabeledDuration;
      }

      AppLogger.debug('getDurationByLabel result: $result', 'DB');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error in getDurationByLabel', e, stackTrace, 'DB');
      return {};
    }
  }

  Future<List<DailyStat>> getDailyStatsRange(DateTime from, DateTime to) {
    return (select(dailyStats)
      ..where((t) => t.date.isBetweenValues(from, to))
      ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<void> upsertDailyStat(DailyStatsCompanion stat) async {
    // 先删除同一天的旧记录，再插入新记录
    if (stat.date.value != null) {
      await (delete(dailyStats)
        ..where((t) => t.date.equals(stat.date.value!))
      ).go();
    }
    await into(dailyStats).insert(stat);
  }

  // 根据当日 AppUsageRecords 和 RecordLabelMappings 重新计算并写入 DailyStats
  Future<void> refreshDailyStat(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    // 当日所有记录
    final records = await (select(appUsageRecords)
      ..where((t) => t.date.isBetweenValues(start, end)))
        .get();

    if (records.isEmpty) return;

    final totalScreenTime = records.fold(0, (s, r) => s + r.duration);
    final totalLaunchCount = records.fold(0, (s, r) => s + r.launchCount); // ✅ 计算总启动次数
    final appCount = records.map((r) => r.packageName).toSet().length;

    // 已打标签的记录 ID
    final mappings = await (select(recordLabelMappings).join([
      innerJoin(userLabels, userLabels.id.equalsExp(recordLabelMappings.labelId)),
    ])
      ..where(recordLabelMappings.recordId.isIn(records.map((r) => r.id).toList())))
        .get();

    int effectiveTime = 0;
    int entertainTime = 0;
    final labeledRecordIds = <int>{};

    for (final row in mappings) {
      final label = row.readTable(userLabels);
      final mapping = row.readTable(recordLabelMappings);
      // ✅ 如果找不到对应记录（数据不一致），跳过而不是用 records.first 兜底
      final matchingRecords = records.where((r) => r.id == mapping.recordId).toList();
      if (matchingRecords.isEmpty) continue;
      final record = matchingRecords.first;
      labeledRecordIds.add(mapping.recordId);
      if (label.isEffective) {
        effectiveTime += record.duration;
      } else if (label.name == '娱乐' || label.name == '刷视频') {
        entertainTime += record.duration;
      }
    }

    final unlabeledTime = records
        .where((r) => !labeledRecordIds.contains(r.id))
        .fold(0, (s, r) => s + r.duration);

    await upsertDailyStat(DailyStatsCompanion.insert(
      date: start,
      totalScreenTime: totalScreenTime,
      effectiveTime: effectiveTime,
      entertainTime: entertainTime,
      unlabeledTime: unlabeledTime,
      appCount: appCount,
      totalLaunchCount: Value(totalLaunchCount), // ✅ 保存总启动次数
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> refreshAllDailyStats() async {
    AppLogger.info('Recalculating all daily stats...', 'DB');
    final allRecords = await select(appUsageRecords).get();
    if (allRecords.isEmpty) {
      AppLogger.debug('No records found', 'DB');
      return;
    }
    final recordsByDate = <DateTime, List<AppUsageRecord>>{};
    for (final record in allRecords) {
      final dateKey = DateTime(record.date.year, record.date.month, record.date.day);
      recordsByDate.putIfAbsent(dateKey, () => []).add(record);
    }
    for (final date in recordsByDate.keys) {
      await refreshDailyStat(date);
    }
    AppLogger.info('Refreshed ${recordsByDate.length} daily stats', 'DB');
  }

  Future<void> cleanupDuplicateDailyStats() async {
    AppLogger.info('Cleaning up duplicate DailyStats...', 'DB');
    final allStats = await select(dailyStats).get();
    AppLogger.debug('Total DailyStats count: ${allStats.length}', 'DB');
    if (allStats.isEmpty) {
      AppLogger.debug('No DailyStats found, nothing to clean', 'DB');
      return;
    }
    final statsByDate = <DateTime, List<DailyStat>>{};
    for (final stat in allStats) {
      final dateKey = DateTime(stat.date.year, stat.date.month, stat.date.day);
      statsByDate.putIfAbsent(dateKey, () => []).add(stat);
    }
    AppLogger.debug('Found ${statsByDate.length} unique dates', 'DB');
    final duplicates = statsByDate.entries.where((e) => e.value.length > 1).toList();
    if (duplicates.isEmpty) {
      AppLogger.debug('No duplicates found', 'DB');
      return;
    }
    AppLogger.warning('Found ${duplicates.length} dates with duplicates', 'DB');
    int totalDeleted = 0;
    for (final entry in duplicates) {
      final date = entry.key;
      final stats = entry.value;
      stats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final toDelete = stats.skip(1).map((s) => s.id).toList();
      AppLogger.debug('Date $date: keeping newest, deleting ${toDelete.length}', 'DB');
      for (final id in toDelete) {
        await (delete(dailyStats)..where((t) => t.id.equals(id))).go();
        totalDeleted++;
      }
    }
    AppLogger.info('Deleted $totalDeleted duplicate records', 'DB');
  }

  Future<void> cleanupInvalidUsageRecords() async {
    AppLogger.info('Cleaning up invalid usage records...', 'DB');
    final allRecords = await select(appUsageRecords).get();
    AppLogger.debug('Total AppUsageRecords count: ${allRecords.length}', 'DB');
    if (allRecords.isEmpty) {
      AppLogger.debug('No usage records found, nothing to clean', 'DB');
      return;
    }
    int totalDeleted = 0;
    final toDelete = <int>[];
    for (final record in allRecords) {
      if (record.startTime >= record.endTime) {
        toDelete.add(record.id);
        AppLogger.warning('Invalid record: id=${record.id}, app=${record.appName}', 'DB');
      }
    }
    for (final id in toDelete) {
      await (delete(appUsageRecords)..where((t) => t.id.equals(id))).go();
      totalDeleted++;
    }
    AppLogger.info('Deleted $totalDeleted invalid records', 'DB');
  }

  // ===== 目标 CRUD =====
  /// 获取所有目标
  Future<List<Goal>> getAllGoals() {
    return (select(goals)
      ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
        .get();
  }

  /// 获取进行中的目标
  Future<Goal?> getActiveGoal() {
    return (select(goals)
      ..where((t) => t.status.equals('active'))
      ..limit(1))
        .getSingleOrNull();
  }

  /// 创建目标
  Future<int> createGoal({
    required String title,
    String? description,
    int? plannedDuration,
  }) async {
    final now = DateTime.now();
    final id = await into(goals).insert(
      GoalsCompanion.insert(
        title: title,
        description: Value(description),
        plannedDuration: plannedDuration ?? 0,  // 0 表示自由计时（无固定时长）
        startTime: now.millisecondsSinceEpoch,
        status: 'active',
        createdAt: now,
      ),
    );
    print('✅ Created goal #$id: $title (${plannedDuration}min)');
    return id;
  }

  /// 结束目标
  Future<void> completeGoal(int goalId, {bool? completed, String? userNote}) async {
    final goal = await getGoalById(goalId);
    if (goal == null) return;

    final now = DateTime.now();
    final actualDurationMs = now.millisecondsSinceEpoch - goal.startTime;
    final actualDurationMin = (actualDurationMs / 60000).round();

    await (update(goals)..where((t) => t.id.equals(goalId))).write(
      GoalsCompanion(
        endTime: Value(now.millisecondsSinceEpoch),
        actualDuration: Value(actualDurationMin),
        status: const Value('completed'),
        completed: Value(completed),
        userNote: Value(userNote),
      ),
    );
    print('✅ Completed goal #$goalId: actual duration = ${actualDurationMin}min, completed=$completed');
  }

  /// 取消目标
  Future<void> cancelGoal(int goalId) async {
    final now = DateTime.now();
    final goal = await getGoalById(goalId);
    if (goal == null) return;

    final actualDurationMs = now.millisecondsSinceEpoch - goal.startTime;
    final actualDurationMin = (actualDurationMs / 60000).round();

    await (update(goals)..where((t) => t.id.equals(goalId))).write(
      GoalsCompanion(
        endTime: Value(now.millisecondsSinceEpoch),
        actualDuration: Value(actualDurationMin),
        status: const Value('cancelled'),
      ),
    );
    print('✅ Cancelled goal #$goalId: actual duration = ${actualDurationMin}min');
  }

  /// 根据 ID 获取目标
  Future<Goal?> getGoalById(int goalId) {
    return (select(goals)..where((t) => t.id.equals(goalId))).getSingleOrNull();
  }

  /// 保存 AI 复盘文本（生成完毕后调用，避免用户重复消耗 token）
  Future<void> saveAiReview(int goalId, String reviewText) async {
    await (update(goals)..where((t) => t.id.equals(goalId))).write(
      GoalsCompanion(aiReviewText: Value(reviewText)),
    );
    AppLogger.debug('AI review saved for goal $goalId', 'DB');
  }

  /// 保存 AI 复盘反馈：1=👍 有帮助  0=👎 没帮助
  Future<void> saveAiReviewFeedback(int goalId, int feedback) async {
    await (update(goals)..where((t) => t.id.equals(goalId))).write(
      GoalsCompanion(aiReviewFeedback: Value(feedback)),
    );
    AppLogger.debug('AI review feedback($feedback) saved for goal $goalId', 'DB');
  }

  /// 获取目标内的所有使用记录
  Future<List<AppUsageRecord>> getRecordsByGoal(int goalId) {
    return (select(appUsageRecords)
      ..where((t) => t.goalId.equals(goalId))
      ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  /// 计算目标内的有效/分心时长
  /// total 使用目标的实际时长（endTime - startTime），包含息屏时间，
  /// 这样专注度分母才是真实时间，而不是仅手机使用时间。
  Future<Map<String, int>> getGoalStats(int goalId) async {
    final goal = await getGoalById(goalId);
    final records = await getRecordsByGoal(goalId);

    // 目标实际总时长：endTime - startTime（包含息屏），单位毫秒
    // 目标进行中时 endTime 可能为 null，此时用 records 加总兜底
    final goalTotalTime = (goal != null && goal.endTime != null && goal.endTime! > goal.startTime)
        ? (goal.endTime! - goal.startTime)
        : records.fold(0, (s, r) => s + r.duration);

    if (records.isEmpty) {
      return {'effective': 0, 'entertain': 0, 'total': goalTotalTime};
    }

    // 获取记录的标签
    final recordIds = records.map((r) => r.id).toList();
    final mappings = await (select(recordLabelMappings).join([
      innerJoin(userLabels, userLabels.id.equalsExp(recordLabelMappings.labelId)),
    ])
      ..where(recordLabelMappings.recordId.isIn(recordIds)))
        .get();

    int effectiveTime = 0;
    int entertainTime = 0;
    final labeledRecordIds = <int>{};

    for (final row in mappings) {
      final label = row.readTable(userLabels);
      final mapping = row.readTable(recordLabelMappings);
      // 数据可能不一致（record 被删但 mapping 还在），跳过而不是抛异常
      final record = records.where((r) => r.id == mapping.recordId).firstOrNull;
      if (record == null) continue;
      labeledRecordIds.add(mapping.recordId);

      if (label.isEffective) {
        effectiveTime += record.duration;
      } else if (label.name == '娱乐' || label.name == '刷视频') {
        entertainTime += record.duration;
      }
    }

    return {
      'effective': effectiveTime,
      'entertain': entertainTime,
      // total 用目标实际时长（含息屏），确保专注度分母正确
      'total': goalTotalTime,
    };
  }

  /// ✅ 获取目标期间App使用时长Top 5
  Future<List<Map<String, dynamic>>> getTopAppsByGoal(int goalId) async {
    final records = await getRecordsByGoal(goalId);
    if (records.isEmpty) return [];

    // 按包名统计总时长
    final appDuration = <String, int>{};
    final appNameMap = <String, String>{};

    for (final record in records) {
      appDuration[record.packageName] = (appDuration[record.packageName] ?? 0) + record.duration;
      appNameMap[record.packageName] = record.appName;
    }

    // 排序取Top 5
    final sorted = appDuration.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => {
      'packageName': e.key,
      'appName': appNameMap[e.key]!,
      'duration': e.value,
    }).toList();
  }

  /// ✅ 获取自评完成率(指定时间范围内)
  Future<double> getCompletionRate(DateTime startDate, DateTime endDate) async {
    final allGoals = await getAllGoals();
    final totalGoals = allGoals
        .where((g) => g.startTime >= startDate.millisecondsSinceEpoch)
        .where((g) => g.startTime <= endDate.millisecondsSinceEpoch)
        .where((g) => g.status == 'completed')
        .toList();

    if (totalGoals.isEmpty) return 0.0;

    final completedGoals = totalGoals.where((g) => g.completed == true).length;
    return completedGoals / totalGoals.length;
  }

  /// ✅ 获取目标期间按标签分类的统计
  Future<Map<String, int>> getGoalStatsByLabel(int goalId) async {
    final records = await getRecordsByGoal(goalId);
    if (records.isEmpty) return {};

    // 获取记录的标签
    final recordIds = records.map((r) => r.id).toList();
    final mappings = await (select(recordLabelMappings).join([
      innerJoin(userLabels, userLabels.id.equalsExp(recordLabelMappings.labelId)),
    ])
      ..where(recordLabelMappings.recordId.isIn(recordIds)))
        .get();

    final result = <String, int>{};
    final labeledRecordIds = <int>{};

    // 统计已打标签的时长(只取每个记录的第一个标签)
    for (final row in mappings) {
      final label = row.readTable(userLabels);
      final mapping = row.readTable(recordLabelMappings);

      // 跳过已计算过的记录(防止多标签重复计算)
      if (labeledRecordIds.contains(mapping.recordId)) {
        continue;
      }
      labeledRecordIds.add(mapping.recordId);

      final record = records.firstWhere((r) => r.id == mapping.recordId);
      result[label.name] = (result[label.name] ?? 0) + record.duration;
    }

    // 统计未打标签的时长放入"其他"
    final unlabeledDuration = records
        .where((r) => !labeledRecordIds.contains(r.id))
        .fold(0, (s, r) => s + r.duration);
    if (unlabeledDuration > 0) {
      result['其他'] = (result['其他'] ?? 0) + unlabeledDuration;
    }

    return result;
  }

  // ===== 分心热力图 =====
  /// 获取分心热力图数据（按时间段统计）
  /// 返回格式：Map<String, int> - key 为时间段（如 "9-10", "10-11"），value 为分心时长（毫秒）
  Future<Map<String, int>> getDistractionHeatmap({int days = 7}) async {
    // 获取最近N天的所有已完成目标
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final goals = await (select(this.goals)
      ..where((g) => g.status.equals('completed'))
      ..where((g) => g.endTime.isBiggerThanValue(startDate.millisecondsSinceEpoch))
      ..orderBy([(g) => OrderingTerm.asc(g.endTime)]))
        .get();

    if (goals.isEmpty) return {};

    // 获取所有相关记录
    final goalIds = goals.map((g) => g.id).toList();
    final records = await (select(appUsageRecords)
      ..where((u) => u.goalId.isIn(goalIds)))
        .get();

    // 获取所有标签映射
    final recordIds = records.map((r) => r.id).toList();
    final mappings = await (select(recordLabelMappings).join([
      innerJoin(userLabels, userLabels.id.equalsExp(recordLabelMappings.labelId)),
    ])
      ..where(recordLabelMappings.recordId.isIn(recordIds)))
        .get();

    // 找出所有分心记录（娱乐类或非有效类）
    final distractionRecords = <AppUsageRecord>[];
    final effectiveLabels = <int>{};
    final entertainLabels = <int>{};

    for (final row in mappings) {
      final label = row.readTable(userLabels);
      if (label.isEffective) {
        effectiveLabels.add(label.id);
      } else if (label.name == '娱乐' || label.name == '刷视频') {
        entertainLabels.add(label.id);
      }
    }

    for (final record in records) {
      // 获取记录的标签
      final recordMappings = mappings.where((m) => m.readTable(recordLabelMappings).recordId == record.id);
      final labelIds = recordMappings.map((m) => m.readTable(userLabels).id).toSet();

      if (labelIds.isEmpty || (!effectiveLabels.intersection(labelIds).isEmpty && !entertainLabels.intersection(labelIds).isEmpty)) {
        // 未打标签 或 同时有有效和娱乐标签 -> 分心
        distractionRecords.add(record);
      } else if (entertainLabels.intersection(labelIds).isNotEmpty) {
        // 娱乐标签 -> 分心
        distractionRecords.add(record);
      }
    }

    // 按时间段统计（每小时一个时间段）
    final heatmap = <String, int>{};

    for (final record in distractionRecords) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(record.startTime);
      final hour = startTime.hour;

      // 创建时间段 key（如 "9-10" 表示 9:00-10:00）
      final timeSlotKey = '$hour-${hour + 1}';

      heatmap[timeSlotKey] = (heatmap[timeSlotKey] ?? 0) + record.duration;
    }

    return heatmap;
  }

  /// 获取按星期几统计的分心热力图数据
  /// 返回格式：Map<int, int> - key 为星期几（1=周一，7=周日），value 为分心时长（毫秒）
  Future<Map<int, int>> getDistractionByDayOfWeek({int weeks = 4}) async {
    // 获取最近N周的所有已完成目标
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: weeks * 7));

    final goals = await (select(this.goals)
      ..where((g) => g.status.equals('completed'))
      ..where((g) => g.endTime.isBiggerThanValue(startDate.millisecondsSinceEpoch))
      ..orderBy([(g) => OrderingTerm.asc(g.endTime)]))
        .get();

    if (goals.isEmpty) return {};

    // 获取所有相关记录
    final goalIds = goals.map((g) => g.id).toList();
    final records = await (select(appUsageRecords)
      ..where((u) => u.goalId.isIn(goalIds)))
        .get();

    // 获取所有标签映射
    final recordIds = records.map((r) => r.id).toList();
    final mappings = await (select(recordLabelMappings).join([
      innerJoin(userLabels, userLabels.id.equalsExp(recordLabelMappings.labelId)),
    ])
      ..where(recordLabelMappings.recordId.isIn(recordIds)))
        .get();

    // 找出所有分心记录
    final distractionRecords = <AppUsageRecord>[];
    final effectiveLabels = <int>{};
    final entertainLabels = <int>{};

    for (final row in mappings) {
      final label = row.readTable(userLabels);
      if (label.isEffective) {
        effectiveLabels.add(label.id);
      } else if (label.name == '娱乐' || label.name == '刷视频') {
        entertainLabels.add(label.id);
      }
    }

    for (final record in records) {
      final recordMappings = mappings.where((m) => m.readTable(recordLabelMappings).recordId == record.id);
      final labelIds = recordMappings.map((m) => m.readTable(userLabels).id).toSet();

      if (labelIds.isEmpty || (!effectiveLabels.intersection(labelIds).isEmpty && !entertainLabels.intersection(labelIds).isEmpty)) {
        distractionRecords.add(record);
      } else if (entertainLabels.intersection(labelIds).isNotEmpty) {
        distractionRecords.add(record);
      }
    }

    // 按星期几统计
    final heatmap = <int, int>{};

    for (final record in distractionRecords) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(record.startTime);
      final dayOfWeek = startTime.weekday; // 1=周一，7=周日

      heatmap[dayOfWeek] = (heatmap[dayOfWeek] ?? 0) + record.duration;
    }

    return heatmap;
  }

  /// 获取目标统计趋势（按日期统计）
  /// 返回格式：List<Map<String, dynamic>> - 每个元素包含 date, completedCount, completionRate
  Future<List<Map<String, dynamic>>> getGoalStatsTrend({int days = 30}) async {
    // 获取最近N天的所有目标
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final goals = await (select(this.goals)
      ..where((g) => g.createdAt.isBiggerThanValue(startDate))
      ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .get();

    if (goals.isEmpty) return [];

    // 按日期分组统计
    final trendMap = <String, Map<String, dynamic>>{};

    for (final goal in goals) {
      final date = goal.createdAt;
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      if (!trendMap.containsKey(dateKey)) {
        trendMap[dateKey] = {
          'date': date,
          'completedCount': 0,
          'totalDuration': 0,
          'plannedDuration': 0,
        };
      }

      if (goal.status == 'completed') {
        trendMap[dateKey]!['completedCount'] = trendMap[dateKey]!['completedCount'] + 1;
        trendMap[dateKey]!['totalDuration'] = (trendMap[dateKey]!['totalDuration'] as int) + (goal.actualDuration ?? 0);
        trendMap[dateKey]!['plannedDuration'] = (trendMap[dateKey]!['plannedDuration'] as int) + goal.plannedDuration;
      }
    }

    // 计算完成率并转换为列表
    final trend = trendMap.values.map((data) {
      final totalDuration = data['totalDuration'] as int;
      final plannedDuration = data['plannedDuration'] as int;
      // plannedDuration=0 表示自由计时目标，直接视为 100%
      final completionRate = plannedDuration == 0
          ? (data['completedCount'] as int) > 0 ? 100.0 : 0.0
          : (totalDuration / plannedDuration * 100).clamp(0.0, 200.0);

      return {
        ...data,
        'completionRate': completionRate,
      };
    }).toList();

    return trend;
  }

  /// 获取智能目标建议
  /// 返回格式：Map<String, dynamic> - 包含建议的最佳时长和理由
  Future<Map<String, dynamic>> getSmartGoalSuggestion() async {
    // 获取最近7天所有已完成的目标
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    final goals = await (select(this.goals)
      ..where((g) => g.status.equals('completed'))
      ..where((g) => g.createdAt.isBiggerThanValue(startDate))
      ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
        .get();

    if (goals.isEmpty) {
      return {
        'suggestedDuration': 30,
        'reason': '暂无历史数据，建议从 30 分钟开始',
        'dataPoints': 0,
      };
    }

    // 计算平均实际时长和平均完成率
    final totalActualDuration = goals.fold<int>(0, (sum, g) => sum + (g.actualDuration ?? 0));
    final avgActualDuration = totalActualDuration ~/ goals.length;

    final totalCompletionRate = goals.fold<double>(0, (sum, g) {
      if (g.plannedDuration == 0) {
        // 自由计时目标：完成即 100%
        return sum + 100.0;
      }
      final rate = ((g.actualDuration ?? 0) / g.plannedDuration * 100).clamp(0.0, 200.0);
      return sum + rate;
    });
    final avgCompletionRate = totalCompletionRate / goals.length;

    // 根据平均完成率给出建议
    int suggestedDuration;
    String reason;

    if (avgCompletionRate >= 120) {
      // 完成率超高，建议增加时长
      suggestedDuration = (avgActualDuration * 1.2).round();
      reason = '你的平均完成率 ${(avgCompletionRate).toStringAsFixed(0)}%，表现超预期！建议尝试 ${(suggestedDuration / avgActualDuration * 100 - 100).toStringAsFixed(0)}% 更长的目标';
    } else if (avgCompletionRate >= 90) {
      // 完成率很好，建议保持
      suggestedDuration = avgActualDuration;
      reason = '你的平均完成率 ${(avgCompletionRate).toStringAsFixed(0)}%，表现很好！建议保持目前的时长';
    } else if (avgCompletionRate >= 60) {
      // 完成率一般，建议稍微减少
      suggestedDuration = (avgActualDuration * 0.9).round();
      reason = '你的平均完成率 ${(avgCompletionRate).toStringAsFixed(0)}%，可以尝试减少目标时长，提高完成率';
    } else {
      // 完成率偏低，建议显著减少
      suggestedDuration = (avgActualDuration * 0.7).round();
      reason = '你的平均完成率 ${(avgCompletionRate).toStringAsFixed(0)}%，建议缩短目标时长，从易到难循序渐进';
    }

    // 确保建议时长在合理范围内
    suggestedDuration = suggestedDuration.clamp(15, 180);

    return {
      'suggestedDuration': suggestedDuration,
      'reason': reason,
      'avgCompletionRate': avgCompletionRate,
      'avgActualDuration': avgActualDuration,
      'dataPoints': goals.length,
    };
  }

  // ===== 标签固化功能 =====

  /// 固化标签：将包名固定绑定到标签
  Future<void> pinLabel(String packageName, int labelId) async {
    await into(pinnedLabels).insertOnConflictUpdate(
      PinnedLabelsCompanion.insert(
        packageName: packageName,
        labelId: labelId,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// 取消固化标签
  Future<void> unpinLabel(String packageName) async {
    await (delete(pinnedLabels)..where((t) => t.packageName.equals(packageName))).go();
  }

  /// 查询包名固化的标签
  Future<int?> getPinnedLabelId(String packageName) async {
    final result = await (select(pinnedLabels)
      ..where((t) => t.packageName.equals(packageName))
      ..limit(1))
        .get();
    if (result.isEmpty) return null;
    return result.first.labelId;
  }

  /// 获取所有固化标签
  Future<List<PinnedLabel>> getAllPinnedLabels() {
    return (select(pinnedLabels)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  /// 自动打标签：根据固化规则为未打标签的记录打标签
  Future<int> autoTagRecords(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // 获取当天所有未打标签的记录
    final allRecords = await (select(appUsageRecords)
      ..where((t) => t.startTime.isBetweenValues(startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch)))
        .get();

    // 找出所有记录ID（排除已有标签的）
    final existingMappingRows = await (select(recordLabelMappings).join([
      innerJoin(appUsageRecords, appUsageRecords.id.equalsExp(recordLabelMappings.recordId)),
    ])
      ..where(appUsageRecords.startTime.isBetweenValues(startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch)))
        .get();

    final recordIdsWithLabels = existingMappingRows.map((row) => row.readTable(recordLabelMappings).recordId).toSet();
    final recordsWithoutLabels = allRecords.where((r) => !recordIdsWithLabels.contains(r.id)).toList();

    if (recordsWithoutLabels.isEmpty) return 0;

    // 批量查询固化标签
    final allPinnedLabels = await getAllPinnedLabels();
    final pinnedLabelMap = {for (var p in allPinnedLabels) p.packageName: p.labelId};

    // 批量插入标签映射
    int taggedCount = 0;
    for (final record in recordsWithoutLabels) {
      final labelId = pinnedLabelMap[record.packageName];
      if (labelId != null) {
        await into(recordLabelMappings).insert(
          RecordLabelMappingsCompanion.insert(
            recordId: record.id,
            labelId: labelId,
            taggedAt: DateTime.now(),
          ),
        );
        taggedCount++;
      }
    }

    return taggedCount;
  }

  // ===== 目标模板功能 =====

  /// 创建模板
  Future<int> createGoalTemplate({
    required String title,
    required int plannedDuration,
    String? notes,
  }) async {
    return await into(goalTemplates).insert(
      GoalTemplatesCompanion.insert(
        title: title,
        plannedDuration: plannedDuration,
        notes: Value(notes),
        usageCount: const Value(0),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// 删除模板
  Future<void> deleteGoalTemplate(int id) async {
    await (delete(goalTemplates)..where((t) => t.id.equals(id))).go();
  }

  /// 获取所有模板
  Future<List<GoalTemplate>> getAllGoalTemplates() {
    return (select(goalTemplates)..orderBy([(t) => OrderingTerm.desc(t.usageCount)])).get();
  }

  /// 使用模板（增加使用次数）
  Future<void> useGoalTemplate(int id) async {
    final template = await getGoalTemplateById(id);
    if (template != null) {
      await (update(goalTemplates)..where((t) => t.id.equals(id))).write(
        GoalTemplatesCompanion(usageCount: Value(template.usageCount + 1)),
      );
    }
  }

  /// 根据ID查询模板
  Future<GoalTemplate?> getGoalTemplateById(int id) {
    return (select(goalTemplates)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // ===== 标签管理辅助方法 =====

  /// 清除所有数据(保留预设标签)
  Future<void> clearAllData() async {
    // 删除所有记录-标签映射
    await delete(recordLabelMappings).go();

    // 删除所有使用记录
    await delete(appUsageRecords).go();

    // 删除所有每日统计
    await delete(dailyStats).go();

    // 删除所有目标
    await delete(goals).go();

    // 删除所有非预设标签
    await (delete(userLabels)..where((t) => t.isPreset.equals(false))).go();

    // ✅ 重置 SQLite autoincrement 序列（防止删除后新记录 id 与历史记录 id 碰撞，导致
    //    新目标的 goalId 与旧活动记录的 goalId 相同，从而错误显示历史活动记录）
    try {
      await customStatement(
        "DELETE FROM sqlite_sequence WHERE name IN "
        "('goals', 'app_usage_records', 'record_label_mappings', 'daily_stats')",
      );
    } catch (_) {
      // sqlite_sequence 只在表有 autoincrement 时存在，忽略异常
    }
  }

  /// 添加标签
  Future<void> addLabel(UserLabelsCompanion label) async {
    await into(userLabels).insert(label);
  }

  /// 获取标签统计(按使用次数)
  Future<Map<String, int>> getLabelStats() async {
    final mappings = await select(recordLabelMappings).get();

    final stats = <String, int>{};
    for (final mapping in mappings) {
      final labelId = mapping.labelId.toString();
      stats[labelId] = (stats[labelId] ?? 0) + 1;
    }

    return stats;
  }
}

// Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Override in main');
});
