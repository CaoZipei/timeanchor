import 'package:flutter/foundation.dart';

/// 应用日志工具类
/// 只在 Debug 模式下输出日志，生产环境自动禁用
class AppLogger {
  /// 调试日志（仅在 Debug 模式输出）
  static void debug(String message, [String? tag]) {
    assert(() {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
      return true;
    }());
  }

  /// 信息日志（仅在 Debug 模式输出）
  static void info(String message, [String? tag]) {
    debug(message, tag);
  }

  /// 警告日志（仅在 Debug 模式输出）
  static void warning(String message, [String? tag]) {
    assert(() {
      final prefix = tag != null ? '⚠️ [$tag] ' : '⚠️ ';
      debugPrint('$prefix$message');
      return true;
    }());
  }

  /// 错误日志（仅在 Debug 模式输出）
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    assert(() {
      final prefix = tag != null ? '❌ [$tag] ' : '❌ ';
      debugPrint('$prefix$message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      return true;
    }());
  }
}
