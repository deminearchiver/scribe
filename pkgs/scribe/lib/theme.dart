import 'package:flutter/foundation.dart';
import 'package:material/material.dart';
import 'package:widgets/widgets.dart';

class AppTheme {
  static const _baselineSeedColor = Color(0xFF6750A4);

  static InteractiveInkFeatureFactory splashFactoryFor(
    TargetPlatform platform,
  ) => switch (platform) {
    TargetPlatform.android ||
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.fuchsia => InkSparkle.splashFactory,
    TargetPlatform.iOS || TargetPlatform.macOS => NoSplash.splashFactory,
  };
  static ColorScheme getColorScheme({
    required Brightness brightness,
    DynamicSchemeVariant variant = DynamicSchemeVariant.tonalSpot,
    Color? seedColor,
    double contrastLevel = 0,
  }) {
    return ColorScheme.fromSeed(
      seedColor: seedColor ?? _baselineSeedColor,
      brightness: brightness,
      dynamicSchemeVariant: variant,
      contrastLevel: contrastLevel,
    );
  }

  static ThemeData withColorScheme(ColorScheme colorScheme) {
    const buttonStyle = ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24)),
    );
    final platform = defaultTargetPlatform;
    return ThemeData(
      colorScheme: colorScheme,
      platform: TargetPlatform.android,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      splashFactory: splashFactoryFor(platform),
      elevatedButtonTheme: const ElevatedButtonThemeData(style: buttonStyle),
      filledButtonTheme: const FilledButtonThemeData(style: buttonStyle),
      outlinedButtonTheme: const OutlinedButtonThemeData(style: buttonStyle),
      textButtonTheme: const TextButtonThemeData(style: buttonStyle),
      sliderTheme: const SliderThemeData(
        overlayColor: WidgetStateColor.transparent,
        // ignore: deprecated_member_use
        year2023: false,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        // ignore: deprecated_member_use
        year2023: false,
      ),
      bottomSheetTheme: const BottomSheetThemeData(),
      extensions: const [StateThemeData.standard()],
    );
  }

  static ThemeData custom({
    required Brightness brightness,
    DynamicSchemeVariant variant = DynamicSchemeVariant.tonalSpot,
    Color? seedColor,
    double contrastLevel = 0,
  }) {
    final colorScheme = getColorScheme(
      brightness: brightness,
      variant: variant,
      seedColor: seedColor,
      contrastLevel: contrastLevel,
    );
    return withColorScheme(colorScheme);
  }

  static ThemeData get light => custom(brightness: Brightness.light);
  static ThemeData get dark => custom(brightness: Brightness.dark);
}
