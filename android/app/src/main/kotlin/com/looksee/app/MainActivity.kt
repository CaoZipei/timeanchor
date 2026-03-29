package com.looksee.app

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.accessibility.AccessibilityManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val USAGE_STATS_CHANNEL = "com.looksee.app/usage_stats"
    private val ACCESSIBILITY_CHANNEL = "com.looksee.app/accessibility"

    companion object {
        private const val PREFS_NAME = "accessibility_prefs"
        private const val KEY_ACTIVE_GOAL = "active_goal_id"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup UsageStats channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_STATS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsageStatsPermission())
                    "requestPermission" -> {
                        requestUsageStatsPermission()
                        result.success(null)
                    }
                    "queryUsageStats" -> {
                        val fromTime = call.argument<Long>("fromTime") ?: 0L
                        val toTime = call.argument<Long>("toTime") ?: System.currentTimeMillis()
                        try {
                            val data = queryUsageStats(fromTime, toTime)
                            Log.i("TimeAnchor", "queryUsageStats returning ${data.size} items")
                            // 转换成 ArrayList<HashMap> 确保序列化正常
                            val resultList = ArrayList<HashMap<String, Any>>()
                            for (map in data) {
                                resultList.add(HashMap(map))
                            }
                            result.success(resultList)
                        } catch (e: Exception) {
                            Log.e("TimeAnchor", "queryUsageStats error: ${e.message}", e)
                            result.success(emptyList<HashMap<String, Any>>())
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Setup Accessibility channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkAccessibilityPermission" -> result.success(isAccessibilityServiceEnabled())
                    "openAccessibilitySettings" -> {
                        openAccessibilitySettings()
                        result.success(null)
                    }
                    "setActiveGoal" -> {
                        val goalId = call.argument<Int>("goalId")
                        setActiveGoal(goalId)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // App 启动时尝试启动后台采集服务（有权限时才有意义）
        if (hasUsageStatsPermission()) {
            startCollectorService()
        }
    }

    // App 从后台返回前台时再次检查权限，如果新开启了权限就启动服务
    override fun onResume() {
        super.onResume()
        if (hasUsageStatsPermission()) {
            startCollectorService()
        }
    }

    // 启动前台采集服务
    private fun startCollectorService() {
        val hasPermission = hasUsageStatsPermission()
        Log.i("TimeAnchor", "startCollectorService called, hasPermission=$hasPermission")

        if (!hasPermission) {
            Log.w("TimeAnchor", "Cannot start service: no permission")
            return
        }

        val intent = Intent(this, UsageCollectorService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.i("TimeAnchor", "Starting foreground service (Android O+)")
            startForegroundService(intent)
        } else {
            Log.i("TimeAnchor", "Starting service (pre-Android O)")
            startService(intent)
        }
        Log.i("TimeAnchor", "Service start command issued")
    }

    // 检查是否有 UsageStats 权限
    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        val hasPermission = mode == AppOpsManager.MODE_ALLOWED
        Log.i("TimeAnchor", "hasUsageStatsPermission check: mode=$mode, result=$hasPermission")
        return hasPermission
    }

    // 跳转系统权限设置页
    private fun requestUsageStatsPermission() {
        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
    }

    // 查询使用统计数据 + 启动次数
    private fun queryUsageStats(fromTime: Long, toTime: Long): List<Map<String, Any>> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            fromTime,
            toTime
        )

        // 获取各应用的启动次数
        val launchCountMap = queryAppLaunchCount(fromTime, toTime)

        val packageManager = packageManager
        return stats
            .filter { it.totalTimeInForeground > 0 }
            .mapNotNull { stat ->
                try {
                    val appInfo = packageManager.getApplicationInfo(stat.packageName, 0)
                    val appName = packageManager.getApplicationLabel(appInfo).toString()
                    val category = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        packageManager.getApplicationInfo(
                            stat.packageName,
                            0
                        ).category
                    } else {
                        -1
                    }

                    mapOf(
                        "packageName" to stat.packageName,
                        "appName" to appName,
                        "totalTimeInForeground" to stat.totalTimeInForeground,
                        "lastTimeUsed" to stat.lastTimeUsed,
                        "category" to category,
                        "launchCount" to (launchCountMap[stat.packageName] ?: 0)  // ✅ 新增：启动次数
                    )
                } catch (e: Exception) {
                    null // 过滤掉无法获取信息的包
                }
            }
    }

    // ✅ 新增：查询各应用的启动次数
    private fun queryAppLaunchCount(fromTime: Long, toTime: Long): Map<String, Int> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val events = usageStatsManager.queryEvents(fromTime, toTime)
        
        val launchCountMap = mutableMapOf<String, Int>()
        
        try {
            while (events.hasNextEvent()) {
                val event = android.app.usage.UsageEvents.Event()
                events.getNextEvent(event)
                
                // 只统计 ACTIVITY_RESUMED 事件（应用被打开）
                if (event.eventType == android.app.usage.UsageEvents.Event.ACTIVITY_RESUMED) {
                    val pkg = event.packageName ?: continue
                    launchCountMap[pkg] = (launchCountMap[pkg] ?: 0) + 1
                }
            }
        } catch (e: Exception) {
            Log.w("TimeAnchor", "Error querying app launch count: ${e.message}")
        }

        Log.i("TimeAnchor", "Query app launch counts: ${launchCountMap.size} apps found")
        return launchCountMap
    }

    // ============ Accessibility Service 相关方法 ============

    /**
     * 检查无障碍服务是否已启用
     *
     * 检测优先级（从最可靠到最不可靠）：
     * 1. 进程内静态标志 isRunning（最准，服务连上时设 true，销毁时设 false）
     * 2. 存活时间戳（跨进程重启后标志丢失时兜底，3 分钟内有效）
     * 3. AccessibilityManager API（兜底，部分小米 ROM 可能不准）
     */
    private fun isAccessibilityServiceEnabled(): Boolean {
        // ✅ 方法1（最优先）：进程内静态标志——服务在同一进程内时 100% 准确
        if (AppAccessibilityService.isRunning) {
            Log.d("TimeAnchor", "isAccessibilityServiceEnabled: isRunning=true")
            return true
        }

        // ✅ 方法2：存活时间戳（App 重启后 isRunning 重置，但服务还在运行时读时间戳）
        val prefs = getSharedPreferences(AppAccessibilityService.PREFS_NAME, Context.MODE_PRIVATE)
        val aliveTs = prefs.getLong(AppAccessibilityService.KEY_SERVICE_ALIVE_TS, 0L)
        val ALIVE_TIMEOUT_MS = 3 * 60 * 1000L  // 3 分钟（2min 心跳 + 1min 容错）
        if (aliveTs > 0 && (System.currentTimeMillis() - aliveTs) < ALIVE_TIMEOUT_MS) {
            Log.d("TimeAnchor", "isAccessibilityServiceEnabled: alive_ts PASSED (age=${System.currentTimeMillis() - aliveTs}ms)")
            return true
        }

        // ✅ 方法3（最终兜底）：AccessibilityManager API
        val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val expectedId = "$packageName/${packageName}.AppAccessibilityService"
        val enabled = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)
            .any { it.id?.equals(expectedId, ignoreCase = true) == true }
        Log.d("TimeAnchor", "isAccessibilityServiceEnabled: isRunning=false, alive_ts expired, AM=$enabled")
        return enabled
    }

    /**
     * 打开系统无障碍设置页面
     */
    private fun openAccessibilitySettings() {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
        } catch (e: Exception) {
            Log.e("TimeAnchor", "Failed to open accessibility settings", e)
        }
    }

    /**
     * 设置活跃的 goalId
     * 通过 SharedPreferences 共享给 AccessibilityService，并发送本地广播立即通知
     *
     * 双保险机制：
     * 1. SharedPreferences 用 commit()（同步写盘，确保广播发出时 SP 已落盘）
     * 2. 本地广播（即时通知，Service 立刻更新内存变量）
     *
     * 注意：这里特意用 commit() 而非 apply()
     * 原因：apply() 是异步的，广播发出后 AccessibilityService 的 syncActiveGoalFromPrefs()
     * 可能在 SP 落盘前就读取，读到旧值 (-1)，把广播刚设置的 activeGoalId 错误地清空。
     * commit() 同步写盘，虽然在主线程会有极短阻塞（通常 < 1ms），但彻底解决时序问题。
     */
    private fun setActiveGoal(goalId: Int?) {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        if (goalId == null) {
            editor.remove(KEY_ACTIVE_GOAL)
        } else {
            editor.putInt(KEY_ACTIVE_GOAL, goalId)
        }
        // ✅ 用 commit() 同步写盘，确保广播发出前 SP 已持久化
        editor.commit()

        // ✅ 发送本地广播，立即通知 AccessibilityService 更新 goalId
        val intent = Intent(AppAccessibilityService.ACTION_GOAL_CHANGED).apply {
            putExtra(AppAccessibilityService.KEY_ACTIVE_GOAL, goalId ?: -1)
            setPackage(packageName) // 限定本应用内，安全性更好
        }
        sendBroadcast(intent)

        Log.i("TimeAnchor", "Active goal set to: $goalId (SP committed + broadcast sent)")
    }
}
