/// 应用常量定义
/// 统一管理应用中的魔法数字和硬编码值

class DurationConstants {
  /// 毫秒单位常量
  static const int millisecondsPerSecond = 1000;
  static const int millisecondsPerMinute = 60000;
  static const int millisecondsPerHour = 3600000;
  static const int millisecondsPerDay = 86400000;

  /// 时间单位转换
  static const int secondsPerMinute = 60;
  static const int minutesPerHour = 60;
  static const int hoursPerDay = 24;
  static const int daysPerWeek = 7;
  static const int daysPerMonth = 30;
  static const int monthsPerYear = 12;
}

class TimeConstants {
  /// 最小年份
  static const int minYear = 2020;

  /// 自动同步间隔（秒）
  static const int autoSyncIntervalSeconds = 30;

  /// 日期选择器显示的天数
  static const int dateSelectorDays = 14;

  /// 倒计时默认分钟数
  static const int defaultCountdownMinutes = 30;
}

class UIConstants {
  /// 图表百分比缩放
  static const int chartPercentageScale = 100;

  /// 动画持续时间（毫秒）
  static const int animationDurationMs = 300;
  static const int animationDurationSlowMs = 500;

  /// 圆角半径
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  /// 间距
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  /// 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
}

class StorageConstants {
  /// SharedPreferences 键名
  static const String storagePathKey = 'storage_path';
  static const String themeModeKey = 'theme_mode';
  static const String activeGoalIdKey = 'active_goal_id';
}

class CategoryColors {
  /// 游戏类别颜色（已在 AppTheme 中定义，这里保留引用）
  static const String categoryGame = 'game';
  static const String categorySocial = 'social';
  static const String categoryVideo = 'video';
  static const String categoryProductivity = 'productivity';
  static const String categoryNews = 'news';
}

class GoalConstants {
  /// 目标状态
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  /// 目标时长限制（分钟）
  static const int minGoalMinutes = 1;
  static const int maxGoalMinutes = 480; // 8小时
}
