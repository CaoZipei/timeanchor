import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:url_launcher/url_launcher.dart';

import '../../core/database/app_database.dart';
import '../../core/services/usage_stats_service.dart';
import '../../core/services/accessibility_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_logger.dart';
import '../../providers/theme_provider.dart';
import '../../providers/storage_provider.dart';
import '../stats/stats_page.dart';
import '../timeline/timeline_page.dart';
import '../goals/goal_tracking_page.dart';
import 'data_export_page.dart';

// 全局标签流 Provider
final allLabelsProvider = StreamProvider<List<UserLabel>>((ref) {
  return ref.watch(databaseProvider).watchAllLabels();
});

// ✅ 权限状态 Provider（StateProvider，支持手动刷新）
final accessibilityPermissionProvider = StateProvider<bool>((ref) => false);

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with WidgetsBindingObserver {
  bool _accessibilityEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ✅ 冷启动/Tab 切换时延迟检测，避免系统未准备好时误报无权限
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _refreshAccessibilityStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App 从后台回来（例如：用户在系统无障碍设置页完成操作后回到 App）
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ 延迟 800ms：MIUI/HyperOS 开启无障碍权限后系统需要一点时间更新状态
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) _refreshAccessibilityStatus();
      });
    }
  }

  Future<void> _refreshAccessibilityStatus() async {
    final isEnabled = await AccessibilityService.isEnabled();
    if (mounted) {
      setState(() {
        _accessibilityEnabled = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final labelsAsync = ref.watch(allLabelsProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设置',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '个性化你的时光锚',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            _SectionTitle(title: '外观'),
            Card(
              child: Column(
                children: [
                  _ThemeOptionTile(
                    label: '浅色',
                    icon: Icons.light_mode_rounded,
                    selected: themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.light),
                  ),
                  const Divider(height: 1, indent: 16),
                  _ThemeOptionTile(
                    label: '深色',
                    icon: Icons.dark_mode_rounded,
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.dark),
                  ),
                  const Divider(height: 1, indent: 16),
                  _ThemeOptionTile(
                    label: '跟随系统',
                    icon: Icons.brightness_auto_rounded,
                    selected: themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '权限管理'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.query_stats_rounded,
                          color: Colors.orange, size: 20),
                    ),
                    title: const Text(
                      '使用记录权限',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('App 使用时间监控所必须', style: TextStyle(fontSize: 12)),
                    trailing: FutureBuilder<bool>(
                      future: ref.read(usageStatsServiceProvider).hasPermission(),
                      builder: (context, snapshot) {
                        final hasPermission = snapshot.data ?? false;
                        return TextButton.icon(
                          onPressed: () async {
                            final service = ref.read(usageStatsServiceProvider);
                            await service.requestPermission();
                          },
                          icon: Icon(
                            hasPermission ? Icons.check_circle : Icons.warning_amber_rounded,
                            size: 16,
                            color: hasPermission ? Colors.green : Colors.orange,
                          ),
                          label: Text(hasPermission ? '已授权' : '去授权'),
                          style: TextButton.styleFrom(
                            foregroundColor: hasPermission ? Colors.green : Colors.orange,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 16),
                  // ✅ 无障碍服务权限检查：用 _accessibilityEnabled 状态变量（通过 didChangeAppLifecycleState 刷新）
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.accessibility_new_rounded,
                          color: Colors.blue, size: 20),
                    ),
                    title: const Text(
                      '无障碍服务',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('目标监控精确记录所必须', style: TextStyle(fontSize: 12)),
                    trailing: TextButton.icon(
                      onPressed: () async {
                        await _openAccessibilitySettings(context);
                        // 返回后延迟刷新（给系统时间更新权限状态）
                        await Future.delayed(const Duration(milliseconds: 800));
                        await _refreshAccessibilityStatus();
                      },
                      icon: Icon(
                        _accessibilityEnabled ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: 16,
                        color: _accessibilityEnabled ? Colors.green : Colors.red,
                      ),
                      label: Text(_accessibilityEnabled ? '已开启' : '去开启'),
                      style: TextButton.styleFrom(
                        foregroundColor: _accessibilityEnabled ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '数据导出'),
            Card(
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.download_rounded,
                      color: Colors.green, size: 20),
                ),
                title: const Text(
                  '导出数据',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  '导出为 CSV 或 JSON 格式',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DataExportPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '标签管理'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.label_rounded,
                          color: Colors.purple, size: 20),
                    ),
                    title: const Text(
                      '我的标签',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '共 ${labelsAsync.value?.length ?? 0} 个标签',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLabelManager(context, ref, labelsAsync),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: Colors.teal, size: 20),
                    ),
                    title: const Text(
                      '标签统计',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('查看各标签的使用情况', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLabelStats(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '数据管理'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: Colors.amber, size: 20),
                    ),
                    title: const Text(
                      '重新计算统计数据',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('手动触发统计更新', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showRefreshStatsDialog(context, ref),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_sweep_rounded,
                          color: Colors.red, size: 20),
                    ),
                    title: const Text(
                      '清除所有数据',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                    subtitle: const Text('删除所有记录(预设标签保留)', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showClearDataDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '数据存储'),
            Card(
              child: ref.watch(storagePathStateProvider).when(
                data: (path) => ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.folder_open_rounded,
                        color: Colors.blue, size: 20),
                  ),
                  title: const Text(
                    '存储路径',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    path,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        onPressed: () => _showChangeStoragePath(context, ref),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline, size: 18),
                        onPressed: () => _showStoragePathInfo(context, path),
                      ),
                    ],
                  ),
                ),
                loading: () => const ListTile(
                  title: Text('加载中...'),
                ),
                error: (e, _) => ListTile(
                  title: const Text('路径加载失败'),
                  subtitle: Text(e.toString(), style: const TextStyle(fontSize: 11)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: '关于'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('👁',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center),
                    ),
                    title: const Text(
                      '时光锚 TimeAnchor',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text('v1.0.0 · 觉察即改变'),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('隐私政策'),
                    trailing: const Icon(Icons.open_in_new, size: 18),
                    onTap: () => _launchPrivacyPolicy(),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    title: const Text('使用条款'),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => _showTermsOfService(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showChangeStoragePath(BuildContext context, WidgetRef ref) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('更改存储路径'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入新路径'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newPath = controller.text.trim();
              // TODO: 实现路径更改功能
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showStoragePathInfo(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('存储路径说明'),
        content: Text('App数据将保存在:\n$path'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  /// 跳转到系统无障碍设置页，并在返回后显示提示
  Future<void> _openAccessibilitySettings(BuildContext context) async {
    await AccessibilityService.openSettings();
    // 延迟一点等用户返回，然后给个提示
    await Future.delayed(const Duration(milliseconds: 800));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请在无障碍服务列表中找到"时光锚"并开启'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }



  void _showLabelManager(BuildContext context, WidgetRef ref, AsyncValue<List<UserLabel>> labelsAsync) {
    labelsAsync.whenData((labels) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _LabelManagerPage(labels: labels),
        ),
      );
      ref.invalidate(allLabelsProvider);
    });
  }

  void _showLabelStats(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _LabelStatsDialog(ref: ref),
    );
  }

  void _showRefreshStatsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('重新计算统计数据'),
        content: const Text('这将重新计算所有日期的统计数据,可能需要一些时间。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.refreshAllDailyStats();

              // 刷新 Provider 数据,确保 UI 更新
              ref.invalidate(allLabelsProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 统计数据已重新计算')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清除所有数据'),
        content: const Text('这将删除所有使用记录、目标和统计数据。\n预设标签将被保留。\n\n此操作不可恢复!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await db.clearAllData();

              // ✅ 清除无障碍服务的活跃 goalId，防止 Service 继续用旧 goalId 写入记录
              await AccessibilityService.setActiveGoal(null);

              // 刷新所有相关 Provider，确保目标页、统计页、时间轴页都更新
              // ✅ 注意：dailyAppStatsProvider 不 invalidate，
              //    清除数据后它会自动 fallback 到系统 UsageStats API，继续显示今日应用分布
              ref.invalidate(allLabelsProvider);
              ref.invalidate(allGoalsProvider);
              ref.invalidate(dailyRecordsProvider);
              ref.invalidate(todayGoalStatsProvider);
              ref.invalidate(goalTopAppsProvider);
              ref.invalidate(completionRateTrendProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 所有数据已清除,预设标签已保留')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://caozipei.github.io/timeanchor/privacy_policy.html');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '时光锚(TimeAnchor) 隐私政策\n\n'
            '1. 数据收集\n'
            '本应用仅收集设备上的App使用时间数据,所有数据均存储在本地设备上。\n\n'
            '2. 数据使用\n'
            '收集的数据仅用于生成使用时间统计和目标监控报告,不会用于其他目的。\n\n'
            '3. 数据共享\n'
            '我们不会将您的任何数据共享给第三方。\n\n'
            '4. 数据安全\n'
            '我们采取合理的安全措施保护您的数据,但不能保证绝对安全。\n\n'
            '5. 权限说明\n'
            '本应用需要"使用情况访问权限"来获取App使用时间数据,这是核心功能所必需的。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('使用条款'),
        content: const SingleChildScrollView(
          child: Text(
            '时光锚(TimeAnchor) 使用条款\n\n'
            '1. 使用许可\n'
            '本应用仅供个人使用,不得用于商业目的。\n\n'
            '2. 免责声明\n'
            '本应用按"现状"提供,不提供任何明示或暗示的保证。\n\n'
            '3. 用户责任\n'
            '用户应合法合规地使用本应用,不得用于任何违法目的。\n\n'
            '4. 数据备份\n'
            '建议用户定期备份重要数据,我们不对数据丢失负责。\n\n'
            '5. 条款更新\n'
            '我们保留随时更新本条款的权利。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20),
      ),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle,
              color: theme.colorScheme.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _LabelManagerPage extends ConsumerStatefulWidget {
  final List<UserLabel> labels;
  const _LabelManagerPage({required this.labels});

  @override
  ConsumerState<_LabelManagerPage> createState() => _LabelManagerPageState();
}

class _LabelManagerPageState extends ConsumerState<_LabelManagerPage> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedColor = Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showAddLabelDialog() {
    _nameController.clear();
    _selectedColor = Colors.blue;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建标签'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '标签名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('选择颜色'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _ColorOption(
                  color: Colors.red,
                  selected: _selectedColor == Colors.red,
                  onTap: () => setState(() => _selectedColor = Colors.red),
                ),
                _ColorOption(
                  color: Colors.orange,
                  selected: _selectedColor == Colors.orange,
                  onTap: () => setState(() => _selectedColor = Colors.orange),
                ),
                _ColorOption(
                  color: Colors.yellow,
                  selected: _selectedColor == Colors.yellow,
                  onTap: () => setState(() => _selectedColor = Colors.yellow),
                ),
                _ColorOption(
                  color: Colors.green,
                  selected: _selectedColor == Colors.green,
                  onTap: () => setState(() => _selectedColor = Colors.green),
                ),
                _ColorOption(
                  color: Colors.blue,
                  selected: _selectedColor == Colors.blue,
                  onTap: () => setState(() => _selectedColor = Colors.blue),
                ),
                _ColorOption(
                  color: Colors.purple,
                  selected: _selectedColor == Colors.purple,
                  onTap: () => setState(() => _selectedColor = Colors.purple),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;

              final db = ref.read(databaseProvider);
              await db.addLabel(
                UserLabelsCompanion(
                  name: Value(name),
                  color: Value(_selectedColor.value),
                ),
              );

              if (mounted) {
                Navigator.pop(context);
                ref.invalidate(allLabelsProvider);
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLabel(UserLabel label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除标签'),
        content: Text('确定要删除标签"${label.name}"吗?\n\n此操作不会影响已使用该标签的记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteLabel(label.id);
      ref.invalidate(allLabelsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(allLabelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('标签管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddLabelDialog,
          ),
        ],
      ),
      body: labels.when(
        data: (data) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final label = data[index];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(label.color),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                title: Text(label.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteLabel(label),
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }
}

class _LabelStatsDialog extends ConsumerWidget {
  const _LabelStatsDialog({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return AlertDialog(
      title: const Text('标签统计'),
      content: FutureBuilder<Map<String, int>>(
        future: db.getLabelStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('加载失败: ${snapshot.error}');
          }

          final stats = snapshot.data ?? {};
          final labels = ref.watch(allLabelsProvider);

          return labels.when(
            data: (data) {
              final items = data.map((label) {
                final count = stats[label.id.toString()] ?? 0;
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(label.color),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  title: Text(label.name),
                  trailing: Text('$count次'),
                );
              }).toList();

              if (items.isEmpty) {
                return const Text('暂无标签');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: items,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('加载失败: $e'),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
