package dev.deminearchiver.scribe

import android.os.Bundle
import android.view.Window
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.transition.platform.MaterialContainerTransform
import com.google.android.material.transition.platform.Hold
import com.google.android.material.transition.platform.MaterialContainerTransformSharedElementCallback


class ShortcutActivity : AppCompatActivity() {
  private lateinit var modalBottomSheet: CreateNewModalBottomSheet

  override fun onCreate(savedInstanceState: Bundle?) {
    window.requestFeature(Window.FEATURE_ACTIVITY_TRANSITIONS)
    window.requestFeature(Window.FEATURE_NO_TITLE)
    setExitSharedElementCallback(MaterialContainerTransformSharedElementCallback())

    modalBottomSheet = CreateNewModalBottomSheet()

    super.onCreate(savedInstanceState)

    modalBottomSheet.show(supportFragmentManager, CreateNewModalBottomSheet.TAG)
  }
}
