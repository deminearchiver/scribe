import "package:flutter/scheduler.dart";
import "package:material/material.dart";

enum FloatingActionButtonVariant { primary, secondary, tertiary, surface }

class ExtendedFloatingActionButton extends StatefulWidget {
  //   static ExtendedFloatingActionButtonState? maybeOf(BuildContext context, {bool root = false}) {
  //   ExtendedFloatingActionButtonState? floatingActionButton;
  //   if (context case StatefulElement(:final ExtendedFloatingActionButtonState state)) {
  //     floatingActionButton = state;
  //   }

  //   return root
  //       ? context.findRootAncestorStateOfType<ExtendedFloatingActionButtonState>() ?? floatingActionButton
  //       : floatingActionButton ?? context.findAncestorStateOfType<ExtendedFloatingActionButtonState>();
  // }

  // static ExtendedFloatingActionButtonState of(BuildContext context, {bool root = false}) {
  //   ExtendedFloatingActionButtonState? floatingActionButton;
  //   if (context case StatefulElement(:final ExtendedFloatingActionButtonState state)) {
  //     floatingActionButton = state;
  //   }

  //   floatingActionButton = root
  //       ? context.findRootAncestorStateOfType<ExtendedFloatingActionButtonState>() ?? floatingActionButton
  //       : floatingActionButton ?? context.findAncestorStateOfType<ExtendedFloatingActionButtonState>();

  //   assert(() {
  //     if (floatingActionButton == null) {
  //       throw FlutterError(
  //         "Floating action button operation requested with a context that does not include a ExtendedFloatingActionButton.\n"
  //         "The context used to push or pop routes from the ExtendedFloatingActionButton must be that of a "
  //         "widget that is a descendant of a ExtendedFloatingActionButton widget.",
  //       );
  //     }
  //     return true;
  //   }());
  //   return floatingActionButton!;
  // }

  const ExtendedFloatingActionButton({
    super.key,
    this.animationDuration = kThemeChangeDuration,
    this.variant = FloatingActionButtonVariant.primary,
    this.animationStyle,
    this.onPressed,
    this.elevation,
    this.lowered = false,
    this.extended = true,
    this.icon,
    required this.label,
  }) : assert(extended || icon != null);

  final Duration animationDuration;
  final FloatingActionButtonVariant variant;

  final VoidCallback? onPressed;

  final AnimationStyle? animationStyle;

  final WidgetStateProperty<double>? elevation;

  final bool lowered;
  final bool extended;
  final Widget? icon;
  final Widget label;

  @override
  State<ExtendedFloatingActionButton> createState() =>
      ExtendedFloatingActionButtonState();
}

class ExtendedFloatingActionButtonState
    extends State<ExtendedFloatingActionButton> {
  late WidgetStatesController _statesController;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController()..addListener(_statesListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ExtendedFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  void _statesListener() {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(() {});
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaults = _ExtendedFloatingActionButtonDefaults(
      context: context,
      variant: widget.variant,
      extended: widget.extended,
      lowered: widget.lowered,
      hasIcon: widget.icon != null,
    );
    final labelPadding = EdgeInsetsDirectional.only(start: defaults.spacing);
    final elevation = widget.elevation ?? defaults.elevation;
    final semanticsChild = ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: 56),
      child: Material(
        animationDuration: widget.animationDuration,
        clipBehavior: Clip.antiAlias,
        shape: defaults.shape,
        color: defaults.backgroundColor,
        shadowColor: defaults.shadowColor,
        type: MaterialType.button,
        elevation: elevation.resolve(_statesController.value),
        child: InkWell(
          statesController: _statesController,
          mouseCursor: WidgetStateMouseCursor.clickable.resolve(
            _statesController.value,
          ),
          overlayColor: defaults.overlayColor,
          onTap: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  IconTheme.merge(
                    data: IconThemeData(
                      color: defaults.foregroundColor,
                      size: 24,
                      opticalSize: 24,
                    ),
                    child: widget.icon!,
                  ),
                _ExtendedFloatingActionButtonLabel(
                  duration:
                      widget.animationStyle?.duration ?? defaults.duration,
                  curve: widget.animationStyle?.curve ?? defaults.curve,
                  color: defaults.foregroundColor,
                  extended: widget.extended,
                  padding: labelPadding,
                  child: widget.label,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return MergeSemantics(child: semanticsChild);
  }
}

const EdgeInsetsGeometry _kDefaultLabelPadding = EdgeInsetsDirectional.only(
  start: 8,
);

class _ExtendedFloatingActionButtonLabel extends ImplicitlyAnimatedWidget {
  const _ExtendedFloatingActionButtonLabel({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.extended,
    this.color,
    this.padding = _kDefaultLabelPadding,
    required this.child,
  });

  final bool extended;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<_ExtendedFloatingActionButtonLabel>
  createState() => _ExtendedFloatingActionButtonLabelState();
}

class _ExtendedFloatingActionButtonLabelState
    extends AnimatedWidgetBaseState<_ExtendedFloatingActionButtonLabel> {
  Tween<double>? _widthFactorTween;
  Tween<double>? _opacityTween;
  EdgeInsetsGeometryTween? _paddingTween;

  Animation<double>? _opacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final double widthFactor = widget.extended ? 1.0 : 0.0;
    _widthFactorTween =
        visitor(
              _widthFactorTween,
              widthFactor,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    final double opacity = widget.extended ? 1.0 : 0.0;
    _opacityTween =
        visitor(
              _opacityTween,
              opacity,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    final padding = widget.padding;
    _paddingTween =
        visitor(
              _paddingTween,
              padding,
              (value) =>
                  EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry),
            )
            as EdgeInsetsGeometryTween?;
  }

  @override
  void didUpdateTweens() {
    super.didUpdateTweens();
    if (_opacityTween?.begin != null && _opacityTween?.end != null) {
      _opacityAnimation = animation.drive(
        _opacityTween!.chain(CurveTween(curve: const Interval(0, 0.5))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double widthFactor =
        _widthFactorTween?.evaluate(animation) ?? (widget.extended ? 1.0 : 0.0);
    // final double opacity =
    //     _opacityTween?.evaluate(animation) ?? (widget.extended ? 1.0 : 0.0);
    final double opacity =
        _opacityAnimation?.value ?? (widget.extended ? 1.0 : 0.0);
    final padding = _paddingTween?.evaluate(animation) ?? EdgeInsets.zero;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Padding(
        padding: padding,
        child: Opacity(
          opacity: opacity,
          child: DefaultTextStyle.merge(
            style: theme.textTheme.labelLarge!.copyWith(color: widget.color),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _ExtendedFloatingActionButtonDefaults {
  _ExtendedFloatingActionButtonDefaults({
    required this.context,
    required this.variant,
    required this.extended,
    required this.lowered,
    required this.hasIcon,
  });

  final BuildContext context;
  final FloatingActionButtonVariant variant;
  final bool extended;
  final bool lowered;
  bool hasIcon;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  double get spacing => hasIcon ? 8.0 : 0.0;
  // hasIcon
  //     ? extended
  //         ? 8.0
  //         : 16.0
  //     : 0.0;

  ShapeBorder get shape => Shapes.large;

  Color get backgroundColor => switch (variant) {
    FloatingActionButtonVariant.primary => _colors.primaryContainer,
    FloatingActionButtonVariant.secondary => _colors.secondaryContainer,
    FloatingActionButtonVariant.tertiary => _colors.tertiaryContainer,
    FloatingActionButtonVariant.surface =>
      lowered ? _colors.surfaceContainerLow : _colors.surfaceContainerHigh,
  };

  Color get foregroundColor => switch (variant) {
    FloatingActionButtonVariant.primary => _colors.onPrimaryContainer,
    FloatingActionButtonVariant.secondary => _colors.onSecondaryContainer,
    FloatingActionButtonVariant.tertiary => _colors.onTertiaryContainer,
    FloatingActionButtonVariant.surface => _colors.primary,
  };

  Color get shadowColor => _colors.shadow;

  WidgetStateProperty<double> get elevation =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return lowered ? Elevations.level1 : Elevations.level3;
        }
        if (states.contains(WidgetState.hovered)) {
          return lowered ? Elevations.level2 : Elevations.level4;
        }
        if (states.contains(WidgetState.focused)) {
          return lowered ? Elevations.level1 : Elevations.level3;
        }
        return lowered ? Elevations.level1 : Elevations.level3;
      });
  WidgetStateProperty<Color?> get overlayColor =>
      WidgetStateLayerColor(switch (variant) {
        FloatingActionButtonVariant.primary => _colors.onPrimaryContainer,
        FloatingActionButtonVariant.secondary => _colors.onSecondaryContainer,
        FloatingActionButtonVariant.tertiary => _colors.onTertiaryContainer,
        FloatingActionButtonVariant.surface => _colors.primary,
      });

  Duration get duration => Durations.long2;
  Curve get curve => Easing.emphasized;
}
