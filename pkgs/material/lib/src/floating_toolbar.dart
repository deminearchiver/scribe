import 'package:material/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:math' as math;

enum FloatingToolbarVariant { standard, vibrant }

class FloatingToolbarThemeData extends ThemeExtension<FloatingToolbarThemeData>
    with Diagnosticable {
  const FloatingToolbarThemeData({
    this.backgroundColor,
    this.foregroundColor,
    this.shape,
  });

  final Color? backgroundColor;
  final Color? foregroundColor;
  final ShapeBorder? shape;

  @override
  FloatingToolbarThemeData copyWith({
    Color? backgroundColor,
    Color? foregroundColor,
    ShapeBorder? shape,
  }) => FloatingToolbarThemeData(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    foregroundColor: foregroundColor ?? this.foregroundColor,
    shape: shape ?? this.shape,
  );

  @override
  FloatingToolbarThemeData lerp(
    covariant FloatingToolbarThemeData? other,
    double t,
  ) {
    if (other == null) return this;
    return FloatingToolbarThemeData(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      shape: ShapeBorder.lerp(shape, other.shape, t),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is FloatingToolbarThemeData &&
            backgroundColor == other.backgroundColor &&
            foregroundColor == other.foregroundColor &&
            shape == other.shape;
  }

  @override
  int get hashCode => Object.hash(backgroundColor, foregroundColor, shape);
}

extension FloatingToolbarThemeExtension on ThemeData {
  FloatingToolbarThemeData? get floatingToolbarTheme =>
      extension<FloatingToolbarThemeData>();
}

class FloatingToolbarTheme extends InheritedTheme {
  const FloatingToolbarTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final FloatingToolbarThemeData data;

  @override
  bool updateShouldNotify(covariant FloatingToolbarTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return FloatingToolbarTheme(data: data, child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FloatingToolbarThemeData>("data", data));
  }

  static FloatingToolbarThemeData? maybeOf(BuildContext context) {
    final floatingToolbarTheme =
        context.dependOnInheritedWidgetOfExactType<FloatingToolbarTheme>();

    return floatingToolbarTheme?.data ?? Theme.of(context).floatingToolbarTheme;
  }

  static FloatingToolbarThemeData of(BuildContext context) {
    final floatingToolbarTheme = maybeOf(context);
    return floatingToolbarTheme!;
  }
}

ButtonStyle? _;

@immutable
class FloatingToolbarStyle with Diagnosticable {
  const FloatingToolbarStyle({this.backgroundColor, this.shape});

  final Color? backgroundColor;
  final ShapeBorder? shape;

  FloatingToolbarStyle copyWith({Color? backgroundColor, ShapeBorder? shape}) =>
      FloatingToolbarStyle(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        shape: shape ?? this.shape,
      );
  static FloatingToolbarStyle? lerp(
    FloatingToolbarStyle? a,
    FloatingToolbarStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    return FloatingToolbarStyle(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ColorProperty("backgroundColor", backgroundColor, defaultValue: null),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType ||
        other is FloatingToolbarStyle &&
            backgroundColor == other.backgroundColor;
  }

  @override
  int get hashCode => backgroundColor.hashCode;
}

class _VibrantFloatingToolbarDefaultsM3 extends FloatingToolbarStyle {
  const _VibrantFloatingToolbarDefaultsM3({required ColorScheme colors})
    : _colors = colors,
      super(shape: const StadiumBorder());
  final ColorScheme _colors;

  @override
  Color? get backgroundColor => _colors.primaryContainer;
}

class _StandardFloatingToolbarActionDefaultsM3 extends ButtonStyle {
  const _StandardFloatingToolbarActionDefaultsM3({
    required ColorScheme colors,
    required StateThemeData state,
  }) : _colors = colors,
       _state = state,
       super(tapTargetSize: MaterialTapTargetSize.padded);

  final ColorScheme _colors;
  final StateThemeData _state;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.disabled)) {
            return _colors.onSurface.withValues(alpha: 0.12);
          }
          return _colors.secondaryContainer;
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;

        final color =
            states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurface;

        final alpha = _state.stateLayerOpacity.resolve(states);
        if (alpha == 0.0) return color.withAlpha(0);
        return color.withValues(alpha: alpha);
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return _colors.onSecondaryContainer;
        }
        return _colors.onSurface;
      });
}

class _VibrantFloatingToolbarActionDefaultsM3 extends ButtonStyle {
  const _VibrantFloatingToolbarActionDefaultsM3({
    required ColorScheme colors,
    required StateThemeData state,
  }) : _colors = colors,
       _state = state,
       super(tapTargetSize: MaterialTapTargetSize.padded);

  final ColorScheme _colors;
  final StateThemeData _state;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.disabled)) {
            return _colors.onSurface.withValues(alpha: 0.12);
          }
          return _colors.surfaceContainer;
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;

        final color =
            states.contains(WidgetState.selected)
                ? _colors.onSurface
                : _colors.onPrimaryContainer;

        final alpha = _state.stateLayerOpacity.resolve(states);
        if (alpha == 0.0) return color.withAlpha(0);
        return color.withValues(alpha: alpha);
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _colors.onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return _colors.onSurface;
        }
        return _colors.onPrimaryContainer;
      });
}

class FloatingToolbarAction {
  const FloatingToolbarAction({
    this.selected = false,
    required this.icon,
    this.selectedIcon,
    this.tooltip,
  });

  final bool selected;
  final Widget icon;
  final Widget? selectedIcon;
  final String? tooltip;
}

class FloatingToolbar extends StatefulWidget {
  const FloatingToolbar({
    super.key,
    this.variant = FloatingToolbarVariant.standard,
    this.scrollController,
    required this.direction,
    required this.actions,
  }) : assert(actions.length > 0);

  const FloatingToolbar.horizontal({
    super.key,
    this.variant = FloatingToolbarVariant.standard,
    this.scrollController,
    required this.actions,
  }) : assert(actions.length > 0),
       direction = Axis.horizontal;

  const FloatingToolbar.vertical({
    super.key,
    this.variant = FloatingToolbarVariant.standard,
    this.scrollController,
    required this.actions,
  }) : assert(actions.length > 0),
       direction = Axis.vertical;

  final FloatingToolbarVariant variant;
  final ScrollController? scrollController;
  final Axis direction;
  final List<Widget> actions;

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

const _kMinInteractiveSize = Size.square(kMinInteractiveDimension);

const _kPadding = EdgeInsets.all(12.0);
const double _kGap =
    8.0; // TODO: investigate why the official value of 8.0 works?

class _FloatingToolbarState extends State<FloatingToolbar> {
  late Size _actionTapTargetSize;
  late EdgeInsets _actionPadding;

  late double _resolvedGap;
  late EdgeInsetsGeometry _resolvedPadding;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    final densityAdjustment = theme.visualDensity.baseSizeAdjustment;

    const containerSize = Size(40.0, 40.0);
    final minSize = Size(
      kMinInteractiveDimension + densityAdjustment.dx,
      kMinInteractiveDimension + densityAdjustment.dy,
    );
    final tapTargetOverflow = minSize - containerSize as Offset;

    assert(minSize.width >= 0.0);
    assert(minSize.height >= 0.0);

    _actionPadding = EdgeInsets.symmetric(
      horizontal: tapTargetOverflow.dx / 2.0,
      vertical: tapTargetOverflow.dy / 2.0,
    );

    _resolvedGap = math.max(0.0, _kGap - _actionPadding.horizontal);
    _resolvedPadding = EdgeInsets.fromLTRB(
      math.max(0.0, _kPadding.left - _actionPadding.left),
      math.max(0.0, _kPadding.top - _actionPadding.top),
      math.max(0.0, _kPadding.right - _actionPadding.right),
      math.max(0.0, _kPadding.bottom - _actionPadding.bottom),
    );
  }

  Iterable<Widget> _buildActions(BuildContext context) {
    return widget.actions.intersperse((index) => SizedBox(width: _resolvedGap));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = StateTheme.of(context);
    final resolvedBackgroundColor = switch (widget.variant) {
      FloatingToolbarVariant.standard => theme.colorScheme.surfaceContainer,
      FloatingToolbarVariant.vibrant => theme.colorScheme.primaryContainer,
    };
    final ButtonStyle resolvedActionStyle = switch (widget.variant) {
      FloatingToolbarVariant.standard =>
        _StandardFloatingToolbarActionDefaultsM3(
          colors: theme.colorScheme,
          state: state,
        ),
      FloatingToolbarVariant.vibrant => _VibrantFloatingToolbarActionDefaultsM3(
        colors: theme.colorScheme,
        state: state,
      ),
    };
    final layout = Flex(
      mainAxisSize: MainAxisSize.min,
      direction: widget.direction,
      children: [..._buildActions(context)],
    );

    return SizedBox(
      width: widget.direction == Axis.vertical ? 64 : null,
      height: widget.direction == Axis.horizontal ? 64 : null,
      child: Material(
        animationDuration: Duration.zero,
        shape: const StadiumBorder(),
        color: resolvedBackgroundColor,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          scrollDirection: widget.direction,
          child: Padding(
            padding: _resolvedPadding,
            child: IconButtonTheme(
              data: IconButtonThemeData(style: resolvedActionStyle),
              child: layout,
            ),
          ),
        ),
      ),
    );
  }
}
