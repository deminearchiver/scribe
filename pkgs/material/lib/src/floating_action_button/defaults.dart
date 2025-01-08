part of 'fab.dart';

class _FABButtonStyle extends ButtonStyle
    implements
        _FABDefaultsColorsProperty,
        _FABDefaultsTextProperty,
        _FABDefaultsStateProperty,
        _FABDefaultsLoweredProperty {
  const _FABButtonStyle({
    required this.colors,
    required this.text,
    required this.state,
    required this.lowered,
    super.animationDuration,
    super.enableFeedback,
    super.alignment,
  });

  @override
  final ColorScheme colors;

  @override
  final TextTheme text;

  @override
  final StateThemeData state;

  @override
  final bool lowered;
}

class _SharedFABDefaultsM3 extends ButtonStyle
    with
        _FABTextStyleDefaultsM3,
        _FABVisualDensityDefaultsM3,
        _FABMouseCursorDefaultsM3,
        _FABElevationDefaultsM3 {
  _SharedFABDefaultsM3({
    required this.colors,
    required this.text,
    required this.lowered,
  }) : super(
         animationDuration: kThemeChangeDuration,
         alignment: Alignment.center,
         enableFeedback: true,
       );

  @override
  final ColorScheme colors;

  @override
  final TextTheme text;

  @override
  final bool lowered;
}

class _PrimaryVariantFABDefaultsM3 extends _FABButtonStyle
    with _PrimaryFABDefaultsM3 {
  _PrimaryVariantFABDefaultsM3({
    required super.colors,
    required super.text,
    required super.state,
    required super.lowered,
  });
}

class _SecondaryVariantFABDefaultsM3 extends _FABButtonStyle
    with _SecondaryFABDefaultsM3 {
  _SecondaryVariantFABDefaultsM3({
    required super.colors,
    required super.text,
    required super.state,
    required super.lowered,
  });
}

class _TertiaryVariantFABDefaultsM3 extends _FABButtonStyle
    with _TertiaryFABDefaultsM3 {
  _TertiaryVariantFABDefaultsM3({
    required super.colors,
    required super.text,
    required super.state,
    required super.lowered,
  });
}

class _SurfaceVariantFABDefaultsM3 extends _FABButtonStyle
    with _SurfaceFABDefaultsM3 {
  _SurfaceVariantFABDefaultsM3({
    required super.colors,
    required super.text,
    required super.state,
    required super.lowered,
  });
}

class _RegularSizeFABDefaultsM3 extends ButtonStyle with _RegularFABDefaultsM3 {
  const _RegularSizeFABDefaultsM3();
}

class _SmallSizeFABDefaultsM3 extends ButtonStyle with _SmallFABDefaultsM3 {
  const _SmallSizeFABDefaultsM3();
}

class _LargeSizeFABDefaultsM3 extends ButtonStyle with _LargeFABDefaultsM3 {
  const _LargeSizeFABDefaultsM3();
}

class _ExtendedSizeFABDefaultsM3 extends ButtonStyle
    with _ExtendedFABDefaultsM3 {
  const _ExtendedSizeFABDefaultsM3();
}

abstract interface class _FABDefaultsColorsProperty {
  ColorScheme get colors;
}

abstract interface class _FABDefaultsTextProperty {
  TextTheme get text;
}

abstract interface class _FABDefaultsStateProperty {
  StateThemeData get state;
}

abstract interface class _FABDefaultsLoweredProperty {
  bool get lowered;
}

// Shared

mixin _FABVisualDensityDefaultsM3 on ButtonStyle {
  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize => MaterialTapTargetSize.shrinkWrap;
}

mixin _FABTextStyleDefaultsM3 on ButtonStyle
    implements _FABDefaultsTextProperty {
  @override
  WidgetStateProperty<TextStyle?>? get textStyle =>
      WidgetStatePropertyAll(text.labelLarge);
}

mixin _FABMouseCursorDefaultsM3 on ButtonStyle {
  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor =>
      WidgetStateMouseCursor.clickable;
}

mixin _FABElevationDefaultsM3 on ButtonStyle
    implements _FABDefaultsColorsProperty, _FABDefaultsLoweredProperty {
  @override
  WidgetStateProperty<Color?>? get surfaceTintColor =>
      const WidgetStatePropertyAll(Colors.transparent);

  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      WidgetStatePropertyAll(colors.shadow);

  @override
  WidgetStateProperty<double?>? get elevation =>
      lowered
          ? WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Elevations.level1;
            }
            if (states.contains(WidgetState.hovered)) {
              return Elevations.level2;
            }
            if (states.contains(WidgetState.focused)) {
              return Elevations.level1;
            }
            return Elevations.level1;
          })
          : WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Elevations.level3;
            }
            if (states.contains(WidgetState.hovered)) {
              return Elevations.level4;
            }
            if (states.contains(WidgetState.focused)) {
              return Elevations.level3;
            }
            return Elevations.level3;
          });
}

// Sizes

mixin _RegularFABDefaultsM3 on ButtonStyle {
  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(56, 56));
  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size(56, 56));
  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding =>
      const WidgetStatePropertyAll(EdgeInsets.all(16));
  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(24.0);
  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.large);
}

mixin _SmallFABDefaultsM3 on ButtonStyle {
  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(40, 40));
  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size(40, 40));
  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding =>
      const WidgetStatePropertyAll(EdgeInsets.all(8));
  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(24.0);
  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.medium);
}

mixin _LargeFABDefaultsM3 on ButtonStyle {
  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(96, 96));
  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size(96, 96));
  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding =>
      const WidgetStatePropertyAll(EdgeInsets.all(16));
  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(36.0);
  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.extraLarge);
}
mixin _ExtendedFABDefaultsM3 on ButtonStyle {
  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(56, 56));
  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size.fromHeight(56));
  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding =>
      const WidgetStatePropertyAll(EdgeInsets.all(16));
  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(24.0);
  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.large);
}

// Variants

mixin _PrimaryFABDefaultsM3 on ButtonStyle
    implements _FABDefaultsColorsProperty, _FABDefaultsStateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStatePropertyAll(colors.primaryContainer);
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStatePropertyAll(colors.onPrimaryContainer);
  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStatePropertyAll(colors.onPrimaryContainer);
  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    colors.onPrimaryContainer,
    opacity: state.stateLayerOpacity,
  );
}
mixin _SecondaryFABDefaultsM3 on ButtonStyle
    implements _FABDefaultsColorsProperty, _FABDefaultsStateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStatePropertyAll(colors.secondaryContainer);
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStatePropertyAll(colors.onSecondaryContainer);
  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStatePropertyAll(colors.onSecondaryContainer);
  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    colors.onSecondaryContainer,
    opacity: state.stateLayerOpacity,
  );
}
mixin _TertiaryFABDefaultsM3 on ButtonStyle
    implements _FABDefaultsColorsProperty, _FABDefaultsStateProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStatePropertyAll(colors.tertiaryContainer);
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStatePropertyAll(colors.onTertiaryContainer);
  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStatePropertyAll(colors.onTertiaryContainer);
  @override
  WidgetStateProperty<Color?>? get overlayColor => WidgetStateLayerColor(
    colors.onTertiaryContainer,
    opacity: state.stateLayerOpacity,
  );
}

mixin _SurfaceFABDefaultsM3 on ButtonStyle
    implements
        _FABDefaultsColorsProperty,
        _FABDefaultsStateProperty,
        _FABDefaultsLoweredProperty {
  @override
  WidgetStateProperty<Color?>? get backgroundColor => WidgetStatePropertyAll(
    lowered ? colors.surfaceContainerLow : colors.surfaceContainerHigh,
  );
  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStatePropertyAll(colors.primary);
  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStatePropertyAll(colors.primary);
  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(colors.primary, opacity: state.stateLayerOpacity);
}
