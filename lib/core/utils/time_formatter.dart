import '../constants/app_constants.dart';

/// 时间格式化扩展方法
extension TimeFormatter on int {
  /// 格式化时长（毫秒转可读字符串）
  /// 
  /// 示例:
  /// - 60000 → "1 分钟"
  /// - 3600000 → "1 小时 0 分钟"  
  /// - 5400000 → "1 小时 30 分钟"
  String formatDuration() {
    if (this == 0) return '0 分钟';
    
    final minutes = this ~/ DurationConstants.millisecondsPerMinute;
    if (minutes < 60) return '$minutes 分钟';
    
    final hours = minutes ~/ DurationConstants.minutesPerHour;
    final remainingMinutes = minutes % DurationConstants.minutesPerHour;
    return '$hours 小时 $remainingMinutes 分钟';
  }

  /// 格式化时间戳为 HH:MM 格式
  /// 
  /// 示例:
  /// - 3600000 → "01:00" (凌晨1点)
  /// - 5400000 → "01:30" (凌晨1点30分)
  String formatTime() {
    final dt = DateTime.fromMillisecondsSinceEpoch(this);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
