package com.looksee.app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.graphics.Path
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import java.text.SimpleDateFormat
import java.util.*

private const val DATE_FORMAT = "yyyy-MM-dd"

/**
 * 无障碍服务：监听 App 切换事件，用于目标监控期间的精确使用时间记录
 *
 * 核心功能：
 * - 实时监听用户在不同 App 之间的切换
 * - 记录每个 App 的使用时间段
 * - 当有活跃目标时，将记录关联到 goalId
 *
 * goalId 同步机制（双保险）：
 * 1. MainActivity 写 SharedPreferences 后，发送本地广播 ACTION_GOAL_CHANGED
 * 2. Service 注册 BroadcastReceiver，收到广播后立即读取最新 goalId
 * 3. 每次 AccessibilityEvent 时也调用 syncActiveGoalFromPrefs()（兜底）
 */
class AppAccessibilityService : AccessibilityService() {

    companion object {
        private const val TAG = "AppAccessibilityService"
        const val PREFS_NAME = "accessibility_prefs"
        const val KEY_ACTIVE_GOAL = "active_goal_id"
        // 服务存活时间戳：onServiceConnected 写入，心跳刷新，onDestroy 清除
        const val KEY_SERVICE_ALIVE_TS = "service_alive_ts"
        // 本地广播 Action，由 MainActivity 发出，Service 监听
        const val ACTION_GOAL_CHANGED = "com.looksee.app.GOAL_CHANGED"

        /**
         * ✅ 进程内静态标志：服务是否正在运行
         * onServiceConnected → true；onDestroy → false
         * 比 AccessibilityManager API 更准（小米 ROM 对该 API 有限制）
         * 比时间戳更即时（内存操作，无 IO 延迟）
         */
        @Volatile
        var isRunning: Boolean = false
            private set
    }

    // 实例变量：每次服务重建时都会重置，避免跨实例状态污染
    private var currentPackageName: String? = null
    private var currentStartTime: Long = 0
    private var activeGoalId: Int? = null
    private var ownPackageName: String = ""
    private var database: AppUsageDatabase? = null
    private var prefsListener: SharedPreferences.OnSharedPreferenceChangeListener? = null
    // ✅ 本地广播接收器：接收 MainActivity 发出的 goal 变更通知
    private var goalChangedReceiver: BroadcastReceiver? = null
    // ✅ 广播设置 goalId 的时间戳，用于保护广播值不被 SP sync 覆盖
    // 广播是即时通知，SP 的 apply() 是异步的，在短时间内 SP 可能还没落盘
    private var lastBroadcastSetTimeMs: Long = 0L
    private val BROADCAST_PROTECT_WINDOW_MS = 3000L  // 广播设置后 3 秒内不允许 SP sync 覆盖

    // ✅ 心跳定时器：每 2 分钟写一次安全网记录，防止极端情况（服务被 kill）丢失数据
    // 正常情况下数据由 App 切换事件驱动写入，心跳只是兜底保障
    private val heartbeatHandler = Handler(Looper.getMainLooper())
    private val HEARTBEAT_INTERVAL_MS = 120_000L  // 2 分钟心跳间隔（安全网）

    private val heartbeatRunnable = object : Runnable {
        override fun run() {
            flushCurrentRecord()
            // 刷新存活时间戳（让 MainActivity 知道服务仍在运行）
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit().putLong(KEY_SERVICE_ALIVE_TS, System.currentTimeMillis()).apply()
            heartbeatHandler.postDelayed(this, HEARTBEAT_INTERVAL_MS)
        }
    }

    /**
     * 心跳安全网：把当前正在计时的 App 写入一条中间记录，并重置计时起点。
     * 正常情况下记录由 App 切换事件触发写入；此函数只在用户长时间停留同一 App
     * 且服务有可能被系统 kill 时起到数据保护作用（每 2 分钟最多产生一条碎片）。
     */
    private fun flushCurrentRecord() {
        val goalId = activeGoalId ?: return
        val pkg = currentPackageName ?: return
        if (currentStartTime <= 0) return

        val now = System.currentTimeMillis()
        val duration = now - currentStartTime
        // 少于 5 秒不写（避免噪音），但也不重置起点
        if (duration < 5000) return

        Log.d(TAG, "Heartbeat flush: $pkg, duration=${duration}ms, goalId=$goalId")
        saveUsageRecord(
            packageName = pkg,
            startTime = currentStartTime,
            endTime = now,
            duration = duration,
            goalId = goalId
        )
        // 重置计时起点，避免下次切换时重复计入这段时间
        currentStartTime = now
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        ownPackageName = packageName
        database = AppUsageDatabase(applicationContext)

        // 1. 注册 SharedPreferences 监听器（作为次级保障）
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val initialGoalId = prefs.getInt(KEY_ACTIVE_GOAL, -1)
        activeGoalId = if (initialGoalId == -1) null else initialGoalId

        prefsListener = SharedPreferences.OnSharedPreferenceChangeListener { p, key ->
            if (key == KEY_ACTIVE_GOAL) {
                val newGoalId = p.getInt(KEY_ACTIVE_GOAL, -1)
                activeGoalId = if (newGoalId == -1) null else newGoalId
                Log.d(TAG, "activeGoalId updated via SharedPreferences listener: $activeGoalId")
            }
        }
        prefs.registerOnSharedPreferenceChangeListener(prefsListener)

        // 2. 注册本地广播接收器（主要通知机制，即时性更好）
        goalChangedReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == ACTION_GOAL_CHANGED) {
                    val newGoalId = intent.getIntExtra(KEY_ACTIVE_GOAL, -1)
                    val resolved = if (newGoalId == -1) null else newGoalId
                    Log.d(TAG, "✅ Goal changed via broadcast: $activeGoalId -> $resolved")
                    activeGoalId = resolved
                    // ✅ 记录广播设置时间，防止后续 syncActiveGoalFromPrefs() 把值覆盖回去
                    lastBroadcastSetTimeMs = System.currentTimeMillis()

                    if (resolved != null) {
                        // 目标开始时：
                        // - 如果当前已经在某个 App 里（currentPackageName 非 null），保持追踪，从现在开始计时
                        // - 如果是 null（刚启动或桌面），等下次 App 切换时自然开始
                        // ✅ 关键：不要把 currentStartTime 重置为 0，而是从现在开始计时
                        // 这样用户开目标后如果一直待在同一个 App 里，这段时间也能被记录
                        // ✅ 使用 System.currentTimeMillis()（Unix 毫秒），与 saveUsageRecord 的存储格式一致
                        if (currentPackageName != null) {
                            // 重新从现在开始计时（目标开始前的时间不计入）
                            currentStartTime = System.currentTimeMillis()
                            Log.d(TAG, "Goal started, resetting timer for current app: $currentPackageName")
                        }
                        // currentPackageName 保持不变（如果非 null），等下次切换时保存记录
                    } else {
                        // 目标结束：currentPackageName 和 currentStartTime 由 setActiveGoal() 方法处理
                    }
                }
            }
        }
        val filter = IntentFilter(ACTION_GOAL_CHANGED)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(goalChangedReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(goalChangedReceiver, filter)
        }

        Log.d(TAG, "AccessibilityService connected, own package: $ownPackageName, activeGoalId: $activeGoalId")

        // ✅ 进程内标志设为 true：服务正在运行（MainActivity.isAccessibilityServiceEnabled 读此值）
        isRunning = true
        // 同时刷新存活时间戳（供跨进程场景兜底）
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putLong(KEY_SERVICE_ALIVE_TS, System.currentTimeMillis()).apply()

        // 3. Service 重启后，检查是否有未完成的目标并恢复监控
        restoreActiveGoalIfRunning()

        // 4. 启动心跳定时器（2min 一次，安全网：防止长时间停留同一 App 时服务被 kill 丢数据）
        heartbeatHandler.postDelayed(heartbeatRunnable, HEARTBEAT_INTERVAL_MS)
    }

    /**
     * Service 重启后，检查是否有未完成的目标并恢复监控
     */
    private fun restoreActiveGoalIfRunning() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedGoalId = prefs.getInt(KEY_ACTIVE_GOAL, -1)

        if (savedGoalId != -1) {
            // 查询目标状态
            val db = database ?: return
            try {
                val goal = db.getGoalById(savedGoalId)
                if (goal != null && goal.status == "active") {
                    // 目标仍在运行中，恢复监控
                    activeGoalId = savedGoalId
                    Log.d(TAG, "✅ Restored monitoring for active goal: $savedGoalId (title: ${goal.title})")
                } else {
                    // 目标已结束或不存在，清理 activeGoalId
                    Log.d(TAG, "⚠️ Goal $savedGoalId is not active (status: ${goal?.status}), cleaning up...")
                    prefs.edit().remove(KEY_ACTIVE_GOAL).apply()
                    activeGoalId = null
                }
            } catch (e: Exception) {
                Log.e(TAG, "❌ Failed to restore active goal: ${e.message}", e)
                // 查询失败，也清理 activeGoalId 避免脏数据
                prefs.edit().remove(KEY_ACTIVE_GOAL).apply()
                activeGoalId = null
            }
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return

        // 只处理窗口状态变化事件（App 切换）
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            // ✅ 每次事件都从 SharedPreferences 同步最新 activeGoalId
            // 原因：监听器在某些 ROM 上可能不可靠，主动轮询是最稳定的方案
            // SharedPreferences 读操作已被 Android 框架缓存，性能影响可忽略不计
            syncActiveGoalFromPrefs()
            // ✅ 使用 System.currentTimeMillis() 而非 event.eventTime
            // event.eventTime 是 SystemClock.uptimeMillis()（不含手机休眠时间），
            // 与 elapsedRealtime 之间存在差值=累计休眠时长，直接导致时间偏差数小时。
            // System.currentTimeMillis() 是 Unix 毫秒时间戳，无需任何转换即可存数据库。
            handleAppSwitch(event.packageName?.toString(), System.currentTimeMillis())
        }
    }

    /**
     * 从 SharedPreferences 同步最新 activeGoalId 到内存
     * 在每次事件前调用，确保不会因为监听器失效而漏更新
     *
     * ⚠️ 重要：广播保护窗口内不执行同步
     * 原因：MainActivity 用 editor.apply()（异步写盘），广播发出后可能需要数百毫秒 SP 才落盘。
     * 如果在这段时间内 sync，读到的还是旧值（-1），会把广播刚设置的 activeGoalId 错误地清空。
     * 解决方案：广播设置后 3 秒内跳过 SP sync，直接信任广播的值。
     * 3 秒后 SP 必然已落盘，sync 才会执行（万一广播漏发时的兜底）。
     */
    private fun syncActiveGoalFromPrefs() {
        // 广播保护窗口内，跳过 SP sync，直接信任广播设置的值
        val timeSinceBroadcast = System.currentTimeMillis() - lastBroadcastSetTimeMs
        if (timeSinceBroadcast < BROADCAST_PROTECT_WINDOW_MS) {
            return
        }

        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val goalIdFromPrefs = prefs.getInt(KEY_ACTIVE_GOAL, -1)
        val newGoalId = if (goalIdFromPrefs == -1) null else goalIdFromPrefs
        if (newGoalId != activeGoalId) {
            Log.d(TAG, "syncActiveGoalFromPrefs: activeGoalId changed $activeGoalId -> $newGoalId")
            activeGoalId = newGoalId
        }
    }

    /**
     * 判断是否是需要忽略的系统/Launcher/输入法/助理包名
     * 这些包名出现在前台只是辅助性弹层，不代表用户真正在使用它们
     */
    private fun isIgnoredPackage(packageName: String): Boolean {
        if (packageName == ownPackageName) return true

        // ── 精确匹配（系统核心 / 常见输入法 / 弹窗）──
        val ignoredExact = setOf(
            "android",
            "com.android.systemui",
            // WebView / Chrome 自定义标签页（小程序跳转时会触发）
            "com.android.webview",
            "com.google.android.webview",
            "com.android.chrome",
            "org.chromium.webview_shell",
            // 系统弹窗 / 对话框
            "com.android.server.telecom",
            "com.android.phone",
            "com.android.dialer",
            // AOSP 输入法
            "com.android.inputmethod.latin",
            "com.google.android.inputmethod.latin",
            // 小米 / 百度 / 搜狗 / 讯飞 / 微软输入法
            "com.baidu.input_mi",
            "com.baidu.input",
            "com.sohu.inputmethod.sogou",
            "com.sohu.inputmethod.sogou.xiaomi",
            "com.iflytek.inputmethod",
            "com.microsoft.swiftkey",
            // MIUI 系统组件
            "com.miui.home",
            "com.miui.securitycenter",
            "com.miui.securityadd",
            "com.miui.voiceassist",          // 小爱同学
            "com.miui.personalassistant",    // 小米智能助理（负一屏）
            "com.xiaomi.aiasst.service",
            "com.xiaomi.aiasst.vision",
            // 华为
            "com.huawei.android.launcher",
            "com.huawei.intelligent",        // 华为智慧助手
            // OPPO / OnePlus
            "com.oppo.launcher",
            "com.oneplus.launcher",
            // Vivo
            "com.vivo.launcher",
            "com.vivo.assistant",
            // 三星
            "com.sec.android.app.launcher",
            // Android 通用系统弹窗
            "com.android.packageinstaller",
            "com.android.permissioncontroller",
            "com.google.android.permissioncontroller",
        )
        if (ignoredExact.contains(packageName)) return true

        // ── 模式匹配 ──
        // 所有含 "launcher" 的包名（覆盖所有厂商桌面）
        if (packageName.contains("launcher", ignoreCase = true)) return true
        // 输入法（包名含 "inputmethod" 或 "keyboard"）
        if (packageName.contains("inputmethod", ignoreCase = true)) return true
        if (packageName.contains("keyboard", ignoreCase = true)) return true
        // 语音助手 / 智能助理
        if (packageName.contains("voiceassist", ignoreCase = true)) return true
        if (packageName.contains("assistant", ignoreCase = true)) return true
        // WebView / 浏览器内核（小程序跳转时可能触发）
        if (packageName.contains("webview", ignoreCase = true)) return true
        // 系统通知面板 / 控制中心（下拉时会触发）
        if (packageName.contains("systemui", ignoreCase = true)) return true

        return false
    }

    /**
     * 处理 App 切换事件
     *
     * @param packageName 切换到的 App 包名
     * @param eventTime 事件时间（毫秒）
     */
    private fun handleAppSwitch(packageName: String?, eventTime: Long) {
        packageName ?: return

        if (isIgnoredPackage(packageName)) {
            Log.v(TAG, "Ignoring system/launcher package: $packageName")
            return
        }

        // ✅ 无论是否有活跃目标，都要追踪当前 App（保证目标开启时能知道用户在哪个 App）
        // 没有活跃目标时只更新追踪状态，不写数据库
        // eventTime 此处已是 System.currentTimeMillis()（Unix 毫秒），直接存储
        if (activeGoalId == null) {
            if (currentPackageName != packageName) {
                currentPackageName = packageName
                currentStartTime = eventTime
            }
            Log.v(TAG, "Tracking (no active goal): $packageName")
            return
        }

        Log.d(TAG, "App switch detected: $packageName (activeGoalId=$activeGoalId)")

        // 如果是首次切换或包名发生了变化
        if (currentPackageName != packageName) {
            // 保存上一个 App 的使用记录
            if (currentPackageName != null && currentStartTime > 0) {
                val duration = eventTime - currentStartTime
                // ✅ 只记录时长超过 2 秒的使用，避免闪现应用的噪音
                if (duration >= 2000) {
                    saveUsageRecord(
                        packageName = currentPackageName!!,
                        startTime = currentStartTime,
                        endTime = eventTime,
                        duration = duration,
                        goalId = activeGoalId!!
                    )
                } else {
                    Log.d(TAG, "Skipping short duration (< 2s): $currentPackageName, ${duration}ms")
                }
            }

            // 更新当前 App 信息
            currentPackageName = packageName
            currentStartTime = eventTime

            Log.d(TAG, "Now tracking: $packageName at $eventTime")
        }
    }

    /**
     * 保存使用记录到数据库
     *
     * @param startTime  System.currentTimeMillis() 的开始时间（Unix 毫秒时间戳）
     * @param endTime    System.currentTimeMillis() 的结束时间（Unix 毫秒时间戳）
     * @param duration   时长（毫秒），= endTime - startTime
     */
    private fun saveUsageRecord(packageName: String, startTime: Long, endTime: Long, duration: Long, goalId: Int) {
        Log.d(TAG, "Saving record: package=$packageName, duration=${duration}ms, goalId=$goalId")

        val db = database ?: return

        try {
            // 获取应用名称
            val appName = try {
                val appInfo = packageManager.getApplicationInfo(packageName, 0)
                packageManager.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                packageName
            }

            // ✅ startTime / endTime 已经是 Unix 毫秒时间戳（System.currentTimeMillis()），
            // 无需再做任何偏移转换，直接用于计算日期和写入数据库
            val startTimeUnix = startTime
            val endTimeUnix = endTime

            // 计算日期（零点时间戳）
            val calendar = Calendar.getInstance().apply {
                timeInMillis = startTimeUnix
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            // ✅ 重要：Drift 的 DateTimeColumn 默认以 Unix 秒存储（milliseconds / 1000）
            // 原生端必须写入秒级时间戳，否则 Flutter 侧查询时日期匹配会失败（时间差1000倍）
            val dateTimestamp = calendar.timeInMillis / 1000

            // 写入数据库
            db.insertUsageRecord(
                packageName = packageName,
                appName = appName,
                appCategory = "other",
                startTime = startTimeUnix,
                endTime = endTimeUnix,
                duration = duration,
                date = dateTimestamp,
                goalId = goalId
            )

            Log.d(TAG, "✅ Record saved successfully: $appName, ${duration}ms, goal=$goalId")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to save record: ${e.message}", e)
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "AccessibilityService interrupted")
    }

    override fun onDestroy() {
        super.onDestroy()
        // 停止心跳定时器
        heartbeatHandler.removeCallbacks(heartbeatRunnable)
        // ✅ 进程内标志设为 false：服务已停止
        isRunning = false
        // 清除存活时间戳（兜底）
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit().remove(KEY_SERVICE_ALIVE_TS).apply()
        // 注销 SharedPreferences 监听器
        prefsListener?.let {
            getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .unregisterOnSharedPreferenceChangeListener(it)
        }
        prefsListener = null
        // 注销广播接收器
        goalChangedReceiver?.let {
            try { unregisterReceiver(it) } catch (_: Exception) {}
        }
        goalChangedReceiver = null
        database?.close()
        database = null
        Log.d(TAG, "AccessibilityService destroyed")
    }

    /**
     * 从 SharedPreferences 读取活跃的 goalId（已由监听器替代，保留仅供外部调用兼容）
     */
    private fun checkActiveGoalFromPrefs() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val goalIdFromPrefs = prefs.getInt(KEY_ACTIVE_GOAL, -1)
        activeGoalId = if (goalIdFromPrefs == -1) null else goalIdFromPrefs
    }

    /**
     * 设置活跃的 goalId
     * 由 Flutter 层通过方法通道调用，保存到 SharedPreferences
     * 立即同步更新内存变量，不依赖监听器延迟
     */
    fun setActiveGoal(goalId: Int?) {
        // 缓存旧的 goalId,用于目标结束时的记录保存
        val oldGoalId = activeGoalId

        val prefs = applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val editor = prefs.edit()
        if (goalId == null) {
            editor.remove(KEY_ACTIVE_GOAL)
        } else {
            editor.putInt(KEY_ACTIVE_GOAL, goalId)
        }
        editor.apply()

        // ✅ 立即同步更新内存，确保目标切换即时生效
        activeGoalId = goalId
        Log.d(TAG, "Active goal set to: $goalId")

        // 目标结束时，将当前正在计时的 App 记录保存下来，防止最后一段时间丢失
        if (goalId == null && oldGoalId != null) {
            val now = System.currentTimeMillis()
            if (currentPackageName != null && currentStartTime > 0) {
                val duration = now - currentStartTime
                if (duration >= 5000) {
                    Log.d(TAG, "Saving final record before goal ends: $currentPackageName, duration=${duration}ms")
                    saveUsageRecord(
                        packageName = currentPackageName!!,
                        startTime = currentStartTime,
                        endTime = now,
                        duration = duration,
                        goalId = oldGoalId
                    )
                }
            }
            // 清空当前状态
            currentPackageName = null
            currentStartTime = 0
        }
    }

    /**
     * 获取当前活跃的 goalId
     */
    fun getActiveGoal(): Int? = activeGoalId
}
