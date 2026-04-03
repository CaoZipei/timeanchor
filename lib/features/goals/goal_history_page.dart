import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';

// ──────────────────────────────────────────────────────────
// 数据模型：单次目标的汇总数据
// ──────────────────────────────────────────────────────────
class _GoalSession {
  final Goal goal;
  final int index; // 第几次（1起）
  final double focusRate; // 专注率 0~1
  final int totalMs; // 实际时长 ms
  final int effectiveMs; // 有效时长 ms

  const _GoalSession({
    required this.goal,
    required this.index,
    required this.focusRate,
    required this.totalMs,
    required this.effectiveMs,
  });
}

// ──────────────────────────────────────────────────────────
// Provider：加载同名目标所有历史会话
// ──────────────────────────────────────────────────────────
final _goalHistoryProvider =
    FutureProvider.family<List<_GoalSession>, String>((ref, title) async {
  final db = ref.watch(databaseProvider);
  final goalList = await db.getGoalsByTitle(title);
  final sessions = <_GoalSession>[];
  for (int i = 0; i < goalList.length; i++) {
    final g = goalList[i];
    final stats = await db.getGoalStats(g.id);
    final total = stats['total'] ?? 0;
    final effective = stats['effective'] ?? 0;
    final rate = total > 0 ? (effective / total).clamp(0.0, 1.0) : 0.0;
    sessions.add(_GoalSession(
      goal: g,
      index: i + 1,
      focusRate: rate,
      totalMs: total,
      effectiveMs: effective,
    ));
  }
  return sessions;
});

// ──────────────────────────────────────────────────────────
// 页面入口
// ──────────────────────────────────────────────────────────
class GoalHistoryPage extends ConsumerWidget {
  final String goalTitle;
  const GoalHistoryPage({super.key, required this.goalTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final async = ref.watch(_goalHistoryProvider(goalTitle));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('「$goalTitle」历史趋势'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('暂无历史记录'));
          }
          if (sessions.length == 1) {
            return _SingleSessionHint(session: sessions.first);
          }
          return _HistoryContent(sessions: sessions);
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 只有 1 次记录时的提示
// ──────────────────────────────────────────────────────────
class _SingleSessionHint extends StatelessWidget {
  final _GoalSession session;
  const _SingleSessionHint({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_outlined,
                size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('只完成了一次', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '再完成一次「${session.goal.title}」，这里就会出现进步趋势图',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _StatBadge(
              label: '本次专注率',
              value: '${(session.focusRate * 100).round()}%',
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 主内容：图表 + 数据表格
// ──────────────────────────────────────────────────────────
class _HistoryContent extends StatelessWidget {
  final List<_GoalSession> sessions;
  const _HistoryContent({required this.sessions});

  String _fmtDuration(int ms) {
    final total = ms ~/ 1000;
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    if (h > 0) return '${h}h${m}m';
    return '${m}m';
  }

  String _fmtDate(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final best = sessions.reduce((a, b) => a.focusRate > b.focusRate ? a : b);
    final latest = sessions.last;
    final trend = sessions.length >= 2
        ? latest.focusRate - sessions[sessions.length - 2].focusRate
        : 0.0;

    // 专注率折线图数据
    final spots = sessions
        .map((s) => FlSpot(s.index.toDouble(), s.focusRate * 100))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 顶部统计行 ──
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: '总次数',
                  value: '${sessions.length}次',
                  icon: Icons.flag_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '最高专注率',
                  value: '${(best.focusRate * 100).round()}%',
                  icon: Icons.emoji_events_outlined,
                  color: const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '较上次',
                  value: trend >= 0
                      ? '+${(trend * 100).round()}%'
                      : '${(trend * 100).round()}%',
                  icon: trend >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  color: trend >= 0
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFFEF5350),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 专注率趋势折线图 ──
          Text('专注率趋势', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _FocusRateChart(sessions: sessions, spots: spots),
          ),

          const SizedBox(height: 24),

          // ── 时长趋势柱状图 ──
          Text('时长趋势（分钟）', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: _DurationChart(sessions: sessions),
          ),

          const SizedBox(height: 24),

          // ── 历史详情列表 ──
          Text('历史记录', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...sessions.reversed.map((s) => _SessionTile(
                session: s,
                fmtDuration: _fmtDuration,
                fmtDate: _fmtDate,
                isBest: s.index == best.index,
              )),

          const SizedBox(height: 24),

          // ── Insight 总结 ──
          if (sessions.length >= 2)
            _InsightCard(sessions: sessions, best: best),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Insight 总结卡
// ──────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final List<_GoalSession> sessions;
  final _GoalSession best;
  const _InsightCard({required this.sessions, required this.best});

  String _buildInsightText() {
    final first = sessions.first;
    final latest = sessions.last;
    final n = sessions.length;

    // 专注率变化
    final rateDelta = latest.focusRate - first.focusRate;
    final rateDeltaPct = (rateDelta * 100).abs().round();
    final rateFirst = (first.focusRate * 100).round();
    final rateLast = (latest.focusRate * 100).round();

    // 最佳次数
    final bestIndex = best.index;

    // 总有效时长
    final totalEffMs = sessions.fold(0, (sum, s) => sum + s.effectiveMs);
    final totalEffMin = totalEffMs ~/ 60000;
    final totalH = totalEffMin ~/ 60;
    final totalM = totalEffMin % 60;
    final totalStr = totalH > 0 ? '$totalH小时$totalM分钟' : '$totalM分钟';

    final sb = StringBuffer();

    // 句1：整体趋势
    if (rateDelta > 0.01) {
      sb.write('经过$n次练习，你的专注率从${rateFirst}%提升到了${rateLast}%，'
          '上涨了${rateDeltaPct}个百分点。');
    } else if (rateDelta < -0.01) {
      sb.write('最近这${n}次中，专注率从${rateFirst}%下滑到了${rateLast}%，'
          '降低了${rateDeltaPct}个百分点——但坚持记录本身就是进步。');
    } else {
      sb.write('你在${n}次练习中保持了稳定的专注水平（${rateLast}%），波动不大。');
    }

    sb.write(' ');

    // 句2：最佳次数
    if (bestIndex == n) {
      sb.write('最近一次就是你的最佳表现，势头很好！');
    } else if (bestIndex == 1) {
      sb.write('第1次就达到了最高专注率（${(best.focusRate * 100).round()}%），'
          '之后可以尝试找回那次的状态。');
    } else {
      sb.write('第${bestIndex}次是你的巅峰（${(best.focusRate * 100).round()}%），'
          '不妨回忆一下那天有什么不同。');
    }

    sb.write(' ');

    // 句3：累计有效时长
    sb.write('累计有效专注时长 $totalStr，加油继续！');

    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = _buildInsightText();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 专注率折线图
// ──────────────────────────────────────────────────────────
class _FocusRateChart extends StatelessWidget {
  final List<_GoalSession> sessions;
  final List<FlSpot> spots;
  const _FocusRateChart({required this.sessions, required this.spots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxY = max(100.0, spots.map((s) => s.y).reduce(max) + 10);

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: sessions.length.toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 32,
              getTitlesWidget: (v, meta) => Text(
                '${v.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt() - 1;
                if (idx < 0 || idx >= sessions.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '第${v.toInt()}次',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: theme.colorScheme.primary,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: theme.colorScheme.primary,
                strokeColor: theme.colorScheme.surface,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: theme.colorScheme.inverseSurface,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toStringAsFixed(1)}%',
                      TextStyle(
                        color: theme.colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 时长柱状图
// ──────────────────────────────────────────────────────────
class _DurationChart extends StatelessWidget {
  final List<_GoalSession> sessions;
  const _DurationChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxMin = sessions
        .map((s) => s.totalMs / 60000)
        .reduce(max);
    final maxY = ((maxMin / 10).ceil() * 10 + 10).toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 32,
              getTitlesWidget: (v, meta) => Text(
                v.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= sessions.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '第${sessions[idx].index}次',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(sessions.length, (i) {
          final minutes = sessions[i].totalMs / 60000;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: minutes,
                width: sessions.length > 8 ? 10 : 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.5),
                    theme.colorScheme.primary,
                  ],
                ),
              ),
            ],
          );
        }),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: theme.colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final s = sessions[group.x.toInt()];
              final h = s.totalMs ~/ 3600000;
              final m = (s.totalMs % 3600000) ~/ 60000;
              final label = h > 0 ? '${h}h${m}m' : '${m}m';
              return BarTooltipItem(
                label,
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 顶部统计卡片
// ──────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 历史条目
// ──────────────────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final _GoalSession session;
  final String Function(int ms) fmtDuration;
  final String Function(int ms) fmtDate;
  final bool isBest;

  const _SessionTile({
    required this.session,
    required this.fmtDuration,
    required this.fmtDate,
    required this.isBest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rate = session.focusRate;
    final rateColor = rate >= 0.7
        ? const Color(0xFF66BB6A)
        : rate >= 0.4
            ? const Color(0xFFFFB74D)
            : const Color(0xFFEF5350);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: isBest
            ? Border.all(color: const Color(0xFFFFB74D).withOpacity(0.6))
            : null,
      ),
      child: Row(
        children: [
          // 次数标记
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${session.index}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fmtDate(session.goal.startTime),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '最佳',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFFB74D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '时长 ${fmtDuration(session.totalMs)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
          // 专注率
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(rate * 100).round()}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: rateColor,
                ),
              ),
              Text(
                '专注率',
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// 小图标徽章
// ──────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55))),
      ],
    );
  }
}
