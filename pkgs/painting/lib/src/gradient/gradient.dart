import 'dart:ui' show FragmentProgram, FragmentShader;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class CustomGradient extends Gradient {
  const CustomGradient({required this.delegate, super.transform})
    : super(colors: const [], stops: const []);

  final GradientDelegate delegate;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    return delegate.createShader(
      rect: rect,
      textDirection: textDirection,
      transform: _resolveTransform(rect, textDirection),
    );
    // return ui.Gradient.linear(
    //   begin.resolve(textDirection).withinRect(rect),
    //   end.resolve(textDirection).withinRect(rect),
    //   colors,
    //   _impliedStops(),
    //   tileMode,
    //   _resolveTransform(rect, textDirection),
    // );
  }

  @override
  Gradient scale(double factor) =>
      CustomGradient(delegate: delegate.scale(factor), transform: transform);

  @override
  Gradient withOpacity(double opacity) => CustomGradient(
    delegate: delegate.withOpacity(opacity),
    transform: transform,
  );

  Float64List? _resolveTransform(Rect bounds, TextDirection? textDirection) {
    return transform?.transform(bounds, textDirection: textDirection)?.storage;
  }
}

abstract class GradientDelegate {
  const GradientDelegate();

  @protected
  Shader createShader({
    required Rect rect,
    TextDirection? textDirection,
    Float64List? transform,
  });

  @protected
  GradientDelegate scale(double factor);

  @protected
  GradientDelegate withOpacity(double opacity);
}

extension FragmentShaderExtension on FragmentShader {}
