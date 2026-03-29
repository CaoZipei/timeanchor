import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/time_formatter.dart';
import '../../core/services/usage_stats_service.dart';

// 统计页日期范围类型
enum StatsRange { week, month }

final statsRangeProvider = StateProvider<StatsRange>((ref) => StatsRange.week);

// ✅ 全天标签/App 分布（今日）
// 优先级：标签分布 > 本地 app_usage_records > 系统 UsageStats API（清除数据后 fallback）
// 即使清除本地数据库数据，也能从系统 API 直接获取今日应用分布
final dailyAppStatsProvider = FutureProvider.family<Map<String, int>, DateTime>(
  (ref, date) async {
    final db = ref.watch(databaseProvider);
    // 先尝试标签分布
    final labelStats = await db.getDurationByLabel(date);
    // 如果有打过标签（非"其他"的 key 存在），就用标签分布
    final hasLabels = labelStats.keys.any((k) => k != '其他');
    if (hasLabels) return labelStats;

    // 尝试从本地数据库获取 App 分布（只用 UsageStats 来源记录，避免目标监控重复计时）
    final records = await db.getUsageStatsRecordsByDate(date);
    if (records.isNotEmpty) {
      final appDuration = <String, int>{};
      for (final r in records) {
        appDuration[r.appName] = (appDuration[r.appName] ?? 0) + r.duration;
      }
      final sorted = appDuration.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final result = <String, int>{};
      int otherDuration = 0;
      for (int i = 0; i < sorted.length; i++) {
        if (i < 7) {
          result[sorted[i].key] = sorted[i].value;
        } else {
          otherDuration += sorted[i].value;
        }
      }
      if (otherDuration > 0) result['其他'] = otherDuration;
      return result;
    }

    // ✅ Fallback：本地数据库为空时，直接从系统 UsageStats API 获取今日数据
    // 清除数据后仍然可以显示真实的今日应用使用分布
    try {
      final service = ref.read(usageStatsServiceProvider);
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final rawData = await service.queryUsageStats(from: startOfDay, to: endOfDay);
      if (rawData.isEmpty) return {};

      final appDuration = <String, int>{};
      for (final item in rawData) {
        final appName = item['appName'] as String? ?? '未知应用';
        final duration = item['totalTimeInForeground'] as int? ?? 0;
        if (duration > 60000) { // 过滤 1 分钟以下
          appDuration[appName] = (appDuration[appName] ?? 0) + duration;
        }
      }
      if (appDuration.isEmpty) return {};

      final sorted = appDuration.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final result = <String, int>{};
      int otherDuration = 0;
      for (int i = 0; i < sorted.length; i++) {
        if (i < 7) {
          result[sorted[i].key] = sorted[i].value;
        } else {
          otherDuration += sorted[i].value;
        }
      }
      if (otherDuration > 0) result['其他'] = otherDuration;
      return result;
    } catch (_) {
      return {};
    }
  },
);



// ✅ 获取今日目标统计
final todayGoalStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  // 获取今日的所有目标
  final allGoals = await db.getAllGoals();
  final todayGoals = allGoals.where((g) => g.startTime >= startOfDay.millisecondsSinceEpoch).toList();

  final totalGoals = todayGoals.length;
  final completedGoals = todayGoals.where((g) => g.status == 'completed').length;
  final userCompletedGoals = todayGoals.where((g) => g.completed == true).length;

  // 计算自评完成率
  final completionRate = completedGoals > 0 ? userCompletedGoals / completedGoals : 0.0;

  // 计算目标期间手机使用总时长
  int totalPhoneUsage = 0;
  for (final goal in todayGoals) {
    final records = await db.getRecordsByGoal(goal.id);
    totalPhoneUsage += records.fold(0, (sum, r) => sum + r.duration);
  }

  return {
    'totalGoals': totalGoals,
    'completedGoals': completedGoals,
    'userCompletedGoals': userCompletedGoals,
    'completionRate': completionRate,
    'totalPhoneUsage': totalPhoneUsage,
  };
});

// ✅ 获取目标期间App使用Top 5
final goalTopAppsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final range = ref.watch(statsRangeProvider);

  DateTime startDate;
  if (range == StatsRange.week) {
    startDate = now.subtract(const Duration(days: 6));
  } else {
    startDate = DateTime(now.year, now.month - 1, now.day);
  }

  // 获取范围内的所有已完成目标
  final allGoals = await db.getAllGoals();
  final goals = allGoals
      .where((g) => g.status == 'completed')
      .where((g) => g.endTime != null && g.endTime! >= startDate.millisecondsSinceEpoch)
      .toList();

  if (goals.isEmpty) return [];

  // 按包名统计总时长
  final appDuration = <String, int>{};
  final appNameMap = <String, String>{};

  for (final goal in goals) {
    final records = await db.getRecordsByGoal(goal.id);
    for (final record in records) {
      appDuration[record.packageName] = (appDuration[record.packageName] ?? 0) + record.duration;
      appNameMap[record.packageName] = record.appName;
    }
  }

  // 排序取Top 5
  final sorted = appDuration.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(5).map((e) => {
    'packageName': e.key,
    'appName': appNameMap[e.key]!,
    'duration': e.value,
  }).toList();
});

// ✅ 获取自评完成率趋势
final completionRateTrendProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final range = ref.watch(statsRangeProvider);

  DateTime startDate;
  int days;
  if (range == StatsRange.week) {
    startDate = now.subtract(const Duration(days: 6));
    days = 7;
  } else {
    startDate = DateTime(now.year, now.month - 1, now.day);
    days = 30;
  }

  // 获取范围内的所有已完成目标
  final allGoals = await db.getAllGoals();
  final goals = allGoals
      .where((g) => g.status == 'completed')
      .where((g) => g.endTime != null && g.endTime! >= startDate.millisecondsSinceEpoch)
      .toList();

  if (goals.isEmpty) return [];

  // 按日期分组统计
  final trendMap = <String, Map<String, dynamic>>{};

  for (final goal in goals) {
    final date = DateTime.fromMillisecondsSinceEpoch(goal.endTime!);
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    if (!trendMap.containsKey(dateKey)) {
      trendMap[dateKey] = {
        'date': date,
        'totalCompleted': 0,
        'userCompleted': 0,
      };
    }

    trendMap[dateKey]!['totalCompleted'] = trendMap[dateKey]!['totalCompleted'] + 1;
    if (goal.completed == true) {
      trendMap[dateKey]!['userCompleted'] = trendMap[dateKey]!['userCompleted'] + 1;
    }
  }

  // 计算每日完成率
  return trendMap.values.map((data) {
    final totalCompleted = data['totalCompleted'] as int;
    final userCompleted = data['userCompleted'] as int;
    final rate = totalCompleted > 0 ? userCompleted / totalCompleted : 0.0;

    return {
      ...data,
      'completionRate': rate,
    };
  }).toList();
});

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final range = ref.watch(statsRangeProvider);
    // 今日 App 分布（和时间轴同源，规范化日期作为 key）
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final labelStatsAsync = ref.watch(dailyAppStatsProvider(today));

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '目标成就',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '了解你的专注情况',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 20),

            // 今日概览卡片
            _TodayGoalOverviewCard(statsAsync: ref.watch(todayGoalStatsProvider)),

            const SizedBox(height: 16),

            // ✅ 全天标签/应用饼图（有打标签时显示标签分布，否则降级为应用分布）
            _LabelPieChart(
              statsAsync: labelStatsAsync,
              title: labelStatsAsync.maybeWhen(
                data: (data) {
                  final hasLabels = data.keys.any((k) => k != '其他');
                  return hasLabels ? '今日标签分布' : '今日应用分布';
                },
                orElse: () => '今日使用分布',
              ),
            ),

            const SizedBox(height: 16),

            // 目标期间App使用Top 5
            _GoalTopAppsChart(topAppsAsync: ref.watch(goalTopAppsProvider)),

            const SizedBox(height: 16),

            // 完成率趋势
            Row(
              children: [
                Text(
                  '完成率趋势',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _RangeToggle(
                  selected: range,
                  onChanged: (r) => ref.read(statsRangeProvider.notifier).state = r,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 完成率折线图
            _CompletionRateTrendChart(trendAsync: ref.watch(completionRateTrendProvider)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// 今日概览卡片
class _TodayGoalOverviewCard extends StatelessWidget {
  final AsyncValue<Map<String, dynamic>> statsAsync;
  const _TodayGoalOverviewCard({required this.statsAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return statsAsync.when(
      data: (data) {
        final totalGoals = data['totalGoals'] as int;
        final completedGoals = data['completedGoals'] as int;
        final userCompletedGoals = data['userCompletedGoals'] as int;
        final completionRate = data['completionRate'] as double;
        final totalPhoneUsage = data['totalPhoneUsage'] as int;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '今日概览',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MM/dd').format(DateTime.now()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatItem(
                      label: '目标数',
                      value: '$totalGoals',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      label: '已完成',
                      value: '$completedGoals',
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      label: '自评完成',
                      value: '$userCompletedGoals',
                      color: AppTheme.successColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatItem(
                      label: '自评完成率',
                      value: '${(completionRate * 100).toStringAsFixed(0)}%',
                      color: completionRate > 0.5
                          ? AppTheme.secondaryColor
                          : AppTheme.accentColor,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      label: '手机使用',
                      value: _formatMs(totalPhoneUsage),
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 完成率进度条
                if (completedGoals > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: completionRate.clamp(0.0, 1.0),
                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation(AppTheme.secondaryColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '完成率: ${(completionRate * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, st) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ 数据加载失败',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '错误: ${e.toString()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMs(int ms) {
    final m = ms ~/ 60000;
    if (m == 0) return '0 分钟';
    if (m < 60) return '$m 分钟';
    return '${m ~/ 60}h ${m % 60}m';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// 目标期间App使用Top 5条形图
class _GoalTopAppsChart extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> topAppsAsync;
  const _GoalTopAppsChart({required this.topAppsAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '目标期间App使用Top 5',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            topAppsAsync.when(
              data: (topApps) {
                if (topApps.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('暂无数据,先完成一个目标吧'),
                    ),
                  );
                }

                final maxDuration = topApps.first['duration'] as int;

                return Column(
                  children: topApps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final app = entry.value;
                    final duration = app['duration'] as int;
                    final widthRatio = maxDuration > 0 ? duration / maxDuration : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${index + 1}.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  app['appName'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatDuration(duration),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: widthRatio,
                              backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                              valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => SizedBox(
                height: 150,
                child: Center(
                  child: Text('加载失败: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final m = ms ~/ 60000;
    if (m < 60) return '$m分';
    return '${m ~/ 60}h${m % 60}m';
  }
}

// 完成率趋势折线图
class _CompletionRateTrendChart extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> trendAsync;
  const _CompletionRateTrendChart({required this.trendAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 180,
          child: trendAsync.when(
            data: (trend) {
              if (trend.isEmpty) {
                return const Center(child: Text('暂无趋势数据'));
              }

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) => FlLine(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) {
                          final rate = v.toInt();
                          return Text(
                            '$rate%',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          );
                        },
                        interval: 20,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i >= 0 && i < trend.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('M/d').format(trend[i]['date']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(trend.length, (i) {
                        return FlSpot(
                          i.toDouble(),
                          (trend[i]['completionRate'] as double) * 100,
                        );
                      }),
                      isCurved: true,
                      color: AppTheme.secondaryColor,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.secondaryColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => const Center(
              child: Text('加载失败'),
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ 全天标签/应用饼图（有标签时显示标签分布，无标签时显示应用分布）
class _LabelPieChart extends StatefulWidget {
  final AsyncValue<Map<String, int>> statsAsync;
  /// 图表标题，由调用方根据实际数据类型传入
  final String title;
  const _LabelPieChart({required this.statsAsync, this.title = '今日使用分布'});

  @override
  State<_LabelPieChart> createState() => _LabelPieChartState();
}

class _LabelPieChartState extends State<_LabelPieChart> {
  int touchedIndex = -1;

  static const _colors = [
    AppTheme.tagStudy,
    AppTheme.tagWork,
    AppTheme.tagEntertain,
    AppTheme.tagRest,
    AppTheme.tagSocial,
    AppTheme.tagShopping,
    AppTheme.tagExercise,
    AppTheme.tagOther,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            widget.statsAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('今天暂无使用记录'),
                    ),
                  );
                }
                final entries = data.entries.toList();
                final total = data.values.fold(0, (s, v) => s + v);

                return Row(
                  children: [
                    // 饼图
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                touchedIndex = response?.touchedSection
                                        ?.touchedSectionIndex ??
                                    -1;
                              });
                            },
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: List.generate(entries.length, (i) {
                            final isTouched = i == touchedIndex;
                            final value = entries[i].value;
                            final pct = value / total * 100;
                            return PieChartSectionData(
                              color: _colors[i % _colors.length],
                              value: value.toDouble(),
                              title: '${pct.toStringAsFixed(0)}%',
                              radius: isTouched ? 65 : 55,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 图例
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(entries.length, (i) {
                          final entry = entries[i];
                          final min = entry.value ~/ 60000;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _colors[i % _colors.length],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  entry.key,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  min < 60
                                      ? '$min 分'
                                      : '${min ~/ 60}h${min % 60}m',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    '加载失败',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 周/月切换
class _RangeToggle extends StatelessWidget {
  final StatsRange selected;
  final ValueChanged<StatsRange> onChanged;

  const _RangeToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            label: '周',
            selected: selected == StatsRange.week,
            onTap: () => onChanged(StatsRange.week),
          ),
          _ToggleBtn(
            label: '月',
            selected: selected == StatsRange.month,
            onTap: () => onChanged(StatsRange.month),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
