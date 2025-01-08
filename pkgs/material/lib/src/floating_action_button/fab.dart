import 'package:material/material.dart';

part 'defaults.dart';

enum FloatingActionButtonVariant { primary, secondary, tertiary, surface }

enum FloatingActionButtonSize { regular, small, large }

enum _FABSize { regular, small, large, extended }

extension ButtonStyleExtension on ButtonStyle {
  ButtonStyle replace(ButtonStyle? style) {
    return style?.merge(this) ?? this;
  }
}

class FloatingActionButton extends ButtonStyleButton {
  const FloatingActionButton({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior,
    super.statesController,
    this.variant = FloatingActionButtonVariant.primary,
    this.lowered = false,
    super.tooltip,
    required super.child,
  }) : _size = _FABSize.regular;

  const FloatingActionButton.small({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior,
    super.statesController,
    this.variant = FloatingActionButtonVariant.primary,
    this.lowered = false,
    super.tooltip,
    required super.child,
  }) : _size = _FABSize.small;

  const FloatingActionButton.large({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior,
    super.statesController,
    this.variant = FloatingActionButtonVariant.primary,
    this.lowered = false,
    super.tooltip,
    required super.child,
  }) : _size = _FABSize.large;

  FloatingActionButton.extended({
    super.key,
    required super.onPressed,
    super.onLongPress,
    super.onHover,
    super.onFocusChange,
    super.style,
    super.focusNode,
    super.autofocus = false,
    super.clipBehavior = Clip.antiAlias,
    super.statesController,
    this.variant = FloatingActionButtonVariant.primary,
    this.lowered = false,
    super.tooltip,
    bool extended = true,
    Widget? icon,
    required Widget label,
  }) : _size = _FABSize.extended,
       super(
         child: _ExtendedFloatingActionButtonChild(
           extended: extended,
           icon: icon,
           label: label,
           //  buttonStyle: style,
           //  iconAlignment: iconAlignment,
         ),
       );
  final _FABSize _size;
  final FloatingActionButtonVariant variant;
  final bool lowered;

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final defaults = styleFrom(
      context: context,
      variant: variant,
      lowered: lowered,
    );
    final sizeDefaults = switch (_size) {
      _FABSize.regular => const _RegularSizeFABDefaultsM3(),
      _FABSize.small => const _SmallSizeFABDefaultsM3(),
      _FABSize.large => const _LargeSizeFABDefaultsM3(),
      _FABSize.extended => const _ExtendedSizeFABDefaultsM3(),
    };
    return defaults.replace(sizeDefaults);
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) {
    return null;
  }

  static ButtonStyle styleFrom({
    required BuildContext context,
    FloatingActionButtonVariant variant = FloatingActionButtonVariant.primary,
    bool lowered = false,
    ButtonStyle? style,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final state = StateTheme.of(context);
    final defaults = _SharedFABDefaultsM3(
      colors: colors,
      text: text,
      lowered: lowered,
    );
    final variantDefaults = switch (variant) {
      FloatingActionButtonVariant.primary => _PrimaryVariantFABDefaultsM3(
        colors: colors,
        text: text,
        state: state,
        lowered: lowered,
      ),
      FloatingActionButtonVariant.secondary => _SecondaryVariantFABDefaultsM3(
        colors: colors,
        text: text,
        state: state,
        lowered: lowered,
      ),
      FloatingActionButtonVariant.tertiary => _TertiaryVariantFABDefaultsM3(
        colors: colors,
        text: text,
        state: state,
        lowered: lowered,
      ),
      FloatingActionButtonVariant.surface => _SurfaceVariantFABDefaultsM3(
        colors: colors,
        text: text,
        state: state,
        lowered: lowered,
      ),
    };
    // final sizeDefaults = switch (_size) {
    //   _FABSize.regular => _RegularSizeFABDefaultsM3(
    //     context: context,
    //     lowered: lowered,
    //   ),
    //   _FABSize.small => _SmallSizeFABDefaultsM3(
    //     context: context,
    //     lowered: lowered,
    //   ),
    //   _FABSize.large => _LargeSizeFABDefaultsM3(
    //     context: context,
    //     lowered: lowered,
    //   ),
    //   _FABSize.extended => _ExtendedSizeFABDefaultsM3(
    //     context: context,
    //     lowered: lowered,
    //   ),
    // };
    final effectiveDefaults = defaults.replace(variantDefaults);
    // .replace(sizeDefaults);
    return effectiveDefaults.replace(style);
  }
}

class _ExtendedFloatingActionButtonChild extends StatefulWidget {
  const _ExtendedFloatingActionButtonChild({
    super.key,
    required this.extended,
    this.icon,
    required this.label,
  });

  final bool extended;

  final Widget? icon;
  final Widget label;

  @override
  State<_ExtendedFloatingActionButtonChild> createState() =>
      _ExtendedFloatingActionButtonChildState();
}

class _ExtendedFloatingActionButtonChildState
    extends State<_ExtendedFloatingActionButtonChild> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.icon != null) widget.icon!,
        Flexible(
          child: _ExtendedFloatingActionButtonLabel(
            duration: Durations.long2,
            curve: Easing.emphasized,
            extended: widget.extended,
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: widget.label,
          ),
        ),
      ],
    );
  }
}

class _ExtendedFloatingActionButtonLabel extends ImplicitlyAnimatedWidget {
  const _ExtendedFloatingActionButtonLabel({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.extended,
    this.padding = EdgeInsets.zero,
    required this.child,
  });

  final bool extended;
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
        child: Opacity(opacity: opacity, child: widget.child),
      ),
    );
  }
}
