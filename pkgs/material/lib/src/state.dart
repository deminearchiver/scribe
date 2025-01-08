import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:material/material.dart';

class WidgetStateLayerColor implements WidgetStateProperty<Color> {
  const WidgetStateLayerColor(this.color, {this.opacity});

  final Color color;
  final WidgetStateProperty<double>? opacity;

  @override
  Color resolve(Set<WidgetState> states) {
    if (opacity == null) return color.withAlpha(0);
    final alpha = opacity!.resolve(states);
    if (alpha == 0.0) return color.withAlpha(0);
    return color.withValues(alpha: alpha);
  }
}

double _lerpDouble(double a, double b, double t) => a * (1.0 - t) + b * t;

@immutable
class StateThemeData extends ThemeExtension<StateThemeData>
    with Diagnosticable {
  const StateThemeData({required this.stateLayerOpacity});
  const StateThemeData.standard()
    : stateLayerOpacity = const _StandardStateLayerOpacity();
  const StateThemeData.web()
    : stateLayerOpacity = const _WebStateLayerOpacity();

  final WidgetStateProperty<double> stateLayerOpacity;

  @override
  StateThemeData copyWith({WidgetStateProperty<double>? stateLayerOpacity}) =>
      StateThemeData(
        stateLayerOpacity: stateLayerOpacity ?? this.stateLayerOpacity,
      );

  @override
  StateThemeData lerp(covariant StateThemeData? other, double t) =>
      StateThemeData(
        stateLayerOpacity: stateLayerOpacity.lerp(
          other?.stateLayerOpacity,
          t,
          _lerpDouble,
        ),
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StateThemeData &&
        stateLayerOpacity == other.stateLayerOpacity;
  }

  @override
  int get hashCode => stateLayerOpacity.hashCode;
}

extension _WidgetStatePropertyExtension<T> on WidgetStateProperty<T> {
  WidgetStateProperty<T> lerp(
    WidgetStateProperty<T?>? other,
    double t,
    T Function(T, T, double) lerpFunction,
  ) => _LerpProperties<T>(this, other, t, lerpFunction);
}

class _LerpProperties<T> implements WidgetStateProperty<T> {
  const _LerpProperties(this.a, this.b, this.t, this.lerpFunction);

  final WidgetStateProperty<T> a;
  final WidgetStateProperty<T?>? b;
  final double t;
  final T Function(T, T, double) lerpFunction;

  @override
  T resolve(Set<WidgetState> states) {
    final resolvedA = a.resolve(states);
    final resolvedB = b?.resolve(states);
    return resolvedB != null
        ? lerpFunction(resolvedA, resolvedB, t)
        : resolvedA;
  }
}

extension StateThemeExtension on ThemeData {
  StateThemeData get stateTheme =>
      extension<StateThemeData>() ?? const StateThemeData.standard();
}

class StateTheme extends InheritedTheme {
  const StateTheme({super.key, required this.data, required super.child});

  final StateThemeData data;

  @override
  bool updateShouldNotify(covariant StateTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      StateTheme(data: data, child: child);

  static StateThemeData of(BuildContext context) {
    final stateTheme = context.dependOnInheritedWidgetOfExactType<StateTheme>();
    return stateTheme?.data ?? Theme.of(context).stateTheme;
  }
}

abstract class WidgetStateLayerOpacity implements WidgetStateProperty<double> {
  const WidgetStateLayerOpacity();

  WidgetStateProperty<Color> apply(Color color) =>
      WidgetStateLayerColor(color, opacity: this);
}

class _StandardStateLayerOpacity extends WidgetStateLayerOpacity {
  const _StandardStateLayerOpacity();

  @override
  double resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return 0.0;
    if (states.contains(WidgetState.dragged)) {
      return 0.16;
    }
    if (states.contains(WidgetState.pressed)) {
      return 0.1;
    }
    if (states.contains(WidgetState.hovered)) {
      return 0.08;
    }
    if (states.contains(WidgetState.focused)) {
      return 0.1;
    }
    return 0.0;
  }
}

class _WebStateLayerOpacity extends WidgetStateLayerOpacity {
  const _WebStateLayerOpacity();

  @override
  double resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return 0.0;
    if (states.contains(WidgetState.dragged)) {
      return 0.16;
    }
    if (states.contains(WidgetState.pressed)) {
      return 0.12;
    }
    if (states.contains(WidgetState.hovered)) {
      return 0.08;
    }
    if (states.contains(WidgetState.focused)) {
      return 0.12;
    }
    return 0.0;
  }
}
