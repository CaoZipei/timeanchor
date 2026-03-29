import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';

// 统计页日期范围类型
enum StatsRange { week, month }

final statsRangeProvider = StateProvider<StatsRange>((ref) => StatsRange.week);

final statsDataProvider = FutureProvider.family<Map<String, int>, DateTime>(
  (ref, date) async {
    final db = ref.watch(databaseProvider);
    return db.getDurationByLabel(date);
  },
);

// 使用固定日期键避免 DateTime 对象每次不同导致重复查询
final weeklyStatsProvider = FutureProvider<List<DailyStat>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 6));
  return db.getDailyStatsRange(
    DateTime(from.year, from.month, from.day),
    DateTime(now.year, now.month, now.day, 23, 59),
  );
});

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // 用规范化的日期（去掉时分秒）作为 key，避免每次 build 创建不同的 DateTime 对象
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final statsAsync = ref.watch(statsDataProvider(today));
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final range = ref.watch(statsRangeProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '统计分析',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '了解你的时间去向',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 20),

            // 今日概览卡片
            _TodayOverviewCard(statsAsync: statsAsync),

            const SizedBox(height: 16),

            // 标签分布饼图
            _LabelPieChart(statsAsync: statsAsync),

            const SizedBox(height: 16),

            // 周/月趋势切换
            Row(
              children: [
                Text(
                  '趋势分析',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _RangeToggle(
                  selected: range,
                  onChanged: (r) =>
                      ref.read(statsRangeProvider.notifier).state = r,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 趋势折线图
            _TrendChart(weeklyAsync: weeklyAsync),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// 今日概览卡片
class _TodayOverviewCard extends ConsumerWidget {
  final AsyncValue<Map<String, int>> statsAsync;
  const _TodayOverviewCard({required this.statsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // ✅ 使用 DailyStat 中已正确计算的 effectiveTime（支持自定义标签）
    final weeklyAsync = ref.watch(weeklyStatsProvider);
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    return statsAsync.when(
      data: (data) {
        // ✅ 优先从 DailyStat 取 effectiveTime（口径与趋势图一致）
        int effective = 0;
        final todayStat = weeklyAsync.whenOrNull(
          data: (stats) => stats.where((s) {
            final d = DateTime(s.date.year, s.date.month, s.date.day);
            return d == todayKey;
          }).firstOrNull,
        );
        if (todayStat != null) {
          effective = todayStat.effectiveTime;
        } else {
          // 降级：用硬编码标签名（兜底，不依赖数据库查询）
          effective = data.entries
              .where((e) => _isEffective(e.key))
              .fold(0, (s, e) => s + e.value);
        }
        final total = data.values.fold(0, (s, v) => s + v);
        final ratio = total > 0 ? effective / total : 0.0;

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
                      label: '屏幕总时长',
                      value: _formatMs(total),
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      label: '有效时间',
                      value: _formatMs(effective),
                      color: AppTheme.secondaryColor,
                    ),
                    const SizedBox(width: 16),
                    _StatItem(
                      label: '有效率',
                      value: '${(ratio * 100).toStringAsFixed(0)}%',
                      color: ratio > 0.5
                          ? AppTheme.secondaryColor
                          : AppTheme.accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    backgroundColor:
                        theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(AppTheme.secondaryColor),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 120,
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
              const SizedBox(height: 12),
              Text(
                '💡 请确保已在系统设置中授予"使用情况统计"权限',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isEffective(String labelName) {
    const effectiveLabels = {'学习', '工作', '网课', '运动'};
    return effectiveLabels.contains(labelName);
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

// 标签饼图
class _LabelPieChart extends StatefulWidget {
  final AsyncValue<Map<String, int>> statsAsync;
  const _LabelPieChart({required this.statsAsync});

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
              '时间分配',
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
                      child: Text('今天还没有打标签的记录'),
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
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, st) => SizedBox(
                height: 200,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '⚠️ 加载失败',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '错误信息: ${e.toString().split('\n').first}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

// 趋势折线图
class _TrendChart extends StatelessWidget {
  final AsyncValue<List<DailyStat>> weeklyAsync;
  const _TrendChart({required this.weeklyAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: weeklyAsync.when(
          data: (stats) {
            if (stats.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(child: Text('暂无趋势数据')),
              );
            }

            return SizedBox(
              height: 180,
              child: LineChart(
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
                        reservedSize: 36,
                        getTitlesWidget: (v, _) {
                          // v 的单位是"分钟"（FlSpot 里已经 /60000 转成分钟）
                          final minutes = v.toInt();
                          if (minutes < 60) {
                            return Text(
                              '${minutes}m',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            );
                          }
                          return Text(
                            '${(minutes / 60).toStringAsFixed(1)}h',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32, // 增加预留空间
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          // 根据数据长度决定显示间隔：少于4个全显示，4-7个显示奇数，8个以上显示每2个
                          int interval;
                          if (stats.length <= 4) {
                            interval = 1;
                          } else if (stats.length <= 7) {
                            interval = 2; // 0, 2, 4, 6
                          } else {
                            interval = 3; // 0, 3, 6
                          }

                          if (i >= 0 && i < stats.length && i % interval == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('M/d', 'zh_CN').format(stats[i].date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        interval: 1.0, // 确保 FlChart 以 1.0 为间隔生成坐标
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
                    // 有效时间线
                    LineChartBarData(
                      spots: List.generate(stats.length, (i) {
                        return FlSpot(
                          i.toDouble(),
                          stats[i].effectiveTime / 60000,
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
                    // 娱乐时间线
                    LineChartBarData(
                      spots: List.generate(stats.length, (i) {
                        return FlSpot(
                          i.toDouble(),
                          stats[i].entertainTime / 60000,
                        );
                      }),
                      isCurved: true,
                      color: AppTheme.accentColor,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.accentColor.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => const SizedBox(
            height: 180,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⚠️ 趋势数据加载失败'),
                    SizedBox(height: 8),
                    Text(
                      '请检查数据权限',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
