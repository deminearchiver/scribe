import 'package:material/material.dart';
import 'package:flutter/material.dart' as flutter;

enum _CircularProgressIndicatorSlot { standalone, icon }

class CircularProgressIndicator extends StatefulWidget {
  const CircularProgressIndicator({
    super.key,
    this.duration = Duration.zero,
    this.curve = Easing.standard,
    this.value,
    this.strokeWidth,
    this.strokeAlign,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeCap,
    this.constraints,
    this.trackGap,
    this.padding,
    this.trackColor,
    this.indicatorColor,
  }) : _slot = _CircularProgressIndicatorSlot.standalone;

  const CircularProgressIndicator.icon({
    super.key,
    this.duration = Duration.zero,
    this.curve = Easing.standard,
    this.value,
    this.strokeWidth,
    this.strokeAlign,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeCap,
    this.constraints,
    this.trackGap,
    this.padding,
    this.trackColor,
    this.indicatorColor,
  }) : _slot = _CircularProgressIndicatorSlot.icon;

  final _CircularProgressIndicatorSlot _slot;

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

  /// The width of the line used to draw the circle.
  final double? strokeWidth;

  /// The relative position of the stroke on a [CircularProgressIndicator].
  ///
  /// Values typically range from -1.0 ([strokeAlignInside], inside stroke)
  /// to 1.0 ([strokeAlignOutside], outside stroke),
  /// without any bound constraints (e.g., a value of -2.0 is not typical, but allowed).
  /// A value of 0 ([strokeAlignCenter]) will center the border
  /// on the edge of the widget.
  ///
  /// If [year2023] is true, then the default value is [strokeAlignCenter].
  /// Otherwise, the default value is [strokeAlignInside].
  final double? strokeAlign;

  /// The progress indicator's line ending.
  ///
  /// This determines the shape of the stroke ends of the progress indicator.
  /// By default, [strokeCap] is null.
  /// When [value] is null (indeterminate), the stroke ends are set to
  /// [StrokeCap.square]. When [value] is not null, the stroke
  /// ends are set to [StrokeCap.butt].
  ///
  /// Setting [strokeCap] to [StrokeCap.round] will result in a rounded end.
  /// Setting [strokeCap] to [StrokeCap.butt] with [value] == null will result
  /// in a slightly different indeterminate animation; the indicator completely
  /// disappears and reappears on its minimum value.
  /// Setting [strokeCap] to [StrokeCap.square] with [value] != null will
  /// result in a different display of [value]. The indicator will start
  /// drawing from slightly less than the start, and end slightly after
  /// the end. This will produce an alternative result, as the
  /// default behavior, for example, that a [value] of 0.5 starts at 90 degrees
  /// and ends at 270 degrees. With [StrokeCap.square], it could start 85
  /// degrees and end at 275 degrees.
  final StrokeCap? strokeCap;

  /// Defines minimum and maximum sizes for a [CircularProgressIndicator].
  ///
  /// If null, then the [ProgressIndicatorThemeData.constraints] will be used.
  /// Otherwise, defaults to a minimum width and height of 36 pixels.
  final BoxConstraints? constraints;

  /// The gap between the active indicator and the background track.
  ///
  /// If [year2023] is false or [ThemeData.useMaterial3] is false, then no track
  /// gap will be drawn.
  ///
  /// Set [trackGap] to 0 to hide the track gap.
  ///
  /// If null, then the [ProgressIndicatorThemeData.trackGap] will be used.
  /// If that is null, then defaults to 4.
  final double? trackGap;

  /// The padding around the indicator track.
  ///
  /// If null, then the [ProgressIndicatorThemeData.circularTrackPadding] will be
  /// used. If that is null and [year2023] is false, then defaults to `EdgeInsets.all(4.0)`
  /// padding. Otherwise, defaults to zero padding.
  final EdgeInsetsGeometry? padding;

  /// The indicator stroke is drawn fully inside of the indicator path.
  ///
  /// This is a constant for use with [strokeAlign].
  static const double strokeAlignInside = -1.0;

  /// The indicator stroke is drawn on the center of the indicator path,
  /// with half of the [strokeWidth] on the inside, and the other half
  /// on the outside of the path.
  ///
  /// This is a constant for use with [strokeAlign].
  ///
  /// This is the default value for [strokeAlign].
  static const double strokeAlignCenter = 0.0;

  /// The indicator stroke is drawn on the outside of the indicator path.
  ///
  /// This is a constant for use with [strokeAlign].
  static const double strokeAlignOutside = 1.0;

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

  @override
  State<CircularProgressIndicator> createState() =>
      _CircularProgressIndicatorState();
}

class _CircularProgressIndicatorState extends State<CircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    final determinate = widget.value != null && widget.duration > Duration.zero;

    BoxConstraints? constraints;
    Color? trackColor;
    Color? indicatorColor;
    double? strokeWidth;

    if (widget._slot == _CircularProgressIndicatorSlot.icon) {
      final iconTheme = IconTheme.of(context);
      constraints = BoxConstraints.tightFor(
        width: iconTheme.size!,
        height: iconTheme.size!,
      );
      trackColor = Colors.transparent;
      indicatorColor = iconTheme.color!;
      strokeWidth = 2;
    } else {
      constraints = const BoxConstraints.tightFor(width: 48, height: 48);
    }

    return determinate
        ? TweenAnimationBuilder(
          tween: Tween<double>(end: widget.value!),
          duration: widget.duration,
          curve: widget.curve,
          builder:
              (context, value, child) => flutter.CircularProgressIndicator(
                // ignore: deprecated_member_use
                year2023: false,
                value: value,
                constraints: widget.constraints ?? constraints,
                backgroundColor:
                    determinate ? widget.trackColor ?? widget.trackColor : null,
                color: widget.indicatorColor ?? indicatorColor,
                strokeWidth: widget.strokeWidth ?? strokeWidth,
                padding: widget.padding ?? EdgeInsets.zero,
                semanticsLabel: widget.semanticsLabel,
                semanticsValue: widget.semanticsValue,
              ),
        )
        : flutter.CircularProgressIndicator(
          // ignore: deprecated_member_use
          year2023: false,
          value: widget.value,
          constraints: widget.constraints ?? constraints,
          backgroundColor:
              determinate ? widget.trackColor ?? widget.trackColor : null,
          color: widget.indicatorColor ?? indicatorColor,
          strokeWidth: widget.strokeWidth ?? strokeWidth,
          padding: widget.padding ?? EdgeInsets.zero,
          semanticsLabel: widget.semanticsLabel,
          semanticsValue: widget.semanticsValue,
        );
  }
}
