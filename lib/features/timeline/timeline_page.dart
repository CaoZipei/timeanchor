import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/database/app_database.dart';
import '../../core/services/usage_stats_service.dart';
import '../../core/utils/app_logger.dart';
import '../stats/stats_page.dart';
import 'widgets/timeline_gantt.dart';
import 'widgets/date_selector.dart';
import 'widgets/permission_banner.dart';
import '../../core/utils/time_formatter.dart';

// 当前选中日期 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// 权限状态 Provider
final usagePermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(usageStatsServiceProvider);
  return service.hasPermission();
});

// 标签筛选 Provider（null 表示显示全部）
final selectedFilterLabelProvider = StateProvider<int?>((ref) => null);

// 当日记录 Provider（支持标签过滤）
// ✅ 只展示 UsageStats 来源记录（goalId == null），目标监控记录在目标报告页独立展示
// 这样避免时间轴出现同一 App 同一时段两条重叠条目的问题
final dailyRecordsProvider = FutureProvider.family<List<AppUsageRecord>, DateTime>(
  (ref, date) async {
    final db = ref.watch(databaseProvider);
    final filterLabelId = ref.watch(selectedFilterLabelProvider);

    var records = await db.getUsageStatsRecordsByDate(date);

    // 如果选择了标签过滤，只返回包含该标签的记录
    if (filterLabelId != null) {
      // ✅ 一次性批量查询所有标签映射，避免N+1查询问题
      final allLabelMappings = await db.getAllLabelMappingsForDate(date);

      // 构建记录ID到标签ID列表的映射
      final labelIdsByRecord = <int, List<int>>{};
      for (final mapping in allLabelMappings) {
        labelIdsByRecord.putIfAbsent(mapping.recordId, () => []);
        labelIdsByRecord[mapping.recordId]!.add(mapping.labelId);
      }

      // 根据标签ID过滤记录
      final filteredRecords = records.where((record) {
        final labelIds = labelIdsByRecord[record.id] ?? [];
        return labelIds.contains(filterLabelId);
      }).toList();

      records = filteredRecords;
    }

    return records;
  },
);

class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> with WidgetsBindingObserver {
  Timer? _autoSyncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 页面启动时同步今日数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.debug('initState: calling _syncTodayData', 'Timeline');
      _syncTodayData();
      _startAutoSync(isBackground: false);
    });
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 页面激活时恢复定时器（页面切回来时）
  @override
  void activate() {
    super.activate();
    _startAutoSync(isBackground: false);
  }

  /// 页面失活时暂停定时器（切到其他 Tab 时）
  @override
  void deactivate() {
    _autoSyncTimer?.cancel();
    super.deactivate();
  }

  /// 前台自动同步：30秒一次
  void _startAutoSync({bool isBackground = false}) {
    _autoSyncTimer?.cancel();
    // ✅ 只保留前台模式，后台不再运行 timer
    const interval = Duration(seconds: 30);
    _autoSyncTimer = Timer.periodic(interval, (_) {
      AppLogger.debug('Auto-sync triggered', 'Timeline');
      _syncTodayData();
    });
    AppLogger.debug('Auto-sync started (interval: ${interval.inSeconds}s)', 'Timeline');
  }

  // ✅ 应用生命周期管理
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppLogger.debug('App resumed - switching to foreground mode', 'Timeline');
      ref.invalidate(usagePermissionProvider);
      _startAutoSync(isBackground: false);
    } else if (state == AppLifecycleState.paused) {
      AppLogger.debug('App paused - stopping sync timer', 'Timeline');
      _autoSyncTimer?.cancel();
      AppLogger.debug('Auto-sync timer cancelled', 'Timeline');
    }
  }

  /// 同步今日数据入口（检查权限后调用核心逻辑）
  Future<void> _syncTodayData() async {
    final service = ref.read(usageStatsServiceProvider);
    final hasPermission = await service.hasPermission();
    AppLogger.debug('_syncTodayData: hasPermission=$hasPermission', 'Timeline');
    if (!hasPermission) {
      AppLogger.debug('No permission, returning', 'Timeline');
      return;
    }
    ref.invalidate(usagePermissionProvider);

    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    // Step 1: 计算增量同步起点，删除边界后的旧记录，返回需要恢复的标签映射
    final (lastSyncTime, labelMappingsToRestore) =
        await _prepareIncrementalSync(db, now, startOfDay);

    // Step 2: 从系统 API 增量拉取新数据并写入数据库
    await _fetchAndInsertNewRecords(service, db, now, startOfDay, lastSyncTime);

    // Step 3: 恢复被删除记录的标签映射
    if (labelMappingsToRestore.isNotEmpty) {
      await _restoreLabelMappings(db, startOfDay, labelMappingsToRestore);
    }

    ref.invalidate(dailyRecordsProvider(startOfDay));
    AppLogger.debug('UI providers invalidated', 'Timeline');
  }

  /// Step 1: 计算增量起点，删除边界后的旧记录，返回 (lastSyncTime, labelMappingsToRestore)
  Future<(DateTime, Map<String, List<int>>)> _prepareIncrementalSync(
    AppDatabase db,
    DateTime now,
    DateTime startOfDay,
  ) async {
    // ✅ 只操作 UsageStats 来源记录（goalId == null），不碰目标监控记录
    final existingRecords = await db.getUsageStatsRecordsByDate(startOfDay);
    final labelMappingsToRestore = <String, List<int>>{};

    if (existingRecords.isEmpty) {
      return (startOfDay, labelMappingsToRestore);
    }

    final lastEndTime = existingRecords.map((r) => r.endTime).reduce((a, b) => a > b ? a : b);
    final lastEndDateTime = DateTime.fromMillisecondsSinceEpoch(lastEndTime);
    // 往前推 30 分钟作为删除边界，避免丢失边界附近的数据
    var lastSyncTime = lastEndDateTime.subtract(const Duration(minutes: 30));
    if (lastSyncTime.isBefore(startOfDay)) lastSyncTime = startOfDay;

    final recordsToDelete = existingRecords
        .where((r) => r.endTime >= lastSyncTime.millisecondsSinceEpoch)
        .toList();

    if (recordsToDelete.isNotEmpty) {
      final recordIdsToDelete = recordsToDelete.map((r) => r.id).toList();
      // 删除前保存标签映射（packageName -> labelIds）
      for (final record in recordsToDelete) {
        final mappings = await db.getLabelsByRecord(record.id);
        if (mappings.isNotEmpty) {
          labelMappingsToRestore[record.packageName] = mappings.map((m) => m.labelId).toList();
        }
      }
      await (db.delete(db.appUsageRecords)..where((t) => t.id.isIn(recordIdsToDelete))).go();
      await (db.delete(db.recordLabelMappings)..where((t) => t.recordId.isIn(recordIdsToDelete))).go();
      await db.refreshDailyStat(now);
      AppLogger.debug('Deleted ${recordsToDelete.length} old records, saved ${labelMappingsToRestore.length} label mappings', 'Timeline');
    }

    return (lastSyncTime, labelMappingsToRestore);
  }

  /// Step 2: 从系统 API 增量拉取数据并写入数据库（自动去重）
  Future<void> _fetchAndInsertNewRecords(
    UsageStatsService service,
    AppDatabase db,
    DateTime now,
    DateTime startOfDay,
    DateTime lastSyncTime,
  ) async {
    AppLogger.debug('Incremental sync from $lastSyncTime to $now', 'Timeline');
    final rawData = await service.queryUsageStats(from: lastSyncTime, to: now);
    AppLogger.debug('New data count: ${rawData.length}', 'Timeline');
    if (rawData.isEmpty) {
      AppLogger.debug('No new data since last sync', 'Timeline');
      return;
    }

    // ✅ 只查 UsageStats 来源记录做去重，不与目标监控记录比对
    final existingRecords = await db.getUsageStatsRecordsByDate(startOfDay);
    final filteredRawData = rawData.where((item) {
      final packageName = item['packageName'] as String;
      final startTime = (item['lastTimeUsed'] as int) - (item['totalTimeInForeground'] as int);
      final endTime = item['lastTimeUsed'] as int;
      return !existingRecords.any((e) =>
        e.packageName == packageName && e.startTime == startTime && e.endTime == endTime);
    }).toList();

    AppLogger.debug('Filtered to ${filteredRawData.length} unique records', 'Timeline');
    if (filteredRawData.isNotEmpty) {
      final newRecords = service.convertToRecords(filteredRawData, startOfDay);
      await db.insertRecords(newRecords);
      AppLogger.debug('Inserted ${newRecords.length} records', 'Timeline');
    }
    await db.refreshDailyStat(now);
  }

  /// Step 3: 将被删除记录的标签映射恢复到新记录上
  Future<void> _restoreLabelMappings(
    AppDatabase db,
    DateTime startOfDay,
    Map<String, List<int>> labelMappingsToRestore,
  ) async {
    AppLogger.debug('Restoring ${labelMappingsToRestore.length} label mappings...', 'Timeline');
    final currentRecords = await db.getRecordsByDate(startOfDay);
    for (final record in currentRecords) {
      final labelIds = labelMappingsToRestore[record.packageName];
      if (labelIds != null && labelIds.isNotEmpty) {
        for (final labelId in labelIds) {
          await db.tagRecord(recordId: record.id, labelId: labelId);
        }
      }
    }
    AppLogger.debug('Label mappings restored', 'Timeline');
  }



  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final recordsAsync = ref.watch(dailyRecordsProvider(selectedDate));
    final permissionAsync = ref.watch(usagePermissionProvider);
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== 顶部标题栏 =====
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '时间轴',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormat('MM月dd日 EEEE', 'zh_CN').format(selectedDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 刷新按钮
                IconButton(
                  onPressed: _syncTodayData,
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ===== 标签筛选 =====
          Consumer(
            builder: (context, ref, _) {
              return FutureBuilder<List<UserLabel>>(
                future: ref.watch(databaseProvider).getAllLabels(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final labels = snapshot.data!;
                  final selectedLabelId = ref.watch(selectedFilterLabelProvider);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedLabelId,
                        hint: Text(
                          '全部标签',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              '全部标签',
                              style: TextStyle(
                                color: selectedLabelId == null
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                                fontWeight: selectedLabelId == null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          ...labels.map((label) => DropdownMenuItem<int?>(
                                value: label.id,
                                child: Row(
                                  children: [
                                    Text(label.emoji, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Text(label.name),
                                  ],
                                ),
                              )),
                        ],
                        onChanged: (labelId) {
                          ref.read(selectedFilterLabelProvider.notifier).state = labelId;
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),

          // ===== 日期选择器 =====
          DateSelector(
            selectedDate: selectedDate,
            onDateChanged: (date) {
              ref.read(selectedDateProvider.notifier).state = date;
            },
          ),

          const SizedBox(height: 8),

          // ===== 时间轴主体 =====
          Expanded(
            child: recordsAsync.when(
              data: (records) => records.isEmpty
                  ? _buildEmpty(context)
                  : TimelineGantt(
                      records: records,
                      date: selectedDate,
                      onRecordTap: (record) => _showTagBottomSheet(context, record),
                      onRecordLongPress: (record) => _showRecordDetail(context, theme, record),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请确保已授予使用记录权限',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(BuildContext context, ThemeData theme, AppUsageRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖动条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              record.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.access_time,
              label: '时长',
              value: record.duration.formatDuration(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.play_circle_outline,
              label: '开始时间',
              value: record.startTime.formatTime(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.stop_circle,
              label: '结束时间',
              value: record.endTime.formatTime(),
              theme: theme,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.apps,
              label: '包名',
              value: record.packageName,
              theme: theme,
            ),
            const SizedBox(height: 16),
            // 编辑标签按钮
            FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context);
                _showTagBottomSheet(context, record);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('编辑标签'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagBottomSheet(BuildContext context, AppUsageRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TagBottomSheet(record: record),
    );
  }
}

// 打标签底部弹层（简化版，详细在 tags feature 中）
class TagBottomSheet extends ConsumerStatefulWidget {
  final AppUsageRecord record;
  const TagBottomSheet({super.key, required this.record});

  @override
  ConsumerState<TagBottomSheet> createState() => _TagBottomSheetState();
}

class _TagBottomSheetState extends ConsumerState<TagBottomSheet> {
  bool _pinLabel = false; // 是否固化标签

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);

    // ✅ 修复 bottom overflowed：用 ConstrainedBox + SingleChildScrollView 限制最大高度
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // ✅ 限制最大高度为屏幕60%，避免标签过多时溢出
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.6,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: viewInsets + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 拖动条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '为「${widget.record.appName}」打标签',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              widget.record.duration.formatDuration(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            Text(
              '${widget.record.startTime.formatTime()} - ${widget.record.endTime.formatTime()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),

            // 固化标签选项
            CheckboxListTile(
              title: const Text('📌 固化此标签'),
              subtitle: Text(
                '该包名下次将自动打上此标签',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              value: _pinLabel,
              onChanged: (value) {
                setState(() {
                  _pinLabel = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),

            // 标签列表
            FutureBuilder<List<UserLabel>>(
              future: db.getAllLabels(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final labels = snapshot.data!;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: labels.map((label) => _LabelChip(
                    label: label,
                    onTap: () async {
                      // 打标签
                      await db.tagRecord(
                        recordId: widget.record.id,
                        labelId: label.id,
                      );

                      // 如果选择固化,则保存固化关系
                      if (_pinLabel) {
                        await db.pinLabel(widget.record.packageName, label.id);
                      }

                      // ✅ 打标签后立即刷新记录 Provider（包含标签颜色和所有相关数据）
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);

                      // 立即重新计算统计（用于趋势图）
                      await db.refreshDailyStat(now);

                      // ✅ 失效时间轴数据 Provider
                      ref.invalidate(dailyRecordsProvider(today));
                      // ✅ 失效统计页饼图 Provider，确保标签分布立即更新
                      ref.invalidate(dailyAppStatsProvider(today));

                      AppLogger.debug('Label applied${_pinLabel ? ' and pinned' : ''} and UI refreshed', 'Timeline');
                      if (context.mounted) Navigator.pop(context);
                    },
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 详情行组件
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 12),
        Text(
          '$label：',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _LabelChip extends StatelessWidget {
  final UserLabel label;
  final VoidCallback onTap;
  const _LabelChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(label.color);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label.name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
