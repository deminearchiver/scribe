import 'package:material/material.dart';

class MaterialRoute<T> extends PageRoute<T> {
  static MaterialRouteData? _maybeOf(
    BuildContext context, [
    _MaterialRouteAspect? aspect,
  ]) {
    return InheritedModel.inheritFrom<_MaterialRouteScope>(
      context,
      aspect: aspect,
    )?.data;
  }

  static MaterialRouteData _of(
    BuildContext context, [
    _MaterialRouteAspect? aspect,
  ]) {
    assert(debugCheckHasMaterialRoute(context));
    return InheritedModel.inheritFrom<_MaterialRouteScope>(
      context,
      aspect: aspect,
    )!.data;
  }

  static MaterialRouteData? maybeOf(BuildContext context) => _maybeOf(context);

  static MaterialRouteData of(BuildContext context) => _of(context);

  static Animation<double>? maybeAnimationOf(BuildContext context) =>
      _maybeOf(context, _MaterialRouteAspect.animation)?.animation;

  static Animation<double> animationOf(BuildContext context) =>
      _of(context, _MaterialRouteAspect.animation).animation;

  static Animation<double>? maybeSecondaryAnimationOf(BuildContext context) =>
      _maybeOf(context, _MaterialRouteAspect.secondaryAnimation)?.animation;

  static Animation<double> secondaryAnimationOf(BuildContext context) =>
      _of(context, _MaterialRouteAspect.secondaryAnimation).animation;

  MaterialRoute({
    this.maintainState = true,
    super.settings,
    super.requestFocus,
    bool barrierDismissible = false,
    this.backgroundColor,
    required this.builder,
  }) : super(fullscreenDialog: false, allowSnapshotting: false) {
    assert(opaque);
  }

  final Color? backgroundColor;
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Durations.extralong2;

  static const _transitionCurve = Easing.emphasized;

  // The previous page slides from right to left as the current page appears.
  static final _secondaryBackwardTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(-0.25, 0.0),
  ).chain(CurveTween(curve: _transitionCurve));

  // The previous page slides from left to right as the current page disappears.
  static final _secondaryForwardTranslationTween = Tween<Offset>(
    begin: const Offset(-0.25, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: _transitionCurve));

  // The fade in transition when the new page appears.
  static final _fadeInTransition = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: const Interval(0.0, 0.1)));
  // ).chain(CurveTween(curve: const Interval(0.0, 0.75)));

  // The fade out trnasition of the old page when the new page appears.
  static final _fadeOutTransition = Tween<double>(
    begin: 1.0,
    end: 0.0, // 0.0
  ).chain(CurveTween(curve: const Interval(0.0, 0.1)));
  // ).chain(CurveTween(curve: const Interval(0.0, 0.25)));

  @override
  bool canTransitionFrom(TransitionRoute previousRoute) {
    // Supress previous route from transitioning if this is a fullscreenDialog route.
    return previousRoute is PageRoute && !fullscreenDialog;
  }

  @override
  bool canTransitionTo(TransitionRoute nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog,
    // or there is no matching transition to use.
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    final bool nextRouteIsNotFullscreen =
        (nextRoute is! PageRoute<T>) || !nextRoute.fullscreenDialog;

    // If the next route has a delegated transition, then this route is able to
    // use that delegated transition to smoothly sync with the next route's
    // transition.
    final bool nextRouteHasDelegatedTransition =
        nextRoute is ModalRoute<T> && nextRoute.delegatedTransition != null;

    // Otherwise if the next route has the same route transition mixin as this
    // one, then this route will already be synced with its transition.
    return nextRouteIsNotFullscreen &&
        ((nextRoute is MaterialRoute) || nextRouteHasDelegatedTransition);
  }

  static Widget _delegatedTransition(
    BuildContext context,
    Animation<double> secondaryAnimation,
    Color? backgroundColor,
    Widget? child,
  ) {
    return DualTransitionBuilder(
      animation: ReverseAnimation(secondaryAnimation),
      forwardBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        final color = backgroundColor ?? Theme.of(context).colorScheme.surface;
        return ColoredBox(
          color: animation.isAnimating ? color : Colors.transparent,
          child: FadeTransition(
            opacity: _fadeInTransition.animate(animation),
            child: SlideTransition(
              position: _secondaryForwardTranslationTween.animate(animation),
              child: child,
            ),
          ),
        );
      },
      reverseBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        final color = backgroundColor ?? Theme.of(context).colorScheme.surface;
        return ColoredBox(
          color: animation.isAnimating ? color : Colors.transparent,
          child: FadeTransition(
            opacity: _fadeOutTransition.animate(animation),
            child: SlideTransition(
              position: _secondaryBackwardTranslationTween.animate(animation),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        bool allowSnapshotting,
        Widget? child,
      ) => _delegatedTransition(context, animation, backgroundColor, child);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scoped = _MaterialRouteScope(
      data: MaterialRouteData(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
      ),
      child: child,
    );
    return _FadeForwardsPageTransition(
      backgroundColor: backgroundColor,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: scoped,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: builder(context),
    );
  }
}

enum _MaterialRouteAspect { animation, secondaryAnimation }

bool debugCheckHasMaterialRoute(BuildContext context) {
  assert(() {
    if (context.widget is! _MaterialRouteScope &&
        context
                .getElementForInheritedWidgetOfExactType<
                  _MaterialRouteScope
                >() ==
            null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No MaterialRoute widget ancestor found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require a MaterialRoute widget ancestor.',
        ),
        context.describeWidget(
          'The specific widget that could not find a MaterialRoute ancestor was',
        ),
        context.describeOwnershipChain(
          'The ownership chain for the affected widget is',
        ),
        ErrorHint(
          'No MaterialRoute ancestor could be found starting from the context '
          'that was passed to MaterialRoute.of(). This can happen because the '
          'context used is not a descendant of a View widget, which introduces '
          'a MaterialRoute.',
        ),
      ]);
    }
    return true;
  }());
  return true;
}

@immutable
class MaterialRouteData {
  const MaterialRouteData({
    required this.animation,
    required this.secondaryAnimation,
  });
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;

  @override
  int get hashCode => Object.hashAll([animation, secondaryAnimation]);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MaterialRouteData &&
            animation == other.animation &&
            secondaryAnimation == other.secondaryAnimation);
  }
}

class _MaterialRouteScope extends InheritedModel<_MaterialRouteAspect> {
  const _MaterialRouteScope({
    super.key,
    required this.data,
    required super.child,
  });

  final MaterialRouteData data;

  @override
  bool updateShouldNotify(covariant _MaterialRouteScope oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant _MaterialRouteScope oldWidget,
    Set<_MaterialRouteAspect> dependencies,
  ) {
    return (data.animation != oldWidget.data.animation &&
            dependencies.contains(_MaterialRouteAspect.animation)) ||
        (data.secondaryAnimation != oldWidget.data.secondaryAnimation &&
            dependencies.contains(_MaterialRouteAspect.secondaryAnimation));
  }
}

class _FadeForwardsPageTransition extends StatelessWidget {
  const _FadeForwardsPageTransition({
    required this.animation,
    required this.secondaryAnimation,
    this.backgroundColor,
    this.child,
  });

  final Animation<double> animation;

  final Animation<double> secondaryAnimation;

  final Color? backgroundColor;

  final Widget? child;

  // The new page slides in from right to left.
  static final Animatable<Offset> _forwardTranslationTween = Tween<Offset>(
    begin: const Offset(0.25, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: MaterialRoute._transitionCurve));

  // The old page slides back from left to right.
  static final Animatable<Offset> _backwardTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.25, 0.0),
  ).chain(CurveTween(curve: MaterialRoute._transitionCurve));

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        return FadeTransition(
          opacity: MaterialRoute._fadeInTransition.animate(animation),
          child: SlideTransition(
            position: _forwardTranslationTween.animate(animation),
            child: child,
          ),
        );
      },
      reverseBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        return FadeTransition(
          opacity: MaterialRoute._fadeOutTransition.animate(animation),
          child: SlideTransition(
            position: _backwardTranslationTween.animate(animation),
            child: child,
          ),
        );
      },
      child: MaterialRoute._delegatedTransition(
        context,
        secondaryAnimation,
        backgroundColor,
        child,
      ),
    );
  }
}
