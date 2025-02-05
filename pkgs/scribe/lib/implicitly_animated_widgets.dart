import 'dart:ui' show ImageFilter;

import 'package:material/material.dart';

class AnimatedPadding extends ImplicitlyAnimatedWidget {
  const AnimatedPadding({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.padding,
    this.child,
  });

  final EdgeInsetsGeometry padding;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedPadding> createState() =>
      _AnimatedPaddingState();
}

class _AnimatedPaddingState extends AnimatedWidgetBaseState<AnimatedPadding> {
  Tween<EdgeInsetsGeometry?>? _paddingTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _paddingTween =
        visitor(
              _paddingTween,
              widget.padding,
              (value) => EdgeInsetsGeometryTween(begin: value),
            )
            as Tween<EdgeInsetsGeometry?>?;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _paddingTween?.evaluate(animation) ?? widget.padding,
      child: widget.child,
    );
  }
}

class AnimatedDefaultTextStyle extends ImplicitlyAnimatedWidget {
  const AnimatedDefaultTextStyle({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.style,
    required this.child,
  });

  final TextStyle style;
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedDefaultTextStyle> createState() =>
      _AnimatedDefaultTextStyleState();
}

class _AnimatedDefaultTextStyleState
    extends AnimatedWidgetBaseState<AnimatedDefaultTextStyle> {
  Tween<TextStyle>? _styleTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _styleTween =
        visitor(
              _styleTween,
              widget.style,
              (value) => TextStyleTween(begin: value),
            )
            as Tween<TextStyle>?;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: _styleTween?.evaluate(animation) ?? widget.style,
      child: widget.child,
    );
  }
}

class AnimatedImageFilterBlur extends ImplicitlyAnimatedWidget {
  const AnimatedImageFilterBlur({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    this.sigmaX = 0.0,
    this.sigmaY = 0.0,
    this.tileMode,
    this.child,
  });
  final double sigmaX;
  final double sigmaY;
  final TileMode? tileMode;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedImageFilterBlur> createState() =>
      _AnimatedImageFilterBlurState();
}

class _AnimatedImageFilterBlurState
    extends AnimatedWidgetBaseState<AnimatedImageFilterBlur> {
  Tween<double>? _sigmaXTween;
  Tween<double>? _sigmaYTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _sigmaXTween =
        visitor(
              _sigmaXTween,
              widget.sigmaX,
              (value) => Tween<double>(begin: value),
            )
            as Tween<double>?;
    _sigmaYTween =
        visitor(
              _sigmaYTween,
              widget.sigmaY,
              (value) => Tween<double>(begin: value),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final sigmaX = _sigmaXTween?.evaluate(animation) ?? widget.sigmaX;
    final sigmaY = _sigmaYTween?.evaluate(animation) ?? widget.sigmaY;
    final enabled = sigmaX > 0.0 || sigmaY > 0.0;
    return ImageFiltered(
      enabled: enabled,
      imageFilter: ImageFilter.blur(
        sigmaX: sigmaX,
        sigmaY: sigmaY,
        tileMode: widget.tileMode,
      ),
      child: widget.child,
    );
  }
}
