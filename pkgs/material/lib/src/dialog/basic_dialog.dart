import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:painting/painting.dart';
import 'package:material/material.dart';

import '../dual_animated_builder.dart';

part 'basic_dialog_theme.dart';

class BasicDialog extends StatefulWidget {
  const BasicDialog({
    super.key,
    this.title,
    this.content,
    this.actions = const [],
  });

  final Widget? title;
  final Widget? content;
  final List<Widget> actions;

  @override
  State<BasicDialog> createState() => _BasicDialogState();
}

class _BasicDialogState extends State<BasicDialog> {
  Animation<double> _animation = kAlwaysCompleteAnimation;
  CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: kAlwaysCompleteAnimation,
    curve: Curves.linear,
  );

  @override
  void initState() {
    super.initState();
    _updateTweens();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final data = BasicDialogRoute.of(context);
    if (_animation != data.animation) {
      _animation = data.animation;
      _updateCurvedAnimation(_animation);
    }
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    super.dispose();
  }

  void _updateTweens() {}

  void _updateCurvedAnimation(Animation<double> animation) {
    if (_curvedAnimation.parent != animation) {
      _curvedAnimation.dispose();
      _curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Easing.emphasizedDecelerate,
        reverseCurve: Easing.emphasizedAccelerate.flipped,
      );
    }
  }

  static final _enterOpacityTween = Tween<double>(begin: 0, end: 1);
  static final _exitOpacityTween = Tween<double>(begin: 1, end: 0);
  static final _titleEnterOpacityTween = _enterOpacityTween.chain(
    CurveTween(curve: const Interval(0.2, 0.7)),
  );
  static final _titleExitOpacityTween = _exitOpacityTween.chain(
    CurveTween(curve: const Interval(0, 2 / 3)),
  );
  Widget _buildHeadline(BuildContext context, Widget child) {
    final theme = Theme.of(context);

    final transition = switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => DefaultTextStyle.merge(
        style: theme.textTheme.headlineSmall!.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        child: child,
      ),
      _ => DualAnimatedBuilder(
        animation: _animation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) =>
                DefaultTextStyle.merge(
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha:
                          _titleEnterOpacityTween.evaluate(forwardAnimation) *
                          _titleExitOpacityTween.evaluate(reverseAnimation),
                    ),
                  ),
                  child: child!,
                ),
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: transition,
    );
  }

  Widget _buildContent(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final transition = switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => child,
      _ => DualAnimatedBuilder(
        animation: _animation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) => Opacity(
              opacity:
                  _titleEnterOpacityTween.evaluate(forwardAnimation) *
                  _titleExitOpacityTween.evaluate(reverseAnimation),
              child: child!,
            ),
      ),
    };
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: transition,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final actionsEnterOpacityTween = _enterOpacityTween.chain(
      CurveTween(
        curve: const Interval(0.5, 1),
      ), // Must actually continue up to 1.1
    );
    final actionsExitOpacityTween = _exitOpacityTween.chain(
      CurveTween(curve: const Interval(0, 2 / 3)),
    );
    final theme = Theme.of(context);
    final actionsBar = OverflowBar(
      alignment: MainAxisAlignment.end,
      spacing: 8,
      overflowAlignment: OverflowBarAlignment.end,
      overflowDirection: VerticalDirection.down,
      overflowSpacing: 0,
      children: widget.actions,
    );
    final transition = switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => actionsBar,
      _ => DualAnimatedBuilder(
        animation: _animation,
        child: actionsBar,
        builder:
            (context, forwardAnimation, reverseAnimation, child) => Opacity(
              opacity:
                  actionsEnterOpacityTween.evaluate(forwardAnimation) *
                  actionsExitOpacityTween.evaluate(reverseAnimation),
              child: child!,
            ),
      ),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: transition,
    );
  }

  Widget _buildSemantics(BuildContext context, Widget child) {
    // if (label != null) {
    //   return Semantics(
    //     scopesRoute: true,
    //     explicitChildNodes: true,
    //     namesRoute: true,
    //     label: label,
    //     child: child,
    //   );
    // }
    return child;
  }

  static final _enterHeightFactorTween = Tween<double>(begin: 0, end: 1);
  static final _exitHeightFactorTween = Tween<double>(begin: 1, end: 0.35);
  Widget _buildContainer(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final basicDialogTheme = BasicDialogTheme.maybeOf(context);
    final defaults = _BasicDialogDefaultsM3(
      colorScheme: theme.colorScheme,
      textTheme: theme.textTheme,
    );
    const type = MaterialType.card;
    const animationDuration = Duration.zero;
    final clipBehaviour =
        basicDialogTheme?.clipBehavior ?? defaults.clipBehavior;
    final color = basicDialogTheme?.backgroundColor ?? defaults.backgroundColor;
    final shape = basicDialogTheme?.shape ?? defaults.shape;
    return switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => Material(
        animationDuration: animationDuration,
        type: type,
        clipBehavior: clipBehaviour,
        color: color,
        shape: shape,
        child: child,
      ),
      _ => DualAnimatedBuilder(
        animation: _curvedAnimation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) => Material(
              animationDuration: animationDuration,
              type: type,
              clipBehavior: clipBehaviour,
              color: color,
              shape: CroppedBorder.align(
                shape: shape,
                alignment: Alignment.topCenter,
                heightFactor:
                    _enterHeightFactorTween.evaluate(forwardAnimation) *
                    _exitHeightFactorTween.evaluate(reverseAnimation),
              ),
              child: child!,
            ),
      ),
    };
  }

  static final _innerEnterOpacityTween = _enterOpacityTween.chain(
    CurveTween(curve: const Interval(0.1, 0.4)),
  );
  Widget _buildInnerFadeTransition(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => DualAnimatedBuilder(
        animation: _animation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) => Opacity(
              opacity: _innerEnterOpacityTween.evaluate(forwardAnimation),
              child: child!,
            ),
      ),
      _ => child,
    };
  }

  static final _outerEnterOpacityTween = _enterOpacityTween.chain(
    CurveTween(curve: const Interval(0, 0.1)),
  );
  static final _outerExitOpacityTween = _exitOpacityTween.chain(
    CurveTween(curve: const Interval(2 / 3, 1)),
  );
  static final _outerCupertinoEnterOpacityTween = _enterOpacityTween.chain(
    CurveTween(curve: const Interval(0, 0.1)),
  );
  static final _outerCupertinoOpacityTween = _exitOpacityTween;
  Widget _buildOuterFadeTransition(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => DualAnimatedBuilder(
        animation: _animation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) => Opacity(
              opacity:
                  _outerCupertinoEnterOpacityTween.evaluate(forwardAnimation) *
                  _outerCupertinoOpacityTween.evaluate(reverseAnimation),
              child: child!,
            ),
      ),
      _ => DualAnimatedBuilder(
        animation: _animation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) => Opacity(
              opacity:
                  _outerEnterOpacityTween.evaluate(forwardAnimation) *
                  _outerExitOpacityTween.evaluate(reverseAnimation),
              child: child!,
            ),
      ),
    };
  }

  static final _offsetTween = Tween<Offset>(
    begin: const Offset(0, -50),
    end: Offset.zero,
  );
  static final _scaleTween = Tween<double>(begin: 1.15, end: 1);
  static final _fadeEnterTween = Tween<double>(
    begin: 0,
    end: 1,
  ).chain(CurveTween(curve: const Interval(0, 1 / 3)));
  static final _fadeExitTween = Tween<double>(begin: 1, end: 0);

  Widget _buildTransformTransition(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return switch (theme.platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => DualAnimatedBuilder(
        animation: _curvedAnimation,
        child: child,
        builder:
            (context, forwardAnimation, reverseAnimation, child) =>
                Transform.scale(
                  scale: _scaleTween.evaluate(forwardAnimation),
                  filterQuality: FilterQuality.medium,
                  child: child!,
                ),
      ),
      _ => AnimatedBuilder(
        animation: _curvedAnimation,
        child: child,
        builder:
            (context, child) => Transform.translate(
              offset: _offsetTween.evaluate(_curvedAnimation),
              child: child!,
            ),
      ),
    };
  }

  Widget _buildViewInsets(BuildContext context, Widget child) {
    final effectivePadding =
        MediaQuery.viewInsetsOf(context) + const EdgeInsets.all(56);
    return Padding(
      padding: effectivePadding,
      child: MediaQuery.removeViewInsets(
        context: context,
        removeLeft: true,
        removeTop: true,
        removeRight: true,
        removeBottom: true,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final columnChildren = [
      // if (widget.title != null)
      if (widget.title != null) _buildHeadline(context, widget.title!),
      if (widget.content != null) _buildContent(context, widget.content!),
      // Flexible(
      //   child: Padding(
      //     padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      //     child: DualAnimatedBuilder(
      //       animation: _animation,
      //       child: widget.content!,
      //       builder:
      //           (context, forwardAnimation, reverseAnimation, child) =>
      //               Opacity(
      //                 opacity:
      //                     titleEnterOpacityTween.evaluate(forwardAnimation) *
      //                     titleExitOpacityTween.evaluate(reverseAnimation),
      //                 child: child!,
      //               ),
      //     ),
      //   ),
      // ),
      if (widget.actions.isNotEmpty) _buildActions(context),
    ];
    final child = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      ),
    );
    final innerFade = _buildInnerFadeTransition(context, child);
    final semantics = _buildSemantics(context, innerFade);

    final container = _buildContainer(context, semantics);
    final fadeTransition = _buildOuterFadeTransition(context, container);
    final dialog = Align(
      alignment: Alignment.center,
      child: _buildTransformTransition(
        context,
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
          child: fadeTransition,
        ),
      ),
    );
    return _buildViewInsets(context, dialog);
  }
}

class BasicDialogRoute<T> extends PopupRoute<T> {
  static BasicDialogRouteData? maybeOf(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<_BasicDialogRouteScope>();
    return result?.data;
  }

  static BasicDialogRouteData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null);
    return result!;
  }

  BasicDialogRoute({
    required this.context,
    required this.builder,
    required this.themes,
    required this.platform,
    this.barrierDismissible = true,
    this.barrierColor,
    super.settings,
    super.filter,
    super.traversalEdgeBehavior,
    super.requestFocus,
  });

  final BuildContext context;
  final WidgetBuilder builder;
  final CapturedThemes themes;
  final TargetPlatform platform;

  @override
  Duration get transitionDuration => switch (platform) {
    // TargetPlatform.iOS || TargetPlatform.macOS => Durations.medium4,
    _ => Durations.long2,
  };
  // Duration get transitionDuration => const Duration(seconds: 3);

  @override
  Duration get reverseTransitionDuration => switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => Durations.short2,
    _ => Durations.short3,
  };
  // Duration get reverseTransitionDuration => const Duration(seconds: 3);

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildModalBarrier() {
    // TODO: implement buildModalBarrier
    return super.buildModalBarrier();
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final child = _BasicDialogRouteScope(
      data: BasicDialogRouteData(animation: animation),
      child: Builder(builder: builder),
    );
    final dialog = SafeArea(child: themes.wrap(child));
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: DisplayFeatureSubScreen(child: dialog),
    );
  }
}

@immutable
class BasicDialogRouteData {
  const BasicDialogRouteData({required this.animation});

  final Animation<double> animation;

  @override
  int get hashCode => Object.hashAll([animation]);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BasicDialogRouteData && animation == other.animation;
  }
}

class _BasicDialogRouteScope extends InheritedWidget {
  const _BasicDialogRouteScope({
    // ignore: unused_element_parameter
    super.key,
    required this.data,
    required super.child,
  });

  final BasicDialogRouteData data;

  @override
  bool updateShouldNotify(covariant _BasicDialogRouteScope oldWidget) {
    return data != oldWidget.data;
  }
}

bool _debugIsActive(BuildContext context) {
  if (context is Element && !context.debugIsActive) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary("This BuildContext is no longer valid."),
      ErrorDescription(
        "The showBasicDialog function context parameter is a BuildContext that is no longer valid.",
      ),
      ErrorHint(
        "This can commonly occur when the showBasicDialog function is called after awaiting a Future. "
        "In this situation the BuildContext might refer to a widget that has already been disposed during the await. "
        "Consider using a parent context instead.",
      ),
    ]);
  }
  return true;
}

Future<T?> showBasicDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TraversalEdgeBehavior? traversalEdgeBehavior,
}) {
  assert(_debugIsActive(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final theme = Theme.of(context);
  final basicDialogTheme = BasicDialogTheme.of(context);

  final themes = InheritedTheme.capture(
    from: context,
    to: Navigator.of(context, rootNavigator: useRootNavigator).context,
  );

  return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
    BasicDialogRoute<T>(
      context: context,
      builder: builder,
      barrierColor: basicDialogTheme.barrierColor,
      barrierDismissible: barrierDismissible,
      settings: routeSettings,
      platform: theme.platform,
      themes: themes,
      traversalEdgeBehavior:
          traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
    ),
  );
}
