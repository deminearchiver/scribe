import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:material/material.dart';
import 'package:flutter/material.dart' as flutter;

@immutable
class MaterialRoutePage<T> extends Page<T> {
  const MaterialRoutePage({
    this.backgroundColor,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.canPop,
    super.onPopInvoked,
    super.name,
    super.arguments,
    super.restorationId,
    required this.child,
  });

  final bool maintainState;
  final bool fullscreenDialog;
  final Color? backgroundColor;
  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedMaterialRoute(page: this);
  }
}

class _PageBasedMaterialRoute<T> extends PageRoute<T>
    with MaterialRouteMixin<T> {
  _PageBasedMaterialRoute({required MaterialRoutePage<T> page})
    : super(settings: page);

  MaterialRoutePage<T> get _page => settings as MaterialRoutePage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  Color? get backgroundColor => _page.backgroundColor;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Widget buildContent(BuildContext context) => _page.child;
}

mixin MaterialRouteMixin<T> on PageRoute<T> {
  Color? get backgroundColor;
  Widget buildContent(BuildContext context);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Durations.extralong2;

  static const _transitionCurve = Easing.emphasized;

  // // The previous page slides from right to left as the current page appears.
  // static final _secondaryBackwardTranslationTween = Tween<Offset>(
  //   begin: Offset.zero,
  //   end: const Offset(-0.25, 0.0),
  // ).chain(CurveTween(curve: _transitionCurve));

  // // The previous page slides from left to right as the current page disappears.
  // static final _secondaryForwardTranslationTween = Tween<Offset>(
  //   begin: const Offset(-0.25, 0.0),
  //   end: Offset.zero,
  // ).chain(CurveTween(curve: _transitionCurve));

  // // The fade in transition when the new page appears.
  // static final _fadeInTransition = Tween<double>(begin: 0.0, end: 1.0)
  //     .chain(CurveTween(curve: const Interval(0.25, 1.0)))
  //     .chain(CurveTween(curve: _transitionCurve));
  // // ).chain(CurveTween(curve: const Interval(0.0, 0.75)));

  // // The fade out trnasition of the old page when the new page appears.
  // static final _fadeOutTransition = Tween<double>(
  //       begin: 1.0,
  //       end: 0.0, // 0.0
  //     )
  //     .chain(CurveTween(curve: const Interval(0.0, 0.25)))
  //     .chain(CurveTween(curve: _transitionCurve));
  // ).chain(CurveTween(curve: const Interval(0.0, 0.25)));

  static final Animatable<Offset> _secondaryBackwardTranslationTween =
      Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.25, 0.0),
      ).chain(CurveTween(curve: _transitionCurve));

  // The previous page slides from left to right as the current page disappears.
  static final Animatable<Offset> _secondaryForwardTranslationTween =
      Tween<Offset>(
        begin: const Offset(-0.25, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: _transitionCurve));

  // The fade in transition when the new page appears.
  static final Animatable<double> _fadeInTransition = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: const Interval(0.0, 0.75)));

  // The fade out transition of the old page when the new page appears.
  static final Animatable<double> _fadeOutTransition = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).chain(CurveTween(curve: const Interval(0.0, 0.25)));

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      (context, animation, secondaryAnimation, allowSnapshotting, child) =>
          _delegatedTransition(
            context,
            animation,
            secondaryAnimation,
            backgroundColor,
            child,
          );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return PredictiveBackGestureDetector(
      route: this,
      builder: (context, phase, startBackEvent, currentBackEvent) {
        // TODO: bring back this behaviour
        // if (popGestureInProgress) {
        //   return _PredictiveBackPageSharedElementTransition(
        //     isDelegatedTransition: false,
        //     animation: animation,
        //     phase: phase,
        //     secondaryAnimation: secondaryAnimation,
        //     startBackEvent: startBackEvent,
        //     currentBackEvent: currentBackEvent,
        //     child: child,
        //   );
        // }
        return _FadeForwardsPageTransition(
          backgroundColor: backgroundColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
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
      child: buildContent(context),
    );
  }

  static Widget? _delegatedTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Color? backgroundColor,
    Widget? child,
  ) {
    final route = ModalRoute.of(context);
    if (child == null || route is! PageRoute) {
      return child;
    }

    final transition = DualTransitionBuilder(
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
    return transition;
    // TODO: bring back this behaviour
    // return PredictiveBackGestureListener(
    //   route: route,
    //   builder: (context, phase, startBackEvent, currentBackEvent) {
    //     if (route.popGestureInProgress) {
    //       return _PredictiveBackPageSharedElementTransition(
    //         isDelegatedTransition: true,
    //         animation: animation,
    //         phase: phase,
    //         secondaryAnimation: secondaryAnimation,
    //         startBackEvent: startBackEvent,
    //         currentBackEvent: currentBackEvent,
    //         child: child,
    //       );
    //     }
    //     return transition;
    //   },
    // );
  }
}

class MaterialRoute<T> extends PageRoute<T> with MaterialRouteMixin<T> {
  MaterialRoute({
    this.backgroundColor,
    super.settings,
    super.requestFocus,
    this.maintainState = true,
    required this.builder,
  }) : super(allowSnapshotting: false, fullscreenDialog: false) {
    assert(opaque);
  }

  @override
  final Color? backgroundColor;
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Widget buildContent(BuildContext context) => builder(context);
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

  // // The new page slides in from right to left.
  // static final Animatable<Offset> _forwardTranslationTween = Tween<Offset>(
  //   begin: const Offset(0.25, 0.0),
  //   end: Offset.zero,
  // ).chain(CurveTween(curve: MaterialRouteMixin._transitionCurve));

  // // The old page slides back from left to right.
  // static final Animatable<Offset> _backwardTranslationTween = Tween<Offset>(
  //   begin: Offset.zero,
  //   end: const Offset(0.25, 0.0),
  // ).chain(CurveTween(curve: MaterialRouteMixin._transitionCurve));

  static final Animatable<Offset> _forwardTranslationTween = Tween<Offset>(
    begin: const Offset(0.25, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: MaterialRouteMixin._transitionCurve));

  // The old page slides back from left to right.
  static final Animatable<Offset> _backwardTranslationTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.25, 0.0),
  ).chain(CurveTween(curve: MaterialRouteMixin._transitionCurve));

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
          opacity: MaterialRouteMixin._fadeInTransition.animate(animation),
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
          opacity: MaterialRouteMixin._fadeOutTransition.animate(animation),
          child: SlideTransition(
            position: _backwardTranslationTween.animate(animation),
            child: child,
          ),
        );
      },
      child: child,
      // child: MaterialRoute._delegatedTransition(
      //   context,
      //   secondaryAnimation,
      //   backgroundColor,
      //   child,
      // ),
    );
  }
}

class _PredictiveBackPageSharedElementTransition extends StatefulWidget {
  const _PredictiveBackPageSharedElementTransition({
    required this.isDelegatedTransition,
    required this.animation,
    required this.secondaryAnimation,
    required this.phase,
    required this.startBackEvent,
    required this.currentBackEvent,
    required this.child,
  });

  final bool isDelegatedTransition;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final PredictiveBackPhase phase;
  final PredictiveBackEvent? startBackEvent;
  final PredictiveBackEvent? currentBackEvent;
  final Widget child;

  @override
  State<_PredictiveBackPageSharedElementTransition> createState() =>
      _PredictiveBackPageSharedElementTransitionState();
}

class _PredictiveBackPageSharedElementTransitionState
    extends State<_PredictiveBackPageSharedElementTransition>
    with SingleTickerProviderStateMixin {
  double xShift = 0;
  double yShift = 0;
  double scale = 1;
  late final AnimationController commitController;
  late final Listenable mergedAnimations;

  // Constants as per the motion specs
  // https://developer.android.com/design/ui/mobile/guides/patterns/predictive-back#motion-specs
  static const double scalePercentage = 0.90;
  static const double divisionFactor = 20.0;
  static const double margin = 8.0;
  static const double borderRadius = 32.0;
  static const double extraShiftDistance = 0.1;

  @override
  void initState() {
    super.initState();
    commitController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    mergedAnimations = Listenable.merge(<Listenable>[
      widget.animation,
      commitController,
    ]);

    if (widget.phase == PredictiveBackPhase.commit) {
      commitController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(_PredictiveBackPageSharedElementTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.phase != oldWidget.phase &&
        widget.phase == PredictiveBackPhase.commit) {
      final int droppedPageBackAnimationTime =
          lerpDouble(0, 800, widget.animation.value)!.floor();

      commitController.duration = Duration(
        milliseconds: droppedPageBackAnimationTime,
      );
      commitController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    commitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mergedAnimations,
      builder: _animatedBuilder,
      child: widget.child,
    );
  }

  double calcXShift() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double xShift = (screenWidth / divisionFactor) - margin;

    return Tween<double>(
      begin:
          widget.currentBackEvent?.swipeEdge == SwipeEdge.right
              ? -xShift
              : xShift,
      end: 0.0,
    ).animate(widget.animation).value;
  }

  double calcCommitXShift() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Tween<double>(begin: 0.0, end: screenWidth * extraShiftDistance)
        .animate(
          CurvedAnimation(
            parent: commitController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        )
        .value;
  }

  double calcYShift() {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double startTouchY = widget.startBackEvent?.touchOffset?.dy ?? 0;
    final double currentTouchY = widget.currentBackEvent?.touchOffset?.dy ?? 0;

    final double yShiftMax = (screenHeight / divisionFactor) - margin;

    final double rawYShift = currentTouchY - startTouchY;
    final double easedYShift =
        Curves.easeOut.transform(
          (rawYShift.abs() / screenHeight).clamp(0.0, 1.0),
        ) *
        rawYShift.sign *
        yShiftMax;

    return easedYShift.clamp(-yShiftMax, yShiftMax);
  }

  double calcScale() {
    return Tween<double>(
      begin: scalePercentage,
      end: 1.0,
    ).animate(widget.animation).value;
  }

  double calcCommitScale() {
    return Tween<double>(begin: 0.0, end: extraShiftDistance)
        .animate(
          CurvedAnimation(
            parent: commitController,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
          ),
        )
        .value;
  }

  double calcOpacity() {
    if (widget.isDelegatedTransition) {
      return 1;
    }

    return Tween<double>(begin: 1.0, end: 0.0)
        .animate(
          CurvedAnimation(parent: commitController, curve: Curves.easeOut),
        )
        .value;
  }

  Widget _animatedBuilder(BuildContext context, Widget? child) {
    final double xShift =
        widget.phase == PredictiveBackPhase.commit
            ? this.xShift + calcCommitXShift()
            : this.xShift = calcXShift();
    final double yShift =
        widget.phase == PredictiveBackPhase.commit
            ? this.yShift
            : this.yShift = calcYShift();
    final double scale =
        widget.phase == PredictiveBackPhase.commit
            ? this.scale - calcCommitScale()
            : this.scale = calcScale();

    final double opacity = calcOpacity();

    final Tween<double> gapTween = Tween<double>(begin: margin, end: 0.0);
    final Tween<double> borderRadiusTween = Tween<double>(
      begin: borderRadius,
      end: 0.0,
    );

    return Transform.scale(
      scale: scale,
      child: Transform.translate(
        offset: Offset(xShift, yShift),
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: gapTween.animate(widget.animation).value,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                borderRadiusTween.animate(widget.animation).value,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
