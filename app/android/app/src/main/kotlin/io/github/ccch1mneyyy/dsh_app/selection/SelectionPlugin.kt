package io.github.ccch1mneyyy.dsh_app.selection

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 正文选区的「翻译」：走系统 PROCESS_TEXT，和原来长按菜单里的翻译是同一个
 * 系统能力，不新增模型调用。优先命中名称里带 translate 的处理器（vivo 翻译），
 * 否则给系统选择器。
 */
class SelectionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "dsh/selection")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "translate" -> {
                val text = call.argument<String>("text")?.trim().orEmpty()
                if (text.isEmpty()) {
                    result.success(false)
                    return
                }
                try {
                    val intent = Intent(Intent.ACTION_PROCESS_TEXT).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_PROCESS_TEXT, text)
                        putExtra(Intent.EXTRA_PROCESS_TEXT_READONLY, true)
                    }
                    val candidates = context.packageManager.queryIntentActivities(intent, 0)
                    val translator = candidates.firstOrNull {
                        it.activityInfo.packageName.contains("translat", ignoreCase = true) ||
                            it.activityInfo.name.contains("translate", ignoreCase = true)
                    }
                    val target = if (translator != null) {
                        Intent(intent).setComponent(
                            ComponentName(translator.activityInfo.packageName, translator.activityInfo.name),
                        )
                    } else {
                        Intent.createChooser(intent, null)
                    }
                    target.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(target)
                    result.success(true)
                } catch (error: Exception) {
                    result.error("translate_failed", error.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
