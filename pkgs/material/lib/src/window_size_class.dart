import 'package:material/material.dart';

enum WindowWidthSizeClass implements Comparable<WindowWidthSizeClass> {
  compact(0, 600),
  medium(600, 840),
  expanded(840, 1200),
  large(1200, 1600),
  extraLarge(1600, double.infinity);

  const WindowWidthSizeClass(this.minWidth, this.maxWidth);

  final double minWidth;
  final double maxWidth;

  bool includes(double width) => width >= minWidth && width < maxWidth;

  static WindowWidthSizeClass fromWidth(double width) {
    // While this implementation seems messy, it's an efficient way for
    // calculating the correct [WindowWidthSizeClass] since it uses at most 3
    // comparisons.
    if (width < WindowWidthSizeClass.expanded.minWidth) {
      return width < WindowWidthSizeClass.medium.minWidth
          ? WindowWidthSizeClass.compact
          : WindowWidthSizeClass.medium;
    } else {
      if (width < WindowWidthSizeClass.large.minWidth) {
        return WindowWidthSizeClass.expanded;
      } else if (width < WindowWidthSizeClass.extraLarge.minWidth) {
        return WindowWidthSizeClass.large;
      } else {
        return WindowWidthSizeClass.extraLarge;
      }
    }
  }

  static WindowWidthSizeClass? maybeOf(BuildContext context) {
    final size = MediaQuery.maybeSizeOf(context);
    if (size == null) return null;
    return WindowWidthSizeClass.fromWidth(size.width);
  }

  static WindowWidthSizeClass of(BuildContext context) {
    return WindowWidthSizeClass.fromWidth(MediaQuery.sizeOf(context).width);
  }

  WindowWidthSizeClass clamp(
    WindowWidthSizeClass? min,
    WindowWidthSizeClass? max,
  ) {
    if (min != null && this <= min) return min;
    if (max != null && this >= max) return max;
    return this;
  }

  @override
  int compareTo(WindowWidthSizeClass other) =>
      minWidth.compareTo(other.minWidth);

  bool operator >(WindowWidthSizeClass other) => minWidth > other.minWidth;

  bool operator >=(WindowWidthSizeClass other) => minWidth >= other.minWidth;

  bool operator <(WindowWidthSizeClass other) => minWidth < other.minWidth;

  bool operator <=(WindowWidthSizeClass other) => minWidth <= other.minWidth;
}

enum WindowHeightSizeClass implements Comparable<WindowHeightSizeClass> {
  compact(0, 480),
  medium(480, 900),
  expanded(900, double.infinity);

  const WindowHeightSizeClass(this.minHeight, this.maxHeight);

  final double minHeight;
  final double maxHeight;

  bool includes(double height) => height >= minHeight && height < maxHeight;

  static WindowHeightSizeClass fromHeight(double height) {
    // While this implementation seems messy, it's an efficient way for
    // calculating the correct [WindowHeightSizeClass] since it uses at most 2
    // comparisons.
    if (height < WindowHeightSizeClass.expanded.minHeight) {
      return height < WindowHeightSizeClass.medium.minHeight
          ? WindowHeightSizeClass.compact
          : WindowHeightSizeClass.medium;
    } else {
      return WindowHeightSizeClass.expanded;
    }
  }

  static WindowHeightSizeClass? maybeOf(BuildContext context) {
    final size = MediaQuery.maybeSizeOf(context);
    if (size == null) return null;
    return WindowHeightSizeClass.fromHeight(size.height);
  }

  static WindowHeightSizeClass of(BuildContext context) {
    return WindowHeightSizeClass.fromHeight(MediaQuery.sizeOf(context).height);
  }

  WindowHeightSizeClass clamp(
    WindowHeightSizeClass? min,
    WindowHeightSizeClass? max,
  ) {
    if (min != null && this <= min) return min;
    if (max != null && this >= max) return max;
    return this;
  }

  @override
  int compareTo(WindowHeightSizeClass other) =>
      minHeight.compareTo(other.minHeight);

  bool operator >(WindowHeightSizeClass other) => minHeight > other.minHeight;

  bool operator >=(WindowHeightSizeClass other) => minHeight >= other.minHeight;

  bool operator <(WindowHeightSizeClass other) => minHeight < other.minHeight;

  bool operator <=(WindowHeightSizeClass other) => minHeight <= other.minHeight;
}

class WindowSizeClass {
  const WindowSizeClass(this.widthSizeClass, this.heightSizeClass);

  final WindowWidthSizeClass widthSizeClass;
  final WindowHeightSizeClass heightSizeClass;

  Size get minSize => Size(widthSizeClass.minWidth, heightSizeClass.minHeight);

  Size get maxSize => Size(widthSizeClass.maxWidth, heightSizeClass.maxHeight);

  bool includesSize(Size size) {
    return widthSizeClass.includes(size.width) &&
        heightSizeClass.includes(size.height);
  }

  static WindowSizeClass? maybeOf(BuildContext context) {
    final widthSizeClass = WindowWidthSizeClass.maybeOf(context);
    final heightSizeClass = WindowHeightSizeClass.maybeOf(context);
    if (widthSizeClass == null || heightSizeClass == null) return null;
    return WindowSizeClass(widthSizeClass, heightSizeClass);
  }

  static WindowSizeClass of(BuildContext context) {
    return WindowSizeClass(
      WindowWidthSizeClass.of(context),
      WindowHeightSizeClass.of(context),
    );
  }
}
