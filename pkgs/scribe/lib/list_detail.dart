import 'dart:ui' show clampDouble, lerpDouble;

import 'package:gap/gap.dart';
import 'package:material/material.dart';

class ListDetailDestination {
  const ListDetailDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  final Icon icon;
  final Icon? selectedIcon;
  final String label;
}

extension _ListDetailDestinationExtension on ListDetailDestination {
  NavigationDestination get navigationBarDestination => NavigationDestination(
    icon: icon,
    selectedIcon: selectedIcon,
    label: label,
  );
  NavigationRailDestination get navigationRailDestination =>
      NavigationRailDestination(
        icon: icon,
        selectedIcon: selectedIcon,
        label: Text(label),
      );
  NavigationDrawerDestination get navigationDrawerDestination =>
      NavigationDrawerDestination(
        icon: icon,
        selectedIcon: selectedIcon,
        label: Text(label),
      );
}

extension _ListDetailDestinationIterable on Iterable<ListDetailDestination> {
  Iterable<NavigationDestination> toNavigationBarDestinations() {
    return map((destination) => destination.navigationBarDestination);
  }

  Iterable<NavigationRailDestination> toNavigationRailDestinations() {
    return map((destination) => destination.navigationRailDestination);
  }

  Iterable<NavigationDrawerDestination> toNavigationDrawerDestinations() {
    return map((destination) => destination.navigationDrawerDestination);
  }
}

const List<ListDetailDestination> _destinations = <ListDetailDestination>[
  ListDetailDestination(
    icon: Icon(Symbols.home, fill: 0),
    selectedIcon: Icon(Symbols.home, fill: 1),
    label: "Home",
  ),
  ListDetailDestination(
    icon: Icon(Symbols.notifications, fill: 0),
    selectedIcon: Icon(Symbols.notifications, fill: 1),
    label: "Reminders",
  ),
  ListDetailDestination(
    icon: Icon(Symbols.settings, fill: 0),
    selectedIcon: Icon(Symbols.settings, fill: 1),
    label: "Settings",
  ),
];

class ListDetail extends StatefulWidget {
  const ListDetail({super.key});

  @override
  State<ListDetail> createState() => _ListDetailState();
}

class _ListDetailState extends State<ListDetail> {
  _ListDetailVisibility _visibility = _ListDetailVisibility.list;

  Widget _buildAnimatedAlign({
    required Duration duration,
    Curve curve = Easing.linear,
    required double opacity,
    required AlignmentGeometry alignment,
    double? widthFactor,
    double? heightFactor,
    required Widget child,
  }) {
    return AnimatedOpacity(
      duration: duration,
      curve: curve,
      opacity: opacity,
      child: AnimatedAlign(
        duration: duration,
        curve: curve,
        alignment: alignment,
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      backgroundColor: theme.colorScheme.surfaceContainer,
      onDestinationSelected: (value) {},
      selectedIndex: 0,
      destinations: _destinations.toNavigationBarDestinations().toList(),
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationRail(
      backgroundColor: theme.colorScheme.surfaceContainer,
      onDestinationSelected: (value) {},
      selectedIndex: 0,
      destinations: _destinations.toNavigationRailDestinations().toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    const duration = Durations.extralong2;
    const curve = Easing.emphasized;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: Row(
        children: [
          _buildAnimatedAlign(
            duration: duration,
            curve: curve,
            opacity:
                windowWidthSizeClass >= WindowWidthSizeClass.expanded
                    ? 1.0
                    : 0.0,
            alignment: Alignment.centerRight,
            widthFactor:
                windowWidthSizeClass >= WindowWidthSizeClass.expanded
                    ? 1.0
                    : 0.0,
            child: _buildNavigationRail(context),
          ),
          Expanded(
            child: _AnimatedListDetailLayout(
              duration: duration,
              curve: curve,
              shift:
                  windowWidthSizeClass <= WindowWidthSizeClass.medium
                      ? switch (_visibility) {
                        _ListDetailVisibility.list => const _Value.continuous(
                          1.0,
                        ),
                        _ListDetailVisibility.detail => const _Value.continuous(
                          -1.0,
                        ),
                      }
                      : const _Value.continuous(0.0),
              flex:
                  windowWidthSizeClass <= WindowWidthSizeClass.medium
                      ? const _Value.continuous(_ListDetailFlex(0.0))
                      : windowWidthSizeClass <= WindowWidthSizeClass.expanded
                      ? const _Value.continuous(_ListDetailFlex.fromEdge(-360))
                      // ? const _Value.continuous(_ListDetailFlex(0.0))
                      : const _Value.continuous(_ListDetailFlex.fromEdge(-412)),
              padding:
                  windowWidthSizeClass <= WindowWidthSizeClass.compact
                      ? const _ContinuousValue(EdgeInsets.zero)
                      : windowWidthSizeClass <= WindowWidthSizeClass.medium
                      ? const _ContinuousValue(
                        EdgeInsets.fromLTRB(24, 24, 24, 0),
                      )
                      : const _ContinuousValue(
                        EdgeInsets.fromLTRB(0, 24, 24, 24),
                      ),
              list: _ListDetailCard(
                duration: duration,
                curve: curve,
                shape:
                    _visibility == _ListDetailVisibility.detail ||
                            windowWidthSizeClass >= WindowWidthSizeClass.medium
                        ? Shapes.medium
                        : Shapes.none,
              ),
              separator: const SizedBox(width: 24.0),
              detail: _ListDetailCard(
                duration: duration,
                curve: curve,
                shape:
                    _visibility == _ListDetailVisibility.list ||
                            windowWidthSizeClass >= WindowWidthSizeClass.medium
                        ? Shapes.medium
                        : Shapes.none,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildAnimatedAlign(
        duration: duration,
        curve: curve,
        alignment: Alignment.topCenter,
        opacity:
            windowWidthSizeClass <= WindowWidthSizeClass.medium ? 1.0 : 0.0,
        heightFactor:
            windowWidthSizeClass <= WindowWidthSizeClass.medium ? 1.0 : 0.0,
        child: _buildNavigationBar(context),
      ),
    );
  }
}

enum _ListDetailVisibility { list, detail }

class _ListDetailCard extends ImplicitlyAnimatedWidget {
  const _ListDetailCard({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    required this.shape,
    this.child,
  });

  final ShapeBorder shape;

  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<_ListDetailCard> createState() =>
      _ListDetailCardState();
}

class _ListDetailCardState extends AnimatedWidgetBaseState<_ListDetailCard> {
  Tween<ShapeBorder?>? _shapeTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shapeTween =
        visitor(
              _shapeTween,
              widget.shape,
              (value) => ShapeBorderTween(begin: value as ShapeBorder),
            )
            as Tween<ShapeBorder?>?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = _shapeTween?.evaluate(animation) ?? widget.shape;
    return Material(
      animationDuration: Duration.zero,
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      shape: shape,
      color: theme.colorScheme.surface,
      child: widget.child,
    );
  }
}

abstract class _Value<T extends Object?> {
  const _Value(this.value);
  const factory _Value.discrete(T value) = _DiscreteValue;
  const factory _Value.continuous(T value) = _ContinuousValue;

  final T value;

  Tween<T>? createTween(
    TweenVisitor<dynamic> visitor,
    Tween<T>? tween,
    TweenConstructor<dynamic> constructor,
  );
}

class _DiscreteValue<T extends Object?> extends _Value<T> {
  const _DiscreteValue(super.value);

  @override
  Tween<T>? createTween(
    TweenVisitor<dynamic> visitor,
    Tween<T>? tween,
    TweenConstructor<dynamic> constructor,
  ) => null;
}

class _ContinuousValue<T extends Object?> extends _Value<T> {
  const _ContinuousValue(super.value);

  @override
  Tween<T>? createTween(
    TweenVisitor<dynamic> visitor,
    Tween<T>? tween,
    TweenConstructor<dynamic> constructor,
  ) => visitor(tween, value, constructor) as Tween<T>?;
}

class _AnimatedListDetailLayout extends ImplicitlyAnimatedWidget {
  const _AnimatedListDetailLayout({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    this.shift = const _Value.discrete(0.0),
    this.flex = const _Value.discrete(_ListDetailFlex(0.0)),
    this.padding = const _Value.discrete(EdgeInsets.zero),
    required this.list,
    this.separator,
    required this.detail,
  });

  final _Value<double> shift;
  final _Value<_ListDetailFlex> flex;
  final _Value<EdgeInsetsGeometry> padding;

  final Widget list;
  final Widget? separator;
  final Widget detail;

  @override
  ImplicitlyAnimatedWidgetState<_AnimatedListDetailLayout> createState() =>
      _AnimatedTwoPaneLayoutState();
}

class _AnimatedTwoPaneLayoutState
    extends AnimatedWidgetBaseState<_AnimatedListDetailLayout> {
  Tween<double>? _shiftTween;
  Tween<_ListDetailFlex>? _flexTween;
  Tween<EdgeInsetsGeometry>? _paddingTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _shiftTween = widget.shift.createTween(
      visitor,
      _shiftTween,
      (value) => Tween<double>(begin: value as double),
    );
    _flexTween = widget.flex.createTween(
      visitor,
      _flexTween,
      (value) => _ListDetailFlexTween(begin: value as _ListDetailFlex),
    );
    _paddingTween = widget.padding.createTween(
      visitor,
      _paddingTween,
      (value) => EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);
    final shift = _shiftTween?.evaluate(animation) ?? widget.shift.value;
    final flex = _flexTween?.evaluate(animation) ?? widget.flex.value;

    final padding = _paddingTween?.evaluate(animation) ?? widget.padding.value;
    final resolvedPadding = padding.resolve(textDirection);

    return CustomMultiChildLayout(
      delegate: _ListDetailLayout(
        shift: shift,
        flex: flex,
        padding: resolvedPadding,
      ),
      children: [
        LayoutId(id: _ListDetailLayoutSlot.list, child: widget.list),
        if (widget.separator != null)
          LayoutId(
            id: _ListDetailLayoutSlot.separator,
            child: widget.separator!,
          ),
        LayoutId(id: _ListDetailLayoutSlot.detail, child: widget.detail),
      ],
    );
  }
}

sealed class _ListDetailFlex {
  const _ListDetailFlex._();

  const factory _ListDetailFlex(double value) = _ListDetailFlexRelative;
  @Deprecated("Should not be used")
  const factory _ListDetailFlex.fromCenter(double value) =
      _ListDetailFlexFromCenter;
  const factory _ListDetailFlex.fromEdge(double value) =
      _ListDetailFlexFromEdge;

  bool get isRelative;
  double resolve(double width);

  static _ListDetailFlex lerp(
    _ListDetailFlex? a,
    _ListDetailFlex? b,
    double t,
  ) {
    return _CompoundListDetailFlex(a, b, t);
  }
}

class _CompoundListDetailFlex implements _ListDetailFlex {
  const _CompoundListDetailFlex(this.a, this.b, this.t);

  final _ListDetailFlex? a;
  final _ListDetailFlex? b;
  final double t;

  @override
  bool get isRelative => (a?.isRelative ?? true) && (b?.isRelative ?? true);

  @override
  double resolve(double width) {
    final flexA = a?.resolve(width);
    final flexB = b?.resolve(width);
    if (flexA != null && flexB != null) {
      return lerpDouble(flexA, flexB, t)!;
    } else {
      return flexB ?? flexA ?? 0.0;
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _CompoundListDetailFlex &&
            a == other.a &&
            b == other.b &&
            t == other.t;
  }

  @override
  int get hashCode => Object.hash(a, b, t);
}

class _ListDetailFlexRelative extends _ListDetailFlex {
  const _ListDetailFlexRelative(this.value)
    : assert(value >= -1.0 && value <= 1.0),
      super._();

  final double value;

  @override
  bool get isRelative => true;

  @override
  double resolve(double width) => value;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ListDetailFlexRelative && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

class _ListDetailFlexFromCenter extends _ListDetailFlex {
  const _ListDetailFlexFromCenter(this.value) : assert(value != 0.0), super._();

  final double value;

  @override
  bool get isRelative => false;

  @override
  double resolve(double width) => switch (value) {
    < 0.0 => clampDouble(value / width / 2, -1.0, 0.0),
    > 0.0 => clampDouble(value / width / 2, 0.0, 1.0),
    _ => throw UnimplementedError(),
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ListDetailFlexFromCenter && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

class _ListDetailFlexFromEdge extends _ListDetailFlex {
  const _ListDetailFlexFromEdge(this.value) : assert(value != 0.0), super._();

  final double value;

  @override
  bool get isRelative => false;

  @override
  double resolve(double width) => switch (value) {
    < 0.0 => clampDouble((-width - value * 2) / width, -1.0, 0.0),
    > 0.0 => clampDouble((width - value * 2) / width, 0.0, 1.0),
    _ => throw UnimplementedError(),
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _ListDetailFlexFromEdge && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;
}

class _ListDetailFlexTween extends Tween<_ListDetailFlex> {
  _ListDetailFlexTween({super.begin, super.end});

  @override
  _ListDetailFlex lerp(double t) => _ListDetailFlex.lerp(begin, end, t);
}

enum _ListDetailLayoutSlot { list, separator, detail }

class _ListDetailLayout extends MultiChildLayoutDelegate {
  _ListDetailLayout({
    this.shift = 0.0,
    this.flex = const _ListDetailFlex(0.0),
    this.padding = EdgeInsets.zero,
  }) : assert(shift >= -1.0 && shift <= 1.0);

  final double shift;
  final _ListDetailFlex flex;
  final EdgeInsets padding;

  @override
  void performLayout(Size size) {
    final hasSeparator = hasChild(_ListDetailLayoutSlot.separator);
    final hasList = hasChild(_ListDetailLayoutSlot.list);
    final hasDetail = hasChild(_ListDetailLayoutSlot.detail);
    final paddingRect = padding.deflateRect(Offset.zero & size);
    double separatorWidth = 0.0;
    if (hasSeparator) {
      final separatorSize = layoutChild(
        _ListDetailLayoutSlot.separator,
        BoxConstraints(
          maxWidth: paddingRect.width,
          minHeight: paddingRect.height,
          maxHeight: paddingRect.height,
        ),
      );
      separatorWidth = separatorSize.width;
    }

    final width = paddingRect.width - separatorWidth;
    final flex = this.flex.resolve(width);

    final flexFraction = (flex + 1.0) / 2.0;
    final flexListFraction = clampDouble(flex, 0.0, 1.0);
    final flexDetailFraction = 1.0 - clampDouble(flex, -1.0, 0.0) - 1.0;
    final shiftFraction = (shift + 1.0) / 2.0;
    final shiftListFraction = clampDouble(shift, 0.0, 1.0);
    final shiftDetailFraction = 1.0 - clampDouble(shift, -1.0, 0.0) - 1.0;

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
      positionChild(
        _ListDetailLayoutSlot.separator,
        Offset(separatorX, paddingRect.top),
      );
    }

    if (hasList && hasDetail) {
      layoutChild(
        _ListDetailLayoutSlot.list,
        BoxConstraints.tightFor(width: listWidth, height: paddingRect.height),
      );
      layoutChild(
        _ListDetailLayoutSlot.detail,
        BoxConstraints.tightFor(width: detailWidth, height: paddingRect.height),
      );

      positionChild(_ListDetailLayoutSlot.list, Offset(listX, paddingRect.top));
      positionChild(
        _ListDetailLayoutSlot.detail,
        Offset(detailX, paddingRect.top),
      );
    } else if (hasList) {
      layoutChild(
        _ListDetailLayoutSlot.list,
        BoxConstraints.tight(paddingRect.size),
      );
      positionChild(_ListDetailLayoutSlot.list, paddingRect.topLeft);
    } else if (hasDetail) {
      layoutChild(
        _ListDetailLayoutSlot.detail,
        BoxConstraints.tight(paddingRect.size),
      );
      positionChild(_ListDetailLayoutSlot.detail, paddingRect.topLeft);
    }
  }

  @override
  bool shouldRelayout(covariant _ListDetailLayout oldDelegate) {
    return shift != oldDelegate.shift ||
        flex != oldDelegate.flex ||
        padding != oldDelegate.padding;
  }
}
