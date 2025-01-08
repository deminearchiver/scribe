package dev.deminearchiver.scribe

fun String.toCamelCase(): String {
  if(isEmpty()) return ""
  val parts = lowercase().split("_")
  if(parts.size == 1) return parts.joinToString("")
  val first = parts.take(1)
  val rest = parts.drop(1)
  return first.joinToString("") + rest.joinToString("", transform = {
    replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
  })
}
