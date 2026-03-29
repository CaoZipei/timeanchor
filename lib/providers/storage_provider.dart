import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../core/utils/app_logger.dart';

/// 存储配置 Provider
/// 用于管理数据库和导出数据的存储路径

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

// 默认存储路径键
const String _storagePathKey = 'app_storage_path';

/// 获取应用的默认存储路径
Future<String> _getDefaultStoragePath() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  } catch (e) {
    // 降级方案
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }
}

/// 存储路径 Provider
final storagePathProvider = FutureProvider<String>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  
  // 首先尝试读取保存的路径
  final savedPath = prefs.getString(_storagePathKey);
  if (savedPath != null && await Directory(savedPath).exists()) {
    AppLogger.debug('Using saved storage path: $savedPath', 'Storage');
    return savedPath;
  }
  
  // 否则使用默认路径并保存
  final defaultPath = await _getDefaultStoragePath();
  
  // 确保路径存在
  final dir = Directory(defaultPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  // 保存默认路径（这次不出错的话就记住它）
  try {
    await prefs.setString(_storagePathKey, defaultPath);
  } catch (e) {
    AppLogger.warning('Failed to save storage path: $e', 'Storage');
  }

  AppLogger.debug('Using default storage path: $defaultPath', 'Storage');
  return defaultPath;
});

/// 更新存储路径
class StoragePathNotifier extends StateNotifier<AsyncValue<String>> {
  StoragePathNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;

  Future<void> _init() async {
    try {
      final path = await ref.watch(storagePathProvider.future);
      state = AsyncValue.data(path);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 更新存储路径
  Future<bool> updatePath(String newPath) async {
    try {
      // 验证路径是否存在或可创建
      final dir = Directory(newPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // 保存到 SharedPreferences
      final prefs = await ref.watch(sharedPreferencesProvider.future);
      await prefs.setString(_storagePathKey, newPath);

      // 更新 state
      state = AsyncValue.data(newPath);
      AppLogger.debug('Storage path updated: $newPath', 'Storage');
      return true;
    } catch (e) {
      AppLogger.error('Failed to update storage path: $e', null, null, 'Storage');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

final storagePathStateProvider = 
    StateNotifierProvider<StoragePathNotifier, AsyncValue<String>>((ref) {
  return StoragePathNotifier(ref);
});
