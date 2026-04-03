import 'dart:async';
import 'package:drift/drift.dart' show innerJoin;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/services/llm_service.dart';
import 'share_card_widget.dart';



// ─── Provider：记录的标签（可刷新） ───
final _recordLabelsProvider = FutureProvider.autoDispose
    .family<UserLabel?, int>((ref, recordId) async {
  final db = ref.watch(databaseProvider);
  final mappings = await db.getLabelsByRecord(recordId);
  if (mappings.isEmpty) return null;
  // 取第一个标签
  final labels = await db.getAllLabels();
  final labelId = mappings.first.labelId;
  return labels.where((l) => l.id == labelId).firstOrNull;
});

// ─── Provider：所有标签列表 ───
final _allLabelsProvider = FutureProvider.autoDispose<List<UserLabel>>((ref) {
  return ref.watch(databaseProvider).getAllLabels();
});

/// 目标报告页面
class GoalReportPage extends ConsumerStatefulWidget {
  final Goal goal;
  const GoalReportPage({super.key, required this.goal});

  @override
  ConsumerState<GoalReportPage> createState() => _GoalReportPageState();
}

class _GoalReportPageState extends ConsumerState<GoalReportPage> {
  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.goal.status == 'active') {
      _elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - widget.goal.startTime) / 1000)
          .round()
          .clamp(0, 999999);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatElapsed(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _showShareCard(BuildContext context) async {
    final goal = widget.goal;
    final stats = ref.read(_goalStatsProvider(goal.id)).valueOrNull ?? {};

    final totalTime = stats['total'] ?? 0;
    final effectiveTime = stats['effective'] ?? 0;
    final goalTotalTime = (goal.endTime != null && goal.endTime! > goal.startTime)
        ? (goal.endTime! - goal.startTime)
        : totalTime;
    final focusRate = goalTotalTime > 0 ? effectiveTime / goalTotalTime : 0.0;
    final totalMinutes = (goalTotalTime / 60000).round();

    // 构建日期范围字符串
    final startDt = DateTime.fromMillisecondsSinceEpoch(goal.startTime);
    final startStr = '${startDt.month.toString().padLeft(2, '0')}/${startDt.day.toString().padLeft(2, '0')} '
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';
    String dateRange;
    if (goal.endTime != null) {
      final endDt = DateTime.fromMillisecondsSinceEpoch(goal.endTime!);
      dateRange = '$startStr - ${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';
    } else {
      dateRange = startStr;
    }

    // AI 复盘取前 60 字作一句话
    String? aiOneLiner;
    if (goal.aiReviewText != null && goal.aiReviewText!.isNotEmpty) {
      final text = goal.aiReviewText!.replaceAll('\n', ' ').trim();
      aiOneLiner = text.length > 60 ? '${text.substring(0, 57)}...' : text;
    }

    // 分心 App（从数据库查）
    final db = ref.read(databaseProvider);
    final records = await db.getRecordsByGoal(goal.id);
    final distractionApps = <String>[];
    for (final r in records) {
      if (r.appName != '时光锚' && !distractionApps.contains(r.appName)) {
        distractionApps.add(r.appName);
        if (distractionApps.length >= 3) break;
      }
    }

    if (!context.mounted) return;
    await showShareCardDialog(
      context,
      ShareCardData(
        goalTitle: goal.title,
        totalMinutes: totalMinutes,
        focusRate: focusRate,
        dateRange: dateRange,
        distractionApps: distractionApps,
        aiOneLiner: aiOneLiner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordsAsync = ref.watch(_goalRecordsProvider(widget.goal.id));
    final statsAsync = ref.watch(_goalStatsProvider(widget.goal.id));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.goal.title),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (widget.goal.status == 'completed')
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: '分享报告',
              onPressed: () => _showShareCard(context),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 统计概览
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => _buildStatsOverview(context, theme, stats),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('加载失败: $e'),
                ),
              ),
            ),

            // 目标复盘（仅已完成的目标显示）
            if (widget.goal.status == 'completed') ...[
              const SliverToBoxAdapter(child: Divider(height: 24)),
              SliverToBoxAdapter(
                child: _GoalReviewSection(
                    goal: widget.goal,
                    recordsAsync: recordsAsync,
                    statsAsync: statsAsync),
              ),
            ],

            // 活动记录标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '活动记录',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '点击可打标签',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 活动记录列表（直接内联到 SliverList）
            recordsAsync.when(
              data: (records) {
                // 展示时过滤掉不足 1 分钟的碎片（计入统计但不展示）
                final displayRecords = records.where((r) => r.duration >= 60000).toList();
                if (displayRecords.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          '目标期间没有使用记录',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) return const SizedBox(height: 8);
                        final record = displayRecords[index ~/ 2];
                        return _ActivityRow(record: record, goalId: widget.goal.id);
                      },
                      childCount: displayRecords.length * 2 - 1,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('加载失败: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, ThemeData theme, Map<String, int> stats) {
    final totalTime = stats['total'] ?? 0;
    final effectiveTime = stats['effective'] ?? 0;
    final entertainTime = stats['entertain'] ?? 0;
    final otherTime = totalTime - effectiveTime - entertainTime;

    final totalMin = totalTime ~/ 60000;
    final effectiveMin = effectiveTime ~/ 60000;
    final entertainMin = entertainTime ~/ 60000;
    final otherMin = otherTime ~/ 60000;

    final isFreeMode = widget.goal.plannedDuration == 0;

    // 构建时间段文字
    final startDt = DateTime.fromMillisecondsSinceEpoch(widget.goal.startTime);
    final startStr = '${startDt.month.toString().padLeft(2, '0')}-${startDt.day.toString().padLeft(2, '0')} '
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')}';

    String timeRangeStr;
    if (widget.goal.endTime != null) {
      final endDt = DateTime.fromMillisecondsSinceEpoch(widget.goal.endTime!);
      final endStr = startDt.day == endDt.day
          ? '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}'
          : '${endDt.month.toString().padLeft(2, '0')}-${endDt.day.toString().padLeft(2, '0')} '
            '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';
      timeRangeStr = '$startStr - $endStr';
    } else {
      timeRangeStr = '$startStr（进行中）';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间段
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4),
              Text(
                timeRangeStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 时长信息行（自由计时只显示实际时长）
          if (!isFreeMode)
            Row(
              children: [
                _InfoChip(
                  label: '计划',
                  value: '${widget.goal.plannedDuration} 分钟',
                  theme: theme,
                ),
                const SizedBox(width: 8),
                if (widget.goal.actualDuration != null)
                  _InfoChip(
                    label: '实际',
                    value: '${widget.goal.actualDuration} 分钟',
                    theme: theme,
                    highlight: true,
                  ),
              ],
            )
          else
            Row(
              children: [
                _InfoChip(
                  label: '自由计时',
                  // 进行中：显示实时已过时长；已结束：显示 actualDuration 或活动记录总时长
                  value: widget.goal.status == 'active'
                      ? _formatElapsed(_elapsedSeconds)
                      : '${widget.goal.actualDuration ?? totalMin} 分钟',
                  theme: theme,
                  highlight: true,
                ),
              ],
            ),

          const SizedBox(height: 14),

          // 统计卡片 2×2
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '总时长',
                  value: '$totalMin 分钟',
                  color: theme.colorScheme.primary,
                  icon: Icons.timer_outlined,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: '有效时间',
                  value: '$effectiveMin 分钟',
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '娱乐时间',
                  value: '$entertainMin 分钟',
                  color: Colors.orange,
                  icon: Icons.movie_outlined,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  label: '息屏/其他',
                  value: '$otherMin 分钟',
                  color: Colors.grey,
                  icon: Icons.phonelink_lock_outlined,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}



/// 单条活动记录行（带标签状态和打标签入口）
class _ActivityRow extends ConsumerWidget {
  final AppUsageRecord record;
  final int goalId;

  const _ActivityRow({required this.record, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final labelAsync = ref.watch(_recordLabelsProvider(record.id));
    final durationMin = record.duration ~/ 60000;
    final durationSec = (record.duration % 60000) ~/ 1000;
    final durationStr = durationMin > 0
        ? '$durationMin分$durationSec秒'
        : '$durationSec秒';
    final startDt = DateTime.fromMillisecondsSinceEpoch(record.startTime);
    final endDt = DateTime.fromMillisecondsSinceEpoch(record.endTime);
    final timeRange =
        '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')} - '
        '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}';

    return labelAsync.when(
      data: (label) {
        // 颜色根据标签 isEffective 决定
        Color rowColor;
        Widget labelBadge;

        if (label == null) {
          rowColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
          labelBadge = GestureDetector(
            onTap: () => _showLabelPicker(context, ref, record),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 2),
                  Text(
                    '打标签',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          final labelColor = Color(label.color);
          final isEffective = label.isEffective;
          rowColor = labelColor.withValues(alpha: 0.08);
          labelBadge = GestureDetector(
            onTap: () => _showLabelPicker(context, ref, record),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: labelColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: labelColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label.emoji, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 3),
                  Text(
                    label.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    isEffective ? Icons.check_circle : Icons.remove_circle_outline,
                    size: 11,
                    color: labelColor,
                  ),
                ],
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _showLabelPicker(context, ref, record),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: rowColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: label != null
                    ? Color(label.color).withValues(alpha: 0.25)
                    : theme.colorScheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                // 左侧：App 名 + 时间段
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.appName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                // 右侧：时长 + 标签徽章
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      durationStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    labelBadge,
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: LinearProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  /// 弹出标签选择器
  void _showLabelPicker(BuildContext context, WidgetRef ref, AppUsageRecord record) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _LabelPickerSheet(record: record),
    );
  }
}

/// 标签选择底部弹窗
class _LabelPickerSheet extends ConsumerWidget {
  final AppUsageRecord record;

  const _LabelPickerSheet({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allLabelsAsync = ref.watch(_allLabelsProvider);
    final currentLabelAsync = ref.watch(_recordLabelsProvider(record.id));

    final durationMin = record.duration ~/ 60000;
    final durationSec = (record.duration % 60000) ~/ 1000;
    final startDt = DateTime.fromMillisecondsSinceEpoch(record.startTime);
    final endDt = DateTime.fromMillisecondsSinceEpoch(record.endTime);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动条
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 应用信息
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.appName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${startDt.hour.toString().padLeft(2, '0')}:${startDt.minute.toString().padLeft(2, '0')} - '
                      '${endDt.hour.toString().padLeft(2, '0')}:${endDt.minute.toString().padLeft(2, '0')}  ·  '
                      '${durationMin > 0 ? "$durationMin分" : ""}$durationSec秒',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 说明文字
          Text(
            '这段时间是专注还是分心？',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),

          // 标签网格
          allLabelsAsync.when(
            data: (labels) => currentLabelAsync.when(
              data: (currentLabel) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...labels.map((label) {
                      final isSelected = currentLabel?.id == label.id;
                      final labelColor = Color(label.color);
                      return GestureDetector(
                        onTap: () async {
                          final db = ref.read(databaseProvider);
                          await db.tagRecord(recordId: record.id, labelId: label.id);
                          // 刷新标签显示
                          ref.invalidate(_recordLabelsProvider(record.id));
                          ref.invalidate(_goalStatsProvider);
                          ref.invalidate(_goalRecordsProvider);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? labelColor.withValues(alpha: 0.25)
                                : labelColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? labelColor
                                  : labelColor.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(label.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                label.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: labelColor,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.check, size: 14, color: labelColor),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                    // 清除标签按钮
                    if (currentLabel != null)
                      GestureDetector(
                        onTap: () async {
                          final db = ref.read(databaseProvider);
                          await (db.delete(db.recordLabelMappings)
                            ..where((t) => t.recordId.equals(record.id)))
                              .go();
                          ref.invalidate(_recordLabelsProvider(record.id));
                          ref.invalidate(_goalStatsProvider);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 14,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                              const SizedBox(width: 4),
                              Text(
                                '清除标签',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('加载失败: $e'),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('加载失败: $e'),
          ),
        ],
      ),
    );
  }
}


class _GoalReviewSection extends ConsumerWidget {
  final Goal goal;
  final AsyncValue<List<AppUsageRecord>> recordsAsync;
  final AsyncValue<Map<String, int>> statsAsync;

  const _GoalReviewSection({
    required this.goal,
    required this.recordsAsync,
    required this.statsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '目标复盘',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 复盘内容
          recordsAsync.when(
            data: (records) => _buildReviewContent(context, theme, ref, records),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('加载失败: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, ThemeData theme, WidgetRef ref, List<AppUsageRecord> records) {
    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '目标期间没有使用记录',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    // 获取数据库
    final db = ref.read(databaseProvider);

    // 计算分心 App 排行
    final distractionApps = <String, int>{};
    final effectiveApps = <String, int>{};

    return FutureBuilder<Map<String, dynamic>>(
      future: _calculateReviewData(db, records, goal),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviewData = snapshot.data!;
        final topDistractionApps = reviewData['topDistractionApps'] as List<MapEntry<String, int>>;
        final effectiveRatio = reviewData['effectiveRatio'] as double;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 有效时间占比
            _ReviewCard(
              icon: Icons.pie_chart_outline,
              title: '专注度分析',
              content: '有效时间占比 ${(effectiveRatio * 100).toStringAsFixed(1)}%',
              color: effectiveRatio >= 0.8
                  ? Colors.green
                  : effectiveRatio >= 0.6
                      ? Colors.orange
                      : Colors.red,
              theme: theme,
            ),
            const SizedBox(height: 12),

            // 分心 App Top 3
            if (topDistractionApps.isNotEmpty)
              _ReviewCard(
                icon: Icons.warning_amber_outlined,
                title: '分心 App Top ${topDistractionApps.length > 3 ? 3 : topDistractionApps.length}',
                content: topDistractionApps.take(3).map((e) {
                  final minutes = (e.value / 60000).toStringAsFixed(0);
                  return '${e.key} ($minutes分钟)';
                }).join('、'),
                color: Colors.orange,
                theme: theme,
              ),

            const SizedBox(height: 12),

            // 复盘建议
            _ReviewSuggestionCard(
              effectiveRatio: effectiveRatio,
              theme: theme,
            ),

            const SizedBox(height: 16),

            // AI 复盘入口
            _AiReviewSection(
              goal: goal,
              reviewData: reviewData,
              theme: theme,
              db: db,
            ),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _calculateReviewData(AppDatabase db, List<AppUsageRecord> records, Goal goal) async {
    final distractionApps = <String, int>{};
    final effectiveApps = <String, int>{};
    int totalEffectiveTime = 0;
    int totalEntertainTime = 0;

    // 目标实际总时长（含息屏）：endTime - startTime
    // 进行中目标 endTime 为 null，用 records 加总兜底
    final goalTotalTime = (goal.endTime != null && goal.endTime! > goal.startTime)
        ? (goal.endTime! - goal.startTime)
        : records.fold<int>(0, (sum, r) => sum + r.duration);

    if (records.isEmpty) {
      return {
        'effectiveApps': effectiveApps,
        'distractionApps': distractionApps,
        'totalEffectiveTime': totalEffectiveTime,
        'totalEntertainTime': totalEntertainTime,
        'effectiveRatio': 0.0,
        'topDistractionApps': <MapEntry<String, int>>[],
      };
    }

    // 批量查询所有 label，避免 N+1
    final recordIds = records.map((r) => r.id).toList();
    final mappings = await (db.select(db.recordLabelMappings).join([
      innerJoin(db.userLabels, db.userLabels.id.equalsExp(db.recordLabelMappings.labelId)),
    ])
      ..where(db.recordLabelMappings.recordId.isIn(recordIds)))
        .get();

    // 构建 recordId -> labels 的映射
    final labelsByRecordId = <int, List<UserLabel>>{};
    for (final row in mappings) {
      final recordId = row.readTable(db.recordLabelMappings).recordId;
      final label = row.readTable(db.userLabels);
      labelsByRecordId.putIfAbsent(recordId, () => []).add(label);
    }

    for (final record in records) {
      final labels = labelsByRecordId[record.id] ?? [];
      final hasEffectiveLabel = labels.any((label) => label.isEffective);
      final hasEntertainLabel = labels.any((label) {
        return label.name == '娱乐' || label.name == '刷视频';
      });

      if (hasEffectiveLabel) {
        effectiveApps[record.appName] = (effectiveApps[record.appName] ?? 0) + record.duration;
        totalEffectiveTime += record.duration;
      } else if (hasEntertainLabel) {
        distractionApps[record.appName] = (distractionApps[record.appName] ?? 0) + record.duration;
        totalEntertainTime += record.duration;
      }
      // 未打标签的不计入任何类别
    }

    // 专注度分母用目标实际时长（含息屏），而非仅 App 使用时间
    // 这样全程不用手机也能有合理的专注度，而非 0%
    final effectiveRatio = goalTotalTime > 0 ? totalEffectiveTime / goalTotalTime : 0.0;

    // 分心 App 按时长降序排序
    final topDistractionApps = distractionApps.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'topDistractionApps': topDistractionApps,
      'effectiveRatio': effectiveRatio,
      'totalEffectiveTime': totalEffectiveTime,
      'totalEntertainTime': totalEntertainTime,
      // AI 复盘所需额外数据
      'goalTotalTime': goalTotalTime,
      'screenOffTime': goalTotalTime - records.fold<int>(0, (s, r) => s + r.duration),
      'topEffectiveApps': (effectiveApps.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .take(3)
          .map((e) => '${e.key}(${(e.value / 60000).toStringAsFixed(0)}分钟)')
          .toList(),
    };
  }
}

/// 复盘卡片
class _ReviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final ThemeData theme;

  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 复盘建议卡片
class _ReviewSuggestionCard extends StatelessWidget {
  final double effectiveRatio;
  final ThemeData theme;

  const _ReviewSuggestionCard({
    required this.effectiveRatio,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    String suggestion;
    IconData suggestionIcon;
    Color suggestionColor;

    if (effectiveRatio >= 0.8) {
      suggestion = '表现优秀！继续保持专注习惯，可以尝试挑战更长的目标时长。';
      suggestionIcon = Icons.star_outline;
      suggestionColor = Colors.green;
    } else if (effectiveRatio >= 0.6) {
      suggestion = '表现不错！有效时间占比尚可，可以适当减少娱乐类 App 的使用时间。';
      suggestionIcon = Icons.trending_up_outlined;
      suggestionColor = Colors.blue;
    } else {
      suggestion = '需要提升！建议下次目标前清理一下手机，减少干扰因素。';
      suggestionIcon = Icons.tips_and_updates_outlined;
      suggestionColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            suggestionColor.withValues(alpha: 0.15),
            suggestionColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: suggestionColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(suggestionIcon, color: suggestionColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: suggestionColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// AI 复盘区域（v2：持久化 + 反馈）
// ─────────────────────────────────────────────────────

/// AI 复盘 Section
/// - 打开时自动加载历史复盘（避免重复消耗 token）
/// - 生成完毕自动保存到数据库
/// - 支持 👍👎 反馈
class _AiReviewSection extends StatefulWidget {
  final Goal goal;
  final Map<String, dynamic> reviewData;
  final ThemeData theme;
  final AppDatabase db;

  const _AiReviewSection({
    required this.goal,
    required this.reviewData,
    required this.theme,
    required this.db,
  });

  @override
  State<_AiReviewSection> createState() => _AiReviewSectionState();
}

class _AiReviewSectionState extends State<_AiReviewSection> {
  // 状态：init（加载历史） / idle / loading / streaming / done / error
  String _status = 'init';
  String _text = '';
  int? _feedback; // 1=👍 0=👎 null=未反馈
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// 加载数据库中已有的复盘文本
  Future<void> _loadHistory() async {
    final goal = await widget.db.getGoalById(widget.goal.id);
    if (!mounted) return;
    if (goal?.aiReviewText != null && goal!.aiReviewText!.isNotEmpty) {
      setState(() {
        _text = goal.aiReviewText!;
        _feedback = goal.aiReviewFeedback;
        _status = 'done';
      });
    } else {
      setState(() => _status = 'idle');
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _startReview() async {
    // 检查 API Key
    final apiKey = await LlmService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      if (!mounted) return;
      _showApiKeyDialog();
      return;
    }

    setState(() {
      _status = 'loading';
      _text = '';
      _feedback = null;
    });

    final goal = widget.goal;
    final data = widget.reviewData;
    final goalTotalTime = (data['goalTotalTime'] as int? ?? 0);
    final screenOffTime = (data['screenOffTime'] as int? ?? 0).clamp(0, goalTotalTime);
    final effectiveTime = (data['totalEffectiveTime'] as int? ?? 0);
    final topDistractionApps = (data['topDistractionApps'] as List<MapEntry<String, int>>)
        .take(3)
        .map((e) => '${e.key}(${(e.value / 60000).toStringAsFixed(0)}分钟)')
        .toList();
    final topEffectiveApps = (data['topEffectiveApps'] as List<String>? ?? []);

    final stream = LlmService.streamGoalReview(
      goalName: goal.title,
      totalMinutes: (goalTotalTime / 60000).round(),
      effectiveMinutes: (effectiveTime / 60000).round(),
      screenOffMinutes: (screenOffTime / 60000).round(),
      topDistractionApps: topDistractionApps,
      topEffectiveApps: topEffectiveApps,
    );

    setState(() => _status = 'streaming');

    _sub = stream.listen(
      (chunk) {
        if (mounted) setState(() => _text += chunk);
      },
      onDone: () async {
        if (!mounted) return;
        setState(() => _status = 'done');
        // 生成完毕 → 自动保存到数据库
        if (_text.isNotEmpty && !_text.startsWith('[')) {
          await widget.db.saveAiReview(widget.goal.id, _text);
        }
      },
      onError: (e) {
        if (mounted) setState(() {
          _text = '[出错了: $e]';
          _status = 'error';
        });
      },
    );
  }

  Future<void> _saveFeedback(int value) async {
    await widget.db.saveAiReviewFeedback(widget.goal.id, value);
    if (mounted) setState(() => _feedback = value);
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('配置 API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请输入阿里云百炼 API Key\n（dashscope.aliyuncs.com 控制台获取）',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'sk-...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                await LlmService.saveApiKey(key);
                if (ctx.mounted) Navigator.pop(ctx);
                _startReview();
              }
            },
            child: const Text('保存并生成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final primary = theme.colorScheme.primary;

    // 历史加载中
    if (_status == 'init') {
      return const SizedBox(height: 46);
    }

    // 无历史，显示触发按钮
    if (_status == 'idle') {
      return OutlinedButton.icon(
        onPressed: _startReview,
        icon: Icon(Icons.auto_awesome_outlined, size: 18, color: primary),
        label: Text('AI 复盘', style: TextStyle(color: primary)),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 46),
          side: BorderSide(color: primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    // 有内容（streaming / done / error）
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: 0.08),
            primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: primary),
              const SizedBox(width: 6),
              Text(
                'AI 复盘',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // 重新生成（仅 done/error 时显示）
              if (_status == 'done' || _status == 'error')
                GestureDetector(
                  onTap: _startReview,
                  child: Tooltip(
                    message: '重新生成',
                    child: Icon(Icons.refresh, size: 16, color: primary.withValues(alpha: 0.6)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 内容区
          if (_status == 'loading')
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                ),
                const SizedBox(width: 8),
                Text('生成中…', style: theme.textTheme.bodySmall?.copyWith(color: primary)),
              ],
            )
          else
            Text(
              _text + (_status == 'streaming' ? '▍' : ''),
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
              ),
            ),

          // 反馈按钮（仅 done 时显示）
          if (_status == 'done') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '这次复盘有帮助吗？',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 10),
                _FeedbackBtn(
                  icon: Icons.thumb_up_outlined,
                  iconSelected: Icons.thumb_up,
                  selected: _feedback == 1,
                  onTap: () => _saveFeedback(1),
                  color: Colors.green,
                ),
                const SizedBox(width: 6),
                _FeedbackBtn(
                  icon: Icons.thumb_down_outlined,
                  iconSelected: Icons.thumb_down,
                  selected: _feedback == 0,
                  onTap: () => _saveFeedback(0),
                  color: Colors.red,
                ),
                if (_feedback != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _feedback == 1 ? '谢谢反馈 👍' : '已记录，下次改进',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// 反馈按钮（选中/未选中状态）
class _FeedbackBtn extends StatelessWidget {
  final IconData icon;
  final IconData iconSelected;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FeedbackBtn({
    required this.icon,
    required this.iconSelected,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          selected ? iconSelected : icon,
          size: 14,
          color: selected ? color : Colors.grey,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool highlight;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label · ',
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final ThemeData theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// 把同一个 App 在时间上相邻的碎片记录合并为一条"完整使用段"
/// 规则：相邻两条记录的间隔 < [gapThresholdMs] 毫秒，则视为同一段连续使用
List<AppUsageRecord> _mergeAdjacentRecords(
  List<AppUsageRecord> records, {
  int gapThresholdMs = 130000, // 130 秒（心跳 2min + 容错 10s），同一 App 连续使用视为一段
}) {
  if (records.isEmpty) return records;

  // 先按开始时间排序
  final sorted = [...records]..sort((a, b) => a.startTime.compareTo(b.startTime));
  final merged = <AppUsageRecord>[];

  AppUsageRecord current = sorted.first;

  for (int i = 1; i < sorted.length; i++) {
    final next = sorted[i];
    final gap = next.startTime - current.endTime;

    if (current.packageName == next.packageName && gap <= gapThresholdMs) {
      // 同一 App 且时间连续，合并：保留 current 的 id（用于标签查询），
      // endTime 取两者最大值，duration 重新计算
      current = current.copyWith(
        endTime: next.endTime > current.endTime ? next.endTime : current.endTime,
        duration: (next.endTime > current.endTime ? next.endTime : current.endTime) - current.startTime,
      );
    } else {
      merged.add(current);
      current = next;
    }
  }
  merged.add(current);

  return merged;
}

/// Provider
final _goalRecordsProvider = FutureProvider.autoDispose.family<List<AppUsageRecord>, int>((ref, goalId) async {
  final db = ref.watch(databaseProvider);
  final raw = await db.getRecordsByGoal(goalId);
  // 展示时合并相邻同 App 碎片，保持精确数据的同时避免碎片化展示
  return _mergeAdjacentRecords(raw);
});

final _goalStatsProvider = FutureProvider.family<Map<String, int>, int>((ref, goalId) async {
  final db = ref.watch(databaseProvider);
  return db.getGoalStats(goalId);
});
