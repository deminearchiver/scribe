import 'package:material/material.dart';

enum _MenuAspect { animation }

@immutable
class _MenuScopeData {
  const _MenuScopeData({required this.animation});

  final Animation<double> animation;

  _MenuScopeData copyWith({Animation<double>? animation}) =>
      _MenuScopeData(animation: animation ?? this.animation);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _MenuScopeData && animation == other.animation;
  }

  @override
  int get hashCode => Object.hashAll([animation]);
}

class _MenuScope extends InheritedModel<_MenuAspect> {
  const _MenuScope({super.key, required this.data, required super.child});

  final _MenuScopeData data;

  @override
  bool updateShouldNotify(covariant _MenuScope oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant _MenuScope oldWidget,
    Set<Object> dependencies,
  ) {
    return dependencies.any(
      (dependency) =>
          dependency is _MenuAspect &&
          switch (dependency) {
            _MenuAspect.animation => data.animation != oldWidget.data.animation,
          },
    );
  }

  static _MenuScopeData _of(BuildContext context, [_MenuAspect? aspect]) {
    assert(_debugCheckHasMenuScope(context));
    return InheritedModel.inheritFrom<_MenuScope>(
      context,
      aspect: aspect,
    )!.data;
  }

  static _MenuScopeData? _maybeOf(BuildContext context, [_MenuAspect? aspect]) {
    return InheritedModel.inheritFrom<_MenuScope>(
      context,
      aspect: aspect,
    )?.data;
  }

  static _MenuScopeData? maybeOf(BuildContext context) => _maybeOf(context);
  static _MenuScopeData of(BuildContext context) => _of(context);

  static Animation<double>? maybeAnimationOf(BuildContext context) =>
      _maybeOf(context, _MenuAspect.animation)?.animation;
  static Animation<double> animationOf(BuildContext context) =>
      _of(context, _MenuAspect.animation).animation;
}

bool _debugCheckHasMenuScope(BuildContext context) {
  assert(() {
    if (context.widget is! _MenuScope &&
        context.getElementForInheritedWidgetOfExactType<_MenuScope>() == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary("No MenuAnchor widget ancestor found."),
        ErrorDescription(
          "${context.widget.runtimeType} widgets require a MenuAnchor widget ancestor.",
        ),
        context.describeWidget(
          "The specific widget that could not find a MenuAnchor ancestor was",
        ),
        context.describeOwnershipChain(
          "The ownership chain for the affected widget is",
        ),
      ]);
    }
    return true;
  }());
  return true;
}

class MenuAnchor extends StatefulWidget {
  const MenuAnchor({super.key});

  @override
  State<MenuAnchor> createState() => _MenuAnchorState();
}

class _MenuAnchorState extends State<MenuAnchor> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _MenuDefaultsM3 extends MenuStyle {
  const _MenuDefaultsM3(this.colors)
    : super(
        shape: const WidgetStatePropertyAll(Shapes.extraSmall),
        elevation: const WidgetStatePropertyAll(Elevations.level2),
        surfaceTintColor: WidgetStateColor.transparent,
        alignment: AlignmentDirectional.topEnd,
        visualDensity: VisualDensity.standard,
      );

  final ColorScheme colors;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStatePropertyAll(colors.surfaceContainer);

  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      WidgetStatePropertyAll(colors.shadow);
}
