import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

/// 无障碍服务封装
/// 用于目标监控期间的精确 App 使用时间记录
class AccessibilityService {
  static const MethodChannel _channel = MethodChannel('com.looksee.app/accessibility');

  /// 检查无障碍服务是否已启用
  static Future<bool> isEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('checkAccessibilityPermission');
      return result;
    } catch (e) {
      AppLogger.error('Error checking accessibility permission', e, null, 'AccessibilityService');
      return false;
    }
  }

  /// 打开系统无障碍设置页面
  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (e) {
      AppLogger.error('Error opening accessibility settings', e, null, 'AccessibilityService');
    }
  }

  /// 设置活跃的目标 ID
  /// 当目标开始时调用，设置为 goalId；目标结束时设置为 null
  static Future<void> setActiveGoal(int? goalId) async {
    try {
      await _channel.invokeMethod('setActiveGoal', {'goalId': goalId});
    } catch (e) {
      AppLogger.error('Error setting active goal', e, null, 'AccessibilityService');
    }
  }
}
