import 'package:material/material.dart';
import 'package:flutter/material.dart' as flutter;

class LinearProgressIndicator extends StatelessWidget {
  /// Creates a linear progress indicator.
  ///
  /// {@macro flutter.material.ProgressIndicator.ProgressIndicator}
  const LinearProgressIndicator({
    super.key,
    this.duration = Duration.zero,
    this.curve = Easing.linear,
    this.value,
    this.minHeight,
    this.borderRadius,
    this.stopIndicatorColor,
    this.stopIndicatorRadius,
    this.trackGap,
    this.semanticsLabel,
    this.semanticsValue,
    this.trackColor,
    this.indicatorColor,
  }) : assert(minHeight == null || minHeight > 0);

  final Duration duration;
  final Curve curve;

  /// If non-null, the value of this progress indicator.
  ///
  /// A value of 0.0 means no progress and 1.0 means that progress is complete.
  /// The value will be clamped to be in the range 0.0-1.0.
  ///
  /// If null, this progress indicator is indeterminate, which means the
  /// indicator displays a predetermined animation that does not indicate how
  /// much actual progress is being made.
  final double? value;

  /// {@template flutter.material.LinearProgressIndicator.minHeight}
  /// The minimum height of the line used to draw the linear indicator.
  ///
  /// If [LinearProgressIndicator.minHeight] is null then it will use the
  /// ambient [ProgressIndicatorThemeData.linearMinHeight]. If that is null
  /// it will use 4dp.
  /// {@endtemplate}
  final double? minHeight;

  /// The border radius of both the indicator and the track.
  ///
  /// If null, then the [ProgressIndicatorThemeData.borderRadius] will be used.
  /// If that is also null, then defaults to radius of 2, which produces a
  /// rounded shape with a rounded indicator. If [ThemeData.useMaterial3] is false,
  /// then defaults to [BorderRadius.zero], which produces a rectangular shape
  /// with a rectangular indicator.
  final BorderRadiusGeometry? borderRadius;

  /// The color of the stop indicator.
  ///
  /// If [year2023] is false or [ThemeData.useMaterial3] is false, then no stop
  /// indicator will be drawn.
  ///
  /// If null, then the [ProgressIndicatorThemeData.stopIndicatorColor] will be used.
  /// If that is null, then the [ColorScheme.primary] will be used.
  final Color? stopIndicatorColor;

  /// The radius of the stop indicator.
  ///
  /// If [year2023] is false or [ThemeData.useMaterial3] is false, then no stop
  /// indicator will be drawn.
  ///
  /// Set [stopIndicatorRadius] to 0 to hide the stop indicator.
  ///
  /// If null, then the [ProgressIndicatorThemeData.stopIndicatorRadius] will be used.
  /// If that is null, then defaults to 2.
  final double? stopIndicatorRadius;

  /// The gap between the indicator and the track.
  ///
  /// If [year2023] is false or [ThemeData.useMaterial3] is false, then no track
  /// gap will be drawn.
  ///
  /// Set [trackGap] to 0 to hide the track gap.
  ///
  /// If null, then the [ProgressIndicatorThemeData.trackGap] will be used.
  /// If that is null, then defaults to 4.
  final double? trackGap;

  /// {@template flutter.progress_indicator.ProgressIndicator.semanticsLabel}
  /// The [SemanticsProperties.label] for this progress indicator.
  ///
  /// This value indicates the purpose of the progress bar, and will be
  /// read out by screen readers to indicate the purpose of this progress
  /// indicator.
  /// {@endtemplate}
  final String? semanticsLabel;

  /// {@template flutter.progress_indicator.ProgressIndicator.semanticsValue}
  /// The [SemanticsProperties.value] for this progress indicator.
  ///
  /// This will be used in conjunction with the [semanticsLabel] by
  /// screen reading software to identify the widget, and is primarily
  /// intended for use with determinate progress indicators to announce
  /// how far along they are.
  ///
  /// For determinate progress indicators, this will be defaulted to
  /// [ProgressIndicator.value] expressed as a percentage, i.e. `0.1` will
  /// become '10%'.
  /// {@endtemplate}
  final String? semanticsValue;

  final Color? trackColor;
  final Color? indicatorColor;

  Widget _buildIndicator(BuildContext context, double? value) {
    return flutter.LinearProgressIndicator(
      // ignore: deprecated_member_use
      year2023: false,
      value: value,
      borderRadius: borderRadius,
      minHeight: minHeight,
      stopIndicatorColor: stopIndicatorColor,
      stopIndicatorRadius: stopIndicatorRadius,
      trackGap: trackGap,
      backgroundColor: trackColor,
      color: indicatorColor,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final determinate = value != null && duration > Duration.zero;
    return determinate
        ? TweenAnimationBuilder(
          tween: Tween<double>(end: value),
          duration: duration,
          curve: curve,
          builder: (context, value, child) => _buildIndicator(context, value),
        )
        : _buildIndicator(context, value);
  }
}
