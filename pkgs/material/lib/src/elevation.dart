import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material/material.dart';

@Deprecated("Use ElevationTheme.of(context) instead")
abstract final class Elevations {
  static const double level0 = 0.0;
  static const double level1 = 1.0;
  static const double level2 = 3.0;
  static const double level3 = 6.0;
  static const double level4 = 8.0;
  static const double level5 = 12.0;
}

class ElevationThemeData extends ThemeExtension<ElevationThemeData>
    with Diagnosticable {
  const ElevationThemeData({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });
  const ElevationThemeData.fallback({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
  }) : level0 = level0 ?? 0.0,
       level1 = level1 ?? 1.0,
       level2 = level2 ?? 3.0,
       level3 = level3 ?? 6.0,
       level4 = level4 ?? 8.0,
       level5 = level5 ?? 12.0;

  final double level0;
  final double level1;
  final double level2;
  final double level3;
  final double level4;
  final double level5;

  @override
  ThemeExtension<ElevationThemeData> copyWith({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
  }) => ElevationThemeData(
    level0: level0 ?? this.level0,
    level1: level1 ?? this.level1,
    level2: level2 ?? this.level2,
    level3: level3 ?? this.level3,
    level4: level4 ?? this.level4,
    level5: level5 ?? this.level5,
  );

  @override
  ElevationThemeData lerp(covariant ElevationThemeData? other, double t) {
    if (identical(this, other)) return this;
    if (other == null) return this;
    return ElevationThemeData(
      level0: lerpDouble(level0, other.level0, t)!,
      level1: lerpDouble(level1, other.level1, t)!,
      level2: lerpDouble(level2, other.level2, t)!,
      level3: lerpDouble(level3, other.level3, t)!,
      level4: lerpDouble(level4, other.level4, t)!,
      level5: lerpDouble(level5, other.level5, t)!,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty("level0", level0));
    properties.add(DoubleProperty("level1", level1));
    properties.add(DoubleProperty("level2", level2));
    properties.add(DoubleProperty("level3", level3));
    properties.add(DoubleProperty("level4", level4));
    properties.add(DoubleProperty("level5", level5));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ElevationThemeData &&
            level0 == other.level0 &&
            level1 == other.level1 &&
            level2 == other.level2 &&
            level3 == other.level3 &&
            level4 == other.level4 &&
            level5 == other.level5;
  }

  @override
  int get hashCode =>
      Object.hash(level0, level1, level2, level3, level4, level5);
}

extension ElevationThemeExtension on ThemeData {
  ElevationThemeData? get elevationTheme => extension<ElevationThemeData>();
}

class ElevationTheme extends InheritedTheme {
  const ElevationTheme({super.key, required this.data, required super.child});

  final ElevationThemeData data;

  @override
  bool updateShouldNotify(covariant ElevationTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return ElevationTheme(data: data, child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ElevationThemeData>("data", data));
  }

  static ElevationThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ElevationTheme>()?.data ??
        Theme.of(context).elevationTheme;
  }

  static ElevationThemeData of(BuildContext context) {
    return maybeOf(context) ?? const ElevationThemeData.fallback();
  }
}
