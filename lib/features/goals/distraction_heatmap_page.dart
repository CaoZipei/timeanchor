import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';

/// 分心热力图页面
class DistractionHeatmapPage extends ConsumerWidget {
  const DistractionHeatmapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hourlyHeatmapAsync = ref.watch(_hourlyHeatmapProvider);
    final dailyHeatmapAsync = ref.watch(_dailyHeatmapProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('分心热力图'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文字
              Text(
                '基于最近 7 天的目标数据统计',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),

              // 按小时统计的热力图
              _HourlyHeatmapSection(hourlyHeatmapAsync: hourlyHeatmapAsync),
              const SizedBox(height: 32),

              // 按星期几统计的热力图
              _DailyHeatmapSection(dailyHeatmapAsync: dailyHeatmapAsync),
            ],
          ),
        ),
      ),
    );
  }
}

/// 按小时统计的热力图
class _HourlyHeatmapSection extends StatelessWidget {
  final AsyncValue<Map<String, int>> hourlyHeatmapAsync;

  const _HourlyHeatmapSection({required this.hourlyHeatmapAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '时间段分布',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        hourlyHeatmapAsync.when(
          data: (heatmap) => heatmap.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '暂无数据',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              : _HourlyHeatmapGrid(heatmap: heatmap),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败: $e')),
        ),
      ],
    );
  }
}

/// 按小时统计的热力图网格
class _HourlyHeatmapGrid extends StatelessWidget {
  final Map<String, int> heatmap;

  const _HourlyHeatmapGrid({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 找出最大值用于归一化
    final maxDuration = heatmap.values.reduce((a, b) => a > b ? a : b);
    final maxDurationMinutes = maxDuration / 60000;

    // 创建24小时的热力图
    final hours = List.generate(24, (i) => i);

    return Column(
      children: [
        // 图例
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('少'),
            const SizedBox(width: 8),
            ...List.generate(5, (i) {
              final opacity = (i + 1) / 5;
              return Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2 + opacity * 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
            const SizedBox(width: 8),
            const Text('多'),
          ],
        ),
        const SizedBox(height: 16),

        // 热力图网格（4行6列）
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 24,
          itemBuilder: (context, index) {
            final hour = hours[index];
            final timeSlotKey = '$hour-${hour + 1}';
            final duration = heatmap[timeSlotKey] ?? 0;
            final durationMinutes = duration / 60000;
            final opacity = maxDuration > 0 ? (duration / maxDuration) : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: opacity > 0
                    ? Colors.red.withValues(alpha: 0.2 + opacity * 0.6)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: opacity > 0
                      ? Colors.red.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$hour',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: opacity > 0 ? Colors.red.shade900 : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (durationMinutes > 0)
                    Text(
                      '${durationMinutes.toStringAsFixed(0)}m',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Colors.red.shade900,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // 提示信息
        if (maxDurationMinutes > 0)
          Text(
            '最易分心时段：${_findMostDistractedHour(heatmap)} (${maxDurationMinutes.toStringAsFixed(0)}分钟)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _findMostDistractedHour(Map<String, int> heatmap) {
    if (heatmap.isEmpty) return '无';

    final maxEntry = heatmap.entries.reduce((a, b) => a.value > b.value ? a : b);
    final hour = int.parse(maxEntry.key.split('-')[0]);
    return '$hour:00-${hour + 1}:00';
  }
}

/// 按星期几统计的热力图
class _DailyHeatmapSection extends StatelessWidget {
  final AsyncValue<Map<int, int>> dailyHeatmapAsync;

  const _DailyHeatmapSection({required this.dailyHeatmapAsync});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '星期分布',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        dailyHeatmapAsync.when(
          data: (heatmap) => heatmap.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      '暂无数据',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              : _DailyHeatmapGrid(heatmap: heatmap),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败: $e')),
        ),
      ],
    );
  }
}

/// 按星期几统计的热力图网格
class _DailyHeatmapGrid extends StatelessWidget {
  final Map<int, int> heatmap;

  const _DailyHeatmapGrid({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    // 找出最大值用于归一化
    final maxDuration = heatmap.values.reduce((a, b) => a > b ? a : b);
    final maxDurationMinutes = maxDuration / 60000;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 7,
          itemBuilder: (context, index) {
            final dayOfWeek = index + 1;
            final duration = heatmap[dayOfWeek] ?? 0;
            final durationMinutes = duration / 60000;
            final opacity = maxDuration > 0 ? (duration / maxDuration) : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // 星期标签
                  SizedBox(
                    width: 40,
                    child: Text(
                      weekdays[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 进度条
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          // 背景条
                          Container(
                            decoration: BoxDecoration(
                              color: opacity > 0
                                  ? Colors.orange.withValues(alpha: 0.2 + opacity * 0.6)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // 文字
                          Center(
                            child: Text(
                              durationMinutes > 0
                                  ? '${durationMinutes.toStringAsFixed(0)} 分钟'
                                  : '无分心',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: durationMinutes > 0 ? Colors.orange.shade900 : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        // 提示信息
        if (maxDurationMinutes > 0)
          Text(
            '最易分心的日子：${weekdays[_findMostDistractedDay(heatmap) - 1]} (${maxDurationMinutes.toStringAsFixed(0)}分钟)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  int _findMostDistractedDay(Map<int, int> heatmap) {
    if (heatmap.isEmpty) return 1;

    final maxEntry = heatmap.entries.reduce((a, b) => a.value > b.value ? a : b);
    return maxEntry.key;
  }
}

/// Providers
final _hourlyHeatmapProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getDistractionHeatmap(days: 7);
});

final _dailyHeatmapProvider = FutureProvider<Map<int, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getDistractionByDayOfWeek(weeks: 4);
});
