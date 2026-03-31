import 'package:drift/drift.dart';

// ✅ 目标表（放在前面，避免循环引用）
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()(); // 目标标题
  TextColumn get description => text().nullable()(); // 目标描述（可选）
  IntColumn get plannedDuration => integer()(); // 预计时长（分钟）
  IntColumn get actualDuration => integer().nullable()(); // 实际时长（分钟，结束时计算）
  IntColumn get startTime => integer()(); // 开始时间戳(ms)
  IntColumn get endTime => integer().nullable()(); // 结束时间戳(ms，可为NULL表示进行中）
  TextColumn get status => text()(); // 状态: active, completed, cancelled
  BoolColumn get completed => boolean().nullable()(); // ✅ 用户主观判断是否完成
  TextColumn get userNote => text().nullable()(); // ✅ 用户备注
  TextColumn get aiReviewText => text().nullable()(); // AI 复盘文本（持久化，避免重复生成）
  IntColumn get aiReviewFeedback => integer().nullable()(); // AI 复盘反馈：1=👍 0=👎 null=未反馈
  DateTimeColumn get createdAt => dateTime()(); // 创建时间
}

// App 使用记录表
class AppUsageRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text()(); // 包名
  TextColumn get appName => text()();     // App 显示名称
  TextColumn get appCategory => text().withDefault(const Constant('other'))(); // 类别
  IntColumn get startTime => integer()(); // 开始时间戳(ms)
  IntColumn get endTime => integer()();   // 结束时间戳(ms)
  IntColumn get duration => integer()();  // 使用时长(ms)
  DateTimeColumn get date => dateTime()(); // 所属日期(取零点)
  IntColumn get launchCount => integer().withDefault(const Constant(0))(); // 启动次数
  IntColumn get goalId => integer().nullable().references(Goals, #id)(); // ✅ 新增：关联目标ID（可为NULL）
}

// 用户标签表
class UserLabels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();        // 标签名
  TextColumn get emoji => text()();       // 表情符号
  IntColumn get color => integer()();     // 颜色值(ARGB)
  BoolColumn get isPreset => boolean().withDefault(const Constant(false))(); // 是否预设
  BoolColumn get isEffective => boolean().withDefault(const Constant(true))(); // 是否为有效时间
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// 时间段标签关联表
class RecordLabelMappings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recordId => integer().references(AppUsageRecords, #id)();
  IntColumn get labelId => integer().references(UserLabels, #id)();
  TextColumn get note => text().nullable()(); // 备注
  DateTimeColumn get taggedAt => dateTime()();
}

// 每日统计汇总缓存表
class DailyStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()(); // 添加 UNIQUE 约束，确保每天只有一条记录
  IntColumn get totalScreenTime => integer()(); // 总屏幕时间(ms)
  IntColumn get effectiveTime => integer()();   // 有效时间(ms)
  IntColumn get entertainTime => integer()();   // 娱乐时间(ms)
  IntColumn get unlabeledTime => integer()();   // 未标注时间(ms)
  IntColumn get appCount => integer()();        // 使用App数量
  IntColumn get totalLaunchCount => integer().withDefault(const Constant(0))(); // 总启动次数
  DateTimeColumn get updatedAt => dateTime()();
}

// 标签固化表：将包名固定绑定到特定标签
class PinnedLabels extends Table {
  TextColumn get packageName => text()(); // 包名（主键）
  IntColumn get labelId => integer().references(UserLabels, #id)(); // 标签ID
  DateTimeColumn get createdAt => dateTime()(); // 创建时间

  @override
  Set<Column> get primaryKey => {packageName};
}

// 目标模板表
class GoalTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()(); // 模板标题
  IntColumn get plannedDuration => integer()(); // 预计时长（分钟）
  TextColumn get notes => text().nullable()(); // 备注
  IntColumn get usageCount => integer().withDefault(const Constant(0))(); // 使用次数
  DateTimeColumn get createdAt => dateTime()(); // 创建时间
}

