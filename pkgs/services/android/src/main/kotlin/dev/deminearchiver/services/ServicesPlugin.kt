package dev.deminearchiver.services

import android.os.Build
import android.view.WindowInsets
import androidx.core.view.OnApplyWindowInsetsListener
import androidx.core.view.ViewCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** ServicesPlugin */
class ServicesPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
  private lateinit var channel: MethodChannel

  private var cachedWindowCorners: Map<String, Double>? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "services")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${Build.VERSION.RELEASE}")
      }

      "getWindowCorners" -> {
        val windowCorners = cachedWindowCorners
        if (!windowCorners.isNullOrEmpty()) {
          result.success(windowCorners)
        } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
          result.error(
            "UnsupportedError",
            "Unsupported Android API level: ${Build.VERSION.SDK_INT}, minimum API level: ${Build.VERSION_CODES.S}",
            "Using Rounded Corner API requires a minimum Android API level ${Build.VERSION_CODES.S} (Android 12)",
          )
        } else {
          result.error(
            "UnsupportedError",
            "Unsupported API: getRoundedCorner",
            null,
          )
        }
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val activity = binding.activity
      val density = activity.resources.displayMetrics.density.toDouble()
      ViewCompat.setOnApplyWindowInsetsListener(
        activity.window.decorView,
        OnApplyWindowInsetsListener { _, insetsCompat ->
          val insets = insetsCompat.toWindowInsets()
          if (insets != null) {
            val windowCorners = insets.getCorners(density).toMap()
            cachedWindowCorners = windowCorners
            channel.invokeMethod("updateWindowCorners", windowCorners)
          }
          return@OnApplyWindowInsetsListener insetsCompat
        }
      )
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {

  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {

  }
}
