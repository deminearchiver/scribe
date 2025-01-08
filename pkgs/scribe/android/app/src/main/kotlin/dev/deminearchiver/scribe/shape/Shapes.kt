package dev.deminearchiver.scribe.shape

import android.graphics.Path
import androidx.graphics.shapes.Cubic
import androidx.graphics.shapes.RoundedPolygon


fun RoundedPolygon.toPathData(): String {
  return buildString {
    var first: Cubic? = null
    for (cubic in cubics) {
      if (first == null) {
        append("M${cubic.anchor0X},${cubic.anchor0Y}")
        first = cubic
      }
      append(" C${cubic.control0X},${cubic.control0Y} ${cubic.control1X},${cubic.control1Y} ${cubic.anchor1X},${cubic.anchor1Y}")
    }
    if (first != null) append("L${first.anchor0X},${first.anchor0Y}")
    append(" Z")
  }
}

fun RoundedPolygon.toFlutterPath(): String {
  return buildString {
    append("Path()")
    var first: Cubic? = null
    for (cubic in cubics) {
      if (first == null) {
        append("..moveTo(${cubic.anchor0X}, ${cubic.anchor0Y})")
        first = cubic
      }
      append("..cubicTo(${cubic.control0X}, ${cubic.control0Y}, ${cubic.control1X}, ${cubic.control1Y}, ${cubic.anchor1X}, ${cubic.anchor1Y})")
    }
    if (first != null) append("..lineTo(${first.anchor0X}, ${first.anchor0Y})")
    append("..close()")
  }
}

private fun RoundedPolygon.toFloatList(): List<Float> {
  return buildList {
    var first: Cubic? = null
    for (cubic in cubics) {
      if (first == null) {
        add(cubic.anchor0X)
        add(cubic.anchor0Y)
        first = cubic
      }
      add(cubic.control0X)
      add(cubic.control0Y)
      add(cubic.control1X)
      add(cubic.control1Y)
      add(cubic.anchor1X)
      add(cubic.anchor1Y)
    }
    if (first != null) {
      add(first.anchor0X)
      add(first.anchor0Y)
    }
  }
}

fun RoundedPolygon.toFlutterClassMember(name: String): String {
  val nonRadial = MaterialShapes.normalize(this, false)
  val radial = MaterialShapes.normalize(this, true)

  val defaultFloatList = toFloatList()
  val nonRadialFloatList = nonRadial.toFloatList()
  val radialFloatList = radial.toFloatList()
  val isNonRadial = defaultFloatList == nonRadialFloatList
  val isRadial = defaultFloatList == radialFloatList

  val defaultPath = toFlutterPath()

  if (isNonRadial && isRadial) {
    return buildString {
      append("static final Path _${name}Default = ${defaultPath};")
      append("static Path ${name}() => Path.from(_${name}Default);")
    }
  }

  if (isNonRadial) {
    val radialPath = radial.toFlutterPath()
    return buildString {
      append("static final Path _${name}Default = ${defaultPath};")
      append("static final Path _${name}Radial = ${radialPath};")

      append("static Path ${name}([bool radial = false]) {")
      append("return Path.from(")
      append("radial ? _${name}Radial : _${name}Default")
      append(");")
      append("}")
    }
  }
  if (isRadial) {
    val nonRadialPath = nonRadial.toFlutterPath()
    return buildString {
      append("static final Path _${name}Default = ${defaultPath};")
      append("static final Path _${name}NonRadial = ${nonRadialPath};")

      append("static Path ${name}([bool radial = true]) {")
      append("return Path.from(")
      append("radial ? _${name}Default : _${name}NonRadial")
      append(");")
      append("}")
    }
  }

  val nonRadialPath = nonRadial.toFlutterPath()
  val radialPath = radial.toFlutterPath()

  return buildString {
    append("static final Path _${name}Default = ${defaultPath};")
    append("static final Path _${name}NonRadial = ${nonRadialPath};")
    append("static final Path _${name}Radial = ${radialPath};")

    append("static Path ${name}([bool? radial]) {")
    append("return Path.from(")
    append("radial == null ? _${name}Default : radial ? _${name}Radial : _${name}NonRadial")
    append(");")
    append("}")
  }
}
