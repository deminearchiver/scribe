package dev.deminearchiver.services

import android.os.Build
import android.view.RoundedCorner
import android.view.WindowInsets
import androidx.annotation.RequiresApi

data class WindowCorners(
  val topLeft: Double,
  val topRight: Double,
  val bottomRight: Double,
  val bottomLeft: Double,
) {
  fun toMap(): Map<String, Double> {
    return mapOf(
      "topLeft" to topLeft,
      "topRight" to topRight,
      "bottomRight" to bottomRight,
      "bottomLeft" to bottomLeft,
    )
  }
}

@RequiresApi(Build.VERSION_CODES.S)
fun WindowInsets.getCorners(density: Double): WindowCorners {
  return if (density == 0.0) {
    WindowCorners(0.0, 0.0, 0.0, 0.0)
  } else {
    val topLeft =
      getRoundedCorner(RoundedCorner.POSITION_TOP_LEFT)?.radius?.toDouble() ?: 0.0
    val topRight =
      getRoundedCorner(RoundedCorner.POSITION_TOP_RIGHT)?.radius?.toDouble() ?: 0.0
    val bottomRight =
      getRoundedCorner(RoundedCorner.POSITION_BOTTOM_RIGHT)?.radius?.toDouble()
        ?: 0.0
    val bottomLeft =
      getRoundedCorner(RoundedCorner.POSITION_BOTTOM_LEFT)?.radius?.toDouble() ?: 0.0
    WindowCorners(
      topLeft / density,
      topRight / density,
      bottomRight / density,
      bottomLeft / density,
    )
  }
}
