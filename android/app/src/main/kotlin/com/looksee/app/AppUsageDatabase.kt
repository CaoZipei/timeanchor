package com.looksee.app

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import android.util.Log
import java.io.File

/**
 * 原生数据库辅助类
 * 用于在 AccessibilityService 中写入使用记录
 *
 * ⚠️ 重要：必须和 Flutter Drift 打开完全相同的文件
 *
 * drift_flutter 0.1.0 的 native.dart 源码：
 *   val dbFolder = await getApplicationDocumentsDirectory()  // Android: /data/data/<pkg>/app_flutter/
 *   val file = File(p.join(dbFolder.path, '$name.sqlite'))   // looksee_db.sqlite
 *
 * 因此实际路径是：/data/data/com.looksee.app/app_flutter/looksee_db.sqlite
 *
 * Android 上 getApplicationDocumentsDirectory() 对应的原生路径：
 *   context.getDir("app_flutter", Context.MODE_PRIVATE) → /data/data/<pkg>/app_flutter
 *   或 context.filesDir.parentFile + "/app_flutter"
 *
 * 这里用 context.filesDir.parentFile 拼接 "app_flutter" 来构造同样的路径。
 */
class AppUsageDatabase(private val context: Context) :
    SQLiteOpenHelper(
        context,
        getDatabaseFile(context).absolutePath,  // 传完整绝对路径
        null,
        DATABASE_VERSION
    ) {

    companion object {
        private const val TAG = "AppUsageDatabase"
        private const val DATABASE_VERSION = 7

        // 表名
        private const val TABLE_APP_USAGE = "app_usage_records"

        /**
         * 计算与 drift_flutter driftDatabase(name: 'looksee_db') 完全一致的数据库文件路径
         *
         * drift_flutter native.dart:
         *   getApplicationDocumentsDirectory() on Android
         *   → context.getFilesDir().parentFile + "/app_flutter"
         *   file = dbFolder + "/looksee_db.sqlite"
         */
        fun getDatabaseFile(context: Context): File {
            // Android 上 Flutter 的 getApplicationDocumentsDirectory() 返回 /data/data/<pkg>/app_flutter
            // 这和 context.filesDir.parentFile + "/app_flutter" 等价
            val appFlutterDir = File(context.filesDir.parentFile, "app_flutter")
            if (!appFlutterDir.exists()) {
                appFlutterDir.mkdirs()
            }
            val dbFile = File(appFlutterDir, "looksee_db.sqlite")
            Log.d(TAG, "Database path: ${dbFile.absolutePath}")
            return dbFile
        }
    }

    override fun onCreate(db: SQLiteDatabase) {
        // 表由 Flutter Drift 管理，这里不需要创建
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // 升级逻辑由 Flutter Drift 管理
    }

    /**
     * 插入使用记录
     */
    fun insertUsageRecord(
        packageName: String,
        appName: String,
        appCategory: String,
        startTime: Long,
        endTime: Long,
        duration: Long,
        date: Long,
        goalId: Int
    ): Long {
        val db = writableDatabase
        val category = appCategory.ifEmpty { "other" }

        val values = android.content.ContentValues().apply {
            put("package_name", packageName)
            put("app_name", appName)
            put("app_category", category)
            put("start_time", startTime)
            put("end_time", endTime)
            put("duration", duration)
            put("date", date)
            put("launch_count", 0)
            put("goal_id", if (goalId > 0) goalId else null)
        }

        val rowId = db.insert(TABLE_APP_USAGE, null, values)
        Log.d(TAG, "Inserted record rowId=$rowId, pkg=$packageName, goalId=$goalId")
        return rowId
    }

    /**
     * 查询目标信息
     */
    fun getGoalById(goalId: Int): GoalInfo? {
        val db = readableDatabase
        val query = "SELECT id, title, status FROM goals WHERE id = ? LIMIT 1"
        val cursor = db.rawQuery(query, arrayOf(goalId.toString()))

        return cursor.use {
            if (it.moveToFirst()) {
                GoalInfo(
                    id = it.getInt(0),
                    title = it.getString(1),
                    status = it.getString(2)
                )
            } else {
                null
            }
        }
    }
}

/**
 * 目标信息数据类
 */
data class GoalInfo(
    val id: Int,
    val title: String,
    val status: String
)
