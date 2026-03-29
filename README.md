# 时光锚 (TimeAnchor)

> 把时间锚定在目标上 — 精确记录每次专注窗口内的应用使用轨迹

## 产品简介

时光锚是一款 Android 专注力追踪应用，核心逻辑：

**用户设定目标 → 开始监控 → 结束 → 看报告**

精确知道这段时间用了哪些 App、专注了多久、分心了多少次。

区别于手机自带的屏幕时间统计（被动汇总全天），时光锚是**主动的、以目标为粒度**的精确记录。

## 核心功能

- **目标管理**：创建专注目标，支持自由计时和定时两种模式
- **实时监控**：通过无障碍服务精确记录目标期间每个 App 的使用时段
- **目标报告**：完成后查看专注分析、分心次数、应用分布饼图
- **时间轴**：每日应用使用甘特图（基于 UsageStats API）
- **趋势统计**：30 天目标完成趋势、智能目标时长建议
- **标签系统**：为应用打标签，区分"高效"和"分心"

## 技术架构

### 双轨数据来源

| 来源 | 精确度 | 用途 |
|------|--------|------|
| AccessibilityService | 精确到秒 | 目标监控期间的应用切换记录 |
| UsageStats API | 每日汇总 | 时间轴、全局统计 |

两轨数据严格隔离，通过 `goalId IS NULL / NOT NULL` 区分。

### 技术栈

- **Flutter** + Dart（跨平台 UI）
- **Drift**（Flutter SQLite ORM）
- **Riverpod**（状态管理）
- **Kotlin**（Android 原生层）

## 权限说明

- **无障碍服务**：仅检测应用切换事件，不读取任何屏幕内容
- **使用情况访问权限**：获取日常应用使用汇总

**所有数据仅存储在设备本地，不上传任何服务器。**

## 隐私政策

[查看隐私政策](https://YOUR_USERNAME.github.io/YOUR_REPO/privacy_policy.html)

## 构建运行

```bash
flutter pub get
flutter run
```

发布构建：
```bash
flutter build apk --release --no-tree-shake-icons
```

## License

MIT
