import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material/material.dart';

class FullscreenDialog extends StatefulWidget {
  const FullscreenDialog({super.key});

  @override
  State<FullscreenDialog> createState() => _FullscreenDialogState();
}

class _FullscreenDialogState extends State<FullscreenDialog> {
  @override
  Widget build(BuildContext context) {
    return Material(
      animationDuration: Duration.zero,
      shape: Shapes.none,

      child: Column(),
    );
  }
}

@immutable
class FullscreenDialogThemeData
    extends ThemeExtension<FullscreenDialogThemeData>
    with Diagnosticable {
  const FullscreenDialogThemeData({
    this.backgroundColor,
    this.shape,
    this.shadowColor,
    this.elevation,
  });

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<ShapeBorder?>? shape;

  final WidgetStateProperty<Color?>? shadowColor;
  final WidgetStateProperty<double?>? elevation;

  @override
  FullscreenDialogThemeData copyWith({
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<ShapeBorder?>? shape,
    WidgetStateProperty<Color?>? shadowColor,
    WidgetStateProperty<double?>? elevation,
  }) {
    return FullscreenDialogThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shape: shape ?? this.shape,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  FullscreenDialogThemeData lerp(
    covariant FullscreenDialogThemeData? other,
    double t,
  ) {
    if (identical(this, other)) return this;
    ButtonStyle.lerp;
    return FullscreenDialogThemeData(
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        backgroundColor,
        other?.backgroundColor,
        t,
        Color.lerp,
      ),
      shape: WidgetStateProperty.lerp<ShapeBorder?>(
        shape,
        other?.shape,
        t,
        ShapeBorder.lerp,
      ),
      shadowColor: WidgetStateProperty.lerp<Color?>(
        shadowColor,
        other?.shadowColor,
        t,
        Color.lerp,
      ),
      elevation: WidgetStateProperty.lerp<double?>(
        elevation,
        other?.elevation,
        t,
        lerpDouble,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FullscreenDialogThemeData &&
        backgroundColor == other.backgroundColor &&
        shape == other.shape;
  }

  @override
  int get hashCode => Object.hash(backgroundColor, shape);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        "backgroundColor",
        backgroundColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<ShapeBorder?>>(
        "shape",
        shape,
        defaultValue: null,
      ),
    );
  }
}

extension FullscreenDialogThemeExtension on ThemeData {
  FullscreenDialogThemeData? get fullscreenDialogTheme =>
      extension<FullscreenDialogThemeData>();
}

class FullscreenDialogTheme extends InheritedTheme with Diagnosticable {
  const FullscreenDialogTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final FullscreenDialogThemeData data;

  @override
  bool updateShouldNotify(covariant FullscreenDialogTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return FullscreenDialogTheme(data: data, child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<FullscreenDialogThemeData>("data", data),
    );
  }

  static FullscreenDialogThemeData? maybeOf(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<FullscreenDialogTheme>();
    return theme?.data ?? Theme.of(context).fullscreenDialogTheme;
  }

  static FullscreenDialogThemeData of(BuildContext context) {
    final fullscreenDialogTheme = maybeOf(context);
    if (fullscreenDialogTheme != null) return fullscreenDialogTheme;
    final theme = Theme.of(context);
    return _FullscreenDialogDefaultsM3(colors: theme.colorScheme);
  }
}

class _FullscreenDialogDefaultsM3 extends FullscreenDialogThemeData {
  const _FullscreenDialogDefaultsM3({required ColorScheme colors})
    : _colors = colors,
      super(shape: const WidgetStatePropertyAll(RoundedRectangleBorder()));

  final ColorScheme _colors;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.scrolledUnder)) {
          return _colors.surfaceContainer;
        }
        return _colors.surface;
      });
}
