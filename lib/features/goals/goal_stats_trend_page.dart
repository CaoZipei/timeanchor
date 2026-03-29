import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';

/// 目标统计趋势页面
class GoalStatsTrendPage extends ConsumerWidget {
  const GoalStatsTrendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trendAsync = ref.watch(_goalStatsTrendProvider);
    final suggestionAsync = ref.watch(_smartGoalSuggestionProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('目标统计趋势'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '这里记录你的专注历程：查看近30天目标完成情况，并根据历史数据智能推荐最适合你的目标时长。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 智能目标建议卡片
              _SmartGoalSuggestionCard(suggestionAsync: suggestionAsync),
              const SizedBox(height: 24),

              // 统计趋势图表
              _StatsTrendSection(trendAsync: trendAsync),
            ],
          ),
        ),
      ),
    );
  }
}

/// 智能目标建议卡片
class _SmartGoalSuggestionCard extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> suggestionAsync;

  const _SmartGoalSuggestionCard({required this.suggestionAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return suggestionAsync.when(
      data: (suggestion) {
        final suggestedDuration = suggestion['suggestedDuration'] as int;
        final reason = suggestion['reason'] as String;
        final avgCompletionRate = (suggestion['avgCompletionRate'] as double?) ?? 0.0;
        final dataPoints = suggestion['dataPoints'] as int;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '智能目标建议',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 建议时长
              Row(
                children: [
                  Text(
                    '建议目标时长：',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$suggestedDuration 分钟',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 建议理由
              Text(
                reason,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),

              if (dataPoints > 0) ...[
                const SizedBox(height: 12),
                // 统计信息
                Row(
                  children: [
                    _StatBadge(
                      label: '平均完成率',
                      value: '${avgCompletionRate.toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      color: avgCompletionRate >= 100 ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    _StatBadge(
                      label: '数据点',
                      value: '$dataPoints 个目标',
                      icon: Icons.bar_chart,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('正在分析历史数据...'),
          ],
        ),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Text(
              '完成更多目标后，这里将显示个性化建议',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 统计徽章
class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 统计趋势图表部分
class _StatsTrendSection extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> trendAsync;

  const _StatsTrendSection({required this.trendAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近30天趋势',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        trendAsync.when(
          data: (trend) => trend.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '暂无趋势数据',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '完成几个目标后，这里将显示你的专注趋势图',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _TrendChart(trend: trend),
          loading: () => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('加载趋势数据...'),
              ],
            ),
          ),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '加载失败，请稍后重试',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 趋势图表
class _TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> trend;

  const _TrendChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 找出最大完成率用于归一化
    final maxCompletionRate = trend.fold<double>(
      0,
      (max, data) {
        final rate = data['completionRate'] as double;
        return rate > max ? rate : max;
      },
    );

    return Column(
      children: [
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: Colors.green, label: '已完成'),
            const SizedBox(width: 16),
            _LegendItem(color: theme.colorScheme.primary, label: '完成率'),
          ],
        ),
        const SizedBox(height: 16),

        // 每日的数据条
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: trend.length,
          itemBuilder: (context, index) {
            final data = trend[index];
            final date = data['date'] as DateTime;
                        final completedCount = data['completedCount'] as int;
                            final completionRate = data['completionRate'] as double;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // 日期标签
                  SizedBox(
                    width: 50,
                    child: Text(
                      DateFormat('M/d').format(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 目标数量条
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // 已完成条
                            if (completedCount > 0)
                              Expanded(
                                flex: completedCount,
                                child: Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$completedCount',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // 完成率进度条
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: maxCompletionRate > 0 ? (completionRate / 100).clamp(0, 1) : 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: completionRate >= 100
                                          ? Colors.green
                                          : completionRate >= 80
                                              ? theme.colorScheme.primary
                                              : Colors.orange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${completionRate.toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: completionRate >= 100
                                    ? Colors.green
                                    : completionRate >= 80
                                        ? theme.colorScheme.primary
                                        : Colors.orange,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 图例项
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// Providers
final _goalStatsTrendProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getGoalStatsTrend(days: 30);
});

final _smartGoalSuggestionProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getSmartGoalSuggestion();
});
