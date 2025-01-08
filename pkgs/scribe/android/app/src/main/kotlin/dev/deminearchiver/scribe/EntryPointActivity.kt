package dev.deminearchiver.scribe

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

abstract class EntryPointActivity : FlutterActivity() {
  abstract val entryPoint: String

  override fun getDartEntrypointFunctionName() = entryPoint

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
  }
}
