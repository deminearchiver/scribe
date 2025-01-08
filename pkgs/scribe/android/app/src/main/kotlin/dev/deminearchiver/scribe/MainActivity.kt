package dev.deminearchiver.scribe

import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowManager
import androidx.annotation.ColorInt
import androidx.core.splashscreen.SplashScreen
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.ViewCompat
import com.google.android.material.color.MaterialColors
import com.google.android.material.transition.platform.MaterialContainerTransform
import com.google.android.material.transition.platform.MaterialContainerTransformSharedElementCallback
import dev.deminearchiver.scribe.shape.MaterialShapes
import dev.deminearchiver.scribe.shape.toFlutterClassMember
import dev.deminearchiver.scribe.shape.toFlutterPath
import dev.deminearchiver.scribe.shape.toPathData
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler


class MainActivity : FlutterActivity(), MethodCallHandler, SplashScreen.KeepOnScreenCondition {
  companion object {
    private const val CHANNEL = "scribe.deminearchiver.dev"

    private const val EXTRA_BACKGROUND_MODE = "background_mode"

    private val RESOURCES: Map<String, Int> = mapOf(
      "@style/LaunchTheme" to R.style.LaunchTheme,
      "@style/NormalTheme" to R.style.NormalTheme,
      "@style/TranslucentBackgroundTheme" to R.style.TranslucentBackgroundTheme,
      "@style/TranslucentTheme" to R.style.TranslucentTheme,
    )

    private val SHAPES = mapOf(
      "circle" to MaterialShapes.CIRCLE,
      "square" to MaterialShapes.SQUARE,
      "slantedSquare" to MaterialShapes.SLANTED_SQUARE,
      "arch" to MaterialShapes.ARCH,
      "fan" to MaterialShapes.FAN,
      "arrow" to MaterialShapes.ARROW,
      "semiCircle" to MaterialShapes.SEMI_CIRCLE,
      "oval" to MaterialShapes.OVAL,
      "pill" to MaterialShapes.PILL,
      "triangle" to MaterialShapes.TRIANGLE,
      "diamond" to MaterialShapes.DIAMOND,
      "clamShell" to MaterialShapes.CLAM_SHELL,
      "pentagon" to MaterialShapes.PENTAGON,
      "gem" to MaterialShapes.GEM,
      "sunny" to MaterialShapes.SUNNY,
      "verySunny" to MaterialShapes.VERY_SUNNY,
      "cookie4" to MaterialShapes.COOKIE_4,
      "cookie6" to MaterialShapes.COOKIE_6,
      "cookie7" to MaterialShapes.COOKIE_7,
      "cookie9" to MaterialShapes.COOKIE_9,
      "cookie12" to MaterialShapes.COOKIE_12,
      "ghostish" to MaterialShapes.GHOSTISH,
      "clover4" to MaterialShapes.CLOVER_4,
      "clover8" to MaterialShapes.CLOVER_8,
      "burst" to MaterialShapes.BURST,
      "softBurst" to MaterialShapes.SOFT_BURST,
      "boom" to MaterialShapes.BOOM,
      "softBoom" to MaterialShapes.SOFT_BOOM,
      "flower" to MaterialShapes.FLOWER,
      "puffy" to MaterialShapes.PUFFY,
      "puffyDiamond" to MaterialShapes.PUFFY_DIAMOND,
      "pixelCircle" to MaterialShapes.PIXEL_CIRCLE,
      "pixelTriangle" to MaterialShapes.PIXEL_TRIANGLE,
      "bun" to MaterialShapes.BUN,
      "heart" to MaterialShapes.HEART,
    )
  }

  private val rootView: View
    get() {
      return window.findViewById(android.R.id.content)
    }

  private var shouldKeepSplashScreen = true

  override fun getBackgroundMode(): BackgroundMode {
    return if (intent.hasExtra(EXTRA_BACKGROUND_MODE)) {
      BackgroundMode.valueOf(intent.getStringExtra(EXTRA_BACKGROUND_MODE)!!)
    } else {
      BackgroundMode.transparent
    }
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      CHANNEL
    ).setMethodCallHandler(this)
  }


  override fun onCreate(savedInstanceState: Bundle?) {
    val splashScreen = installSplashScreen()
    splashScreen.setKeepOnScreenCondition(this)

    window.requestFeature(Window.FEATURE_ACTIVITY_TRANSITIONS)


    val colorSurface =
      MaterialColors.getColorOrNull(context, com.google.android.material.R.attr.colorSurface)!!

//    val containerColor = intent.getIntExtra("start_container_color", colorSurface)
    val containerColor = intent.getIntExtra("container_color", colorSurface)
    val startContainerColor = intent.getIntExtra("start_container_color", colorSurface)
    val endContainerColor = intent.getIntExtra("end_container_color", colorSurface)

    ViewCompat.setTransitionName(rootView, "shared_element_root")

    setEnterSharedElementCallback(MaterialContainerTransformSharedElementCallback())

//    window.sharedElementsUseOverlay = true
    window.sharedElementEnterTransition =
      buildContainerTransform(true, containerColor, endContainerColor, startContainerColor)
    window.sharedElementReturnTransition =
      buildContainerTransform(false, containerColor, endContainerColor, startContainerColor)

    super.onCreate(savedInstanceState)


    val flutterView = findViewById<View>(FLUTTER_VIEW_ID)
    flutterView.transitionName = "flutter_view"
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "setShouldKeepSplashScreen" -> {
        val value = call.arguments
        if (value is Boolean) {
          shouldKeepSplashScreen = value
        } else {
          result.error("ArgumentError", null, null)
        }
      }

      "hideSplashScreen" -> {
        shouldKeepSplashScreen = false
      }

      "getResourceIdentifier" -> {
        val key = call.arguments
        if (key is String) {
          val id = RESOURCES[key]
          result.success(id)
        } else {
          result.error("ArgumentError", null, null)
        }
      }

      "getShapePathData" -> {
        val shape = MaterialShapes.COOKIE_4
        val pathData = shape.toPathData()
        result.success(pathData)
      }

      "getShapesPathData" -> {
        val radial = call.arguments<Boolean?>()
        val data = SHAPES.mapValues { it.value.toFlutterClassMember(it.key) }
        result.success(data)
      }

      else -> result.notImplemented()
    }
  }

  override fun shouldKeepOnScreen(): Boolean {
    return shouldKeepSplashScreen
  }

  private fun buildContainerTransform(
    entering: Boolean, @ColorInt allContainersColor: Int
  ): MaterialContainerTransform {
    return buildContainerTransform(
      entering, allContainersColor, allContainersColor, allContainersColor
    )
  }

  private fun buildContainerTransform(
    entering: Boolean,
    @ColorInt containerColor: Int? = null,
    @ColorInt startContainerColor: Int? = null,
    @ColorInt endContainerColor: Int? = null,
  ): MaterialContainerTransform {
    val transform = MaterialContainerTransform(window.context, entering)
    if (containerColor != null) {
      transform.containerColor = containerColor
    }
    if (startContainerColor != null) {
      transform.startContainerColor = startContainerColor
    }
    if (endContainerColor != null) {
      transform.endContainerColor = endContainerColor
    }
    transform.addTarget(rootView)
    return transform
  }


}



