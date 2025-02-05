import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/rendering/sliver_persistent_header.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material/material.dart';
import 'package:painting/painting.dart';
import 'package:services/services.dart';
import 'package:sliver_tools/sliver_tools.dart';

List<Widget> _defaultSuggestionsBuilder(BuildContext context) {
  return [];
}

typedef SearchViewSuggestionsBuilder =
    List<Widget> Function(BuildContext context);

class SliverSearchView extends StatefulWidget {
  const SliverSearchView({
    super.key,
    this.pinned = false,
    this.floating = false,
    this.snapConfiguration,
    this.padding = EdgeInsets.zero,
    this.dockedViewMargin = EdgeInsets.zero,
    this.flexibleSpace,
    this.supportingText,
    this.trailing,
    this.suggestionsBuilder = _defaultSuggestionsBuilder,
  });

  final bool pinned;
  final bool floating;
  final FloatingHeaderSnapConfiguration? snapConfiguration;

  final EdgeInsets padding;
  final EdgeInsets dockedViewMargin;

  final Widget? flexibleSpace;
  final String? supportingText;
  final Widget? trailing;

  final SearchViewSuggestionsBuilder suggestionsBuilder;

  @override
  State<SliverSearchView> createState() => _SliverSearchViewState();
}

class _SliverSearchViewState extends State<SliverSearchView>
    with SingleTickerProviderStateMixin {
  final _anchorKey = GlobalKey();

  late NavigatorState _navigator;

  late TextEditingController _textEditingController;

  late ValueNotifier<String?> _supportingText;
  late ValueNotifier<EdgeInsetsGeometry> _dockedViewMargin;
  late ValueNotifier<SearchViewSuggestionsBuilder> _suggestionsBuilder;

  _SliverSearchViewRoute? _route;

  bool _anchorVisible = true;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: "")
      ..addListener(_textListener);
    _dockedViewMargin = ValueNotifier(widget.dockedViewMargin);
    _supportingText = ValueNotifier(widget.supportingText);
    _suggestionsBuilder = ValueNotifier(widget.suggestionsBuilder);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context, rootNavigator: true);
  }

  @override
  void didUpdateWidget(covariant SliverSearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dockedViewMargin != oldWidget.dockedViewMargin) {
      _dockedViewMargin.value = widget.dockedViewMargin;
    }
    if (widget.supportingText != oldWidget.supportingText) {
      _supportingText.value = widget.supportingText;
    }
    if (widget.suggestionsBuilder != oldWidget.suggestionsBuilder) {
      _suggestionsBuilder.value = widget.suggestionsBuilder;
    }
  }

  @override
  void dispose() {
    final route = _route;
    if (route != null) {
      route.navigator?.removeRoute(route);
    }

    _supportingText.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  void _scheduleSetState(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(callback);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(callback));
      // if (_mounted) setState(callback);
    }
  }

  void _textListener() {
    setState(() {});
  }

  void _openView() {
    final route = _SliverSearchViewRoute(
      anchorKey: _anchorKey,
      textEditingController: _textEditingController,
      onAnchorVisibilityChanged:
          (value) => _scheduleSetState(() => _anchorVisible = value),
      dockedViewMargin: _dockedViewMargin,
      supportingText: _supportingText,
      suggestionsBuilder: _suggestionsBuilder,
    );
    _navigator.push(route);
  }

  void _closeView() {
    final route = _route;
    if (route == null) return;
    if (route.isCurrent) {
      _navigator.pop();
    } else if (route.isActive) {
      _navigator.removeRoute(route);
    }
    _route = null;
  }

  Widget _buildLeading(BuildContext context) {
    return const SizedBox(
      width: 56,
      child: Align(child: const Icon(Symbols.search)),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);
    if (_textEditingController.text.isNotEmpty) {
      return SizedBox(
        width: 56,
        child: Align(
          child: IconButton(
            onPressed: _textEditingController.clear,
            icon: const Icon(Symbols.close),
          ),
        ),
      );
    }
    return widget.trailing ?? const SizedBox(width: 16);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    final fixedExtent = widget.padding.vertical + _kSearchBarHeight;
    return SliverPersistentHeader(
      pinned: widget.pinned,
      floating: widget.floating,
      delegate: _SliverPersistentHeaderDelegate(
        minExtent: fixedExtent,
        maxExtent: fixedExtent,
        vsync: this,
        snapConfiguration: widget.snapConfiguration,
        // snapConfiguration: FloatingHeaderSnapConfiguration(
        //   duration: Durations.medium1,
        //   curve: Easing.emphasized,
        // ),
        builder:
            (context, shrinkOffset, overlapsContent) => Stack(
              children: [
                if (widget.flexibleSpace != null)
                  Positioned.fill(child: widget.flexibleSpace!),
                Positioned(
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: widget.padding,
                    child: Visibility(
                      visible: _anchorVisible,
                      maintainInteractivity: false,
                      maintainSemantics: true,
                      maintainSize: true,
                      maintainState: true,
                      maintainAnimation: true,
                      child: _SearchBarContainer(
                        key: _anchorKey,
                        onPressed: _openView,
                        child: _SearchContent(
                          leading: _buildLeading(context),
                          content: _SearchText(
                            supportingText: _supportingText.value,
                            inputText: _textEditingController.text,
                          ),
                          trailing: _buildTrailing(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

const _kSearchBarHeight = 56.0;

class _SearchBarContainer extends StatelessWidget {
  const _SearchBarContainer({
    super.key,
    this.onPressed,
    this.onLongPress,
    this.child,
  });

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 360,
        maxWidth: 720,
        minHeight: _kSearchBarHeight,
        maxHeight: _kSearchBarHeight,
      ),
      child: Material(
        animationDuration: Duration.zero,
        type: MaterialType.button,
        clipBehavior: Clip.antiAlias,
        color: theme.colorScheme.surfaceContainerHigh,
        shape: Shapes.full,
        child: InkWell(
          onTap: onPressed,
          onLongPress: onLongPress,
          overlayColor: WidgetStateLayerColor(
            theme.colorScheme.onSurface,
            opacity: stateTheme.stateLayerOpacity,
          ),
          child: child,
        ),
      ),
    );
  }
}

typedef _SliverPersistentHeaderBuilder =
    Widget Function(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
    );

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _SliverPersistentHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    this.vsync,
    this.snapConfiguration,
    required this.builder,
  }) : assert(snapConfiguration == null || vsync != null);

  final _SliverPersistentHeaderBuilder builder;

  @override
  final double minExtent;

  @override
  final double maxExtent;

  @override
  final TickerProvider? vsync;

  @override
  final FloatingHeaderSnapConfiguration? snapConfiguration;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset, overlapsContent);
  }

  @override
  bool shouldRebuild(covariant _SliverPersistentHeaderDelegate oldDelegate) {
    return builder != oldDelegate.builder ||
        minExtent != oldDelegate.minExtent ||
        maxExtent != oldDelegate.maxExtent ||
        snapConfiguration != oldDelegate.snapConfiguration;
  }
}

class _SearchText extends StatelessWidget {
  const _SearchText({super.key, this.supportingText, this.inputText});

  final String? supportingText;
  final String? inputText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportingTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final inputTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final hasInputText = inputText != null && inputText!.isNotEmpty;
    return Text(
      (hasInputText ? inputText : supportingText) ?? supportingText ?? "",
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: hasInputText ? inputTextStyle : supportingTextStyle,
    );
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.supportingText,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final supportingTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final inputTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 1,
      style: inputTextStyle,
      decoration: InputDecoration(
        hintText: supportingText,
        hintStyle: supportingTextStyle,
        enabledBorder: InputBorder.none,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent({
    super.key,
    this.padding = EdgeInsets.zero,
    this.spacing = 0.0,
    this.leading,
    this.content,
    this.trailing,
  });

  final EdgeInsetsGeometry padding;
  final double spacing;

  final Widget? leading;
  final Widget? content;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Flex.horizontal(
        children: [
          if (leading != null)
            IconTheme.merge(
              data: IconThemeData(
                size: 24.0,
                opticalSize: 24.0,
                color: theme.colorScheme.onSurface,
              ),
              child: leading!,
            ),
          Flexible.expand(child: content),
          if (trailing != null)
            IconTheme.merge(
              data: IconThemeData(
                size: 24.0,
                opticalSize: 24.0,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              child: trailing!,
            ),
        ],
      ),
    );
  }
}

enum _Change { dockedViewMargin, supportingText, suggestionsBuilder }

class _SliverSearchViewRoute<T> extends PopupRoute<T> {
  _SliverSearchViewRoute({
    required this.anchorKey,
    required this.textEditingController,
    this.onAnchorVisibilityChanged,
    required this.dockedViewMargin,
    required this.supportingText,
    required this.suggestionsBuilder,
  });

  final GlobalKey anchorKey;
  final TextEditingController textEditingController;
  final ValueChanged<bool>? onAnchorVisibilityChanged;

  final ValueNotifier<EdgeInsetsGeometry> dockedViewMargin;
  // final ValueNotifier<Widget> barLeading;
  // final ValueNotifier<Widget> barTrailing;
  final ValueNotifier<String?> supportingText;

  final ValueNotifier<SearchViewSuggestionsBuilder> suggestionsBuilder;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;
  @override
  Duration get transitionDuration => Durations.long4;

  @override
  Duration get reverseTransitionDuration => Durations.long2;

  CurvedAnimation _containerTransformAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: Easing.linear,
  );
  CurvedAnimation _fadeOutAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: Easing.linear,
  );
  CurvedAnimation _fadeInAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: Easing.linear,
  );
  CurvedAnimation _enterExitAnimation = CurvedAnimation(
    parent: kAlwaysDismissedAnimation,
    curve: Easing.linear,
  );

  final _barHeaderOpacityTween = Tween<double>(begin: 1, end: 0);
  final _viewHeaderOpacityTween = Tween<double>(begin: 0, end: 1);

  final _dockedShapeTween = ShapeBorderTween(
    begin: Shapes.extraLarge,
    end: Shapes.extraLarge,
  );
  final _fullscreenShapeTween = ShapeBorderTween(
    begin: Shapes.extraLarge,
    end: Shapes.none,
  );

  final _suggestionsOffsetTween = Tween<Offset>(
    begin: const Offset(0, -56),
    end: Offset.zero,
  );
  late Animation<double> _barHeaderOpacity;
  late Animation<double> _viewHeaderOpacity;
  late Animation<ShapeBorder?> _dockedShape;
  late Animation<ShapeBorder?> _fullscreenShape;

  late Animation<Offset> _suggestionsOffset;

  final Set<_Change> _changes = {..._Change.values};

  void _scheduleSetState(VoidCallback callback) {
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(callback);
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => setState(callback));
      // if (_mounted) setState(callback);
    }
  }

  void _onMarginChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.dockedViewMargin);
    });
  }

  void _onSupportingTextChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.supportingText);
    });
  }

  void _onSuggestionsBuilderChanged() {
    _scheduleSetState(() {
      _changes.add(_Change.suggestionsBuilder);
    });
  }

  void _updateState(
    BuildContext context,
    Animation<double> animation,
    Set<_Change> changes,
  ) {
    if (_containerTransformAnimation.parent != animation) {
      _containerTransformAnimation.dispose();
      _containerTransformAnimation = CurvedAnimation(
        parent: animation,
        curve: Easing.emphasized,
        reverseCurve: Easing.emphasized.flipped,
      );
      _dockedShape = _dockedShapeTween.animate(_containerTransformAnimation);
      _fullscreenShape = _fullscreenShapeTween.animate(
        _containerTransformAnimation,
      );
      _suggestionsOffset = _suggestionsOffsetTween.animate(
        _containerTransformAnimation,
      );
    }
    if (_enterExitAnimation.parent != animation) {
      _enterExitAnimation.dispose();
      _enterExitAnimation = CurvedAnimation(
        parent: animation,
        curve: Easing.emphasizedDecelerate,
        reverseCurve: Easing.emphasizedAccelerate.flipped,
      );
    }
    if (_fadeOutAnimation.parent != animation) {
      _fadeOutAnimation.dispose();
      _fadeOutAnimation = CurvedAnimation(
        parent: animation,
        curve: const Interval(0, 0.25),
        reverseCurve: const Interval(0, 0.75),
      );
      _barHeaderOpacity = _barHeaderOpacityTween.animate(_fadeOutAnimation);
    }
    if (_fadeInAnimation.parent != animation) {
      _fadeInAnimation.dispose();
      _fadeInAnimation = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.25, 1),
        reverseCurve: const Interval(0.5, 1),
      );
      _viewHeaderOpacity = _viewHeaderOpacityTween.animate(_fadeInAnimation);
    }
  }

  bool? _anchorVisible;
  void _animationListener() {
    final anchorVisible =
        offstage || animation!.status == AnimationStatus.dismissed;
    if (_anchorVisible != anchorVisible) {
      onAnchorVisibilityChanged?.call(anchorVisible);
    }
    _anchorVisible = anchorVisible;
  }

  StreamSubscription<BorderRadius>? _windowCornersSubscription;
  void _windowCornersListener(BorderRadius windowCorners) {
    debugPrint("${windowCorners}");
    setState(() {
      _fullscreenShapeTween.end = RoundedRectangleBorder(
        borderRadius: windowCorners,
      );
    });
  }

  @override
  void install() {
    super.install();

    animation?.addListener(_animationListener);

    dockedViewMargin.addListener(_onMarginChanged);
    supportingText.addListener(_onSupportingTextChanged);
    suggestionsBuilder.addListener(_onSuggestionsBuilderChanged);

    _windowCornersSubscription = const Services().onWindowCornersChange.listen(
      _windowCornersListener,
    );
  }

  @override
  void dispose() {
    _windowCornersSubscription?.cancel();

    suggestionsBuilder.removeListener(_onSuggestionsBuilderChanged);
    supportingText.removeListener(_onSupportingTextChanged);
    dockedViewMargin.removeListener(_onMarginChanged);
    _fadeInAnimation.dispose();
    _fadeOutAnimation.dispose();
    _containerTransformAnimation.dispose();

    animation?.removeListener(_animationListener);
    super.dispose();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> _,
    Widget child,
  ) {
    _updateState(context, animation, EqualUnmodifiableSetView(_changes));
    _changes.clear();

    final anchorContext = anchorKey.currentContext!;
    final navigatorBox = navigator!.context.findRenderObject()! as RenderBox;
    final navigatorRect = Offset.zero & navigatorBox.size;

    final anchorNavigator = Navigator.of(anchorContext);
    final anchorNavigatorBox =
        anchorNavigator.context.findRenderObject()! as RenderBox;
    final anchorNavigatorRect =
        anchorNavigatorBox.localToGlobal(Offset.zero) & anchorNavigatorBox.size;

    final anchorBox = anchorContext.findRenderObject()! as RenderBox;
    final anchorRect =
        navigatorBox.globalToLocal(anchorBox.localToGlobal(Offset.zero)) &
        anchorBox.size;

    final fullscreen =
        WindowWidthSizeClass.of(context) <= WindowWidthSizeClass.compact;
    final textDirection = Directionality.of(context);

    final resolvedMargin = dockedViewMargin.value.resolve(textDirection);
    final insets = MediaQuery.paddingOf(context);

    final fullscreenOuterPadding =
        EdgeInsetsGeometry.lerp(
          insets,
          EdgeInsets.zero,
          // padding,
          _containerTransformAnimation.value,
        )!;
    final fullscreenInnerPadding =
        EdgeInsetsGeometry.lerp(
          EdgeInsets.zero,
          insets,
          _containerTransformAnimation.value,
        )!;

    final dockedViewRect = Rect.fromLTRB(
      anchorRect.left,
      anchorRect.top,
      anchorRect.right,
      anchorNavigatorRect.bottom,
    );
    final dockedViewOffset =
        Offset.lerp(
          anchorRect.topLeft,
          Offset(
            math.max(
              anchorRect.left,
              navigatorRect.left + insets.left + resolvedMargin.left,
            ),
            math.max(
              anchorRect.top,
              navigatorRect.top + insets.top + resolvedMargin.top,
            ),
          ),
          _containerTransformAnimation.value,
        )!;
    final dockedViewConstraints = BoxConstraints(
      minWidth: anchorRect.width,
      maxWidth: anchorRect.width,
      minHeight: 240,
      maxHeight: navigatorRect.height * 2 / 3,
    );

    final fullscreenViewRect = navigatorRect;
    final fullscreenViewOffset =
        Offset.lerp(
          anchorRect.topLeft,
          fullscreenViewRect.topLeft,
          _containerTransformAnimation.value,
        )!;
    final fullscreenViewConstraints =
        BoxConstraints.lerp(
          BoxConstraints(
            maxWidth: anchorRect.width,
            maxHeight: fullscreenViewRect.height,
          ),
          BoxConstraints.tightFor(
            width: fullscreenViewRect.width,
            height: fullscreenViewRect.height,
          ),
          _containerTransformAnimation.value,
        )!;

    final theme = Theme.of(context);

    _dockedShapeTween.begin = _FixedHeightBorder(
      shape: Shapes.extraLarge,
      height: anchorRect.height,
    );
    _fullscreenShapeTween.begin = _FixedHeightBorder(
      shape: Shapes.extraLarge,
      height: anchorRect.height,
    );
    _fullscreenShapeTween.end = RoundedRectangleBorder(
      borderRadius: const Services().windowCorners,
    );

    final headerHeight =
        lerpDouble(
          56,
          fullscreen ? 72 : 56,
          _containerTransformAnimation.value,
        )!;

    final backgroundColor = theme.colorScheme.surfaceContainerHigh;

    return IgnorePointer(
      ignoring: !animation.isForwardOrCompleted,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (fullscreen)
            Positioned.fill(
              child: Opacity(
                opacity: lerpDouble(0, 1, _containerTransformAnimation.value)!,
                child: ColoredBox(
                  color: theme.colorScheme.scrim.withValues(alpha: 0.32),
                  // color:
                  //     Color.lerp(
                  //       backgroundColor.withValues(alpha: 0.0),
                  //       backgroundColor,
                  //       _containerTransformAnimation.value,
                  //     )!,
                ),
              ),
            ),
          ClipPath.shape(
            shape: CroppedBorder.padding(
              shape: const RoundedRectangleBorder(),
              padding: fullscreen ? fullscreenOuterPadding : insets,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: fullscreen ? fullscreenViewOffset : dockedViewOffset,
                child: ConstrainedBox(
                  constraints:
                      fullscreen
                          ? fullscreenViewConstraints
                          : dockedViewConstraints,
                  child: Material(
                    animationDuration: Duration.zero,
                    clipBehavior: Clip.antiAlias,
                    type: MaterialType.card,
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape:
                        fullscreen
                            ? _fullscreenShape.value!
                            : _dockedShape.value!,
                    child: Padding(
                      padding:
                          fullscreen ? fullscreenInnerPadding : EdgeInsets.zero,
                      child: CustomScrollView(
                        scrollBehavior: ScrollConfiguration.of(
                          context,
                        ).copyWith(
                          dragDevices: {
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.touch,
                          },
                        ),
                        shrinkWrap: true,
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverPersistentHeaderDelegate(
                              minExtent: headerHeight,
                              maxExtent: headerHeight,
                              builder:
                                  (
                                    context,
                                    shrinkOffset,
                                    overlapsContent,
                                  ) => Material(
                                    animationDuration: Duration.zero,
                                    clipBehavior: Clip.hardEdge,
                                    type: MaterialType.card,
                                    color:
                                        theme.colorScheme.surfaceContainerHigh,
                                    shape: Border(
                                      bottom: BorderSide(
                                        color:
                                            Color.lerp(
                                              theme.colorScheme.outline
                                                  .withAlpha(0),
                                              theme.colorScheme.outline,
                                              _fadeInAnimation.value,
                                            )!,
                                      ),
                                    ),
                                    child: _SearchContent(
                                      leading: SizedBox(
                                        width: 56,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if (_barHeaderOpacity.value > 0.0)
                                              Align(
                                                child: Opacity(
                                                  opacity:
                                                      _barHeaderOpacity.value,
                                                  child: IgnorePointer(
                                                    child: Icon(Symbols.search),
                                                  ),
                                                ),
                                              ),
                                            if (_viewHeaderOpacity.value > 0.0)
                                              Align(
                                                child: Opacity(
                                                  opacity:
                                                      _viewHeaderOpacity.value,
                                                  child: IconButton(
                                                    onPressed: navigator!.pop,
                                                    icon: const Icon(
                                                      Symbols.arrow_back,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      content: _SearchTextField(
                                        controller: textEditingController,
                                        supportingText: supportingText.value,
                                      ),
                                      trailing: SizedBox(
                                        width: 56,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if (_viewHeaderOpacity.value > 0.0)
                                              Align(
                                                child: Opacity(
                                                  opacity:
                                                      _viewHeaderOpacity.value,
                                                  child: IconButton(
                                                    onPressed:
                                                        () =>
                                                            textEditingController
                                                                .clear(),
                                                    icon: const Icon(
                                                      Symbols.close,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                          ),

                          // SliverOpacity(
                          //   opacity: _viewHeaderOpacity.value,
                          //   sliver: SliverList.builder(
                          //     itemBuilder:
                          //         (context, index) => ListTile(
                          //           onTap: navigator?.pop,
                          //           title: Text("Result ${index + 1}"),
                          //         ),
                          //   ),
                          // ),
                          SliverTransform.translate(
                            offset:
                                Offset.lerp(
                                  Offset(0, -32),
                                  Offset.zero,
                                  _containerTransformAnimation.value,
                                )!,
                            child: SliverOpacity(
                              opacity:
                                  lerpDouble(
                                    0.0,
                                    1.0,
                                    _containerTransformAnimation.value,
                                  )!,
                              sliver: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                removeBottom: true,
                                removeLeft: true,
                                removeRight: true,

                                child: MultiSliver(
                                  children: suggestionsBuilder.value(context),
                                ),
                              ),
                            ),
                          ),
                          // ...suggestionsBuilder.value(context),
                        ],
                      ),
                    ),
                    // child: Flex.vertical(
                    //   crossAxisAlignment: CrossAxisAlignment.stretch,
                    //   children: [
                    //     Stack(
                    //       children: [
                    //         SizedBox(
                    //           height: 56,
                    //           child: Opacity(
                    //             opacity: _barHeaderOpacity.value,
                    //             child: _SearchBarContent(
                    //               leading: SizedBox(
                    //                 width: 56,
                    //                 child: Align(child: Icon(Symbols.search)),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         SizedBox(
                    //           height: 56,
                    //           child: Opacity(
                    //             opacity: _viewHeaderOpacity.value,
                    //             child: _SearchViewHeader(
                    //               leading: SizedBox(
                    //                 width: 56,
                    //                 child: Align(
                    //                   child: IconButton(
                    //                     onPressed: navigator!.pop,
                    //                     icon: const Icon(Symbols.arrow_back),
                    //                   ),
                    //                 ),
                    //               ),
                    //               trailing: SizedBox(
                    //                 width: 56,
                    //                 child: Align(
                    //                   child: IconButton(
                    //                     onPressed: () {},
                    //                     icon: const Icon(Symbols.close),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ),
                ),
              ),
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

class _SearchView extends ImplicitlyAnimatedWidget {
  const _SearchView({
    super.key,
    required super.duration,
    super.curve,
    super.onEnd,
    required this.fullscreen,
    required this.animation,
    required this.anchorRect,
    required this.dockedShape,
    required this.fullscreenShape,
  });

  final bool fullscreen;

  final Animation<double> animation;
  final Rect anchorRect;
  final Animation<ShapeBorder?> dockedShape;
  final Animation<ShapeBorder?> fullscreenShape;

  @override
  ImplicitlyAnimatedWidgetState<_SearchView> createState() =>
      _SearchViewState();
}

class _SearchViewState extends AnimatedWidgetBaseState<_SearchView> {
  double get _dockedToFullscreen => widget.fullscreen ? 1.0 : 0.0;
  Tween<double>? _dockedToFullscreenTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _dockedToFullscreenTween =
        visitor(
              _dockedToFullscreenTween,
              _dockedToFullscreen,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final dockedToFullscreen =
        _dockedToFullscreenTween?.evaluate(animation) ?? _dockedToFullscreen;
    // final shape = _shapeTween?.evaluate(animation) ?? widget.shape;

    return Align(
      alignment: Alignment.topLeft,
      child: Transform.translate(
        offset: widget.anchorRect.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.anchorRect.width,
            maxWidth: widget.anchorRect.width,
            minHeight: 240,
            maxHeight: 600,
          ),
          child: AnimatedBuilder(
            animation: widget.animation,
            builder: (context, child) {
              // final shape = ShapeBorder.lerp(
              //   widget.dockedShape.value,
              //   widget.fullscreenShape.value,
              //   dockedToFullscreen,
              // );
              final shape = widget.fullscreenShape.value;
              debugPrint("${shape}");
              return Material(
                color: Colors.red,
                shape: shape,
                child: Flex.vertical(children: [Text("AAAAA")]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnimationTween<T extends Object?> extends Tween<Animation<T>> {
  _AnimationTween({super.begin, super.end, required this.lerpFunction});

  final T Function(T a, T b, double t) lerpFunction;

  @override
  Animation<T> lerp(double t) {
    assert(begin != null);
    assert(end != null);
    if (t <= 0.0) return begin!;
    if (t >= 1.0) return end!;
    return _AnimationTweenEvaluation<T>(begin!, end!, t, lerpFunction);
  }
}

class _AnimationTweenEvaluation<T extends Object?>
    extends CompoundAnimation<T> {
  _AnimationTweenEvaluation(
    Animation<T> begin,
    Animation<T> end,
    this.t,
    this.lerpFunction,
  ) : assert(t >= 0.0 && t <= 1.0),
      super(first: begin, next: end);

  final double t;
  final T Function(T a, T b, double t) lerpFunction;

  @override
  T get value => lerpFunction(first.value, next.value, t);
}

class _FixedHeightBorder extends ProxyOutlinedBorder {
  const _FixedHeightBorder({required super.shape, required this.height});

  final double height;

  Rect _getRect(Rect rect) {
    return Rect.fromLTRB(rect.left, rect.top, rect.right, rect.top + height);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return super.getInnerPath(_getRect(rect), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return super.getOuterPath(_getRect(rect), textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    super.paint(canvas, _getRect(rect), textDirection: textDirection);
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    super.paintInterior(
      canvas,
      _getRect(rect),
      paint,
      textDirection: textDirection,
    );
  }

  @override
  ShapeBorder scale(double t) {
    final scaled = shape.scale(t);
    return _FixedHeightBorder(
      shape: scaled is OutlinedBorder ? scaled : shape,
      height: height,
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side, double? height, double? t}) {
    return _FixedHeightBorder(
      shape: shape.copyWith(side: side),
      height: height ?? this.height,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double progress) {
    if (identical(this, a)) return this;
    if (a is _FixedHeightBorder) {
      return _FixedHeightBorder(
        shape: a.shape.lerpFrom(shape, progress) as OutlinedBorder? ?? shape,
        height: lerpDouble(a.height, height, progress)!,
      );
    }
    if (a is OutlinedBorder) {
      return _FixedHeightBorderLerp(
        shape: a.lerpFrom(shape, progress) as OutlinedBorder? ?? shape,
        height: height,
        t: 1.0 - progress,
      );
    }
    return super.lerpFrom(a, progress);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double progress) {
    if (identical(this, b)) return this;
    if (b is _FixedHeightBorder) {
      return _FixedHeightBorder(
        shape: shape.lerpTo(b.shape, progress) as OutlinedBorder? ?? shape,
        height: lerpDouble(height, b.height, progress)!,
      );
    }
    if (b is OutlinedBorder) {
      return _FixedHeightBorderLerp(
        shape: shape.lerpTo(b, progress) as OutlinedBorder? ?? shape,
        height: height,
        t: progress,
      );
    }
    return super.lerpTo(b, progress);
  }
}

class _FixedHeightBorderLerp extends ProxyOutlinedBorder {
  const _FixedHeightBorderLerp({
    required super.shape,
    required this.height,
    required this.t,
  });

  final double height;
  final double t;

  Rect _getRect(Rect rect) {
    return Rect.fromLTRB(
      rect.left,
      rect.top,
      rect.right,
      lerpDouble(rect.top + height, rect.bottom, t)!,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return super.getInnerPath(_getRect(rect), textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return super.getOuterPath(_getRect(rect), textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    super.paint(canvas, _getRect(rect), textDirection: textDirection);
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    super.paintInterior(
      canvas,
      _getRect(rect),
      paint,
      textDirection: textDirection,
    );
  }

  @override
  ShapeBorder scale(double t) {
    final scaled = shape.scale(t);
    return _FixedHeightBorderLerp(
      shape: scaled is OutlinedBorder ? scaled : shape,
      height: height,
      t: this.t,
    );
  }

  @override
  OutlinedBorder copyWith({BorderSide? side, double? height, double? t}) {
    return _FixedHeightBorderLerp(
      shape: shape.copyWith(side: side),
      height: height ?? this.height,
      t: t ?? this.t,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double progress) {
    if (identical(this, a)) return this;
    if (a is _FixedHeightBorderLerp) {
      return _FixedHeightBorderLerp(
        shape:
            ShapeBorder.lerp(a.shape, shape, progress) as OutlinedBorder? ??
            shape,
        height: lerpDouble(a.height, height, progress)!,
        t: lerpDouble(a.t, t, progress)!,
      );
    }
    if (a is _FixedHeightBorder) {
      return _FixedHeightBorderLerp(
        shape:
            ShapeBorder.lerp(a.shape, shape, progress) as OutlinedBorder? ??
            shape,
        height: lerpDouble(a.height, height, progress)!,
        t: lerpDouble(1.0, t, progress)!,
      );
    }
    if (a is OutlinedBorder) {
      return _FixedHeightBorderLerp(
        shape: ShapeBorder.lerp(a, shape, progress) as OutlinedBorder? ?? shape,
        height: height,
        t: t,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double progress) {
    if (identical(this, b)) return this;
    if (b is _FixedHeightBorderLerp) {
      return _FixedHeightBorderLerp(
        shape:
            ShapeBorder.lerp(shape, b.shape, progress) as OutlinedBorder? ??
            shape,
        height: lerpDouble(height, b.height, progress)!,
        t: lerpDouble(t, b.t, progress)!,
      );
    }
    if (b is _FixedHeightBorder) {
      return _FixedHeightBorderLerp(
        shape:
            ShapeBorder.lerp(shape, b.shape, progress) as OutlinedBorder? ??
            shape,
        height: lerpDouble(height, b.height, progress)!,
        t: lerpDouble(t, 1.0, progress)!,
      );
    }
    if (b is OutlinedBorder) {
      return _FixedHeightBorderLerp(
        shape: ShapeBorder.lerp(shape, b, progress) as OutlinedBorder? ?? shape,
        height: height,
        t: t,
      );
    }
    return super.lerpTo(b, t);
  }
}
