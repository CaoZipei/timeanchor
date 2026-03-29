import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_logger.dart';

class TimelineGantt extends StatefulWidget {
  final List<AppUsageRecord> records;
  final DateTime date;
  final ValueChanged<AppUsageRecord> onRecordTap;
  final ValueChanged<AppUsageRecord>? onRecordLongPress;

  const TimelineGantt({
    super.key,
    required this.records,
    required this.date,
    required this.onRecordTap,
    this.onRecordLongPress,
  });

  @override
  State<TimelineGantt> createState() => _TimelineGanttState();
}

class _TimelineGanttState extends State<TimelineGantt> {
  // 内容区水平滚动控制器（用户实际滑动的 controller）
  late final ScrollController _contentHorizontalController;
  // 表头时间刻度水平滚动控制器（被动跟随，不接受手势）
  late final ScrollController _headerHorizontalController;

  @override
  void initState() {
    super.initState();
    _contentHorizontalController = ScrollController();
    _headerHorizontalController = ScrollController();

    // 监听内容区水平滚动，被动同步表头位置
    _contentHorizontalController.addListener(() {
      if (!_contentHorizontalController.hasClients) return;
      final offset = _contentHorizontalController.offset;
      if (_headerHorizontalController.hasClients &&
          _headerHorizontalController.position.maxScrollExtent >= offset) {
        _headerHorizontalController.jumpTo(offset);
      }
    });
  }

  @override
  void dispose() {
    _contentHorizontalController.dispose();
    _headerHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = widget.records;
    final date = widget.date;

    // 根据记录计算实际的时间范围
    if (records.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }

    // 检测时间重叠（多个应用同时运行）
    bool hasOverlap = _detectTimeOverlap(records);

    // 找出最早和最晚的时间
    int? minTime, maxTime;
    for (final r in records) {
      minTime ??= r.startTime;
      maxTime ??= r.endTime;
      if (r.startTime < minTime) minTime = r.startTime;
      if (r.endTime > maxTime) maxTime = r.endTime;
    }

    if (minTime == null || maxTime == null) {
      return const Center(child: Text('数据异常'));
    }

    // ✅ 使用日期参数传入的日期来显示整天
    final dayStart = DateTime(date.year, date.month, date.day, 0, 0);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final totalMs = dayEnd.difference(dayStart).inMilliseconds.toDouble();

    AppLogger.debug('TimelineGantt - date=$date, dayStart=$dayStart, dayEnd=$dayEnd, totalMs=$totalMs hours=${totalMs ~/ 3600000}', 'TimelineGantt');

    // 准备分组数据
    final groupedRecords = _groupByApp(records);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⚠️ 时间重叠提示（不滚动）
        if (hasOverlap)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '多个应用同时运行，统计时长可能超过实际屏幕使用时间',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // ✅ 时间轴表头（固定不垂直滚动，水平被动跟随内容区）
        Row(
          children: [
            // 左侧应用名列表头占位
            const SizedBox(width: 96),
            // 右侧时间刻度：用独立 controller，由内容区滚动时 jumpTo 驱动
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _headerHorizontalController,
                physics: const NeverScrollableScrollPhysics(), // 不接受手势，只被动跟随
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: totalMs / 3600000 * 100 + 100,
                  child: Column(
                    children: [
                      _TimeRuler(dayStart: dayStart, dayEnd: dayEnd, totalMs: totalMs),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        // ✅ 主体区域：左侧固定名称 + 右侧甘特条，整体可垂直滚动
        // 内容区水平滚动时通过监听器同步带动表头
        Expanded(
          child: _SyncScrollGantt(
            groupedRecords: groupedRecords,
            dayStart: dayStart,
            dayEnd: dayEnd,
            totalMs: totalMs,
            onRecordTap: widget.onRecordTap,
            theme: theme,
            horizontalScrollController: _contentHorizontalController,
          ),
        ),
      ],
    );
  }

  bool _detectTimeOverlap(List<AppUsageRecord> records) {
    if (records.length <= 1) return false;
    final sorted = [...records]..sort((a, b) => a.startTime.compareTo(b.startTime));
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i].endTime > sorted[i + 1].startTime) return true;
    }
    return false;
  }

  Map<String, List<AppUsageRecord>> _groupByApp(List<AppUsageRecord> records) {
    final map = <String, List<AppUsageRecord>>{};
    for (final r in records) {
      map.putIfAbsent(r.appName, () => []).add(r);
    }
    final sorted = map.entries.toList()
      ..sort((a, b) {
        final aDur = a.value.fold(0, (s, r) => s + r.duration);
        final bDur = b.value.fold(0, (s, r) => s + r.duration);
        return bDur.compareTo(aDur);
      });
    return Map.fromEntries(sorted);
  }
}

/// ✅ 左右两列同步垂直滚动的甘特主体
/// 左列：应用名称（固定宽度96px，可垂直滚动）
/// 右列：时间段色块（可水平+垂直滚动，垂直与左列同步，水平与表头联动）
class _SyncScrollGantt extends StatefulWidget {
  final Map<String, List<AppUsageRecord>> groupedRecords;
  final DateTime dayStart;
  final DateTime dayEnd;
  final double totalMs;
  final ValueChanged<AppUsageRecord> onRecordTap;
  final ThemeData theme;
  /// 与表头时间刻度共享的水平滚动控制器
  final ScrollController horizontalScrollController;

  const _SyncScrollGantt({
    required this.groupedRecords,
    required this.dayStart,
    required this.dayEnd,
    required this.totalMs,
    required this.onRecordTap,
    required this.theme,
    required this.horizontalScrollController,
  });

  @override
  State<_SyncScrollGantt> createState() => _SyncScrollGanttState();
}

class _SyncScrollGanttState extends State<_SyncScrollGantt> {
  late final ScrollController _leftVertical;
  late final ScrollController _rightVertical;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _leftVertical = ScrollController();
    _rightVertical = ScrollController();

    // 左右垂直滚动互相同步
    _leftVertical.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_rightVertical.hasClients) {
        _rightVertical.jumpTo(_leftVertical.offset);
      }
      _isSyncing = false;
    });
    _rightVertical.addListener(() {
      if (_isSyncing) return;
      _isSyncing = true;
      if (_leftVertical.hasClients) {
        _leftVertical.jumpTo(_rightVertical.offset);
      }
      _isSyncing = false;
    });
  }

  @override
  void dispose() {
    _leftVertical.dispose();
    _rightVertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.groupedRecords.entries.toList();

    return Row(
      children: [
        // 左侧：应用名称列（垂直滚动）
        SizedBox(
          width: 96,
          child: ListView.builder(
            controller: _leftVertical,
            physics: const ClampingScrollPhysics(),
            itemCount: entries.length + 1, // +1 for bottom padding
            itemBuilder: (context, index) {
              if (index == entries.length) {
                return const SizedBox(height: 40);
              }
              return _AppNameRow(
                appName: entries[index].key,
                records: entries[index].value,
                theme: widget.theme,
              );
            },
          ),
        ),
        // 右侧：可水平+垂直滚动的甘特条
        // ✅ 水平 ScrollController 与表头共享，滚动时表头同步跟随
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.horizontalScrollController,
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: widget.totalMs / 3600000 * 100 + 100,
              child: ListView.builder(
                controller: _rightVertical,
                physics: const ClampingScrollPhysics(),
                itemCount: entries.length + 1, // +1 for bottom padding
                itemBuilder: (context, index) {
                  if (index == entries.length) {
                    return const SizedBox(height: 40);
                  }
                  return _GanttRow(
                    appName: entries[index].key,
                    records: entries[index].value,
                    dayStart: widget.dayStart,
                    dayEnd: widget.dayEnd,
                    totalMs: widget.totalMs,
                    onTap: widget.onRecordTap,
                    theme: widget.theme,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 时间刻度尺
class _TimeRuler extends StatelessWidget {
  final DateTime dayStart;
  final DateTime dayEnd;
  final double totalMs;

  const _TimeRuler({
    required this.dayStart,
    required this.dayEnd,
    required this.totalMs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 选择合适的刻度间隔：范围≤4小时用30min，≤8小时用1h，否则用2h
    final rangeHours = dayEnd.difference(dayStart).inHours;
    final tickIntervalHours = rangeHours <= 4 ? 0.5 : (rangeHours <= 8 ? 1 : 2);
    final tickIntervalMs = tickIntervalHours * 3600000;

    return SizedBox(
      height: 24,
      width: totalMs / 3600000 * 100 + 100,
      child: Stack(
        children: [
          // 生成刻度：从 dayStart 开始，每隔 tickInterval 加一个刻度
          ..._generateTicks(tickIntervalMs, theme),
        ],
      ),
    );
  }

  List<Positioned> _generateTicks(num tickIntervalMs, ThemeData theme) {
    final ticks = <Positioned>[];
    var tickTime = dayStart;

    while (tickTime.isBefore(dayEnd) || tickTime.isAtSameMomentAs(dayEnd)) {
      final offsetMs = tickTime.difference(dayStart).inMilliseconds.toDouble();
      // 计算位置：每1小时=100px宽度
      final left = (offsetMs / 3600000 * 100) + 20;

      // 时间标签
      final label = tickTime.minute == 0
          ? '${tickTime.hour}:00'
          : '${tickTime.hour}:${tickTime.minute.toString().padLeft(2, '0')}';

      ticks.add(
        Positioned(
          left: left,
          top: 0,
          child: Transform.translate(
            offset: const Offset(-12, 0), // 居中对齐
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      );

      // 递增
      final nextMs = tickTime.millisecondsSinceEpoch + tickIntervalMs.toInt();
      tickTime = DateTime.fromMillisecondsSinceEpoch(nextMs);
    }

    return ticks;
  }
}

// 左侧固定的应用名行
class _AppNameRow extends StatelessWidget {
  final String appName;
  final List<AppUsageRecord> records;
  final ThemeData theme;

  const _AppNameRow({
    required this.appName,
    required this.records,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = records.fold(0, (s, r) => s + r.duration);
    final totalMin = totalDuration ~/ 60000;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 12, right: 12),
      child: SizedBox(
        height: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              totalMin < 60
                  ? '$totalMin 分'
                  : '${totalMin ~/ 60}h${totalMin % 60}m',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 单 App 甘特行
class _GanttRow extends ConsumerStatefulWidget {
  final String appName;
  final List<AppUsageRecord> records;
  final DateTime dayStart;
  final DateTime dayEnd;
  final double totalMs;
  final ValueChanged<AppUsageRecord> onTap;
  final ValueChanged<AppUsageRecord>? onRecordLongPress;
  final ThemeData theme;

  const _GanttRow({
    required this.appName,
    required this.records,
    required this.dayStart,
    required this.dayEnd,
    required this.totalMs,
    required this.onTap,
    this.onRecordLongPress,
    required this.theme,
  });

  @override
  ConsumerState<_GanttRow> createState() => _GanttRowState();
}

class _GanttRowState extends ConsumerState<_GanttRow> {
  // 缓存每个 recordId 对应的标签颜色
  final Map<int, Color?> _recordLabelColor = {};

  @override
  void initState() {
    super.initState();
    // 加载所有记录的标签颜色
    _loadLabelColors();
  }

  @override
  void didUpdateWidget(_GanttRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 records 改变时，清除缓存并重新加载
    if (oldWidget.records != widget.records) {
      _recordLabelColor.clear();
      _loadLabelColors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: 32,
        child: Stack(
          children: [
            // 背景轨道
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            // 各时间段色块
            ...widget.records.map((record) {
              // 确保时间戳有效
              if (record.startTime <= 0 || record.endTime <= 0) {
                AppLogger.warning('Record ${record.id}: startTime=${record.startTime}, endTime=${record.endTime}', 'TimelineGantt');
                return const SizedBox.shrink();
              }

              // 时间戳必须在日期范围内
              final dayStartMs = widget.dayStart.millisecondsSinceEpoch;
              final dayEndMs = widget.dayEnd.millisecondsSinceEpoch;

              // 边界检查
              if (record.startTime > dayEndMs || record.endTime < dayStartMs) {
                return const SizedBox.shrink();
              }

              final startDt = DateTime.fromMillisecondsSinceEpoch(record.startTime);
              final endDt = DateTime.fromMillisecondsSinceEpoch(record.endTime);

              final offsetMs = startDt.difference(widget.dayStart).inMilliseconds.toDouble();
              // 计算位置：每1小时=100px宽度
              final left = (offsetMs / 3600000 * 100).clamp(0.0, double.infinity);

              // 使用实际的 endTime 计算宽度，而不是 duration
              final actualDuration = endDt.difference(startDt).inMilliseconds.toDouble();
              final barWidth = (actualDuration / 3600000 * 100).clamp(1.0, double.infinity);

              if (left.isNaN || barWidth.isNaN || left.isInfinite || barWidth.isInfinite) {
                AppLogger.warning('Record ${record.id}: Invalid calculations - '
                    'left=$left, width=$barWidth, offsetMs=$offsetMs, totalMs=${widget.totalMs}', 'TimelineGantt');
                return const SizedBox.shrink();
              }

              // ✅ 查询标签颜色（如果没有标签则使用分类颜色）
              final labelColor = _getLabelColor(record);
              final color = labelColor ?? _colorForCategory(record.appCategory);

              return Positioned(
                left: left,
                top: 4,
                bottom: 4,
                width: barWidth,
                child: GestureDetector(
                  onTap: () => widget.onTap(record),
                  onLongPress: widget.onRecordLongPress != null
                      ? () => widget.onRecordLongPress!(record)
                      : null,
                  child: Tooltip(
                    message: '${record.appName}\n${_formatMs(record.duration)}',
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        border: labelColor != null
                          ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5)
                          : null, // ✅ 有标签时显示白色边框
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// ✅ 获取 record 关联的标签颜色（有标签则返回标签颜色，否则返回null）
  Color? _getLabelColor(AppUsageRecord record) {
    // 从缓存中查询
    return _recordLabelColor[record.id];
  }

  /// 异步加载标签颜色
  Future<void> _loadLabelColors() async {
    final db = ref.read(databaseProvider);

    // ✅ 优化：先一次性查询所有标签，避免 N+1 查询
    final allLabels = await db.getAllLabels();
    final labelMap = {for (final l in allLabels) l.id: l};

    // ✅ 优化：批量查询所有记录的标签映射（解决 N+1 查询）
    final recordIds = widget.records.map((r) => r.id).toList();
    final allMappings = await db.getAllLabelMappingsByRecordIds(recordIds);

    // 按 recordId 分组
    final mappingsByRecordId = <int, List<RecordLabelMapping>>{};
    for (final mapping in allMappings) {
      mappingsByRecordId.putIfAbsent(mapping.recordId, () => []).add(mapping);
    }

    // 批量更新标签颜色
    if (mounted) {
      setState(() {
        for (final record in widget.records) {
          final mappings = mappingsByRecordId[record.id];
          if (mappings != null && mappings.isNotEmpty) {
            final labelId = mappings.first.labelId;
            final label = labelMap[labelId];
            if (label != null) {
              _recordLabelColor[record.id] = Color(label.color);
            }
          }
        }
      });
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'game': return AppTheme.tagEntertain;
      case 'social': return AppTheme.tagSocial;
      case 'video': return AppTheme.accentColor;
      case 'productivity': return AppTheme.tagWork;
      case 'news': return AppTheme.tagStudy;
      default: return AppTheme.primaryColor.withValues(alpha: 0.6);
    }
  }

  String _formatMs(int ms) {
    final m = ms ~/ 60000;
    if (m < 60) return '$m 分钟';
    return '${m ~/ 60} 小时 ${m % 60} 分钟';
  }
}
