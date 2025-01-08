part of 'basic_dialog.dart';

@immutable
class BasicDialogThemeData extends ThemeExtension<BasicDialogThemeData>
    with Diagnosticable {
  const BasicDialogThemeData({
    this.clipBehavior,
    this.backgroundColor,
    this.shadowColor,
    this.elevation,
    this.shape,
    this.barrierColor,
  });

  final Clip? clipBehavior;
  final Color? backgroundColor;
  final Color? shadowColor;
  final double? elevation;
  final ShapeBorder? shape;

  final Color? barrierColor;

  @override
  BasicDialogThemeData copyWith({
    Clip? clipBehavior,
    Color? backgroundColor,
    Color? shadowColor,
    double? elevation,
    ShapeBorder? shape,
    Color? barrierColor,
  }) {
    return BasicDialogThemeData(
      clipBehavior: clipBehavior ?? this.clipBehavior,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shadowColor: shadowColor ?? this.shadowColor,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      barrierColor: barrierColor ?? this.barrierColor,
    );
  }

  @override
  BasicDialogThemeData lerp(covariant BasicDialogThemeData? other, double t) {
    return BasicDialogThemeData(
      clipBehavior: t < 0.5 ? clipBehavior : other?.clipBehavior,
      backgroundColor: Color.lerp(backgroundColor, other?.backgroundColor, t),
      shadowColor: Color.lerp(shadowColor, other?.shadowColor, t),
      elevation: lerpDouble(elevation, other?.elevation, t),
      shape: ShapeBorder.lerp(shape, other?.shape, t),
      barrierColor: Color.lerp(barrierColor, other?.barrierColor, t),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<Clip>(
        "clipBehavior",
        clipBehavior,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty("backgroundColor", backgroundColor, defaultValue: null),
    );
    properties.add(
      ColorProperty("shadowColor", shadowColor, defaultValue: null),
    );
    properties.add(DoubleProperty("elevation", elevation, defaultValue: null));
    properties.add(
      DiagnosticsProperty<ShapeBorder>("shape", shape, defaultValue: null),
    );
    properties.add(
      ColorProperty("barrierColor", barrierColor, defaultValue: null),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BasicDialogThemeData &&
        clipBehavior == other.clipBehavior &&
        backgroundColor == other.backgroundColor &&
        shadowColor == other.shadowColor &&
        elevation == other.elevation &&
        shape == other.shape &&
        barrierColor == other.barrierColor;
  }

  @override
  int get hashCode => Object.hash(
    clipBehavior,
    backgroundColor,
    shadowColor,
    elevation,
    shape,
    barrierColor,
  );
}

extension BasicDialogThemeExtension on ThemeData {
  BasicDialogThemeData? get basicDialogTheme =>
      extension<BasicDialogThemeData>();
}

class BasicDialogTheme extends InheritedTheme {
  const BasicDialogTheme({super.key, required this.data, required super.child});

  final BasicDialogThemeData data;

  @override
  bool updateShouldNotify(covariant BasicDialogTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return BasicDialogTheme(data: data, child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BasicDialogThemeData>("data", data));
  }

  static BasicDialogThemeData? maybeOf(BuildContext context) {
    final theme =
        context.dependOnInheritedWidgetOfExactType<BasicDialogTheme>();
    return theme?.data ?? Theme.of(context).basicDialogTheme;
  }

  static BasicDialogThemeData of(BuildContext context) {
    final basicDialogTheme = maybeOf(context);
    if (basicDialogTheme != null) return basicDialogTheme;
    final theme = Theme.of(context);
    return _BasicDialogDefaultsM3(
      colorScheme: theme.colorScheme,
      textTheme: theme.textTheme,
    );
  }
}

class _BasicDialogDefaultsM3 extends BasicDialogThemeData {
  const _BasicDialogDefaultsM3({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) : _colors = colorScheme,
       _text = textTheme,
       super();

  final ColorScheme _colors;
  final TextTheme _text;

  @override
  Clip get clipBehavior => Clip.antiAlias;

  @override
  Color get backgroundColor => _colors.surfaceContainerHighest;

  @override
  Color get barrierColor => _colors.scrim.withValues(alpha: 0.32);

  @override
  Color get shadowColor => Colors.transparent;

  @override
  double get elevation => Elevations.level3;

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(28)),
  );
}
