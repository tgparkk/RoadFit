package com.example.road_fit

import android.app.Application
import com.kakao.vectormap.KakaoMapSdk
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        setupUncaughtExceptionHandler()

        try {
            Log.d("KakaoMapSdk", "⚙️ KakaoMapSdk.init 시작 (MyApplication)")
            KakaoMapSdk.init(this, "b20862b7b0e3d319e0cd0d9c1aa40d2e")
            Log.d("KakaoMapSdk", "✅ KakaoMapSdk.init 성공 (MyApplication)")
        } catch (e: Exception) {
            logToFile("❌ KakaoMapSdk.init 실패: ${e.message}")
            Log.e("KakaoMapSdk", "❌ KakaoMapSdk.init 실패: ${e.message}")
        }
    }

    private fun setupUncaughtExceptionHandler() {
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            val logMessage = """
                🛑 Uncaught Exception!
                Thread: ${thread.name}
                Message: ${throwable.message}
                Stack Trace: ${Log.getStackTraceString(throwable)}
            """.trimIndent()

            logToFile(logMessage)
            Log.e("UncaughtException", logMessage)
        }
    }

    private fun logToFile(logMessage: String) {
        try {
            val logFile = File(filesDir, "app_crash_log.txt")
            val timeStamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date())
            val fullLogMessage = "$timeStamp - $logMessage\n"

            FileOutputStream(logFile, true).use { fos ->
                fos.write(fullLogMessage.toByteArray())
            }

            Log.d("LogToFile", "📁 Log saved to ${logFile.absolutePath}")
        } catch (e: Exception) {
            Log.e("LogToFile", "❌ Failed to write log to file: ${e.message}")
        }
    }
}
