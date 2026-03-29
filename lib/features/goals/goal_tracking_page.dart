import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/accessibility_service.dart';
import '../../core/utils/time_formatter.dart';
import '../stats/stats_page.dart';
import 'goal_report_page.dart';
import 'distraction_heatmap_page.dart';
import 'goal_stats_trend_page.dart';

/// 目标管理页面
class GoalTrackingPage extends ConsumerStatefulWidget {
  const GoalTrackingPage({super.key});

  @override
  ConsumerState<GoalTrackingPage> createState() => _GoalTrackingPageState();
}

class _GoalTrackingPageState extends ConsumerState<GoalTrackingPage> with WidgetsBindingObserver {
  // 进程内防重复弹窗：同一次运行中只弹一次
  // 注意：从后台回来不重置，因为用户已知情（去设置也是自愿的）
  // 只在 App 冷启动时检测并弹一次；如果用户已开启权限则检测到 true 不会弹
  static bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 启动时检测：500ms 后第一次，3s 后补充一次（等服务初始化完成）
    Future.delayed(const Duration(milliseconds: 500), _checkPermission);
    Future.delayed(const Duration(seconds: 3), _checkPermission);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App 从后台回来：只有在权限已开启状态下才重置标志（允许再次检测）
  /// 如果权限没开，从后台回来不重新弹（避免无限弹窗）
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 不重置 _dialogShown，防止无限弹窗
      // 只做一次检测：如果权限开了就什么都不做，如果没开且还没弹过才弹
      Future.delayed(const Duration(milliseconds: 500), _checkPermission);
    }
  }

  Future<void> _checkPermission() async {
    if (!mounted || _dialogShown) return;
    final enabled = await AccessibilityService.isEnabled();
    if (!mounted || enabled) return; // 已开启，什么都不做
    _dialogShown = true;
    _showAccessibilityPrompt(context);
  }

  void _showAccessibilityPrompt(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('开启无障碍服务'),
          content: const Text(
            '时光锚需要使用无障碍服务来精确记录目标期间的应用使用情况。\n\n'
            '开启后，系统会显示"此服务可以读取您的屏幕内容"的提示，这是正常的安全提醒。\n\n'
            '请放心：我们只用于记录您在不同 App 之间的切换时间，不会收集任何其他隐私信息。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('暂不开启'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await AccessibilityService.openSettings();
              },
              child: const Text('去设置'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsAsync = ref.watch(allGoalsProvider);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '目标',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '设定目标，追踪专注',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 目标统计趋势按钮
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GoalStatsTrendPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 8),
                // 分心热力图按钮
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DistractionHeatmapPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_fire_department_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.warningColor.withValues(alpha: 0.1),
                  ),
                ),
                const SizedBox(width: 8),
                // 创建目标按钮
                IconButton(
                  onPressed: () => _showCreateGoalDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 目标列表
          Expanded(
            child: goalsAsync.when(
              data: (goals) => goals.isEmpty
                  ? _buildEmpty(context, theme)
                  : _buildGoalList(goals, theme, ref),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无目标',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角创建一个新目标',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalList(List<Goal> goals, ThemeData theme, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _GoalCard(goal: goal);
      },
    );
  }

  void _showCreateGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    bool isCountdownMode = true; // 默认倒计时模式

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final theme = Theme.of(dialogContext);
          return AlertDialog(
          title: const Text('创建目标'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '目标标题',
                  hintText: '例如：写代码2小时',
                ),
              ),
              const SizedBox(height: 16),

              // 模式切换
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text('倒计时'),
                    icon: Icon(Icons.timer_outlined),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text('自由计时'),
                    icon: Icon(Icons.all_inclusive),
                  ),
                ],
                selected: {isCountdownMode},
                onSelectionChanged: (Set<bool> selected) {
                  setDialogState(() {
                    isCountdownMode = selected.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 根据模式显示不同的输入框
              if (isCountdownMode)
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '预计时长（分钟）',
                    suffixText: '分钟',
                    helperText: '设定固定时长，到时自动提醒',
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '自由计时模式',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '没有固定时长，手动开始/结束',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final plannedDuration = isCountdownMode
                    ? (int.tryParse(durationController.text) ?? 30)
                    : null; // 自由计时模式下没有计划时长

                if (title.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('请输入目标标题')),
                  );
                  return;
                }

                if (isCountdownMode && plannedDuration == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('请输入有效的预计时长')),
                  );
                  return;
                }

                // 先关闭对话框
                Navigator.pop(dialogContext);

                // 执行异步操作
                final goalId = await ref.read(databaseProvider).createGoal(
                  title: title,
                  plannedDuration: plannedDuration,
                );

                // 设置活跃的 goalId，开始监听 App 切换
                await AccessibilityService.setActiveGoal(goalId);

                // 刷新目标列表
                ref.invalidate(allGoalsProvider);
              },
              child: const Text('开始'),
            ),
          ],
          );
        },
      ),
    );
  }
}

/// 目标卡片
class _GoalCard extends ConsumerStatefulWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  ConsumerState<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends ConsumerState<_GoalCard> {
  bool _isExpanded = false;
  Timer? _ticker;
  // 活跃目标：实时已过时间（秒）
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTickerIfActive();
  }

  @override
  void didUpdateWidget(_GoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.goal.status != widget.goal.status) {
      _startTickerIfActive();
    }
  }

  void _startTickerIfActive() {
    _ticker?.cancel();
    if (widget.goal.status == 'active') {
      // 计算到目前为止已过了多少秒
      final startMs = widget.goal.startTime;
      _elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - startMs) / 1000).round().clamp(0, 999999);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  /// 把秒数格式化为 "2:05:33" 或 "12:07" 样式
  String _formatElapsed(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// 倒计时剩余秒数（负数表示超时）
  int _remainingSeconds() {
    final planned = widget.goal.plannedDuration; // 分钟
    if (planned <= 0) return 0;
    return planned * 60 - _elapsedSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 计算完成率（仅在有实际时长且是倒计时模式时显示）
    double? completionRate;
    Color progressColor;
    if (widget.goal.actualDuration != null && widget.goal.plannedDuration > 0) {
      completionRate = (widget.goal.actualDuration! / widget.goal.plannedDuration).clamp(0, 1);
      if (completionRate != null && completionRate >= 1) {
        progressColor = AppTheme.successColor;
      } else if (completionRate != null && completionRate >= 0.8) {
        progressColor = theme.colorScheme.primary;
      } else {
        progressColor = AppTheme.warningColor;
      }
    } else {
      progressColor = theme.colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 点击卡片跳转到目标报告页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoalReportPage(goal: widget.goal),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上半部分：标题和操作按钮
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(widget.goal.status, theme).withValues(alpha: 0.1),
                  child: Icon(
                    _getStatusIcon(widget.goal.status),
                    color: _getStatusColor(widget.goal.status, theme),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.goal.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      _buildTimeDisplay(widget.goal, theme),
                      ],
                    ),
                  ),
                  if (widget.goal.status == 'active')
                    IconButton(
                      icon: const Icon(Icons.stop_circle_outlined),
                      color: AppTheme.errorColor,
                      onPressed: () async {
                        await _endGoal(context, ref, widget.goal);
                      },
                      tooltip: '结束目标',
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 中间部分：时长信息
              if (widget.goal.status == 'active') ...[
                // ✅ 活跃状态：显示实时已过时间 + 倒计时（如有）
                Row(
                  children: [
                    // 已过时间（实时跳动）
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            '已过 ${_formatElapsed(_elapsedSeconds)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 倒计时（有 plannedDuration 时才显示）
                    if (widget.goal.plannedDuration > 0)
                      Builder(builder: (context) {
                        final rem = _remainingSeconds();
                        final isOvertime = rem < 0;
                        final displaySec = isOvertime ? -rem : rem;
                        return Row(
                          children: [
                            Icon(
                              isOvertime ? Icons.warning_amber_rounded : Icons.hourglass_bottom_rounded,
                              size: 14,
                              color: isOvertime ? AppTheme.errorColor : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOvertime
                                  ? '超时 ${_formatElapsed(displaySec)}'
                                  : '剩 ${_formatElapsed(displaySec)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isOvertime
                                    ? AppTheme.errorColor
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: isOvertime ? FontWeight.w600 : null,
                              ),
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ] else ...[
                // ✅ 非活跃状态：显示静态时长摘要
                Row(
                  children: [
                    if (widget.goal.plannedDuration > 0)
                      Expanded(
                        child: Text(
                          '预计时长：${widget.goal.plannedDuration} 分钟',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    if (widget.goal.actualDuration != null)
                      Expanded(
                        child: Text(
                          '实际时长：${widget.goal.actualDuration} 分钟',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // 底部部分：进度条（仅在倒计时模式且有实际时长时显示）
              if (completionRate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: progressColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '完成率：${(completionRate * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

              // 展开按钮（仅活跃状态显示）
              if (widget.goal.status == 'active') ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isExpanded ? '收起活动记录' : '展开查看活动记录',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 展开后显示实时活动记录
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  FutureBuilder<List<AppUsageRecord>>(
                    future: ref.read(databaseProvider).getRecordsByGoal(widget.goal.id).then(_mergeRecords),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      final records = snapshot.data!;
                      if (records.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              '暂无活动记录',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '活动记录（${records.length}条）',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...records.map((record) => _buildActivityRecord(context, record)),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityRecord(BuildContext context, AppUsageRecord record) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.apps,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.appName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${record.startTime.formatTime()} - ${record.endTime.formatTime()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            record.duration.formatDuration(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// 根据目标状态构建时间显示文字
  Widget _buildTimeDisplay(Goal goal, ThemeData theme) {
    final startDt = DateTime.fromMillisecondsSinceEpoch(goal.startTime);
    final startStr = DateFormat('MM-dd HH:mm').format(startDt);

    String timeText;
    if (goal.status == 'active') {
      // 进行中：只显示开始时间
      timeText = '开始于 $startStr';
    } else if (goal.endTime != null) {
      // 已结束：显示 "开始 - 结束"
      final endDt = DateTime.fromMillisecondsSinceEpoch(goal.endTime!);
      final endStr = startDt.day == endDt.day
          ? DateFormat('HH:mm').format(endDt)           // 同一天只显示时间
          : DateFormat('MM-dd HH:mm').format(endDt);    // 跨天显示日期+时间
      timeText = '$startStr - $endStr';
    } else {
      // 无结束时间（理论上不应出现，兜底）
      timeText = startStr;
    }

    return Text(
      timeText,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'active':
        return theme.colorScheme.primary;
      case 'completed':
        return AppTheme.successColor;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.timer_outlined;
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// ✅ 结束目标流程：询问完成度 -> 直接保存（活动标签在报告页单独打）
  Future<void> _endGoal(BuildContext context, WidgetRef ref, Goal goal) async {
    final completed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('结束目标'),
        content: Text('你认为完成了目标「${goal.title}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('没有'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('完成了'),
          ),
        ],
      ),
    );

    if (completed == null) return; // 用户取消

    final db = ref.read(databaseProvider);
    await db.completeGoal(goal.id, completed: completed);
    await AccessibilityService.setActiveGoal(null);
    ref.invalidate(allGoalsProvider);
    // ✅ 同步刷新统计页的目标统计数据（目标数、完成数、Top Apps）
    ref.invalidate(todayGoalStatsProvider);
    ref.invalidate(goalTopAppsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(completed ? '✅ 目标完成！可在报告页为每条活动打标签' : '目标已结束'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}


/// 把同一个 App 相邻碎片合并为完整使用段（与报告页保持一致）
/// 阈值 130s = 2min 心跳 + 10s 容错
List<AppUsageRecord> _mergeRecords(List<AppUsageRecord> records, {int gapMs = 130000}) {
  if (records.isEmpty) return records;
  final sorted = [...records]..sort((a, b) => a.startTime.compareTo(b.startTime));
  final merged = <AppUsageRecord>[];
  AppUsageRecord cur = sorted.first;
  for (int i = 1; i < sorted.length; i++) {
    final next = sorted[i];
    if (cur.packageName == next.packageName && (next.startTime - cur.endTime) <= gapMs) {
      final newEnd = next.endTime > cur.endTime ? next.endTime : cur.endTime;
      cur = cur.copyWith(endTime: newEnd, duration: newEnd - cur.startTime);
    } else {
      merged.add(cur);
      cur = next;
    }
  }
  merged.add(cur);
  return merged;
}

/// Provider（公开，以便其他页面（如设置页清除数据后）可以 invalidate）
final allGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getAllGoals();
});
