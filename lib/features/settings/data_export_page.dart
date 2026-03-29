import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../../core/database/app_database.dart';

/// 数据导出页面
class DataExportPage extends ConsumerWidget {
  const DataExportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('数据导出'),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '导出的数据仅包含本地存储的信息,不会上传到任何服务器',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 导出格式选择
              Text(
                '导出格式',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // CSV 导出
              _ExportOption(
                icon: Icons.table_chart,
                title: 'CSV 格式',
                description: '适合用 Excel 或其他表格软件打开',
                color: Colors.green,
                onTap: () => _exportCSV(context, ref, theme),
              ),
              const SizedBox(height: 12),

              // JSON 导出
              _ExportOption(
                icon: Icons.code,
                title: 'JSON 格式',
                description: '适合开发者或程序处理',
                color: Colors.blue,
                onTap: () => _exportJSON(context, ref, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导出为 CSV 格式
  Future<void> _exportCSV(BuildContext context, WidgetRef ref, ThemeData theme) async {
    try {
      final db = ref.read(databaseProvider);

      // 显示加载对话框
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '正在导出...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 获取所有记录
      final records = await db.getAllRecords();

      // 生成 CSV 内容
      final csv = [
        'App名称,包名,开始时间,结束时间,时长(分钟)',
        ...records.map((r) => [
          '"${r.appName}"',
          r.packageName,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(
            DateTime.fromMillisecondsSinceEpoch(r.startTime),
          ),
          DateFormat('yyyy-MM-dd HH:mm:ss').format(
            DateTime.fromMillisecondsSinceEpoch(r.endTime),
          ),
          (r.duration / 60000).toStringAsFixed(2),
        ].join(',')),
      ].join('\n');

      // 保存文件
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/looksee_export_$timestamp.csv');
      await file.writeAsString(csv);

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 分享文件
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: '时光锚数据导出 - CSV格式',
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 导出为 JSON 格式
  Future<void> _exportJSON(BuildContext context, WidgetRef ref, ThemeData theme) async {
    try {
      final db = ref.read(databaseProvider);

      // 显示加载对话框
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '正在导出...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 获取所有数据
      final records = await db.getAllRecords();
      final goals = await db.getAllGoals();
      final labels = await db.getAllLabels();

      // 生成 JSON 内容
      final json = {
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'data': {
          'records': records.map((r) => {
            'id': r.id,
            'appName': r.appName,
            'packageName': r.packageName,
            'startTime': DateTime.fromMillisecondsSinceEpoch(r.startTime).toIso8601String(),
            'endTime': DateTime.fromMillisecondsSinceEpoch(r.endTime).toIso8601String(),
            'duration': r.duration,
            'date': r.date.toIso8601String(),
          }).toList(),
          'goals': goals.map((g) => {
            'id': g.id,
            'title': g.title,
            'plannedDuration': g.plannedDuration,
            'actualDuration': g.actualDuration,
            'status': g.status,
            'startTime': DateTime.fromMillisecondsSinceEpoch(g.startTime).toIso8601String(),
            'endTime': g.endTime != null ? DateTime.fromMillisecondsSinceEpoch(g.endTime!).toIso8601String() : null,
            'createdAt': g.createdAt.toIso8601String(),
          }).toList(),
          'labels': labels.map((l) => {
            'id': l.id,
            'name': l.name,
            'emoji': l.emoji,
            'color': l.color,
            'isPreset': l.isPreset,
            'isEffective': l.isEffective,
          }).toList(),
        },
      };

      // 转换为 JSON 字符串
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);

      // 保存文件
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/looksee_export_$timestamp.json');
      await file.writeAsString(jsonString);

      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 分享文件
      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: '时光锚数据导出 - JSON格式',
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (context.mounted) Navigator.pop(context);

      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// 导出选项卡片
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
