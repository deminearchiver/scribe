import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';
import 'package:painting/painting.dart';
import 'package:super_editor/super_editor.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _layoutKey = GlobalKey();
  final _listKey = GlobalKey();
  final _separatorKey = GlobalKey();
  final _detailKey = GlobalKey();

  int _selectedIndex = 0;
  bool _open = false;

  ModalRoute? _route;

  double? get _widthWithoutPadding {
    final renderBox =
        _layoutKey.currentContext?.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width;
    if (width == null) return null;
    return math.max(
      0.0,
      width - 48.0,
    ); // I guess separator width + right padding?
  }

  double _flex = 0.0;

  void _onDragStart(DragStartDetails details) {}
  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta! / _widthWithoutPadding! * 2;
    setState(() => _flex = clampDouble(_flex + delta, -1 / 3, 1 / 3));
  }

  Timer? _drawerCloseTimer;

  void _openDrawer() {
    _drawerCloseTimer?.cancel();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _closeDrawerWithDelay() {
    _drawerCloseTimer?.cancel();
    _drawerCloseTimer = Timer(
      Durations.short4,
      () => _scaffoldKey.currentState?.closeDrawer(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _drawerCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthSizeClass = WindowWidthSizeClass.of(context);
    final heightSizeClass = WindowHeightSizeClass.of(context);
    final theme = Theme.of(context);
    // const duration = Durations.long4;
    final duration = switch (theme.platform) {
      TargetPlatform.android || TargetPlatform.iOS => Durations.extralong2,
      _ => Durations.long2,
    };
    final curve = switch (theme.platform) {
      TargetPlatform.android || TargetPlatform.iOS => Easing.emphasized,
      _ => Easing.standard,
    };
    const destinations = <AdaptiveDestination<int>>[
      AdaptiveDestination(
        value: 0,

        icon: Icon(Symbols.home, fill: 0),
        selectedIcon: Icon(Symbols.home, fill: 1),
        label: "Home",
      ),
      AdaptiveDestination(
        value: 1,

        icon: Icon(Symbols.notifications, fill: 0),
        selectedIcon: Icon(Symbols.notifications, fill: 1),
        label: "Reminders",
      ),
      AdaptiveDestination(
        value: 2,

        icon: Icon(Symbols.settings, fill: 0),
        selectedIcon: Icon(Symbols.settings, fill: 1),
        label: "Settings",
      ),
    ];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surfaceContainer,
      drawer: DrawerTheme(
        data: const DrawerThemeData(width: 360),
        child: NavigationDrawer(
          onDestinationSelected: (value) {
            if (_selectedIndex == value) return;
            _closeDrawerWithDelay();
            setState(() => _selectedIndex = value);
          },
          selectedIndex: _selectedIndex,
          children: [
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12 + 8),
              child: Flex.horizontal(
                children: [
                  Icon(
                    Symbols.gesture_rounded,
                    size: 48,
                    opticalSize: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const Gap(8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Scribe",
                          style: theme.textTheme.headlineMedium!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            ...destinations.toNavigationDrawerDestinations(),
          ],
        ),
      ),
      body: Flex.horizontal(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedOpacity(
            duration: duration,
            curve: curve,
            opacity:
                widthSizeClass >= WindowWidthSizeClass.expanded ? 1.0 : 0.0,
            child: AnimatedAlign(
              duration: duration,
              curve: curve,
              alignment: Alignment.centerRight,
              widthFactor:
                  widthSizeClass >= WindowWidthSizeClass.expanded ? 1.0 : 0.0,
              child: NavigationRail(
                onDestinationSelected:
                    (value) => setState(() => _selectedIndex = value),
                selectedIndex: _selectedIndex,
                groupAlignment: -0.75, // Eye-balled to be roughly in the middle
                labelType: NavigationRailLabelType.all,
                backgroundColor: theme.colorScheme.surfaceContainer,
                // NavigationRail already has 8dp top padding
                leading: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Flex.vertical(
                    children: [
                      IconButton(
                        onPressed: _openDrawer,
                        icon: const Icon(Symbols.menu),
                      ),
                      const Gap(12),
                      FloatingActionButton(
                        onPressed: () => setState(() => _open = !_open),
                        style: const ButtonStyle(
                          shadowColor: WidgetStateColor.transparent,
                        ),
                        child: const Icon(Symbols.add),
                      ),
                    ],
                  ),
                ),
                destinations: [...destinations.toNavigationRailDestinations()],
              ),
            ),
          ),
          Expanded(
            child: ClipRect(
              child: AnimatedPaneLayout(
                key: _layoutKey,
                duration: duration,
                curve: curve,

                shift:
                    widthSizeClass <= WindowWidthSizeClass.medium
                        ? _open
                            ? -1.0
                            : 1.0
                        : 0.0,
                // shift: 0,
                flex: _flex,
                padding:
                    widthSizeClass <= WindowWidthSizeClass.compact
                        ? EdgeInsets.zero
                        : widthSizeClass <= WindowWidthSizeClass.medium
                        ? const EdgeInsets.fromLTRB(24, 24, 24, 0)
                        : const EdgeInsets.fromLTRB(0, 24, 24, 24),
                // separator: Container(
                //   color: Colors.green.withValues(alpha: 0.5),
                //   width: 8,
                // ),
                // list: Container(color: Colors.red),
                // detail: Container(color: Colors.blue),
                separator: KeyedSubtree(
                  key: _separatorKey,
                  child: SizedBox(
                    width: 24,
                    child: DragHandle(
                      onDragStart: _onDragStart,
                      onDragUpdate: _onDragUpdate,
                    ),
                  ),
                ),

                list: KeyedSubtree(
                  key: _listKey,
                  child: AnimatedOpacity(
                    duration: duration,
                    curve: curve,
                    opacity:
                        widthSizeClass <= WindowWidthSizeClass.medium
                            ? _open
                                ? 0.0
                                : 1.0
                            : 1.0,
                    child: AnimatedPane(
                      duration: duration,
                      curve: curve,
                      shape:
                          widthSizeClass <= WindowWidthSizeClass.compact
                              ? Shapes.none
                              : Shapes.medium,
                      child: CustomScrollView(
                        scrollBehavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(
                          dragDevices: {
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.touch,
                          },
                        ),
                        slivers: [
                          SliverPersistentHeader(
                            pinned: false,
                            floating: true,
                            delegate: _SliverAppBar(),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList.separated(
                              separatorBuilder: (context, index) => Gap(8),
                              itemBuilder:
                                  (context, index) => _Card(
                                    selected: index == 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      child: Flex.vertical(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            "Lorem ipsum",
                                            style: theme.textTheme.titleMedium!
                                                .copyWith(
                                                  color:
                                                      index == 1
                                                          ? theme
                                                              .colorScheme
                                                              .onSecondaryContainer
                                                          : theme
                                                              .colorScheme
                                                              .onSurface,
                                                ),
                                          ),
                                          Text(
                                            "Dolore duis consectetur Lorem nostrud commodo aliqua ad. Aute aliquip laborum amet minim est aute irure laborum. Sunt velit excepteur ex ad amet minim magna.",
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: theme.textTheme.bodyMedium!
                                                .copyWith(
                                                  color:
                                                      index == 1
                                                          ? theme
                                                              .colorScheme
                                                              .onSecondaryContainer
                                                          : theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                detail: KeyedSubtree(
                  key: _detailKey,
                  child: AnimatedOpacity(
                    duration: duration,
                    curve: curve,
                    opacity:
                        _open
                            ? 1.0
                            : widthSizeClass <= WindowWidthSizeClass.medium
                            ? 0.0
                            : 1.0,
                    // child: AnimatedPane(
                    //   duration: duration,
                    //   curve: curve,
                    //   shape: Shapes.medium,
                    //   child: CustomScrollView(),
                    // ),
                    child: AnimatedSwitcher(
                      duration: Durations.long4,
                      reverseDuration: Durations.short3,
                      // switchInCurve: const Interval(0.5, 1),
                      // switchOutCurve: const Interval(0.5, 1),
                      switchOutCurve: Easing.emphasizedAccelerate.flipped,
                      switchInCurve: const Interval(
                        0.2,
                        1,
                        curve: Easing.emphasized,
                      ),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.9,
                              end: 1,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(_open),
                        child:
                            _open
                                ? AnimatedPane(
                                  duration: duration,
                                  curve: curve,
                                  shape:
                                      widthSizeClass <=
                                              WindowWidthSizeClass.compact
                                          ? Shapes.none
                                          : Shapes.medium,
                                  child: CustomScrollView(),
                                )
                                // : AspectRatio(
                                //   aspectRatio: 1,
                                //   child: DecoratedBox(
                                //     decoration: ShapeDecoration(
                                //       shape: PathBorder(
                                //         path: ShapePaths.pill(false),
                                //         side: BorderSide(
                                //           color:
                                //               theme.colorScheme.outlineVariant,
                                //         ),
                                //       ),
                                //     ),
                                //     child: Center(
                                //       child: Text(
                                //         "Select something first",
                                //         style: theme.textTheme.bodyLarge!
                                //             .copyWith(
                                //               color:
                                //                   theme
                                //                       .colorScheme
                                //                       .onSurfaceVariant,
                                //             ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                : Flex.vertical(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox.square(
                                      dimension: 112,
                                      child: Material(
                                        color:
                                            theme
                                                .colorScheme
                                                .secondaryContainer,
                                        shape: PathBorder(
                                          path: ShapePaths.pill(false),
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    Text(
                                      "Select something first",
                                      style: theme.textTheme.bodyLarge!
                                          .copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
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
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton:
          widthSizeClass <= WindowWidthSizeClass.medium
              ? FloatingActionButton(
                onPressed: () {},
                child: const Icon(Symbols.add),
              )
              : null,
      bottomNavigationBar: AnimatedOpacity(
        duration: duration,
        curve: curve,
        opacity: widthSizeClass <= WindowWidthSizeClass.medium ? 1.0 : 0.0,
        child: AnimatedAlign(
          duration: duration,
          curve: curve,
          alignment: Alignment.topCenter,
          heightFactor:
              widthSizeClass <= WindowWidthSizeClass.medium ? 1.0 : 0.0,
          child: NavigationBar(
            onDestinationSelected:
                (value) => setState(() => _selectedIndex = value),
            selectedIndex: _selectedIndex,
            destinations: [...destinations.toNavigationBarDestinations()],
          ),
        ),
      ),
    );
  }
}

// enum _AdaptiveFABLocationPosition { screen, pane, navigationRail }

// class _AdaptiveFABLocation extends FloatingActionButtonLocation {
//   const _AdaptiveFABLocation();

//   @override
//   Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
//     // TODO: implement getOffset
//     throw UnimplementedError();
//   }
// }

// class _ExpressiveFABAnimator extends FloatingActionButtonAnimator {
//   const _ExpressiveFABAnimator();

//   @override
//   Offset getOffset({
//     required Offset begin,
//     required Offset end,
//     required double progress,
//   }) {
//     if (progress < 0.5) {
//       return begin;
//     } else {
//       return end;
//     }
//   }

//   @override
//   Animation<double> getScaleAnimation({required Animation<double> parent}) {
//     return parent.drive(CurveTween(curve: Easing.emphasized));
//     // // Animate the scale down from 1 to 0 in the first half of the animation
//     // // then from 0 back to 1 in the second half.
//     // const Curve curve = Interval(0.5, 1.0, curve: Curves.ease);
//     // return _AnimationSwap<double>(
//     //   ReverseAnimation(parent.drive(CurveTween(curve: curve.flipped))),
//     //   parent.drive(CurveTween(curve: curve)),
//     //   parent,
//     //   0.5,
//     // );
//   }

//   // Because we only see the last half of the rotation tween,
//   // it needs to go twice as far.
//   static final Animatable<double> _rotationTween = Tween<double>(
//     begin: 1.0 - kFloatingActionButtonTurnInterval * 2.0,
//     end: 1.0,
//   );

//   static final Animatable<double> _thresholdCenterTween = CurveTween(
//     curve: const Threshold(0.5),
//   );

//   @override
//   Animation<double> getRotationAnimation({required Animation<double> parent}) {
//     // This rotation will turn on the way in, but not on the way out.
//     return _AnimationSwap<double>(
//       parent.drive(_rotationTween),
//       ReverseAnimation(parent.drive(_thresholdCenterTween)),
//       parent,
//       0.5,
//     );
//   }

//   // If the animation was just starting, we'll continue from where we left off.
//   // If the animation was finishing, we'll treat it as if we were starting at that point in reverse.
//   // This avoids a size jump during the animation.
//   @override
//   double getAnimationRestart(double previousValue) =>
//       math.min(1.0 - previousValue, previousValue);
// }

class DragHandle extends StatefulWidget {
  const DragHandle({
    super.key,
    this.onDragDown,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
  });

  final void Function(DragDownDetails details)? onDragDown;
  final void Function(DragStartDetails details)? onDragStart;
  final void Function(DragUpdateDetails details)? onDragUpdate;
  final void Function(DragEndDetails details)? onDragEnd;
  final void Function()? onDragCancel;

  @override
  State<DragHandle> createState() => _DragHandleState();
}

class _DragHandleState extends State<DragHandle> {
  late WidgetStatesController _statesController;

  @override
  void initState() {
    super.initState();
    _statesController =
        WidgetStatesController()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  void _onDragDown(DragDownDetails details) {
    widget.onDragDown?.call(details);
    _statesController.update(WidgetState.pressed, true);
  }

  void _onDragStart(DragStartDetails details) {
    _statesController.update(WidgetState.dragged, true);
    widget.onDragStart?.call(details);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    widget.onDragUpdate?.call(details);
  }

  void _onDragEnd(DragEndDetails details) {
    _statesController.update(WidgetState.dragged, false);
    _statesController.update(WidgetState.pressed, false);
    widget.onDragEnd?.call(details);
  }

  void _onDragCancel() {
    _statesController.update(WidgetState.pressed, false);
    widget.onDragCancel?.call();
  }

  WidgetStateProperty<Size> get _size =>
      WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.dragged)) {
          return const Size(8, 40);
        }
        if (states.contains(WidgetState.hovered)) {}
        return const Size(4, 32);
      });

  WidgetStateMouseCursor get _mouseCursor =>
      WidgetStateMouseCursor.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.dragged)) {
          return SystemMouseCursors.resizeColumn;
        }
        return SystemMouseCursors.basic;
      });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final WidgetStateProperty<Color> color = WidgetStateProperty.resolveWith((
      states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return theme.colorScheme.onSurface;
      }
      if (states.contains(WidgetState.hovered)) {
        return theme.colorScheme.onSurfaceVariant;
      }
      return theme.colorScheme.onSurfaceVariant.withAlpha(0);
    });
    final resolvedColor = color.resolve(_statesController.value);
    final resolvedSize = _size.resolve(_statesController.value);
    return MouseRegion(
      cursor: _mouseCursor.resolve(_statesController.value),
      onEnter: (event) => _statesController.update(WidgetState.hovered, true),
      onExit: (event) => _statesController.update(WidgetState.hovered, false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onHorizontalDragDown: _onDragDown,
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onHorizontalDragCancel: _onDragCancel,
        child: Center(
          child: _DragHandleIndicator(
            duration: Durations.short4,
            curve: Easing.standard,
            size: resolvedSize,
            color: resolvedColor,
          ),
        ),
      ),
    );
  }
}

class _DragHandleIndicator extends ImplicitlyAnimatedWidget {
  const _DragHandleIndicator({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.size,
    required this.color,
  });

  final Size size;
  final Color color;

  @override
  ImplicitlyAnimatedWidgetState<_DragHandleIndicator> createState() =>
      _DragHandleIndicatorState();
}

class _DragHandleIndicatorState
    extends AnimatedWidgetBaseState<_DragHandleIndicator> {
  Tween<Size>? _sizeTween;
  Tween<Color?>? _colorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _sizeTween =
        visitor(
              _sizeTween,
              widget.size,
              (value) => Tween<Size>(begin: value as Size),
            )
            as Tween<Size>?;
    _colorTween =
        visitor(
              _colorTween,
              widget.color,
              (value) => ColorTween(begin: value as Color?),
            )
            as Tween<Color?>?;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: _sizeTween?.evaluate(animation) ?? widget.size,
      child: Material(
        animationDuration: Duration.zero,
        clipBehavior: Clip.none,
        shape: Shapes.full,
        color: _colorTween?.evaluate(animation) ?? widget.color,
      ),
    );
  }
}

class _SliverAppBar extends SliverPersistentHeaderDelegate {
  const _SliverAppBar();
  @override
  double get minExtent => 88;

  @override
  double get maxExtent => 88;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        // Positioned(
        //   left: 0,
        //   top: 0,
        //   right: 0,
        //   height: 44,
        //   child: Material(animationDuration: Duration.zero),
        // ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [44 / 88, 1],
                // stops: const [72 / 88, 1],
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withAlpha(0),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SearchBar(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.only(left: 16, right: 16),
            ),
            shadowColor: WidgetStateColor.transparent,
            leading: const Icon(Symbols.search),
            hintText: "Search your notes",
          ),
        ),
      ],
    );
  }
}

class _Card extends StatefulWidget {
  const _Card({super.key, this.selected = false, this.child});

  final bool selected;
  final Widget? child;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  late WidgetStatesController _statesController;

  late WidgetStateProperty<Color> _backgroundColor;
  late WidgetStateProperty<Color> _overlayColor;
  late WidgetStateProperty<BorderSide> _side;
  late WidgetStateProperty<TextStyle> _headlineTextStyle;
  late WidgetStateProperty<TextStyle> _contentTextStyle;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController({
      if (widget.selected) WidgetState.selected,
    })..addListener(() {
      if (!mounted) return;
      if (SchedulerBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {}));
      } else {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return theme.colorScheme.secondaryContainer;
      }
      return theme.colorScheme.surface;
    });
    _overlayColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return theme.colorScheme.onSecondaryContainer;
      }
      return theme.colorScheme.onSurface;
    });
    _side = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return BorderSide(width: 3.0, color: theme.colorScheme.secondary);
      }
      if (states.contains(WidgetState.selected)) {
        return BorderSide.none;
      }
      return BorderSide(width: 1.0, color: theme.colorScheme.outlineVariant);
    });
    _headlineTextStyle = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return theme.textTheme.titleMedium!.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        );
      }
      return theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurface,
      );
    });
    _contentTextStyle = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        );
      }
      return theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _Card oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _statesController.update(WidgetState.selected, widget.selected);
    }
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);

    final states = _statesController.value;
    final backgroundColor = _backgroundColor.resolve(states);
    final overlayColor = _overlayColor.resolve(states);
    final side = _side.resolve(states);
    final headlineTextStyle = _headlineTextStyle.resolve(states);
    final contentTextStyle = _contentTextStyle.resolve(states);

    return Material(
      animationDuration: Duration.zero,
      clipBehavior: Clip.antiAlias,
      type: MaterialType.card,
      color: backgroundColor,
      shape: Shapes.medium.copyWith(side: side),
      child: InkWell(
        onTap: () {},
        statesController: _statesController,
        overlayColor: WidgetStateLayerColor(
          overlayColor,
          opacity: stateTheme.stateLayerOpacity,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Flex.vertical(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Lorem ipsum dolor",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: headlineTextStyle,
              ),
              const Gap(4.0),
              Text(
                "Laboris laborum esse nostrud ea non pariatur laboris mollit officia commodo ipsum quis laboris. Est ut anim occaecat in. Sunt dolore pariatur nulla minim fugiat dolor veniam. Excepteur veniam in laboris sunt Lorem.",
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: contentTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedPane extends ImplicitlyAnimatedWidget {
  const AnimatedPane({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    this.color,
    this.shape,
    this.child,
  });

  final Color? color;
  final ShapeBorder? shape;

  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedPane> createState() =>
      _AnimatedPaneState();
}

class _AnimatedPaneState extends AnimatedWidgetBaseState<AnimatedPane> {
  Tween<Color?>? _colorTween;
  Tween<ShapeBorder?>? _shapeTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween =
        visitor(
              _colorTween,
              widget.color,
              (value) => ColorTween(begin: value as Color?),
            )
            as Tween<Color?>?;
    _shapeTween =
        visitor(
              _shapeTween,
              widget.shape,
              (value) => ShapeBorderTween(begin: value as ShapeBorder?),
            )
            as Tween<ShapeBorder?>?;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      animationDuration: Duration.zero,
      clipBehavior: Clip.antiAlias,
      color: _colorTween?.evaluate(animation) ?? widget.color,
      shape: _shapeTween?.evaluate(animation) ?? widget.shape,
      child: widget.child,
    );
  }
}

class AnimatedPaneLayout extends ImplicitlyAnimatedWidget {
  const AnimatedPaneLayout({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    this.shift = 0.0,
    this.flex = 0.0,
    this.padding = EdgeInsets.zero,
    required this.list,
    this.separator,
    required this.detail,
  });

  final double shift;
  final double flex;
  final EdgeInsets padding;

  final Widget list;
  final Widget? separator;
  final Widget detail;

  @override
  ImplicitlyAnimatedWidgetState<AnimatedPaneLayout> createState() =>
      _AnimatedPaneLayoutState();
}

class _AnimatedPaneLayoutState
    extends AnimatedWidgetBaseState<AnimatedPaneLayout> {
  Tween<double>? _shiftTween;
  Tween<double>? _flexTween;
  Tween<EdgeInsets>? _paddingTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shiftTween =
        visitor(
              _shiftTween,
              widget.shift,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    // _flexTween =
    //     visitor(
    //           _flexTween,
    //           widget.flex,
    //           (value) => Tween<double>(begin: value as double),
    //         )
    //         as Tween<double>?;
    _paddingTween =
        visitor(
              _paddingTween,
              widget.padding,
              (value) => EdgeInsetsTween(begin: value as EdgeInsets),
            )
            as Tween<EdgeInsets>?;
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _PaneLayoutDelegate(
        shift: _shiftTween?.evaluate(animation) ?? widget.shift,
        flex: _flexTween?.evaluate(animation) ?? widget.flex,
        padding: _paddingTween?.evaluate(animation) ?? widget.padding,
      ),
      children: [
        LayoutId(id: _PaneSlot.list, child: widget.list),
        LayoutId(id: _PaneSlot.detail, child: widget.detail),
        if (widget.separator != null)
          LayoutId(id: _PaneSlot.separator, child: widget.separator!),
      ],
    );
  }
}

enum _PaneSlot { list, separator, detail }

class _PaneLayoutDelegate extends MultiChildLayoutDelegate {
  _PaneLayoutDelegate({
    this.flex = 0.0,
    this.shift = 0.0,
    this.padding = EdgeInsets.zero,
  }) : assert(flex >= -1 && flex <= 1);

  final double flex;
  final double shift;
  final EdgeInsets padding;

  // @override
  // void performLayout(Size size) {
  //   final rect = Rect.fromLTRB(
  //     padding.left,
  //     padding.top,
  //     size.width - padding.right,
  //     size.height - padding.bottom,
  //   );

  //   Size separatorSize = Size(0.0, rect.height);
  //   if (hasChild(_PaneSlot.separator)) {
  //     separatorSize = layoutChild(
  //       _PaneSlot.separator,
  //       BoxConstraints(minHeight: rect.height, maxHeight: rect.height),
  //     );
  //   }

  //   final tFlex = (flex + 1.0) / 2.0;
  //   final tFlexList = clampDouble(flex, 0.0, 1.0);
  //   final tFlexDetail = 1.0 - clampDouble(flex, -1.0, 0.0) - 1.0;
  //   final tShift = (shift + 1.0) / 2.0;
  //   final tShiftList = clampDouble(shift, 0.0, 1.0);
  //   final tShiftDetail = 1.0 - clampDouble(shift, -1.0, 0.0) - 1.0;
  //   final spacing =
  //       lerpDouble(separatorSize.width, 0.0, tShiftList + tShiftDetail)!;

  //   final availableWidth = rect.width - spacing;

  //   final listWidth =
  //       lerpDouble(
  //         lerpDouble(0.0, availableWidth, tFlex)!,
  //         rect.width,
  //         tShiftList,
  //       )!;

  //   final detailWidth =
  //       lerpDouble(
  //         lerpDouble(availableWidth, 0.0, tFlex)!,
  //         rect.width,
  //         tShiftDetail,
  //       )!;

  //   final listOffset = Offset(
  //     rect.left -
  //         lerpDouble(0.0, listWidth, tShiftDetail)! -
  //         lerpDouble(0, math.max(padding.left, spacing), tShiftDetail)!,
  //     rect.top,
  //   );
  //   final detailOffset = Offset(
  //     rect.left +
  //         lerpDouble(listWidth, 0.0, tShiftDetail)! +
  //         // lerpDouble(spacing, spacing + padding.right, tList)!,
  //         lerpDouble(
  //           lerpDouble(spacing, math.max(spacing, padding.right), tShiftList)!,
  //           0,
  //           tShiftDetail,
  //         )!,
  //     rect.top,
  //   );

  //   final separatorOffset = Offset(
  //     lerpDouble(
  //       detailOffset.dx,
  //       listOffset.dx + listWidth - separatorSize.width,
  //       tShift,
  //     )!,
  //     rect.top,
  //   );

  //   if (hasChild(_PaneSlot.separator)) {
  //     positionChild(_PaneSlot.separator, separatorOffset);
  //   }

  //   if (hasChild(_PaneSlot.list)) {
  //     layoutChild(
  //       _PaneSlot.list,
  //       BoxConstraints(
  //         minWidth: listWidth,
  //         maxWidth: listWidth,
  //         minHeight: rect.height,
  //         maxHeight: rect.height,
  //       ),
  //     );
  //     positionChild(_PaneSlot.list, listOffset);
  //   }

  //   if (hasChild(_PaneSlot.detail)) {
  //     layoutChild(
  //       _PaneSlot.detail,
  //       BoxConstraints(
  //         minWidth: detailWidth,
  //         maxWidth: detailWidth,
  //         minHeight: rect.height,
  //         maxHeight: rect.height,
  //       ),
  //     );
  //     positionChild(_PaneSlot.detail, detailOffset);
  //   }
  // }

  @override
  void performLayout(Size size) {
    final hasSeparator = hasChild(_PaneSlot.separator);
    final hasList = hasChild(_PaneSlot.list);
    final hasDetail = hasChild(_PaneSlot.detail);

    final flexFraction = (flex + 1.0) / 2.0;
    final flexListFraction = clampDouble(flex, 0.0, 1.0);
    final flexDetailFraction = 1.0 - clampDouble(flex, -1.0, 0.0) - 1.0;
    final shiftFraction = (shift + 1.0) / 2.0;
    final shiftListFraction = clampDouble(shift, 0.0, 1.0);
    final shiftDetailFraction = 1.0 - clampDouble(shift, -1.0, 0.0) - 1.0;

    final paddingRect = padding.deflateRect(Offset.zero & size);

    double separatorWidth = 0.0;
    if (hasSeparator) {
      final separatorSize = layoutChild(
        _PaneSlot.separator,
        BoxConstraints(
          maxWidth: paddingRect.width,
          minHeight: paddingRect.height,
          maxHeight: paddingRect.height,
        ),
      );
      separatorWidth = separatorSize.width;
    }

    final width = paddingRect.width - separatorWidth;

    final doubleSeparatorWidth = separatorWidth * 2;
    // double listWidth =
    //     lerpDouble(
    //       lerpDouble(0.0, width, flexFraction)!,
    //       paddingRect.width,
    //       shiftListFraction,
    //     )!;

    // double detailWidth =
    //     lerpDouble(
    //       lerpDouble(width, 0.0, flexFraction)!,
    //       paddingRect.width,
    //       shiftDetailFraction,
    //     )!;
    double listFlexWidth = lerpDouble(0.0, width, flexFraction)!;

    double detailFlexWidth = lerpDouble(width, 0.0, flexFraction)!;

    double listWidthCorrection = 0.0;
    final listDelta = paddingRect.width - listFlexWidth;
    if (listDelta <= doubleSeparatorWidth) {
      listWidthCorrection =
          lerpDouble(
            0.0,
            doubleSeparatorWidth,
            1.0 - listDelta / doubleSeparatorWidth,
          )!;
    }

    double detailWidthCorrection = 0.0;
    final detailDelta = paddingRect.width - detailFlexWidth;
    if (detailDelta <= doubleSeparatorWidth) {
      detailWidthCorrection =
          lerpDouble(
            0.0,
            doubleSeparatorWidth,
            1.0 - detailDelta / doubleSeparatorWidth,
          )!;
    }
    listFlexWidth += listWidthCorrection;
    detailFlexWidth += detailWidthCorrection;

    final listWidth =
        lerpDouble(listFlexWidth, paddingRect.width, shiftListFraction)!;
    final detailWidth =
        lerpDouble(detailFlexWidth, paddingRect.width, shiftDetailFraction)!;

    final listFlexX = paddingRect.left;
    final detailFlexX =
        listFlexX +
        listWidth +
        separatorWidth -
        detailWidthCorrection -
        listWidthCorrection;

    final listShiftX =
        lerpDouble(0.0, -listWidth, shiftDetailFraction)! +
        lerpDouble(0.0, -padding.left - separatorWidth, shiftDetailFraction)!;
    final detailShiftX =
        lerpDouble(0.0, padding.right, shiftListFraction)! +
        lerpDouble(0.0, -listWidth - separatorWidth, shiftDetailFraction)!;

    // final separatorFlexX =
    //     lerpDouble(
    //       paddingRect.left,
    //       paddingRect.right - separatorWidth,
    //       flexFraction,
    //     )!;
    final separatorFlexX = listWidth + listFlexX - listWidthCorrection;
    final separatorShiftX =
        lerpDouble(
          0.0,
          -listWidth - padding.left - separatorWidth,
          shiftDetailFraction,
        )! +
        lerpDouble(0.0, padding.right, shiftListFraction)!;

    final listX = listFlexX + listShiftX;
    final detailX = detailFlexX + detailShiftX;
    final separatorX = separatorFlexX + separatorShiftX;
    // final separatorX = switch (shift) {
    //   > 0.0 => lerpDouble(separatorFlexX, size.width, shiftListFraction)!,
    //   < 0.0 =>
    //     lerpDouble(separatorFlexX, -separatorWidth, shiftDetailFraction)!,
    //   _ => separatorFlexX,
    // };

    if (hasSeparator) {
      positionChild(_PaneSlot.separator, Offset(separatorX, paddingRect.top));
    }

    if (hasList && hasDetail) {
      layoutChild(
        _PaneSlot.list,
        BoxConstraints.tightFor(width: listWidth, height: paddingRect.height),
      );
      layoutChild(
        _PaneSlot.detail,
        BoxConstraints.tightFor(width: detailWidth, height: paddingRect.height),
      );

      positionChild(_PaneSlot.list, Offset(listX, paddingRect.top));
      positionChild(_PaneSlot.detail, Offset(detailX, paddingRect.top));
    } else if (hasList) {
      layoutChild(_PaneSlot.list, BoxConstraints.tight(paddingRect.size));
      positionChild(_PaneSlot.list, paddingRect.topLeft);
    } else if (hasDetail) {
      layoutChild(_PaneSlot.detail, BoxConstraints.tight(paddingRect.size));
      positionChild(_PaneSlot.detail, paddingRect.topLeft);
    } else {}
  }

  @override
  bool shouldRelayout(covariant _PaneLayoutDelegate oldDelegate) {
    return shift != oldDelegate.shift ||
        flex != oldDelegate.flex ||
        padding != oldDelegate.padding;
  }
}

class AdaptiveDestination<T extends Object> {
  const AdaptiveDestination({
    required this.value,
    this.enabled = true,
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  final T value;

  final bool enabled;
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

  NavigationDestination toNavigationBarDestination() => NavigationDestination(
    enabled: enabled,
    icon: icon,
    selectedIcon: selectedIcon,
    label: label,
  );
  NavigationRailDestination toNavigationRailDestination() =>
      NavigationRailDestination(
        disabled: !enabled,
        icon: icon,
        selectedIcon: selectedIcon,
        label: Text(label),
      );
  NavigationDrawerDestination toNavigationDrawerDestination() =>
      NavigationDrawerDestination(
        enabled: enabled,
        icon: icon,
        selectedIcon: selectedIcon,
        label: Text(label),
      );
}

extension Ext<T extends Object> on Iterable<AdaptiveDestination<T>> {
  Iterable<NavigationDestination> toNavigationBarDestinations() {
    return map((destination) => destination.toNavigationBarDestination());
  }

  Iterable<NavigationRailDestination> toNavigationRailDestinations() {
    return map((destination) => destination.toNavigationRailDestination());
  }

  Iterable<NavigationDrawerDestination> toNavigationDrawerDestinations() {
    return map((destination) => destination.toNavigationDrawerDestination());
  }
}
