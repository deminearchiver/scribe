import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:material/material.dart';

Widget _buildSizedFAB({
  required BuildContext context,
  Key? key,
  required FloatingActionButtonSize size,
  VoidCallback? onPressed,
  ButtonStyle? style,
  required Widget? child,
}) {
  return switch (size) {
    FloatingActionButtonSize.regular => FloatingActionButton(
      key: key,
      onPressed: onPressed,
      style: style,
      child: child,
    ),
    FloatingActionButtonSize.small => FloatingActionButton.small(
      key: key,
      onPressed: onPressed,
      style: style,
      child: child,
    ),
    FloatingActionButtonSize.large => FloatingActionButton.large(
      key: key,
      onPressed: onPressed,
      style: style,
      child: child,
    ),
  };
}

class FloatingActionButtonAction<T extends Object> {
  const FloatingActionButtonAction({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final Widget icon;
  final Widget label;

  @override
  bool operator ==(Object other) {
    return other is FloatingActionButtonAction &&
        value == other.value &&
        icon == other.icon &&
        label == other.label;
  }

  @override
  int get hashCode => Object.hash(value, icon, label);
}

class ExpandableFloatingActionButton<T extends Object> extends StatefulWidget {
  const ExpandableFloatingActionButton({
    super.key,
    this.onPressed,
    this.size = FloatingActionButtonSize.regular,
    this.expandedStyle,
    this.collapsedStyle,
    required this.actions,
  }) : assert(actions.length >= 1);

  final VoidCallback? onPressed;

  final FloatingActionButtonSize size;

  final ButtonStyle? collapsedStyle;
  final ButtonStyle? expandedStyle;

  final List<FloatingActionButtonAction<T>> actions;

  @override
  State<ExpandableFloatingActionButton> createState() =>
      ExpandableFloatingActionButtonState<T>();
}

class ExpandableFloatingActionButtonState<T extends Object>
    extends State<ExpandableFloatingActionButton<T>> {
  final _anchorKey = GlobalKey();
  final _stateKey = GlobalKey();
  bool _visible = true;

  late ValueNotifier<FloatingActionButtonSize> _size;
  late ValueNotifier<ButtonStyle?> _collapsedStyle;
  late ValueNotifier<ButtonStyle?> _expandedStyle;
  late ValueNotifier<List<FloatingActionButtonAction<T>>> _actions;

  _ExpandableFloatingActionButtonRoute<T>? _route;

  static const ButtonStyle _collapsedDefaults =
      _CollapsedFloatingActionButtonDefaultsM3();
  static const ButtonStyle _expandedDefaults =
      _ExpandedFloatingActionButtonDefaultsM3();

  void expand() {
    final navigator = Navigator.of(context);
    final route = _ExpandableFloatingActionButtonRoute<T>(
      anchorKey: _anchorKey,
      stateKey: _stateKey,
      onVisibilityChanged:
          (value) => _scheduleSetState(() => _visible = !value),
      size: _size,
      collapsedStyle: _collapsedStyle,
      expandedStyle: _expandedStyle,
      actions: _actions,
    );
    navigator.push(route);
    _route = route;
  }

  void collapse() {
    Navigator.of(context).pop();
  }

  void _scheduleSetState(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(callback);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(callback);
      });
    }
  }

  ButtonStyle get _resolvedCollapsedStyle =>
      _collapsedDefaults.merge(widget.collapsedStyle);
  ButtonStyle get _resolvedExpandedStyle =>
      _expandedDefaults.merge(widget.expandedStyle);

  @override
  void initState() {
    super.initState();

    _size = ValueNotifier(widget.size);
    _collapsedStyle = ValueNotifier(_resolvedCollapsedStyle);
    _expandedStyle = ValueNotifier(_resolvedExpandedStyle);
    _actions = ValueNotifier(widget.actions);
  }

  @override
  void didUpdateWidget(covariant ExpandableFloatingActionButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.size != oldWidget.size) {
      _size.value = widget.size;
    }
    if (widget.collapsedStyle != oldWidget.collapsedStyle) {
      _collapsedStyle.value = _resolvedCollapsedStyle;
    }
    if (widget.expandedStyle != oldWidget.expandedStyle) {
      _expandedStyle.value = _resolvedExpandedStyle;
    }
    if (!listEquals(widget.actions, oldWidget.actions)) {
      _actions.value = widget.actions;
    }
  }

  @override
  void dispose() {
    if (_route?.navigator != null) {
      _route?._remove();
    }
    _actions.dispose();
    _expandedStyle.dispose();
    _collapsedStyle.dispose();
    _size.dispose();
    super.dispose();
  }

  void _onPressed() {
    expand();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _anchorKey,
      child: Visibility.maintain(
        visible: _visible,
        child: _buildSizedFAB(
          key: _visible ? _stateKey : null,
          context: context,
          size: _size.value,
          onPressed: widget.onPressed ?? _onPressed,
          style: _collapsedStyle.value,
          child: const Icon(Symbols.add),
        ),
      ),
    );
  }
}

class _CollapsedFloatingActionButtonDefaultsM3 extends ButtonStyle {
  const _CollapsedFloatingActionButtonDefaultsM3()
    : super(animationDuration: Duration.zero);
}

class _ExpandedFloatingActionButtonDefaultsM3 extends ButtonStyle {
  const _ExpandedFloatingActionButtonDefaultsM3()
    : super(animationDuration: Duration.zero);

  @override
  WidgetStateProperty<Color?>? get shadowColor =>
      const WidgetStatePropertyAll(Colors.transparent);
}

class _ExpandableFloatingActionButtonRoute<T extends Object>
    extends PopupRoute<T> {
  _ExpandableFloatingActionButtonRoute({
    required this.anchorKey,
    required this.stateKey,
    this.onVisibilityChanged,
    required this.size,
    required this.expandedStyle,
    required this.collapsedStyle,
    required this.actions,
  });

  final GlobalKey anchorKey;
  final GlobalKey stateKey;
  final ValueChanged<bool>? onVisibilityChanged;

  final ValueNotifier<FloatingActionButtonSize> size;
  final ValueNotifier<ButtonStyle?> collapsedStyle;
  final ValueNotifier<ButtonStyle?> expandedStyle;
  final ValueNotifier<List<FloatingActionButtonAction<T>>> actions;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.32);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Durations.long4;

  bool _mounted = false;

  void _remove() {
    if (isActive) {
      navigator?.removeRoute(this);
    }
  }

  Rect? _getAnchorRect() {
    final context = anchorKey.currentContext;
    if (context == null) return null;

    final anchorBox = context.findRenderObject()! as RenderBox;
    final navigator = Navigator.of(context);
    return anchorBox.localToGlobal(
          Offset.zero,
          ancestor: navigator.context.findRenderObject(),
        ) &
        anchorBox.size;
  }

  Rect? _getNavigatorRect() {
    if (navigator == null) return null;
    final navigatorBox = navigator!.context.findRenderObject()! as RenderBox;
    return navigatorBox.localToGlobal(Offset.zero) & navigatorBox.size;
  }

  final Set<_Change> _changes = Set.from(_Change.values);

  void _scheduleSetState(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(callback);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(callback));
      // if (_mounted) setState(callback);
    }
  }

  void _onSizeChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.size);
    });
  }

  void _onCollapsedStyleChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.collapsedStyle);
    });
  }

  void _onExpandedStyleChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.expandedStyle);
    });
  }

  void _onActionsChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.actions);
    });
  }

  bool? _visible;
  void _animationListener() {
    final visible = !offstage && animation!.status != AnimationStatus.dismissed;
    if (_visible != visible) onVisibilityChanged?.call(visible);
    _visible = visible;
  }

  CurvedAnimation _curvedAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: Easing.linear,
  );

  final _buttonStyleTween = ButtonStyleTween();
  late Animation<ButtonStyle?> _buttonStyle;

  final List<_ActionData> _actionsData = [];

  void _updateState({
    required BuildContext context,
    required Animation<double> animation,
    required Set<_Change> changes,
  }) {
    List<_Stagger>? forwardStaggers;
    List<_Stagger>? reverseStaggers;
    if (_curvedAnimation.parent != animation) {
      _curvedAnimation.dispose();
      _curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Easing.emphasized,
        reverseCurve: Easing.emphasized.flipped,
      );

      _buttonStyle = _buttonStyleTween.animate(_curvedAnimation);

      forwardStaggers ??= _getForwardStaggers();
      reverseStaggers ??= _getReverseStaggers();
    }
    if (changes.contains(_Change.collapsedStyle)) {
      _buttonStyleTween.begin = collapsedStyle.value;
    }
    if (changes.contains(_Change.expandedStyle)) {
      _buttonStyleTween.end = expandedStyle.value;
    }
    if (changes.contains(_Change.actions)) {
      forwardStaggers ??= _getForwardStaggers();
      reverseStaggers ??= _getReverseStaggers();
      final forwardDuration = forwardStaggers.totalDuration;
      final reverseDuration = reverseStaggers.totalDuration;

      controller?.duration = forwardDuration;
      controller?.reverseDuration = reverseDuration;

      final actions = this.actions.value;
      if (_actionsData.length > actions.length) {
        _actionsData.removeRange(actions.length - 1, _actionsData.length);
      } else if (actions.length > _actionsData.length) {
        final range = actions.getRange(_actionsData.length, actions.length);
        for (final (index, action) in range.indexed) {
          final forwardStagger = forwardStaggers[index];
          final reverseStagger = reverseStaggers[index];
          final staggerAnimation = CurvedAnimation(
            parent: animation,
            curve: forwardStagger.toInterval(
              duration: forwardDuration,
              curve: Easing.emphasized,
            ),
            reverseCurve: reverseStagger.toInterval(
              duration: reverseDuration,
              curve: Easing.emphasized.flipped,
            ),
          );
          _actionsData.add(
            _ActionData(
              action: action,
              curvedAnimation: staggerAnimation,
              outerPadding: EdgeInsetsTween(
                begin: const EdgeInsets.only(right: 4),
                end: const EdgeInsets.symmetric(vertical: 2),
              ).animate(staggerAnimation),
              height: Tween<double>(
                begin: 48,
                end: 56,
              ).animate(staggerAnimation),
              opacity: Tween<double>(begin: 0, end: 1)
                  .chain(CurveTween(curve: const Interval(0, 0.5)))
                  .animate(staggerAnimation),
              innerPadding: EdgeInsetsTween(
                begin: const EdgeInsets.symmetric(horizontal: 12),
                end: const EdgeInsets.symmetric(horizontal: 16),
              ).animate(staggerAnimation),
              labelWidthFactor: Tween<double>(
                begin: 0,
                end: 1,
              ).animate(staggerAnimation),
              labelOffset: Tween<Offset>(
                begin: const Offset(-16, 0),
                end: Offset.zero,
              ).animate(staggerAnimation),
            ),
          );
        }
      }
    }
  }

  List<_Stagger> _getForwardStaggers() {
    const forwardDelay = Durations.short1;
    const forwardDuration = Durations.long4;
    final length = actions.value.length;
    return List.generate(
      length,
      (index) => _Stagger(
        delay: forwardDelay * index,
        // delay: forwardDelay * (length - index - 1),
        duration: forwardDuration,
      ),
    );
  }

  List<_Stagger> _getReverseStaggers() {
    const reverseDelay = Durations.short1;
    const reverseDuration = Durations.medium1;
    final length = actions.value.length;
    return List.generate(
      length,
      (index) => _Stagger(
        delay: reverseDelay * index,
        // delay: reverseDelay * (length - index - 1),
        duration: reverseDuration,
      ),
    );
  }

  @override
  void install() {
    super.install();
    _mounted = true;

    animation?.addListener(_animationListener);

    size.addListener(_onSizeChanged);
    collapsedStyle.addListener(_onCollapsedStyleChanged);
    expandedStyle.addListener(_onExpandedStyleChanged);
    actions.addListener(_onActionsChanged);
  }

  @override
  AnimationController createAnimationController() {
    assert(
      !debugTransitionCompleted(),
      "Cannot reuse a $runtimeType after disposing it.",
    );
    final forwardDuration = _getForwardStaggers().totalDuration;
    final reverseDuration = _getReverseStaggers().totalDuration;
    return AnimationController(
      duration: forwardDuration,
      reverseDuration: reverseDuration,
      debugLabel: debugLabel,
      vsync: navigator!,
    );
  }

  // @override
  // TickerFuture didPush() {
  //   onVisibilityChanged?.call(false);
  //   return super.didPush();
  // }

  @override
  void dispose() {
    actions.removeListener(_onActionsChanged);
    expandedStyle.removeListener(_onExpandedStyleChanged);
    collapsedStyle.removeListener(_onCollapsedStyleChanged);
    size.removeListener(_onSizeChanged);

    for (final data in _actionsData) {
      data.curvedAnimation.dispose();
    }
    _curvedAnimation.dispose();

    animation?.removeListener(_animationListener);

    _mounted = false;
    super.dispose();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Handle state changes
    _updateState(
      context: context,
      animation: animation,
      changes: Set.from(_changes),
    );
    _changes.clear();

    if (offstage) return const SizedBox.shrink();

    // Perform render object measures
    final anchorRect = _getAnchorRect()!;

    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);

    return IgnorePointer(
      ignoring: switch (animation.status) {
        AnimationStatus.dismissed || AnimationStatus.reverse => true,
        AnimationStatus.forward || AnimationStatus.completed => false,
      },
      child: CustomMultiChildLayout(
        delegate: _ExpandedFloatingActionButtonLayout(
          anchorId: _Slot.anchor,
          actionIds: List.generate(
            _actionsData.length,
            (index) => _Slot.action(index),
          ),
          textDirection: Directionality.of(context),
          anchorRect: anchorRect,
          avoidBounds:
              DisplayFeatureSubScreen.avoidBounds(
                MediaQuery.of(context),
              ).toSet(),
        ),
        children: [
          ..._actionsData.mapIndexed<Widget>(
            (index, data) => LayoutId(
              id: _Slot.action(index),
              child: SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: data.outerPadding.value,
                    child: SizedBox(
                      height: data.height.value,
                      child: Opacity(
                        opacity: data.opacity.value,
                        child: Material(
                          animationDuration: Duration.zero,
                          clipBehavior: Clip.antiAlias,
                          shape: Shapes.full,
                          color: theme.colorScheme.primary,
                          child: InkWell(
                            overlayColor: WidgetStateLayerColor(
                              theme.colorScheme.onPrimary,
                              opacity: stateTheme.stateLayerOpacity,
                            ),
                            onTap: () {},
                            child: Padding(
                              padding: data.innerPadding.value,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.translate(
                                    offset: data.labelOffset.value,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      widthFactor: data.labelWidthFactor.value,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: DefaultTextStyle.merge(
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                              ),
                                          child: data.action.label,
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconTheme.merge(
                                    data: IconThemeData(
                                      color: theme.colorScheme.onPrimary,
                                      size: 24,
                                    ),
                                    child: data.action.icon,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          LayoutId(
            id: _Slot.anchor,
            child: _buildSizedFAB(
              context: context,
              key: stateKey,
              size: size.value,
              onPressed: () {},
              style: _buttonStyle.value,
              child: const Icon(Symbols.close),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox.shrink();
  }
}

enum _Change { size, collapsedStyle, expandedStyle, actions }

@immutable
class _Stagger implements Comparable<_Stagger> {
  const _Stagger({this.delay = Duration.zero, this.duration = Duration.zero});

  final Duration delay;
  final Duration duration;

  Duration get totalDuration => delay + duration;

  Interval toInterval({
    required Duration duration,
    Curve curve = Easing.linear,
  }) {
    final start = delay.inMicroseconds / duration.inMicroseconds;
    final end = totalDuration.inMicroseconds / duration.inMicroseconds;
    return Interval(start, end, curve: curve);
  }

  CurveTween toTween({
    required Duration duration,
    Curve curve = Easing.linear,
  }) => CurveTween(curve: toInterval(duration: duration, curve: curve));

  @override
  int compareTo(_Stagger other) => totalDuration.compareTo(other.totalDuration);

  bool operator <(_Stagger other) => totalDuration < other.totalDuration;
  bool operator >(_Stagger other) => totalDuration > other.totalDuration;
  bool operator <=(_Stagger other) => totalDuration <= other.totalDuration;
  bool operator >=(_Stagger other) => totalDuration >= other.totalDuration;

  @override
  bool operator ==(Object other) {
    return other is _Stagger &&
        delay == other.delay &&
        duration == other.duration;
  }

  @override
  int get hashCode => Object.hash(delay, duration);
}

extension _StaggerDataIterable on Iterable<_Stagger> {
  Duration get totalDuration => maxOrNull?.totalDuration ?? Duration.zero;
}

class _ActionData {
  const _ActionData({
    required this.action,
    required this.curvedAnimation,
    required this.outerPadding,
    required this.opacity,
    required this.height,
    required this.innerPadding,
    required this.labelOffset,
    required this.labelWidthFactor,
  });

  final CurvedAnimation curvedAnimation;

  final FloatingActionButtonAction action;

  final Animation<EdgeInsetsGeometry> outerPadding;
  final Animation<double> height;
  final Animation<double> opacity;
  final Animation<EdgeInsetsGeometry> innerPadding;

  final Animation<Offset> labelOffset;
  final Animation<double> labelWidthFactor;
}

class _Action extends ButtonStyleButton {
  const _Action({
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
    required super.child,
  });

  @override
  ButtonStyle defaultStyleOf(BuildContext context) {
    final theme = Theme.of(context);
    return _ActionDefaultsM3(
      colors: theme.colorScheme,
      text: theme.textTheme,
      state: StateTheme.of(context),
    );
  }

  @override
  ButtonStyle? themeStyleOf(BuildContext context) => null;
}

class _ActionDefaultsM3 extends ButtonStyle {
  const _ActionDefaultsM3({
    required this.colors,
    required this.text,
    required this.state,
  }) : super(
         animationDuration: Duration.zero,
         enableFeedback: true,
         alignment: Alignment.centerRight,
         visualDensity: VisualDensity.standard,
         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
       );

  final ColorScheme colors;
  final TextTheme text;
  final StateThemeData state;

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStatePropertyAll(colors.primary);

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStatePropertyAll(colors.onPrimary);

  @override
  WidgetStateProperty<TextStyle?>? get textStyle =>
      WidgetStatePropertyAll(text.labelLarge);

  @override
  WidgetStateProperty<Color?>? get iconColor =>
      WidgetStatePropertyAll(colors.onPrimary);

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateLayerColor(colors.onPrimary, opacity: state.stateLayerOpacity);
  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor =>
      WidgetStateMouseCursor.clickable;

  @override
  WidgetStateProperty<EdgeInsetsGeometry?>? get padding =>
      const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16));

  @override
  WidgetStateProperty<OutlinedBorder?>? get shape =>
      const WidgetStatePropertyAll(Shapes.full);

  @override
  WidgetStateProperty<Color?>? get surfaceTintColor =>
      WidgetStateColor.transparent;

  @override
  WidgetStateProperty<double?>? get elevation =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Elevations.level3;
        }
        if (states.contains(WidgetState.hovered)) {
          return Elevations.level4;
        }
        if (states.contains(WidgetState.focused)) {
          return Elevations.level3;
        }
        return Elevations.level3;
      });

  @override
  WidgetStateProperty<Color?>? get shadowColor => WidgetStateColor.transparent;

  @override
  WidgetStateProperty<double?>? get iconSize =>
      const WidgetStatePropertyAll(24);

  @override
  WidgetStateProperty<Size?>? get minimumSize =>
      const WidgetStatePropertyAll(Size(56, 56));

  @override
  WidgetStateProperty<Size?>? get maximumSize =>
      const WidgetStatePropertyAll(Size.fromHeight(56));
}

MenuAnchor? a;

enum _SlotType { anchor, action }

sealed class _Slot {
  static const _Slot anchor = _AnchorSlot();
  const factory _Slot.action(int index) = _ActionSlot;

  _SlotType get type;

  @override
  bool operator ==(Object other) {
    return other is _Slot && type == other.type;
  }

  @override
  int get hashCode => type.hashCode;
}

class _AnchorSlot implements _Slot {
  const _AnchorSlot();

  @override
  _SlotType get type => _SlotType.anchor;

  @override
  bool operator ==(Object other) {
    return other is _AnchorSlot && type == other.type;
  }

  @override
  int get hashCode => type.hashCode;
}

class _ActionSlot implements _Slot {
  const _ActionSlot(this.index);

  final int index;

  @override
  _SlotType get type => _SlotType.action;

  @override
  bool operator ==(Object other) {
    return other is _ActionSlot && type == other.type && index == other.index;
  }

  @override
  int get hashCode => Object.hash(type, index);
}

class _ExpandedFloatingActionButtonLayout extends MultiChildLayoutDelegate {
  _ExpandedFloatingActionButtonLayout({
    this.anchorId,
    this.actionIds = const [],
    required this.textDirection,
    this.alignment = Alignment.topLeft,
    required this.anchorRect,
    required this.avoidBounds,
  }) : assert(
         (alignment is Alignment && alignment.x != 0 && alignment.y != 0) ||
             (alignment is AlignmentDirectional &&
                 alignment.start != 0 &&
                 alignment.y != 0),
         "Alignment must not be centered",
       );

  final Object? anchorId;
  final List<Object> actionIds;
  final TextDirection textDirection;
  final AlignmentGeometry alignment;
  final Rect anchorRect;
  final Set<Rect> avoidBounds;

  static const double _anchorGap = 8.0;
  static const double _actionGap = 4.0;

  @override
  void performLayout(Size size) {
    final rect = Offset.zero & size;
    if (anchorId != null && hasChild(anchorId!)) {
      layoutChild(anchorId!, BoxConstraints.tight(anchorRect.size));
      positionChild(anchorId!, anchorRect.topLeft);
    }

    if (actionIds.isEmpty) return;

    final actionConstraints = BoxConstraints(
      minWidth: anchorRect.width,
      maxWidth: double.infinity,
    );
    final ids = actionIds.where((id) => hasChild(id)).toList();
    final sizes = ids.map((id) => layoutChild(id, actionConstraints)).toList();

    final firstSize = sizes[0];

    final lastIndex = sizes.length - 1;
    final columnHeight = sizes.foldIndexed(0.0, (index, height, size) {
      final base = height + size.height;
      if (index == 0) return base + _anchorGap;
      if (index == lastIndex) return base;
      return base + _actionGap;
    });

    final resolvedAlignment = alignment.resolve(textDirection);
    _HorizontalPriority horizontal = resolvedAlignment.horizontalPriority!;
    _VerticalPriority vertical = resolvedAlignment.verticalPriority!;

    // final maxWidth = sizes.fold(
    //   0.0,
    //   (width, size) => size.width > width ? size.width : width,
    // );
    // final left = anchorRect.right - maxWidth;
    // final right = anchorRect.left + maxWidth;

    // switch (horizontal) {
    //   case _HorizontalPriority.left
    //       when left < rect.left && right <= rect.right:
    //     horizontal = _HorizontalPriority.right;
    //   case _HorizontalPriority.right
    //       when right > rect.right && left >= rect.left:
    //     horizontal = _HorizontalPriority.left;
    //   default:
    // }

    final bottom = anchorRect.bottom + columnHeight;
    final top = anchorRect.top - columnHeight;

    switch (vertical) {
      case _VerticalPriority.top when top < rect.top && bottom <= rect.bottom:
        vertical = _VerticalPriority.bottom;
      case _VerticalPriority.bottom
          when bottom > rect.bottom && top >= rect.top:
        vertical = _VerticalPriority.top;
      default:
    }

    double dy = switch (vertical) {
      _VerticalPriority.top => anchorRect.top - _anchorGap - firstSize.height,
      _VerticalPriority.bottom => anchorRect.bottom + _anchorGap,
    };
    // final Iterable<Object> resolvedIds = switch (vertical) {
    //   _VerticalPriority.top => ids.reversed,
    //   _VerticalPriority.bottom => ids,
    // };
    for (final (index, id) in ids.indexed) {
      final size = sizes[index];
      final double dx = switch (horizontal) {
        _HorizontalPriority.left => anchorRect.right - size.width,
        _HorizontalPriority.right => anchorRect.left,
      };
      positionChild(id, Offset(dx, dy));
      final delta = _actionGap + size.height;
      switch (vertical) {
        case _VerticalPriority.top:
          dy -= delta;
        case _VerticalPriority.bottom:
          dy += delta;
      }
    }
  }

  @override
  bool shouldRelayout(
    covariant _ExpandedFloatingActionButtonLayout oldDelegate,
  ) {
    return anchorId != oldDelegate.anchorId ||
        !listEquals(actionIds, oldDelegate.actionIds) ||
        textDirection != oldDelegate.textDirection ||
        alignment != oldDelegate.alignment ||
        anchorRect != oldDelegate.anchorRect ||
        !setEquals(avoidBounds, oldDelegate.avoidBounds);
  }
}

enum _HorizontalPriority {
  left,
  right;

  bool get isLeft => this == _HorizontalPriority.left;
  bool get isRight => this == _HorizontalPriority.right;
}

enum _VerticalPriority {
  top,
  bottom;

  bool get isTop => this == _VerticalPriority.top;
  bool get isBottom => this == _VerticalPriority.bottom;
}

extension _AlignmentPriority on Alignment {
  _HorizontalPriority? get horizontalPriority {
    if (x < 0) return _HorizontalPriority.left;
    if (x > 0) return _HorizontalPriority.right;
    return null;
  }

  _VerticalPriority? get verticalPriority {
    if (y < 0) return _VerticalPriority.top;
    if (y > 0) return _VerticalPriority.bottom;
    return null;
  }
}

class _AnchorLayout extends SingleChildLayoutDelegate {
  const _AnchorLayout({required this.anchorRect});
  final Rect anchorRect;

  @override
  bool shouldRelayout(covariant _AnchorLayout oldDelegate) {
    return anchorRect != oldDelegate.anchorRect;
  }
}

class _ActionsLayout extends SingleChildLayoutDelegate {
  const _ActionsLayout({required this.anchorRect});
  final Rect anchorRect;

  @override
  bool shouldRelayout(covariant _ActionsLayout oldDelegate) {
    return anchorRect != oldDelegate.anchorRect;
  }
}
