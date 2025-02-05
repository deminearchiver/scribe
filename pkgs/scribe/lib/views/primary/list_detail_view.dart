import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';
import 'package:scribe/brick/models/note.model.dart';
import 'package:scribe/brick/models/user.model.dart';
import 'package:scribe/brick/repository.dart';
import 'package:scribe/providers.dart';
import 'package:scribe/two_pane_layout.dart';
import 'package:scribe/views/primary/note_card.dart';
import 'package:scribe/views/primary/note_editor.dart';
import 'package:brick_core/query.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:super_editor/super_editor.dart';
import 'package:super_editor_quill/super_editor_quill.dart';

class _ListDetailConfiguration {
  const _ListDetailConfiguration(this.windowWidthSizeClass);

  final WindowWidthSizeClass windowWidthSizeClass;

  bool get showOnePane => windowWidthSizeClass <= WindowWidthSizeClass.medium;
  bool get showTwoPanes => !showOnePane;

  TwoPaneLayoutFlexFactor get defaultFlexFactor {
    if (windowWidthSizeClass <= WindowWidthSizeClass.medium) {
      return const TwoPaneLayoutFlexFactor(0.0);
    }
    if (windowWidthSizeClass <= WindowWidthSizeClass.expanded) {
      return const TwoPaneLayoutFlexFactor.fixedListWidth(360.0);
    }
    return const TwoPaneLayoutFlexFactor.fixedListWidth(412.0);
  }

  bool get showNavigationBar =>
      windowWidthSizeClass <= WindowWidthSizeClass.medium;
  bool get showNavigationRail =>
      windowWidthSizeClass >= WindowWidthSizeClass.expanded;

  EdgeInsetsGeometry get padding {
    if (windowWidthSizeClass <= WindowWidthSizeClass.compact) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(
      showNavigationRail ? 0.0 : 24.0,
      24.0,
      24.0,
      showNavigationBar ? 0.0 : 24.0,
    );
  }

  FloatingActionButtonLocation get floatingActionButtonLocation {
    if (windowWidthSizeClass <= WindowWidthSizeClass.medium) {
      return FloatingActionButtonLocation.endFloat;
    }
    return FloatingActionButtonLocation.startTop;
  }

  EdgeInsetsGeometry get floatingActionButtonPadding {
    return padding;
  }

  Offset get floatingActionButtonOffset {
    return switch (floatingActionButtonLocation) {
      FloatingActionButtonLocation.startTop => const Offset(-4.0, 0.0),
      _ => Offset.zero,
    };
  }

  bool get isFloatingActionButtonContained {
    if (windowWidthSizeClass <= WindowWidthSizeClass.medium) return false;
    return true;
  }

  static _ListDetailConfiguration? maybeOf(BuildContext context) {
    final windowWidthSizeClass = WindowWidthSizeClass.maybeOf(context);
    return windowWidthSizeClass != null
        ? _ListDetailConfiguration(windowWidthSizeClass)
        : null;
  }

  static _ListDetailConfiguration of(BuildContext context) {
    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    return _ListDetailConfiguration(windowWidthSizeClass);
  }
}

@immutable
class _ListDetailViewDestination with Diagnosticable {
  const _ListDetailViewDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
  final Widget icon;
  final Widget? selectedIcon;
  final String label;

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Widget>("icon", selectedIcon));
    properties.add(
      DiagnosticsProperty<Widget>(
        "selectedIcon",
        selectedIcon,
        defaultValue: null,
      ),
    );
    properties.add(StringProperty("label", label));
  }
}

extension _ListDetailViewDestinationIterable
    on Iterable<_ListDetailViewDestination> {
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

class ListDetailView extends StatefulWidget {
  const ListDetailView({super.key});

  @override
  State<ListDetailView> createState() => _ListDetailViewState();
}

class _ListDetailViewState extends State<ListDetailView> {
  ModalRoute? _noteRoute;

  final _repository = Repository();
  late _ListDetailConfiguration _configuration;

  int _selectedIndex = 0;

  late UserController _userController;
  StreamSubscription<UserModel?>? _userSubscription;
  StreamSubscription<List<NoteModel>>? _notesSubscription;

  @override
  void initState() {
    super.initState();
    _userController = UserController();

    _userSubscription = _userController.stream.listen((user) {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configuration = _ListDetailConfiguration.of(context);
  }

  @override
  void didUpdateWidget(covariant ListDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    _userSubscription?.cancel();
    _userController.dispose();
    super.dispose();
  }

  Widget _buildListNavigator(BuildContext context) {
    return Navigator();
  }

  Widget _buildDetailNavigator(BuildContext context) {
    return Navigator();
  }

  void _onDestinationSelected(int value) {
    setState(() => _selectedIndex = value);
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      style: ButtonStyle(
        shadowColor:
            _configuration.isFloatingActionButtonContained
                ? WidgetStateColor.transparent
                : null,
      ),
      child: const Icon(Symbols.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<_ListDetailViewDestination> destinations = [
      _ListDetailViewDestination(
        icon: Icon(Symbols.home, fill: 0),
        selectedIcon: Icon(Symbols.home, fill: 1),
        label: "Home",
      ),
      _ListDetailViewDestination(
        icon: Icon(Symbols.notifications, fill: 0),
        selectedIcon: Icon(Symbols.notifications, fill: 1),
        label: "Reminders",
      ),
      _ListDetailViewDestination(
        icon: Icon(Symbols.settings, fill: 0),
        selectedIcon: Icon(Symbols.settings, fill: 1),
        label: "Settings",
      ),
    ];

    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    final textDirection = Directionality.of(context);
    final theme = Theme.of(context);
    const duration = Durations.extralong2;
    const curve = Easing.emphasized;

    final resolvedPadding = _configuration.padding.resolve(textDirection);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      onDrawerChanged: (isOpened) {},
      drawer: NavigationDrawer(
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _selectedIndex,
        children: destinations.toNavigationDrawerDestinations().toList(),
      ),
      body: Flex.horizontal(
        children: [
          _ListDetailViewNavigationRail(
            duration: duration,
            curve: curve,
            widthFactor: _configuration.showNavigationRail ? 1.0 : 0.0,
            opacity: _configuration.showNavigationRail ? 1.0 : 0.0,
            leading: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Flex.vertical(
                children: [_buildFloatingActionButton(context)],
              ),
            ),

            onDestinationSelected: _onDestinationSelected,
            selectedIndex: _selectedIndex,
            destinations: destinations.toNavigationRailDestinations().toList(),
          ),

          Expanded(
            child: TweenAnimationBuilder<double>(
              duration: duration,
              curve: curve,
              tween: Tween<double>(end: _configuration.showOnePane ? 1.0 : 0.0),
              builder:
                  (
                    context,
                    shift,
                    child,
                  ) => TweenAnimationBuilder<TwoPaneLayoutFlexFactor?>(
                    duration: duration,
                    curve: curve,
                    tween: TwoPaneLayoutFlexFactorTween(
                      end: _configuration.defaultFlexFactor,
                    ),
                    builder:
                        (context, flex, child) => _ListDetailViewTwoPaneLayout(
                          duration: duration,
                          curve: curve,
                          shift: shift,
                          flex: flex!,
                          padding: _configuration.padding,
                          list: _ListDetailViewCard(
                            duration: duration,
                            curve: curve,
                            shape: Shapes.medium,
                            child: CustomScrollView(
                              slivers: [
                                StreamBuilder(
                                  stream: _userController.stream,
                                  builder: (context, snapshot) {
                                    final user = snapshot.data;

                                    if (user != null) {
                                      // final notes = user.notes;
                                      final notes = [];
                                      return SliverPadding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        sliver: SliverList.separated(
                                          itemCount: notes.length,
                                          separatorBuilder:
                                              (context, index) =>
                                                  const SizedBox(height: 8),
                                          itemBuilder: (context, index) {
                                            final note = notes[index];
                                            return NoteCard(
                                              headline:
                                                  note.title != null
                                                      ? Text(note.title!)
                                                      : null,
                                              supportingText: Text(
                                                parseQuillDeltaDocument(
                                                      note.rawQuillDelta,
                                                    )
                                                    .map(
                                                      (node) =>
                                                          node is TextNode
                                                              ? node.text
                                                                  .toPlainText()
                                                              : null,
                                                    )
                                                    .toString(),
                                                maxLines: 100,
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    }
                                    return SliverToBoxAdapter();
                                  },
                                ),
                              ],
                            ),
                          ),
                          separator: const SizedBox(width: 24.0),
                          detail: _ListDetailViewCard(
                            duration: duration,
                            curve: curve,
                            shape: Shapes.medium,
                            child: NoteEditor(
                              windowWidthSizeClass: windowWidthSizeClass.clamp(
                                WindowWidthSizeClass.expanded,
                                null,
                              ),
                            ),
                          ),
                        ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          !_configuration.isFloatingActionButtonContained
              ? AnimatedPadding(
                duration: duration,
                curve: curve,
                padding: _configuration.floatingActionButtonPadding,
                child: _buildFloatingActionButton(context),
              )
              : null,

      bottomNavigationBar: _ListDetailViewNavigationBar(
        duration: duration,
        curve: curve,
        heightFactor: _configuration.showNavigationBar ? 1.0 : 0.0,
        opacity: _configuration.showNavigationBar ? 1.0 : 0.0,
        onDestinationSelected: _onDestinationSelected,
        selectedIndex: _selectedIndex,
        destinations: destinations.toNavigationBarDestinations().toList(),
      ),
    );
  }
}

class _ListDetailViewList extends StatefulWidget {
  const _ListDetailViewList({super.key});

  @override
  State<_ListDetailViewList> createState() => _ListDetailViewListState();
}

class _ListDetailViewListState extends State<_ListDetailViewList> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floating = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => true, // TODO: change to false
    };
    return RefreshIndicator(
      onRefresh: () => Future.delayed(const Duration(seconds: 1)),
      child: CustomScrollView(
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        slivers: [
          _SliverSearchBar(
            pinned: !floating,
            floating: floating,
            // pinned: false,
            // floating: true,
            leading: const Icon(Symbols.search),
            hintText: "Search your notes",
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.separated(
              itemCount: 50,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              // itemBuilder:
              //     (context, index) => Material(
              //       type: MaterialType.card,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: const BorderRadius.all(Radii.medium),
              //         side: BorderSide(color: theme.colorScheme.outlineVariant),
              //       ),
              //       clipBehavior: Clip.antiAlias,
              //       child: InkWell(onTap: () {}, child: SizedBox(height: 100)),
              //     ),
              itemBuilder:
                  (context, index) => NoteCard(
                    checked: index > 2,
                    selected: index == 1,
                    headline: Text("Lorem ipsum"),
                    supportingText: Text(
                      "Labore tempor exercitation reprehenderit non ex elit nisi in nisi excepteur. Ullamco velit consequat labore occaecat mollit duis nisi mollit. Tempor nostrud deserunt magna labore eiusmod sit. Exercitation anim deserunt dolore eu nisi enim deserunt irure esse occaecat aute. Aliqua ea reprehenderit qui ipsum consectetur ullamco ea quis non ut.",
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListDetailViewCard extends ImplicitlyAnimatedWidget {
  const _ListDetailViewCard({
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
  ImplicitlyAnimatedWidgetState<_ListDetailViewCard> createState() =>
      _ListDetailViewCardState();
}

class _ListDetailViewCardState
    extends AnimatedWidgetBaseState<_ListDetailViewCard> {
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
      color: theme.colorScheme.surface,
      shape: shape,
      child: widget.child,
    );
  }
}

class _SliverSearchBar extends StatefulWidget {
  const _SliverSearchBar({
    super.key,
    this.pinned = false,
    this.floating = false,
    this.padding,
    this.leading,
    this.hintText,
  });

  final bool pinned;
  final bool floating;

  final EdgeInsetsGeometry? padding;
  final Widget? leading;
  final String? hintText;

  @override
  State<_SliverSearchBar> createState() => _SliverSearchBarState();
}

class _SliverSearchBarState extends State<_SliverSearchBar>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      key: _key,
      pinned: widget.pinned,
      floating: widget.floating,
      delegate: _SliverSearchBarDelegate(
        onTap: () {
          final renderObject = _key.currentContext?.findRenderObject();
          renderObject?.showOnScreen(
            duration: Durations.long4,
            curve: Easing.emphasized,
          );
        },
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        leading: widget.leading,
        hintText: widget.hintText,
        vsync: this,
        snapConfiguration: FloatingHeaderSnapConfiguration(
          duration: Durations.long4,
          curve: Easing.emphasized,
        ),
      ),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverSearchBarDelegate({
    this.onTap,
    this.onTapOutside,
    this.padding = EdgeInsets.zero,
    this.leading,
    this.hintText,
    this.vsync,
    this.snapConfiguration,
  });

  final VoidCallback? onTap;
  final PointerDownEventListener? onTapOutside;
  final EdgeInsetsGeometry padding;
  final Widget? leading;
  final String? hintText;

  @override
  final TickerProvider? vsync;

  @override
  final FloatingHeaderSnapConfiguration? snapConfiguration;

  @override
  double get minExtent => 16 + 56 + 16;

  @override
  double get maxExtent => 16 + 56 + 16;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    // final heightFactor = 1.0 - shrinkOffset / maxExtent;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          height: 16 + 56 / 2,
          right: 0,
          child: Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.none,
            color: theme.colorScheme.surface,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          // child: SearchBar(
          //   onTap: () => onTap?.call(),
          //   onTapOutside: (event) => onTapOutside?.call(event),
          //   padding: WidgetStatePropertyAll(padding),
          //   shadowColor: WidgetStateColor.transparent,
          //   leading: leading,
          //   hintText: hintText,
          // ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 360,
              maxWidth: 720,
              minHeight: 56,
              maxHeight: 56,
            ),
            child: Material(
              animationDuration: Duration.zero,
              type: MaterialType.button,
              clipBehavior: Clip.antiAlias,
              shape: Shapes.full,
              elevation: 6.0,
              color: theme.colorScheme.surfaceContainerHigh,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              child: InkWell(
                onTap: () {},
                overlayColor: WidgetStateLayerColor(
                  theme.colorScheme.onSurface,
                  opacity: stateTheme.stateLayerOpacity,
                ),
                child: Padding(
                  padding: padding,
                  child: Flex.horizontal(
                    children: [
                      if (leading != null)
                        IconTheme.merge(
                          data: IconThemeData(
                            color: theme.colorScheme.onSurface,
                          ),
                          child: leading!,
                        ),
                      const Gap(16),
                      Expanded(
                        child: Text(
                          hintText ?? "",
                          style: theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _SliverSearchBarDelegate oldDelegate) {
    return padding != oldDelegate.padding ||
        leading != oldDelegate.leading ||
        hintText != oldDelegate.hintText;
  }
}

class _SliverSearchView extends StatefulWidget {
  const _SliverSearchView({super.key});

  @override
  State<_SliverSearchView> createState() => __SliverSearchViewState();
}

class __SliverSearchViewState extends State<_SliverSearchView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _ListDetailViewTwoPaneLayout extends ImplicitlyAnimatedWidget {
  const _ListDetailViewTwoPaneLayout({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    this.shift = 0.0,
    this.flex = const TwoPaneLayoutFlexFactor(0.0),
    this.padding = EdgeInsets.zero,
    required this.list,
    this.separator,
    required this.detail,
  });

  final double shift;
  final TwoPaneLayoutFlexFactor flex;
  final EdgeInsetsGeometry padding;

  final Widget list;
  final Widget? separator;
  final Widget detail;

  @override
  ImplicitlyAnimatedWidgetState<_ListDetailViewTwoPaneLayout> createState() =>
      _ListDetailViewTwoPaneLayoutState();
}

class _ListDetailViewTwoPaneLayoutState
    extends AnimatedWidgetBaseState<_ListDetailViewTwoPaneLayout> {
  Tween<EdgeInsetsGeometry>? _paddingTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _paddingTween =
        visitor(
              _paddingTween,
              widget.padding,
              (value) =>
                  EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry),
            )
            as Tween<EdgeInsetsGeometry>?;
  }

  @override
  Widget build(BuildContext context) {
    final padding = _paddingTween?.evaluate(animation) ?? widget.padding;
    return TwoPaneLayout(
      shift: widget.shift,
      flex: widget.flex,
      padding: padding,
      list: widget.list,
      separator: widget.separator,
      detail: widget.detail,
    );
  }
}

class _ListDetailViewNavigationBar extends ImplicitlyAnimatedWidget {
  const _ListDetailViewNavigationBar({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    this.heightFactor = 1.0,
    this.padding = 0.0,
    this.opacity = 1.0,
    this.onDestinationSelected,
    required this.selectedIndex,
    required this.destinations,
  }) : assert(destinations.length >= 2);

  final double heightFactor;
  final double padding;
  final double opacity;

  final ValueChanged<int>? onDestinationSelected;
  final int selectedIndex;
  final List<NavigationDestination> destinations;

  @override
  ImplicitlyAnimatedWidgetState<_ListDetailViewNavigationBar> createState() =>
      _ListDetailViewNavigationBarState();
}

class _ListDetailViewNavigationBarState
    extends AnimatedWidgetBaseState<_ListDetailViewNavigationBar> {
  Tween<double>? _heightFactorTween;
  Tween<double>? _paddingTween;
  Tween<double>? _opacityTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _heightFactorTween =
        visitor(
              _heightFactorTween,
              widget.heightFactor,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _paddingTween =
        visitor(
              _paddingTween,
              widget.padding,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _opacityTween =
        visitor(
              _opacityTween,
              widget.opacity,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heightFactor =
        _heightFactorTween?.evaluate(animation) ?? widget.heightFactor;
    final padding = _paddingTween?.evaluate(animation) ?? widget.padding;
    final opacity = _opacityTween?.evaluate(animation) ?? widget.opacity;
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: heightFactor,
      child: Transform.translate(
        offset: Offset(0.0, -padding),
        child: Opacity(
          opacity: opacity,
          child: NavigationBar(
            backgroundColor: theme.colorScheme.surfaceContainer,
            onDestinationSelected: widget.onDestinationSelected,
            selectedIndex: widget.selectedIndex,
            destinations: widget.destinations,
          ),
        ),
      ),
    );
  }
}

class _ListDetailViewNavigationRail extends ImplicitlyAnimatedWidget {
  const _ListDetailViewNavigationRail({
    super.key,
    required super.duration,
    super.curve = Easing.linear,
    super.onEnd,
    this.widthFactor = 1.0,
    this.offset = Offset.zero,
    this.opacity = 1.0,
    this.leading,
    this.onDestinationSelected,
    required this.selectedIndex,
    required this.destinations,
  }) : assert(destinations.length >= 2);

  final double widthFactor;
  final Offset offset;
  final double opacity;

  final Widget? leading;

  final ValueChanged<int>? onDestinationSelected;
  final int selectedIndex;
  final List<NavigationRailDestination> destinations;

  @override
  ImplicitlyAnimatedWidgetState<_ListDetailViewNavigationRail> createState() =>
      _ListDetailViewNavigationRailState();
}

class _ListDetailViewNavigationRailState
    extends AnimatedWidgetBaseState<_ListDetailViewNavigationRail> {
  Tween<double>? _widthFactorTween;
  Tween<Offset>? _offsetTween;
  Tween<double>? _opacityTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactorTween =
        visitor(
              _widthFactorTween,
              widget.widthFactor,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
    _offsetTween =
        visitor(
              _offsetTween,
              widget.offset,
              (value) => Tween<Offset>(begin: value as Offset),
            )
            as Tween<Offset>?;
    _opacityTween =
        visitor(
              _opacityTween,
              widget.opacity,
              (value) => Tween<double>(begin: value as double),
            )
            as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widthFactor =
        _widthFactorTween?.evaluate(animation) ?? widget.widthFactor;
    final offset = _offsetTween?.evaluate(animation) ?? widget.offset;
    final opacity = _opacityTween?.evaluate(animation) ?? widget.opacity;
    return Align(
      alignment: Alignment.centerRight,
      widthFactor: widthFactor,
      child: Transform.translate(
        offset: offset,
        child: Opacity(
          opacity: opacity,
          child: NavigationRail(
            backgroundColor: theme.colorScheme.surfaceContainer,
            labelType: NavigationRailLabelType.all,
            groupAlignment: 0,
            leading: widget.leading,
            onDestinationSelected: widget.onDestinationSelected,
            selectedIndex: widget.selectedIndex,
            destinations: widget.destinations,
          ),
        ),
      ),
    );
  }
}
