import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../utils/app_logger.dart';

// 通过 MethodChannel 调用 Android 原生 UsageStats API
class UsageStatsService {
  static const _channel = MethodChannel('com.looksee.app/usage_stats');

  // 检查权限
  Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod('hasPermission') ?? false;
      AppLogger.debug('hasPermission() returned: $result', 'UsageStatsService');
      return result;
    } catch (e) {
      AppLogger.error('hasPermission() error', e, null, 'UsageStatsService');
      return false;
    }
  }

  // 跳转系统设置页面请求权限
  Future<void> requestPermission() async {
    await _channel.invokeMethod('requestPermission');
  }

  // 获取指定时间范围内的 App 使用数据
  Future<List<Map<String, dynamic>>> queryUsageStats({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      AppLogger.debug('queryUsageStats: from=$from, to=$to', 'UsageStatsService');

      // 使用 dynamic 接收，避免类型检查
      final dynamic result = await _channel.invokeMethod('queryUsageStats', {
        'fromTime': from.millisecondsSinceEpoch,
        'toTime': to.millisecondsSinceEpoch,
      });

      AppLogger.debug('Raw result type: ${result.runtimeType}', 'UsageStatsService');

      if (result == null) {
        AppLogger.debug('queryUsageStats returned null', 'UsageStatsService');
        return [];
      }

      if (result is! List) {
        AppLogger.error('Expected List but got ${result.runtimeType}', null, null, 'UsageStatsService');
        return [];
      }

      final data = <Map<String, dynamic>>[];
      for (int i = 0; i < result.length; i++) {
        try {
          final item = result[i];
          if (item is Map) {
            final map = <String, dynamic>{};
            item.forEach((key, value) {
              map['$key'] = value;
            });
            data.add(map);
          }
        } catch (e) {
          AppLogger.warning('Failed to convert item $i: $e', 'UsageStatsService');
        }
      }

      AppLogger.debug('queryUsageStats returned ${data.length} items', 'UsageStatsService');
      return data;
    } catch (e, st) {
      AppLogger.error('queryUsageStats error', e, st, 'UsageStatsService');
      return [];
    }
  }

  // 将原始数据转换为数据库记录格式
  List<AppUsageRecordsCompanion> convertToRecords(
    List<Map<String, dynamic>> rawData,
    DateTime date,
  ) {
    // ✅ 使用传入的 date 参数，而不是硬编码"今天"
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final validRecords = <AppUsageRecordsCompanion>[];

    for (final item in rawData) {
      // 过滤1分钟以下的记录
      if ((item['totalTimeInForeground'] as int? ?? 0) <= 60000) continue;

      final lastTimeUsed = item['lastTimeUsed'] as int? ?? 0;
      final duration = item['totalTimeInForeground'] as int? ?? 0;
      final launchCount = item['launchCount'] as int? ?? 0;

      // lastTimeUsed 是最后一次使用的时间戳
      // 由于我们不知道确切的 startTime，使用保守估计：
      // startTime = lastTimeUsed - duration，但不能超出当天范围
      final estimatedStartTime = lastTimeUsed - duration;
      final dayStartMs = startOfDay.millisecondsSinceEpoch.toInt();
      final dayEndMs = endOfDay.millisecondsSinceEpoch.toInt();

      // 确保时间在当天范围内
      final startTime = estimatedStartTime < dayStartMs ? dayStartMs : estimatedStartTime;
      final endTime = lastTimeUsed > dayEndMs ? dayEndMs : lastTimeUsed;

      // 检查时间是否有效（startTime 必须 <= endTime）
      if (startTime >= endTime) {
        AppLogger.warning('Skipping invalid record: pkg=${item['packageName']}, startTime=$startTime, endTime=$endTime', 'UsageStatsService');
        continue;
      }

      AppLogger.debug(
        'Converting: pkg=${item['packageName']}, '
        'duration=${duration}ms (${duration ~/ 60000}min), '
        'launchCount=$launchCount',
        'UsageStatsService',
      );

      validRecords.add(AppUsageRecordsCompanion.insert(
        packageName: item['packageName'] as String? ?? '',
        appName: item['appName'] as String? ?? '未知应用',
        appCategory: Value(_classifyByPackageName(item['packageName'] as String? ?? '')),
        startTime: startTime,
        endTime: endTime,
        duration: duration,
        date: DateTime(date.year, date.month, date.day),
        launchCount: Value(launchCount),
      ));
    }

    return validRecords;
  }

  // ✅ 基于包名的智能分类识别
  String _classifyByPackageName(String packageName) {
    final lower = packageName.toLowerCase();
    
    if (lower.contains('qq') || lower.contains('com.tencent.mobileqq') ||
        lower.contains('wechat') || lower.contains('com.tencent.wework') ||
        lower.contains('social') || lower.contains('whatsapp') ||
        lower.contains('telegram') || lower.contains('messenger') ||
        lower.contains('discord') || lower.contains('slack')) {
      return 'social';
    }
    if (lower.contains('video') || lower.contains('youtube') || 
        lower.contains('tiktok') || lower.contains('douyin') ||
        lower.contains('com.ss.android.ugc') ||
        lower.contains('com.tiktok') ||
        lower.contains('bilibili') || lower.contains('netflix') ||
        lower.contains('youku') || lower.contains('iqiyi') ||
        lower.contains('vimeo')) {
      return 'video';
    }
    if (lower.contains('game') ||
        lower.contains('minecraft') || lower.contains('roblox') ||
        lower.contains('pubg') || lower.contains('com.tencent.tmgp')) {
      return 'game';
    }
    if (lower.contains('news') || lower.contains('reddit') ||
        lower.contains('twitter') || lower.contains('x.com') ||
        lower.contains('zhihu')) {
      return 'news';
    }
    if (lower.contains('productivity') || lower.contains('office') ||
        lower.contains('docs') || lower.contains('sheets') ||
        lower.contains('notion') || lower.contains('trello') ||
        lower.contains('asana') || lower.contains('jira') ||
        lower.contains('gmail') || lower.contains('mail') ||
        lower.contains('outlook') || lower.contains('drive') ||
        lower.contains('dropbox')) {
      return 'productivity';
    }
    if (lower.contains('music') || lower.contains('spotify') ||
        lower.contains('soundcloud') || lower.contains('apple.music') ||
        lower.contains('qq.music') || lower.contains('netease') ||
        lower.contains('audio')) {
      return 'audio';
    }
    if (lower.contains('shop') || lower.contains('taobao') ||
        lower.contains('amazon') || lower.contains('ebay') ||
        lower.contains('mall') || lower.contains('shopping')) {
      return 'shopping';
    }
    return 'other';
  }
}

final usageStatsServiceProvider = Provider<UsageStatsService>((ref) {
  return UsageStatsService();
});
