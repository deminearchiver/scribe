package dev.deminearchiver.scribe

import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.View.OnClickListener
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.app.ActivityOptionsCompat
import androidx.core.view.ViewCompat
import androidx.graphics.shapes.toPath
import com.google.android.material.bottomsheet.BottomSheetDialogFragment
import com.google.android.material.color.MaterialColors
import com.google.android.material.transition.MaterialContainerTransform
import dev.deminearchiver.scribe.shape.MaterialShapes
import dev.deminearchiver.scribe.shape.toPathData


open class CreateNewModalBottomSheet : BottomSheetDialogFragment() {
  override fun onCreateView(
    inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
  ): View? {

    val view = inflater.inflate(R.layout.modal_bottom_sheet_content, container, false)

    val tempText = view.findViewById<TextView>(R.id.tempText)
    val shape = MaterialShapes.COOKIE_4
    val pathData = shape.toPathData()
    tempText.text = pathData




    val openButton = view.findViewById<Button>(R.id.openButton)
    ViewCompat.setTransitionName(openButton, "open_button")

    val imageButton = view.findViewById<View>(R.id.imageButton)
    ViewCompat.setTransitionName(imageButton, "image_button")

    val textButton = view.findViewById<View>(R.id.textButton)
    ViewCompat.setTransitionName(textButton, "text_button")

    imageButton.setOnClickListener { _ ->
      val intent = Intent(requireContext(), MainActivity::class.java)

      val color =
        MaterialColors.getColor(view, com.google.android.material.R.attr.colorSecondaryContainer)
      intent.putExtra("start_container_color", color)

      startActivity(
        intent, ActivityOptionsCompat.makeSceneTransitionAnimation(
          requireActivity(), imageButton, "shared_element_root"
        ).toBundle()
      )
    }
    textButton.setOnClickListener { _ ->
      val intent = Intent(requireContext(), MainActivity::class.java)

      val color =
        MaterialColors.getColor(view, com.google.android.material.R.attr.colorSecondaryContainer)
      intent.putExtra("start_container_color", color)

      startActivity(
        intent, ActivityOptionsCompat.makeSceneTransitionAnimation(
          requireActivity(), textButton, "shared_element_root"
        ).toBundle()
      )
    }

    openButton.setOnClickListener { _ ->
      val sharedElement = view.parent as View
      val intent = Intent(requireContext(), MainActivity::class.java)
      startActivity(
        intent, ActivityOptionsCompat.makeSceneTransitionAnimation(
          requireActivity(), sharedElement, "shared_element_root"
        ).toBundle()
      )
    }
    return view
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
//
//    val container = view.parent as View
//    ViewCompat.setTransitionName(container, "container")
//
//
//    val colorSurface =
//      MaterialColors.getColor(view, com.google.android.material.R.attr.colorSurface)
//    val colorSecondaryContainer =
//      MaterialColors.getColor(view, com.google.android.material.R.attr.colorSecondaryContainer)
//
//    val imageButton = view.findViewById<View>(R.id.imageButton)
//    val textButton = view.findViewById<View>(R.id.textButton)
//
//    val enterContainerTransform =
//      buildContainerTransform(true, colorSurface, colorSecondaryContainer, colorSurface)
//    enterContainerTransform.addTarget(container)
//    enterContainerTransform.addTarget(imageButton)
//    enterContainerTransform.addTarget(textButton)
//    sharedElementEnterTransition = enterContainerTransform
//
//
//    val returnContainerTransform =
//      buildContainerTransform(false, colorSurface, colorSecondaryContainer, colorSurface)
//    returnContainerTransform.addTarget(container)
//    returnContainerTransform.addTarget(imageButton)
//    returnContainerTransform.addTarget(textButton)
//    sharedElementReturnTransition = returnContainerTransform
  }

  //  private fun addTransitionableTarget(view: View, @IdRes id: Int) {
//    val target = view.findViewById<View>(id)
//    if (target != null) {
//      ViewCompat.setTransitionName(target, id.toString())
//      target.setOnClickListener(this::showEndFragment)
//    }
//  }
//  private fun configureTransitions(fragment: Fragment) {
//    val colorSurface = MaterialColors.getColor(requireView(), com.google.android.material.R.attr.colorSurface)
//
//    val enterContainerTransform = buildContainerTransform(true)
//    enterContainerTransform.setAllContainerColors(colorSurface)
//    fragment.sharedElementEnterTransition = enterContainerTransform
//    holdTransition.duration = enterContainerTransform.getDuration()
//
//    val returnContainerTransform = buildContainerTransform(false)
//    returnContainerTransform.setAllContainerColors(colorSurface)
//    fragment.sharedElementReturnTransition = returnContainerTransform
//  }
//
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
    val transform = MaterialContainerTransform(
      requireContext(), entering
    )
    if (containerColor != null) {
      transform.containerColor = containerColor
    }
    if (startContainerColor != null) {
      transform.startContainerColor = startContainerColor
    }
    if (endContainerColor != null) {
      transform.endContainerColor = endContainerColor
    }
    return transform
  }

  companion object {
    const val TAG = "CreateNewModalBottomSheet"
  }
}
