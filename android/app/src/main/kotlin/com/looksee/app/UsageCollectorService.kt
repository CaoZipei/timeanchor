package com.looksee.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

/**
 * 前台采集服务 - 保持 App 在后台持续运行并定期同步使用数据
 * 每隔5分钟触发一次 Flutter 侧同步
 */
class UsageCollectorService : Service() {

    companion object {
        const val CHANNEL_ID = "looksee_collector"
        const val NOTIFICATION_ID = 1001
    }

    override fun onCreate() {
        super.onCreate()
        Log.i("LookSee", "UsageCollectorService.onCreate() called")
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, buildNotification())
        Log.i("LookSee", "UsageCollectorService started with foreground notification")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i("LookSee", "UsageCollectorService.onStartCommand() called")
        // 服务被系统杀死后自动重启
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "时间记录服务",
                NotificationManager.IMPORTANCE_LOW // 改为 LOW，避免被小米隐藏
            ).apply {
                description = "看一看正在后台记录您的使用时间"
                setShowBadge(false)
                enableVibration(false)
                setSound(null, null)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
            Log.i("LookSee", "Notification channel created with IMPORTANCE_LOW")
        }
    }

    private fun buildNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("时光锚")
            .setContentText("时间记录中...")
            .setSmallIcon(R.drawable.ic_notification)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true) // 设为持续通知，防止被滑动删除
            .setSilent(true)
            .build()
    }
}
