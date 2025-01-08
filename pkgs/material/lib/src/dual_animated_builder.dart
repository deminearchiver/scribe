import 'package:flutter/material.dart';

/// Builder callback used by [DualAnimatedBuilder].
///
/// The builder is expected to return a transition powered by the provided
/// `animation` and wrapping the provided `child`.
///
/// The `animation` provided to the builder always runs forward from 0.0 to 1.0.
typedef DualAnimatedWidgetBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> forwardAnimation,
      Animation<double> reverseAnimation,
      Widget? child,
    );

/// A transition builder that animates its [child] based on the
/// [AnimationStatus] of the provided [animation].
///
/// This widget can be used to specify different enter and exit transitions for
/// a [child].
///
/// While the [animation] runs forward, the [child] is animated according to
/// [forwardBuilder] and while the [animation] is running in reverse, it is
/// animated according to [reverseBuilder].
///
/// Using this builder allows the widget tree to maintain its shape by nesting
/// the enter and exit transitions. This ensures that no state information of
/// any descendant widget is lost when the transition starts or completes.
class DualAnimatedBuilder extends StatefulWidget {
  /// Creates a [DualAnimatedBuilder].
  const DualAnimatedBuilder({
    super.key,
    required this.animation,
    this.child,
    required this.builder,
  });

  /// The animation that drives the [child]'s transition.
  ///
  /// When this animation runs forward, the [child] transitions as specified by
  /// [forwardBuilder]. When it runs in reverse, the child transitions according
  /// to [reverseBuilder].
  final Animation<double> animation;

  /// A builder for the transition that makes [child] appear on screen.
  ///
  /// The [child] should be fully visible when the provided `animation` reaches
  /// 1.0.
  ///
  /// The `animation` provided to this builder is running forward from 0.0 to
  /// 1.0 when [animation] runs _forward_. When [animation] runs in reverse,
  /// the given `animation` is set to [kAlwaysCompleteAnimation].
  ///
  /// See also:
  ///
  ///  * [reverseBuilder], which builds the transition for making the [child]
  ///   disappear from the screen.
  // final DualAnimatedWidgetBuilder forwardBuilder;

  /// A builder for a transition that makes [child] disappear from the screen.
  ///
  /// The [child] should be fully invisible when the provided `animation`
  /// reaches 1.0.
  ///
  /// The `animation` provided to this builder is running forward from 0.0 to
  /// 1.0 when [animation] runs in _reverse_. When [animation] runs forward,
  /// the given `animation` is set to [kAlwaysDismissedAnimation].
  ///
  /// See also:
  ///
  ///  * [forwardBuilder], which builds the transition for making the [child]
  ///    appear on screen.
  // final DualAnimatedWidgetBuilder reverseBuilder;

  /// The widget below this [DualAnimatedBuilder] in the tree.
  ///
  /// This child widget will be wrapped by the transitions built by
  /// [forwardBuilder] and [reverseBuilder].
  final Widget? child;

  final DualAnimatedWidgetBuilder builder;

  @override
  State<DualAnimatedBuilder> createState() => _DualAnimatedBuilderState();
}

class _DualAnimatedBuilderState extends State<DualAnimatedBuilder> {
  late AnimationStatus _effectiveAnimationStatus;
  final ProxyAnimation _forwardAnimation = ProxyAnimation();
  final ProxyAnimation _reverseAnimation = ProxyAnimation();

  @override
  void initState() {
    super.initState();
    _effectiveAnimationStatus = widget.animation.status;
    widget.animation.addStatusListener(_animationListener);
    _updateAnimations();
  }

  void _animationListener(AnimationStatus animationStatus) {
    final AnimationStatus oldEffective = _effectiveAnimationStatus;
    _effectiveAnimationStatus = _calculateEffectiveAnimationStatus(
      lastEffective: _effectiveAnimationStatus,
      current: animationStatus,
    );
    if (oldEffective != _effectiveAnimationStatus) {
      _updateAnimations();
    }
  }

  @override
  void didUpdateWidget(DualAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_animationListener);
      widget.animation.addStatusListener(_animationListener);
      _animationListener(widget.animation.status);
    }
  }

  // When a transition is interrupted midway we just want to play the ongoing
  // animation in reverse. Switching to the actual reverse transition would
  // yield a disjoint experience since the forward and reverse transitions are
  // very different.
  AnimationStatus _calculateEffectiveAnimationStatus({
    required AnimationStatus lastEffective,
    required AnimationStatus current,
  }) {
    switch (current) {
      case AnimationStatus.dismissed:
      case AnimationStatus.completed:
        return current;
      case AnimationStatus.forward:
        switch (lastEffective) {
          case AnimationStatus.dismissed:
          case AnimationStatus.completed:
          case AnimationStatus.forward:
            return current;
          case AnimationStatus.reverse:
            return lastEffective;
        }
      case AnimationStatus.reverse:
        switch (lastEffective) {
          case AnimationStatus.dismissed:
          case AnimationStatus.completed:
          case AnimationStatus.reverse:
            return current;
          case AnimationStatus.forward:
            return lastEffective;
        }
    }
  }

  void _updateAnimations() {
    switch (_effectiveAnimationStatus) {
      case AnimationStatus.dismissed:
      case AnimationStatus.forward:
        _forwardAnimation.parent = widget.animation;
        _reverseAnimation.parent = kAlwaysDismissedAnimation;
      case AnimationStatus.reverse:
      case AnimationStatus.completed:
        _forwardAnimation.parent = kAlwaysCompleteAnimation;
        _reverseAnimation.parent = ReverseAnimation(widget.animation);
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      child: widget.child,
      builder:
          (context, child) => widget.builder(
            context,
            _forwardAnimation,
            _reverseAnimation,
            child,
          ),
    );
  }
}
