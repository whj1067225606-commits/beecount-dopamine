package com.inspiration.inspiration_spark

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "inspiration_spark/shortcuts"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pinShortcut" -> {
                        val type = call.argument<String>("type") ?: "home"
                        val ok = pinShortcut(type)
                        result.success(ok)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun pinShortcut(type: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }
        val shortcutManager = getSystemService(ShortcutManager::class.java) ?: return false
        if (!shortcutManager.isRequestPinShortcutSupported) {
            return false
        }

        val (id, label, action) = when (type) {
            "inspiration" -> Triple(
                "shortcut_inspiration",
                "灵感",
                "com.inspiration.inspiration_spark.OPEN_INSPIRATION",
            )
            "notes" -> Triple(
                "shortcut_notes",
                "记事",
                "com.inspiration.inspiration_spark.OPEN_NOTES",
            )
            else -> Triple(
                "shortcut_home",
                "灵感火花",
                Intent.ACTION_MAIN,
            )
        }

        val intent = Intent(this, MainActivity::class.java).apply {
            this.action = action
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }

        val shortcut = ShortcutInfo.Builder(this, id)
            .setShortLabel(label)
            .setLongLabel(label)
            .setIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))
            .setIntent(intent)
            .build()

        return shortcutManager.requestPinShortcut(shortcut, null)
    }
}
