package dev.deminearchiver.scribe.shape

import android.graphics.Matrix
import android.graphics.PointF
import android.graphics.RectF
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.PathShape
import androidx.graphics.shapes.CornerRounding
import androidx.graphics.shapes.RoundedPolygon
import androidx.graphics.shapes.circle
import androidx.graphics.shapes.rectangle
import androidx.graphics.shapes.star
import androidx.graphics.shapes.toPath
import androidx.graphics.shapes.transformed
import java.util.Arrays
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.hypot
import kotlin.math.min
import kotlin.math.sin


/**
 * A utility class providing static methods for creating Material endorsed shapes using the `androidx.graphics.shapes` library.
 */
object MaterialShapes {
  // Cache various roundings for use below
  private val CORNER_ROUND_15: CornerRounding =
    CornerRounding( /* radius= */.15f,  /* smoothing= */0f)
  private val CORNER_ROUND_20: CornerRounding =
    CornerRounding( /* radius= */.2f,  /* smoothing= */0f)
  private val CORNER_ROUND_30: CornerRounding =
    CornerRounding( /* radius= */.3f,  /* smoothing= */0f)
  private val CORNER_ROUND_50: CornerRounding =
    CornerRounding( /* radius= */.5f,  /* smoothing= */0f)
  private val CORNER_ROUND_100: CornerRounding =
    CornerRounding( /* radius= */1f,  /* smoothing= */0f)

  /** A circle shape [RoundedPolygon] fitting in a unit circle.  */
  val CIRCLE: RoundedPolygon = normalize(circle,  /* radial= */true)

  /** A rounded square shape [RoundedPolygon] fitting in a unit circle.  */
  val SQUARE: RoundedPolygon = normalize(square,  /* radial= */true)

  /** A slanted rounded square shape [RoundedPolygon] fitting in a unit circle.  */
  val SLANTED_SQUARE: RoundedPolygon = normalize(slantedSquare,  /* radial= */true)

  /** An arch shape [RoundedPolygon] fitting in a unit circle.  */
  val ARCH: RoundedPolygon = normalize(arch,  /* radial= */true)

  /** A fan shape [RoundedPolygon] fitting in a unit circle.  */
  val FAN: RoundedPolygon = normalize(fan,  /* radial= */true)

  /** An arrow shape [RoundedPolygon] fitting in a unit circle.  */
  val ARROW: RoundedPolygon = normalize(arrow,  /* radial= */true)

  /** A semi-circle shape [RoundedPolygon] fitting in a unit circle.  */
  val SEMI_CIRCLE: RoundedPolygon = normalize(semiCircle,  /* radial= */true)

  /** An oval shape [RoundedPolygon] fitting in a unit circle.  */
  val OVAL: RoundedPolygon = normalize(getOval( /* rotateDegrees= */-45f),  /* radial= */true)

  /** A pill shape [RoundedPolygon] fitting in a unit circle.  */
  val PILL: RoundedPolygon = normalize(pill,  /* radial= */true)

  /** A triangle shape [RoundedPolygon] fitting in a unit circle.  */
  val TRIANGLE: RoundedPolygon =
    normalize(getTriangle( /* rotateDegrees= */-90f),  /* radial= */true)

  /** A diamond shape [RoundedPolygon] fitting in a unit circle.  */
  val DIAMOND: RoundedPolygon = normalize(diamond,  /* radial= */true)

  /** A clam-shell shape [RoundedPolygon] fitting in a unit circle.  */
  val CLAM_SHELL: RoundedPolygon = normalize(clamShell,  /* radial= */true)

  /** A pentagon shape [RoundedPolygon] fitting in a unit circle.  */
  val PENTAGON: RoundedPolygon = normalize(pentagon,  /* radial= */true)

  /** A gem shape [RoundedPolygon] fitting in a unit circle.  */
  val GEM: RoundedPolygon = normalize(getGem( /* rotateDegrees= */-90f),  /* radial= */true)

  val SUNNY: RoundedPolygon = normalize(sunny,  /* radial= */true)
  val VERY_SUNNY: RoundedPolygon = normalize(verySunny,  /* radial= */true)
  val COOKIE_4: RoundedPolygon = normalize(cookie4,  /* radial= */true)
  val COOKIE_6: RoundedPolygon = normalize(cookie6,  /* radial= */true)
  val COOKIE_7: RoundedPolygon = normalize(cookie7,  /* radial= */true)
  val COOKIE_9: RoundedPolygon = normalize(cookie9,  /* radial= */true)
  val COOKIE_12: RoundedPolygon = normalize(cookie12,  /* radial= */true)
  val GHOSTISH: RoundedPolygon = normalize(ghostish,  /* radial= */true)
  val CLOVER_4: RoundedPolygon = normalize(clover4,  /* radial= */true)
  val CLOVER_8: RoundedPolygon = normalize(clover8,  /* radial= */true)
  val BURST: RoundedPolygon = normalize(burst,  /* radial= */true)
  val SOFT_BURST: RoundedPolygon = normalize(softBurst,  /* radial= */true)
  val BOOM: RoundedPolygon = normalize(boom,  /* radial= */true)
  val SOFT_BOOM: RoundedPolygon = normalize(softBoom,  /* radial= */true)
  val FLOWER: RoundedPolygon = normalize(flower,  /* radial= */true)
  val PUFFY: RoundedPolygon = normalize(puffy,  /* radial= */true)
  val PUFFY_DIAMOND: RoundedPolygon = normalize(puffyDiamond,  /* radial= */true)
  val PIXEL_CIRCLE: RoundedPolygon = normalize(pixelCircle,  /* radial= */true)
  val PIXEL_TRIANGLE: RoundedPolygon = normalize(pixelTriangle,  /* radial= */true)
  val BUN: RoundedPolygon = normalize(bun,  /* radial= */true)
  val HEART: RoundedPolygon = normalize(heart,  /* radial= */true)

  private val circle: RoundedPolygon
    get() = RoundedPolygon /* numVertices= */.circle(10)

  private val square: RoundedPolygon
    get() = RoundedPolygon /* width= */.rectangle(
      1f,  /* height= */
      1f,  /* rounding= */
      CORNER_ROUND_30,  /* perVertexRounding= */
      null,  /* centerX= */
      0f,  /* centerY= */
      0f
    )

  private val slantedSquare: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(
        VertexAndRounding(PointF(0.926f, 0.970f), CornerRounding(0.189f, 0.811f))
      )
      points.add(
        VertexAndRounding(PointF(-0.021f, 0.967f), CornerRounding(0.187f, 0.057f))
      )
      return customPolygon(points, 2, 0.5f, 0.5f, false)
    }

  private val arch: RoundedPolygon
    get() {
      return RoundedPolygon( /* numVertices= */
        4,  /* radius= */
        1f,  /* centerX= */
        0f,  /* centerY= */
        0f,  /* rounding= */
        CornerRounding.Unrounded,  /* perVertexRounding= */
        Arrays.asList(
          CORNER_ROUND_100, CORNER_ROUND_100, CORNER_ROUND_20, CORNER_ROUND_20
        )
      ).transformed(createRotationMatrix(-135f))
    }

  private val fan: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(1f, 1f), CornerRounding(0.148f, 0.417f)))
      points.add(VertexAndRounding(PointF(0f, 1f), CornerRounding(0.151f, 0f)))
      points.add(VertexAndRounding(PointF(0f, 0f), CornerRounding(0.148f, 0f)))
      points.add(VertexAndRounding(PointF(0.978f, 0.020f), CornerRounding(0.803f, 0f)))
      return customPolygon(points, 1, 0.5f, 0.5f, false)
    }

  private val arrow: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0.892f), CornerRounding(0.313f, 0f)))
      points.add(VertexAndRounding(PointF(-0.216f, 1.050f), CornerRounding(0.207f, 0f)))
      points.add(
        VertexAndRounding(PointF(0.499f, -0.160f), CornerRounding(0.215f, 1.000f))
      )
      points.add(VertexAndRounding(PointF(1.225f, 1.060f), CornerRounding(0.211f, 0f)))
      return customPolygon(points, 1, 0.5f, 0.5f, false)
    }

  private val semiCircle: RoundedPolygon
    get() {
      return RoundedPolygon /* width= */.rectangle(
        1.6f,  /* height= */
        1f,  /* rounding= */
        CornerRounding.Unrounded,  /* perVertexRounding= */
        listOf(
          CORNER_ROUND_20, CORNER_ROUND_20, CORNER_ROUND_100, CORNER_ROUND_100
        ),  /* centerX= */
        0f,  /* centerY= */
        0f
      )
    }

  private val oval: RoundedPolygon
    get() {
      return RoundedPolygon.circle()
        .transformed(createScaleMatrix( /* scaleX= */1f,  /* scaleY= */.64f))
    }

  private fun getOval(rotateDegrees: Float): RoundedPolygon {
    return oval.transformed(createRotationMatrix(rotateDegrees))
  }

  private val pill: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.961f, 0.039f), CornerRounding(0.426f, 0f)))
      points.add(VertexAndRounding(PointF(1.001f, 0.428f)))
      points.add(VertexAndRounding(PointF(1.000f, 0.609f), CORNER_ROUND_100))
      return customPolygon(points, 2, 0.5f, 0.5f, true)
    }

  private val triangle: RoundedPolygon
    get() {
      return RoundedPolygon( /* numVertices= */
        3,  /* radius= */
        1f,  /* centerX= */
        0f,  /* centerY= */
        0f,  /* rounding= */
        CORNER_ROUND_20
      )
    }

  private fun getTriangle(rotateDegrees: Float): RoundedPolygon {
    return triangle.transformed(createRotationMatrix(rotateDegrees))
  }

  private val diamond: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(
        VertexAndRounding(PointF(0.500f, 1.096f), CornerRounding(0.151f, 0.524f))
      )
      points.add(VertexAndRounding(PointF(0.040f, 0.500f), CornerRounding(0.159f, 0f)))
      return customPolygon(points, 2, 0.5f, 0.5f, false)
    }

  private val clamShell: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.171f, 0.841f), CornerRounding(0.159f, 0f)))
      points.add(VertexAndRounding(PointF(-0.020f, 0.500f), CornerRounding(0.140f, 0f)))
      points.add(VertexAndRounding(PointF(0.170f, 0.159f), CornerRounding(0.159f, 0f)))
      return customPolygon(points, 2, 0.5f, 0.5f, false)
    }

  private val pentagon: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, -0.009f), CornerRounding(0.172f, 0f)))
      return customPolygon(points, 5, 0.5f, 0.5f, false)
    }

  private val gem: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(
        VertexAndRounding(PointF(0.499f, 1.023f), CornerRounding(0.241f, 0.778f))
      )
      points.add(VertexAndRounding(PointF(-0.005f, 0.792f), CornerRounding(0.208f, 0f)))
      points.add(VertexAndRounding(PointF(0.073f, 0.258f), CornerRounding(0.228f, 0f)))
      points.add(VertexAndRounding(PointF(0.433f, -0.000f), CornerRounding(0.491f, 0f)))
      return customPolygon(points, 1, 0.5f, 0.5f, true)
    }

  private fun getGem(rotateDegrees: Float): RoundedPolygon {
    return gem.transformed(createRotationMatrix(rotateDegrees))
  }

  private val sunny: RoundedPolygon
    get() {
      return RoundedPolygon /* numVerticesPerRadius= */.star(
        8,  /* radius= */
        1f,  /* innerRadius= */
        0.8f,  /* rounding= */
        CORNER_ROUND_15
      )
    }

  private val verySunny: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 1.080f), CornerRounding(0.085f, 0f)))
      points.add(VertexAndRounding(PointF(0.358f, 0.843f), CornerRounding(0.085f, 0f)))
      return customPolygon(points, 8, 0.5f, 0.5f, false)
    }

  private val cookie4: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(1.237f, 1.236f), CornerRounding(0.258f, 0f)))
      points.add(VertexAndRounding(PointF(0.500f, 0.918f), CornerRounding(0.233f, 0f)))
      return customPolygon(points, 4, 0.5f, 0.5f, false)
    }

  private val cookie6: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.723f, 0.884f), CornerRounding(0.394f, 0f)))
      points.add(VertexAndRounding(PointF(0.500f, 1.099f), CornerRounding(0.398f, 0f)))
      return customPolygon(points, 6, 0.5f, 0.5f, false)
    }

  private val cookie7: RoundedPolygon
    get() {
      return RoundedPolygon /* numVerticesPerRadius= */.star(
        7,  /* radius= */
        1f,  /* innerRadius= */
        0.75f,  /* rounding= */
        CORNER_ROUND_50
      ).transformed(createRotationMatrix(-90f))
    }

  private val cookie9: RoundedPolygon
    get() {
      return RoundedPolygon /* numVerticesPerRadius= */.star(
        9,  /* radius= */
        1f,  /* innerRadius= */
        0.8f,  /* rounding= */
        CORNER_ROUND_50
      ).transformed(createRotationMatrix(-90f))
    }

  private val cookie12: RoundedPolygon
    get() {
      return RoundedPolygon /* numVerticesPerRadius= */.star(
        12,  /* radius= */
        1f,  /* innerRadius= */
        0.8f,  /* rounding= */
        CORNER_ROUND_50
      ).transformed(createRotationMatrix(-90f))
    }

  private val ghostish: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0f), CORNER_ROUND_100))
      points.add(VertexAndRounding(PointF(1f, 0f), CORNER_ROUND_100))
      points.add(VertexAndRounding(PointF(1f, 1.140f), CornerRounding(0.254f, 0.106f)))
      points.add(VertexAndRounding(PointF(0.575f, 0.906f), CornerRounding(0.253f, 0f)))
      return customPolygon(points, 1, 0.5f, 0.5f, true)
    }

  private val clover4: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0.074f)))
      points.add(VertexAndRounding(PointF(0.725f, -0.099f), CornerRounding(0.476f, 0f)))
      return customPolygon(points, 4, 0.5f, 0.5f, true)
    }

  private val clover8: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0.036f)))
      points.add(VertexAndRounding(PointF(0.758f, -0.101f), CornerRounding(0.209f, 0f)))
      return customPolygon(points, 8, 0.5f, 0.5f, false)
    }

  private val burst: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, -0.006f), CornerRounding(0.006f, 0f)))
      points.add(VertexAndRounding(PointF(0.592f, 0.158f), CornerRounding(0.006f, 0f)))
      return customPolygon(points, 12, 0.5f, 0.5f, false)
    }

  private val softBurst: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.193f, 0.277f), CornerRounding(0.053f, 0f)))
      points.add(VertexAndRounding(PointF(0.176f, 0.055f), CornerRounding(0.053f, 0f)))
      return customPolygon(points, 10, 0.5f, 0.5f, false)
    }

  private val boom: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.457f, 0.296f), CornerRounding(0.007f, 0f)))
      points.add(VertexAndRounding(PointF(0.500f, -0.051f), CornerRounding(0.007f, 0f)))
      return customPolygon(points, 15, 0.5f, 0.5f, false)
    }

  private val softBoom: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.733f, 0.454f)))
      points.add(VertexAndRounding(PointF(0.839f, 0.437f), CornerRounding(0.532f, 0f)))
      points.add(VertexAndRounding(PointF(0.949f, 0.449f), CornerRounding(0.439f, 1f)))
      points.add(VertexAndRounding(PointF(0.998f, 0.478f), CornerRounding(0.174f, 0f)))
      return customPolygon(points, 16, 0.5f, 0.5f, true)
    }

  private val flower: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.370f, 0.187f)))
      points.add(VertexAndRounding(PointF(0.416f, 0.049f), CornerRounding(0.381f, 0f)))
      points.add(VertexAndRounding(PointF(0.479f, 0f), CornerRounding(0.095f, 0f)))
      return customPolygon(points, 8, 0.5f, 0.5f, true)
    }

  private val puffy: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0.053f)))
      points.add(VertexAndRounding(PointF(0.545f, -0.040f), CornerRounding(0.405f, 0f)))
      points.add(VertexAndRounding(PointF(0.670f, -0.035f), CornerRounding(0.426f, 0f)))
      points.add(VertexAndRounding(PointF(0.717f, 0.066f), CornerRounding(0.574f, 0f)))
      points.add(VertexAndRounding(PointF(0.722f, 0.128f)))
      points.add(VertexAndRounding(PointF(0.777f, 0.002f), CornerRounding(0.360f, 0f)))
      points.add(VertexAndRounding(PointF(0.914f, 0.149f), CornerRounding(0.660f, 0f)))
      points.add(VertexAndRounding(PointF(0.926f, 0.289f), CornerRounding(0.660f, 0f)))
      points.add(VertexAndRounding(PointF(0.881f, 0.346f)))
      points.add(VertexAndRounding(PointF(0.940f, 0.344f), CornerRounding(0.126f, 0f)))
      points.add(VertexAndRounding(PointF(1.003f, 0.437f), CornerRounding(0.255f, 0f)))
      return customPolygon(points, 2, 0.5f, 0.5f, true).transformed(createScaleMatrix(1f, 0.742f))
    }

  private val puffyDiamond: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.870f, 0.130f), CornerRounding(0.146f, 0f)))
      points.add(VertexAndRounding(PointF(0.818f, 0.357f)))
      points.add(VertexAndRounding(PointF(1.000f, 0.332f), CornerRounding(0.853f, 0f)))
      return customPolygon(points, 4, 0.5f, 0.5f, true)
    }

  private val pixelCircle: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0.000f)))
      points.add(VertexAndRounding(PointF(0.704f, 0.000f)))
      points.add(VertexAndRounding(PointF(0.704f, 0.065f)))
      points.add(VertexAndRounding(PointF(0.843f, 0.065f)))
      points.add(VertexAndRounding(PointF(0.843f, 0.148f)))
      points.add(VertexAndRounding(PointF(0.926f, 0.148f)))
      points.add(VertexAndRounding(PointF(0.926f, 0.296f)))
      points.add(VertexAndRounding(PointF(1.000f, 0.296f)))
      return customPolygon(points, 2, 0.5f, 0.5f, true)
    }

  private val pixelTriangle: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.110f, 0.500f)))
      points.add(VertexAndRounding(PointF(0.113f, 0.000f)))
      points.add(VertexAndRounding(PointF(0.287f, 0.000f)))
      points.add(VertexAndRounding(PointF(0.287f, 0.087f)))
      points.add(VertexAndRounding(PointF(0.421f, 0.087f)))
      points.add(VertexAndRounding(PointF(0.421f, 0.170f)))
      points.add(VertexAndRounding(PointF(0.560f, 0.170f)))
      points.add(VertexAndRounding(PointF(0.560f, 0.265f)))
      points.add(VertexAndRounding(PointF(0.674f, 0.265f)))
      points.add(VertexAndRounding(PointF(0.675f, 0.344f)))
      points.add(VertexAndRounding(PointF(0.789f, 0.344f)))
      points.add(VertexAndRounding(PointF(0.789f, 0.439f)))
      points.add(VertexAndRounding(PointF(0.888f, 0.439f)))
      return customPolygon(points, 1, 0.5f, 0.5f, true)
    }

  private val bun: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.796f, 0.500f)))
      points.add(VertexAndRounding(PointF(0.853f, 0.518f), CORNER_ROUND_100))
      points.add(VertexAndRounding(PointF(0.992f, 0.631f), CORNER_ROUND_100))
      points.add(VertexAndRounding(PointF(0.968f, 1.000f), CORNER_ROUND_100))
      return customPolygon(points, 2, 0.5f, 0.5f, true)
    }

  private val heart: RoundedPolygon
    get() {
      val points: MutableList<VertexAndRounding> = ArrayList()
      points.add(VertexAndRounding(PointF(0.500f, 0.268f), CornerRounding(0.016f, 0f)))
      points.add(VertexAndRounding(PointF(0.792f, -0.066f), CornerRounding(0.958f, 0f)))
      points.add(VertexAndRounding(PointF(1.064f, 0.276f), CORNER_ROUND_100))
      points.add(VertexAndRounding(PointF(0.501f, 0.946f), CornerRounding(0.129f, 0f)))
      return customPolygon(points, 1, 0.5f, 0.5f, true)
    }

  private fun repeatAroundCenter(
    template: List<VertexAndRounding>,
    outList: MutableList<VertexAndRounding>,
    repeatCount: Int,
    centerX: Float,
    centerY: Float,
    mirroring: Boolean
  ) {
    outList.clear()
    toRadial(template, centerX, centerY)
    var spanPerRepeat: Float = (2 * Math.PI / repeatCount).toFloat()
    if (mirroring) {
      // Template will be repeated in the original order then in the reverse order.
      val mirroredRepeatCount: Int = repeatCount * 2
      spanPerRepeat /= 2f
      for (i in 0 until mirroredRepeatCount) {
        for (j in template.indices) {
          val reverse: Boolean = i % 2 != 0
          val indexInTemplate: Int = if (reverse) template.size - 1 - j else j
          val templatePoint: VertexAndRounding = template.get(indexInTemplate)
          if (indexInTemplate > 0 || !reverse) {
            val angle: Float =
              (spanPerRepeat * i + (if (reverse) spanPerRepeat - templatePoint.vertex.x + 2 * template.get(
                0
              ).vertex.x
              else templatePoint.vertex.x))
            val outVertex: PointF = PointF(angle, templatePoint.vertex.y)
            outList.add(VertexAndRounding(outVertex, templatePoint.rounding))
          }
        }
      }
    } else {
      for (i in 0 until repeatCount) {
        for (templatePoint: VertexAndRounding in template) {
          val angle: Float = spanPerRepeat * i + templatePoint.vertex.x
          val outVertex: PointF = PointF(angle, templatePoint.vertex.y)
          outList.add(VertexAndRounding(outVertex, templatePoint.rounding))
        }
      }
    }
    toCartesian(outList, centerX, centerY)
  }

  private fun customPolygon(
    template: List<VertexAndRounding>,
    repeat: Int,
    centerX: Float,
    centerY: Float,
    mirroring: Boolean
  ): RoundedPolygon {
    val vertexAndRoundings: MutableList<VertexAndRounding> = ArrayList()
    repeatAroundCenter(template, vertexAndRoundings, repeat, centerX, centerY, mirroring)

    val verticesXy: FloatArray = toVerticesXyArray(vertexAndRoundings)
    val roundings: List<CornerRounding> = toRoundingsList(vertexAndRoundings)
    return RoundedPolygon(
      verticesXy, CornerRounding.Unrounded, roundings, centerX, centerY
    )
  }

  // ============== Utility methods. ==================
  /**
   * Returns a [ShapeDrawable] with the shape's path.
   *
   *
   * The shape is always assumed to fit in (0, 0) to (1, 1) square.
   *
   * @param shape A [RoundedPolygon] object to be used in the drawable.
   * @hide
   */
  fun createShapeDrawable(shape: RoundedPolygon): ShapeDrawable {
    val pathShape: PathShape = PathShape(shape.toPath(), 1f, 1f)
    return ShapeDrawable(pathShape)
  }

  /**
   * Creates a new [RoundedPolygon], moving and resizing this one, so it's completely inside
   * the destination bounds.
   *
   *
   * If `radial` is true, the shape will be scaled to fit in the biggest circle centered in
   * the destination bounds. This is useful when the shape is animated to rotate around its center.
   * Otherwise, the shape will be scaled to fit in the destination bounds. With either option, the
   * shape's original center will be aligned with the destination bounds center.
   *
   * @param shape The original [RoundedPolygon].
   * @param radial Whether to transform the shape to fit in the biggest circle centered in the
   * destination bounds.
   * @param dstBounds The destination bounds to fit.
   * @return A new [RoundedPolygon] that fits in the destination bounds.
   */
  fun normalize(
    shape: RoundedPolygon, radial: Boolean, dstBounds: RectF
  ): RoundedPolygon {
    val srcBoundsArray = FloatArray(4)
    if (radial) {
      // This calculates the axis-aligned bounds of the shape and returns that rectangle. It
      // determines the max dimension of the shape (by calculating the distance from its center to
      // the start and midpoint of each curve) and returns a square which can be used to hold the
      // object in any rotation.
      shape.calculateMaxBounds(srcBoundsArray)
    } else {
      // This calculates the bounds of the shape without rotating the shape.
      shape.calculateBounds(srcBoundsArray)
    }
    val srcBounds = RectF(
      srcBoundsArray[0], srcBoundsArray[1], srcBoundsArray[2], srcBoundsArray[3]
    )
    val scale: Float = min(
      (dstBounds.width() / srcBounds.width()).toDouble(),
      (dstBounds.height() / srcBounds.height()).toDouble()
    ).toFloat()
    // Scales the shape with pivot point at its original center then moves it to align its original
    // center with the destination bounds center.
    val transform: Matrix = createScaleMatrix(scale, scale)
    transform.preTranslate(-srcBounds.centerX(), -srcBounds.centerY())
    transform.postTranslate(dstBounds.centerX(), dstBounds.centerY())
    return shape.transformed(transform)
  }

  /**
   * Creates a new [RoundedPolygon], moving and resizing this one, so it's completely inside
   * (0, 0) - (1, 1) square.
   *
   *
   * If `radial` is true, the shape will be scaled to fit in the circle centered at (0.5,
   * 0.5) with a radius of 0.5. This is useful when the shape is animated to rotate around its
   * center. Otherwise, the shape will be scaled to fit in the (0, 0) - (1, 1) square. With either
   * option, the shape center will be (0.5, 0.5).
   *
   * @param shape The original [RoundedPolygon].
   * @param radial Whether to transform the shape to fit in the circle centered at (0.5, 0.5) with a
   * radius of 0.5.
   * @return A new [RoundedPolygon] that fits in (0, 0) - (1, 1) square.
   */
  fun normalize(shape: RoundedPolygon, radial: Boolean): RoundedPolygon {
    return normalize(shape, radial, RectF(0f, 0f, 1f, 1f))
  }

  /**
   * Returns a [Matrix] with the input scales.
   *
   * @param scaleX Scale in X axis.
   * @param scaleY Scale in Y axis
   */
  private fun createScaleMatrix(scaleX: Float, scaleY: Float): Matrix {
    val matrix: Matrix = Matrix()
    matrix.setScale(scaleX, scaleY)
    return matrix
  }

  /**
   * Returns a [Matrix] with the input rotation in degrees.
   *
   * @param degrees The rotation in degrees.
   */
  private fun createRotationMatrix(degrees: Float): Matrix {
    val matrix = Matrix()
    matrix.setRotate(degrees)
    return matrix
  }

  /**
   * Returns a [Matrix] with the input skews.
   *
   * @param kx The skew in X axis.
   * @param ky The skew in Y axis.
   */
  private fun createSkewMatrix(kx: Float, ky: Float): Matrix {
    val matrix: Matrix = Matrix()
    matrix.setSkew(kx, ky)
    return matrix
  }

  private fun toRadial(
    vertexAndRoundings: List<VertexAndRounding>, centerX: Float, centerY: Float
  ) {
    for (vertexAndRounding: VertexAndRounding in vertexAndRoundings) {
      vertexAndRounding.toRadial(centerX, centerY)
    }
  }

  private fun toCartesian(
    vertexAndRoundings: List<VertexAndRounding>, centerX: Float, centerY: Float
  ) {
    for (vertexAndRounding: VertexAndRounding in vertexAndRoundings) {
      vertexAndRounding.toCartesian(centerX, centerY)
    }
  }

  private fun toVerticesXyArray(vertexAndRoundings: List<VertexAndRounding>): FloatArray {
    val verticesXy = FloatArray(vertexAndRoundings.size * 2)
    for (i in vertexAndRoundings.indices) {
      verticesXy[2 * i] = vertexAndRoundings[i].vertex.x
      verticesXy[2 * i + 1] = vertexAndRoundings[i].vertex.y
    }
    return verticesXy
  }

  private fun toRoundingsList(
    vertexAndRoundings: List<VertexAndRounding>
  ): List<CornerRounding> {
    val roundings: MutableList<CornerRounding> = ArrayList()
    for (i in vertexAndRoundings.indices) {
      roundings.add(vertexAndRoundings[i].rounding)
    }
    return roundings
  }

  internal class VertexAndRounding(
    val vertex: PointF, val rounding: CornerRounding = CornerRounding.Unrounded
  ) {
    fun toRadial(centerX: Float, centerY: Float) {
      vertex.offset(-centerX, -centerY)
      val angle = atan2(vertex.y, vertex.x)
      val distance = hypot(vertex.x, vertex.y)
      vertex.x = angle
      vertex.y = distance
    }

    fun toCartesian(centerX: Float, centerY: Float) {
      val x = (vertex.y * cos(vertex.x) + centerX)
      val y = (vertex.y * sin(vertex.x) + centerY)
      vertex.x = x
      vertex.y = y
    }
  }
}
