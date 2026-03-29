import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/utils/app_logger.dart';
import 'features/timeline/timeline_page.dart';
import 'features/stats/stats_page.dart';
import 'features/goals/goal_tracking_page.dart';
import 'features/settings/settings_page.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化中文日期本地化数据
  await initializeDateFormatting('zh_CN', null);
  // 初始化数据库
  final db = AppDatabase();

  // ✅ 清理重复的 DailyStats 数据
  try {
    await db.cleanupDuplicateDailyStats();
  } catch (e) {
    AppLogger.error('Error cleaning up duplicate stats: $e', null, null, 'Database');
  }

  // ✅ 清理无效的使用记录（startTime >= endTime）
  try {
    await db.cleanupInvalidUsageRecords();
  } catch (e) {
    AppLogger.error('Error cleaning up invalid usage records: $e', null, null, 'Database');
  }

  // ✅ 重新计算历史统计数据（修复 DailyStats 数据）
  try {
    await db.refreshAllDailyStats();
  } catch (e) {
    AppLogger.error('Error recalculating daily stats: $e', null, null, 'Database');
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const TimeAnchorApp(),
    ),
  );
}

class TimeAnchorApp extends ConsumerWidget {
  const TimeAnchorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: '时光锚',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    GoalTrackingPage(),
    TimelinePage(),
    StatsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: '目标',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: '时间轴',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
