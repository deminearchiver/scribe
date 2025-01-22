import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribe/accordion.dart';
import 'package:scribe/app_icons.dart';
import 'package:scribe/keep.dart';
import 'package:scribe/misc.dart';
import 'package:archive/archive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: "/",
      onGenerateInitialRoutes: (navigator, initialRoute) {
        return [
          MaterialRoute(builder: (context) => const OnboardingWelcomePage()),
        ];
      },
    );
  }
}

class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.headline,
    required this.content,
    this.actionsPadding,
    required this.actions,
  });

  final Widget headline;

  final Widget content;

  final EdgeInsetsGeometry? actionsPadding;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineTextStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final supportingTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      body: Flex.vertical(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: DefaultTextStyle.merge(
              textAlign: TextAlign.start,
              style: headlineTextStyle,
              child: headline,
            ),
          ),
          content,
          Padding(
            padding:
                actionsPadding ?? const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [...actions],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingWelcomePage extends StatefulWidget {
  const OnboardingWelcomePage({super.key});

  @override
  State<OnboardingWelcomePage> createState() => _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends State<OnboardingWelcomePage> {
  bool _accessibility = false;

  void _closeAccessibility() {
    if (_accessibility) setState(() => _accessibility = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineTextStyle = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return OnboardingScaffold(
      headline: Text("Welcome to your Scribe"),
      content: ListTileTheme(
        data: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Flex.vertical(
          children: [
            ListTile(
              onTap: () {
                _closeAccessibility();
              },
              leading: Icon(Symbols.language, color: theme.colorScheme.primary),
              title: Text("Language"),
              subtitle: Text("English (United States)"),
            ),
            ListTile(
              onTap: () => setState(() => _accessibility = !_accessibility),
              leading: Icon(
                Symbols.accessibility_new,
                color: theme.colorScheme.primary,
              ),
              title: Text("Accessibility"),
              trailing: AnimatedRotation(
                duration: Durations.extralong2,
                curve: Easing.emphasized,
                turns: _accessibility ? -0.5 : 0.0,
                child: Icon(Symbols.keyboard_arrow_down),
              ),
            ),
            ClipRect(
              clipBehavior: Clip.hardEdge,
              child: AnimatedOpacity(
                duration: Durations.extralong2,
                curve: Easing.emphasized,
                opacity: _accessibility ? 1.0 : 0.0,
                child: AnimatedAlign(
                  duration: Durations.extralong2,
                  curve: Easing.emphasized,
                  alignment: Alignment.topCenter,
                  heightFactor: _accessibility ? 1.0 : 0.0,
                  child: Flex.vertical(
                    children: [ListTile(title: Text("Text"))],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        const Spacer(),
        FilledButton(
          onPressed:
              () => Navigator.push(
                context,
                MaterialRoute(builder: (context) => const OnboardingMigrate()),
              ),
          label: Text("Get started"),
        ),
      ],
    );
    // return Scaffold(
    //   body: Flex.vertical(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       const Spacer(),
    //       Padding(
    //         padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
    //         child: Text(
    //           "Welcome to your Scribe",
    //           textAlign: TextAlign.start,
    //           style: headlineTextStyle,
    //         ),
    //       ),

    //       ListTileTheme(
    //         data: ListTileThemeData(
    //           contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    //         ),
    //         child: Flex.vertical(
    //           children: [
    //             ListTile(
    //               onTap: () {
    //                 _closeAccessibility();
    //               },
    //               leading: Icon(
    //                 Symbols.language,
    //                 color: theme.colorScheme.primary,
    //               ),
    //               title: Text("Language"),
    //               subtitle: Text("English (United States)"),
    //             ),
    //             ListTile(
    //               onTap: () => setState(() => _accessibility = !_accessibility),
    //               leading: Icon(
    //                 Symbols.accessibility_new,
    //                 color: theme.colorScheme.primary,
    //               ),
    //               title: Text("Accessibility"),
    //               trailing: AnimatedRotation(
    //                 duration: Durations.extralong2,
    //                 curve: Easing.emphasized,
    //                 turns: _accessibility ? -0.5 : 0.0,
    //                 child: Icon(Symbols.keyboard_arrow_down),
    //               ),
    //             ),
    //             ClipRect(
    //               clipBehavior: Clip.hardEdge,
    //               child: AnimatedOpacity(
    //                 duration: Durations.extralong2,
    //                 curve: Easing.emphasized,
    //                 opacity: _accessibility ? 1.0 : 0.0,
    //                 child: AnimatedAlign(
    //                   duration: Durations.extralong2,
    //                   curve: Easing.emphasized,
    //                   alignment: Alignment.topCenter,
    //                   heightFactor: _accessibility ? 1.0 : 0.0,
    //                   child: Flex.vertical(
    //                     children: [ListTile(title: Text("Text"))],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
    //         child: Row(
    //           children: [
    //             // TextButton(onPressed: () {}, label: Text("Back")),
    //             const Spacer(),
    //             FilledButton(
    //               onPressed:
    //                   () => Navigator.push(
    //                     context,
    //                     MaterialRoute(
    //                       builder: (context) => const OnboardingWelcomePage(),
    //                     ),
    //                   ),
    //               label: Text("Get started"),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class OnboardingMigrate extends StatefulWidget {
  const OnboardingMigrate({super.key});

  @override
  State<OnboardingMigrate> createState() => _OnboardingMigrateState();
}

class _OnboardingMigrateState extends State<OnboardingMigrate> {
  late ScrollController _scrollController;

  final Set<int> _expanded = <int>{};

  bool _scrolledUnder = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // final isScrollable = _scrollController.position.maxScrollExtent > 0.0;
    // final scrolledUnder =
    //     isScrollable && _scrollController.position.pixels > 0.0;
    // if (scrolledUnder != _scrolledUnder) {
    //   setState(() => _scrolledUnder = scrolledUnder);
    // }
  }

  bool _updateScrolledUnder(ScrollMetricsNotification notification) {
    final isScrollable = notification.metrics.maxScrollExtent > 0.0;
    final hasScrolled = notification.metrics.pixels > 0.0;
    final maxScrollReached =
        notification.metrics.maxScrollExtent == notification.metrics.pixels;

    final isScrolledUnder = isScrollable && !maxScrollReached && hasScrolled;
    if (isScrolledUnder != _scrolledUnder) {
      setState(() => _scrolledUnder = isScrolledUnder);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    debugPrint("$_expanded");
    return Scaffold(
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: _updateScrolledUnder,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverTopAppBar.small(
            //   leading: IconButton(
            //     onPressed: () {},
            //     icon: const Icon(Symbols.arrow_back),
            //   ),
            // ),
            SliverList.list(
              children: [
                const Gap(48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Symbols.sync_alt,
                        size: 48,
                        opticalSize: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const Gap(16),
                      Text(
                        "Migrate from another app",
                        style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        "Easily copy notes from other apps to Scribe",
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 24),
                //   child: AspectRatio(
                //     aspectRatio: 21 / 9,

                //     child: Material(
                //       shape: Shapes.extraLarge,
                //       color: theme.colorScheme.scrim,
                //     ),
                //   ),
                // ),
                // const Gap(24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Choose a supported app",
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const Gap(12),
                      Flex.vertical(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 4,
                        children: [
                          ...Iterable.generate(
                            1,
                            (index) => AppCard(
                              onExpandedChanged:
                                  (value) => setState(
                                    () =>
                                        value
                                            ? _expanded.add(index)
                                            : _expanded.remove(index),
                                  ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top:
                                      index > 0.0
                                          ? _expanded.contains(index - 1)
                                              ? Radii.extraLarge
                                              : Radii.small
                                          : Radii.extraLarge,
                                  bottom:
                                      _expanded.contains(index + 1)
                                          ? Radii.extraLarge
                                          : Radii.small,
                                ),
                              ),
                              // leadingAvatar: const GoogleKeepAvatar(size: 40),
                              // leadingAvatar: const GoogleKeepIcon(size: 40),
                              leadingAvatar: const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: GoogleKeepIcon(),
                              ),
                              // leadingAvatar: CircleAvatar(
                              //   backgroundColor: theme.colorScheme.secondary,
                              //   foregroundColor: theme.colorScheme.onSecondary,
                              //   child: const Icon(Symbols.lightbulb, fill: 1),
                              // ),
                              headline: Text("Google Keep"),
                              items: const [
                                AppCardItem(
                                  headline: Text("Features"),
                                  supportingText: Text(
                                    "Import your notes from Google Keep into Scribe, keeping text formatting and images",
                                  ),
                                ),
                                AppCardItem(
                                  headline: Text("Permission"),
                                  supportingText: Text(
                                    "It will be required to provide Scribe access to the full Google Takeout \"Keep\" subdirectory",
                                  ),
                                ),
                                AppCardItem(
                                  headline: Text("Data loss"),
                                  supportingText: Text(
                                    "Some data might be lost, such as labels assigned to notes",
                                  ),
                                ),
                              ],
                              footer: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  12,
                                ),
                                // child: FilledButton(
                                //   onPressed:
                                //       () => Navigator.push(
                                //         context,
                                //         MaterialRoute(
                                //           builder:
                                //               (context) =>
                                //                   const KeepNoteImport(),
                                //         ),
                                //       ),
                                //   label: Text("Continue with Keep"),
                                // ),
                                child: Flex.horizontal(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialRoute(
                                                builder:
                                                    (context) =>
                                                        const KeepNoteImport(),
                                              ),
                                            ),
                                        label: Text("Skip tutorial"),
                                      ),
                                    ),

                                    const Gap(8.0),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {},
                                        label: Text("Step-by-step guide"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // AppCard(
                          //   onExpandedChanged:
                          //       (value) => setState(
                          //         () =>
                          //             value
                          //                 ? _expanded.add(0)
                          //                 : _expanded.remove(0),
                          //       ),
                          //   // leadingAvatar: const GoogleKeepAvatar(size: 40),
                          //   // leadingAvatar: const GoogleKeepIcon(size: 40),
                          //   leadingAvatar: CircleAvatar(
                          //     backgroundColor: Colors.white,
                          //     child: const GoogleKeepIcon(),
                          //   ),
                          //   // leadingAvatar: CircleAvatar(
                          //   //   backgroundColor: theme.colorScheme.secondary,
                          //   //   foregroundColor: theme.colorScheme.onSecondary,
                          //   //   child: const Icon(Symbols.lightbulb, fill: 1),
                          //   // ),
                          //   headline: Text("Google Keep"),
                          // ),
                          Tooltip(
                            message:
                                "Stay tuned for more apps to transfer data from!",
                            child: Material(
                              animationDuration: Duration.zero,
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(
                                top: Radii.small,
                                bottom: Radii.extraLarge,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Text(
                                  "More apps coming soon!",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(16),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Flex.vertical(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end:
                  _scrolledUnder
                      ? theme.colorScheme.surfaceContainer
                      : theme.colorScheme.surface,
            ),
            duration: Durations.short4,
            curve: Easing.standard,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Flex.vertical(
                children: [
                  Flex.horizontal(
                    children: [
                      // TextButton(
                      //       onPressed: () {},
                      //       label: Text("Back"),
                      //     ),

                      //   const Gap(8),
                      TextButton(onPressed: () {}, label: Text("Skip")),
                    ],
                  ),
                ],
              ),
            ),
            builder:
                (context, value, child) =>
                    Material(color: value!, child: child),
          ),
        ],
      ),
    );
  }
}

@immutable
class AppCardItem {
  const AppCardItem({this.icon, this.headline, this.supportingText});

  final Widget? icon;
  final Widget? headline;
  final Widget? supportingText;
}

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    this.focusNode,
    this.onExpandedChanged,
    this.collapsedShape,
    this.expandedShape,
    required this.leadingAvatar,
    required this.headline,
    this.items = const [],
    this.footer,
  });

  final FocusNode? focusNode;

  final ValueChanged<bool>? onExpandedChanged;

  final OutlinedBorder? collapsedShape;
  final OutlinedBorder? expandedShape;

  final Widget leadingAvatar;
  final Widget headline;
  final List<AppCardItem> items;
  final Widget? footer;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _expanded = false;

  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    }
  }

  @override
  void didUpdateWidget(covariant AppCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _internalFocusNode?.dispose();
      if (widget.focusNode == null) {
        _internalFocusNode = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  Widget _buildContainer(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final shape =
        _expanded
            ? widget.expandedShape ?? Shapes.extraLarge
            : widget.collapsedShape ??
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radii.extraLarge,
                    bottom: Radii.small,
                  ),
                );

    return TweenAnimationBuilder<OutlinedBorder?>(
      tween: OutlinedBorderTween(end: shape),
      duration: Durations.medium4,
      curve: Easing.standard,
      child: child,
      builder:
          (context, value, child) => Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.antiAlias,
            shape: value!,
            color: theme.colorScheme.secondaryContainer,
            child: child!,
          ),
    );
  }

  Widget _buildListItemBullet(BuildContext context, int index) {
    final theme = Theme.of(context);
    return Transform.rotate(
      angle: math.pi * 0.2 * index,
      child: ExpressiveListBulletIcon(
        size: 8.0,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildIcon(BuildContext context, int index) {
    final theme = Theme.of(context);

    final listItemBullet = _buildListItemBullet(context, index);
    final icon = widget.items[index].icon;
    return SizedBox.square(
      dimension: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // if (icon != null)
          //   IconTheme.merge(
          //     data: IconThemeData(
          //       size: 36.0,
          //       opticalSize: 36.0,
          //       fill: 0,
          //       color: theme.colorScheme.onSurfaceVariant,
          //     ),
          //     child: icon,
          //   ),
          listItemBullet,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    return _buildContainer(
      context,
      Flex.vertical(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            focusNode: _focusNode,
            onTap: () {
              setState(() => _expanded = !_expanded);
              widget.onExpandedChanged?.call(_expanded);
            },
            overlayColor: WidgetStateLayerColor(
              theme.colorScheme.onSecondaryContainer,
              opacity: stateTheme.stateLayerOpacity,
            ),
            // customBorder: Shapes.extraLarge,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Flex.horizontal(
                children: [
                  widget.leadingAvatar,
                  const Gap(16),
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    child: widget.headline,
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    duration: Durations.medium4,
                    curve: Easing.standard,
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Symbols.keyboard_arrow_down,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedAlign(
            duration: Durations.medium4,
            curve: Easing.standard,
            alignment: Alignment.topCenter,
            heightFactor: _expanded ? 1.0 : 0.0,
            child: AnimatedOpacity(
              duration: Durations.medium4,
              curve: Easing.standard,
              opacity: _expanded ? 1.0 : 0.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTileTheme(
                    data: ListTileThemeData(
                      minLeadingWidth: 40.0,
                      horizontalTitleGap: 16,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Flex.vertical(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...widget.items.mapIndexed(
                          (index, item) => ListTile(
                            // leading: Transform.rotate(
                            //   angle: math.pi * 0.2 * index,
                            //   child: ExpressiveListBulletIcon(
                            //     size: 8.0,
                            //     color: theme.colorScheme.primary,
                            //   ),
                            // ),
                            leading: _buildIcon(context, index),

                            title:
                                item.headline != null
                                    ? DefaultTextStyle.merge(
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      child: item.headline!,
                                    )
                                    : null,
                            subtitle:
                                item.supportingText != null
                                    ? DefaultTextStyle.merge(
                                      style: TextStyle(
                                        color:
                                            item.headline == null
                                                ? theme.colorScheme.onSurface
                                                : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                      ),
                                      child: item.supportingText!,
                                    )
                                    : null,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ...Iterable.generate(
                  //   3,
                  //   (index) => ListTile(
                  //     leading: Transform.rotate(
                  //       // 36 deg = pi * 36 / 180 = pi * 0.2
                  //       angle: math.pi * 0.2 * index,
                  //       child: ExpressiveListBulletIcon(),
                  //     ),
                  //     title: Text("AAA"),
                  //   ),
                  // ),
                  if (widget.footer != null) widget.footer!,
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  //   child: FilledButton(
                  //     onPressed: () {},
                  //     label: Text("Continue with Keep"),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingAllSetPage extends StatelessWidget {
  const OnboardingAllSetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineTextStyle = theme.textTheme.headlineLarge!.copyWith(
      color: theme.colorScheme.onSurface,
    );

    return Scaffold(
      body: Flex.vertical(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Flex.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Symbols.check,
                  size: 48,
                  opticalSize: 48,
                  color: theme.colorScheme.primary,
                ),
                const Gap(8),
                Text("All set!", style: headlineTextStyle),
                const Gap(8),
                Text(
                  "You are ready to start using Scribe",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Flex.vertical(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Things to do next",
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Expanded(child: ListView(children: [ListTile()])),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: FilledButton(
              onPressed: () {},
              icon: const Icon(Symbols.rocket_launch, fill: 1),
              label: Text("Let's go!"),
            ),
          ),
        ],
      ),
    );
  }
}

class OutlinedBorderTween extends Tween<OutlinedBorder?> {
  /// Creates a [OutlinedBorder] tween.
  ///
  /// the [begin] and [end] properties may be null; see [OutlinedBorder.lerp] for
  /// the null handling semantics.
  OutlinedBorderTween({super.begin, super.end});

  /// Returns the value this tween has at the given animation clock value.
  @override
  OutlinedBorder? lerp(double t) {
    return OutlinedBorder.lerp(begin, end, t);
  }
}

class KeepNoteImport extends StatefulWidget {
  const KeepNoteImport({super.key});

  @override
  State<KeepNoteImport> createState() => _KeepNoteImportState();
}

class _KeepNoteImportState extends State<KeepNoteImport> {
  int? _expanded;

  Future<String?> _getInitialDirectory() async {
    final downloadsDirectory = await getDownloadsDirectory();
    return downloadsDirectory?.path;
  }

  Future<void> _openArchive() async {
    final initialDirectory = await _getInitialDirectory();
    final result = await FilePicker.platform.pickFiles(
      lockParentWindow: true,
      initialDirectory: initialDirectory,
      type: FileType.custom,
      allowedExtensions: ["zip", "tar", "gz"],
    );
    if (result == null) return;
    if (result.paths.isEmpty) return;
    final path = result.paths.single;
    if (path == null) return;
    final file = File(path);
    final ext = p.extension(path);
    final bytes = await file.readAsBytes();
    final archive = switch (ext) {
      ".zip" => ZipDecoder().decodeBytes(bytes),
      ".tar" => TarDecoder().decodeBytes(bytes),
      _ => null,
    };
    if (archive == null) return;

    String? keepPath;
    for (final entry in archive) {
      if (entry.isFile) {
        final dirname = p.dirname(entry.name);
        final basename = p.basename(entry.name);
        if (basename == "archive_browser.html") {
          keepPath = p.join(dirname, "Keep");
        }
      }
    }
    if (keepPath == null) return;
    for (final entry in archive) {
      if (entry.isFile) {
        final dirname = p.dirname(entry.name);
        final basename = p.basename(entry.name);
        if (p.equals(dirname, keepPath)) {
          final ext = p.extension(basename);
          switch (entry.name) {
            // case "Labels.txt":
            case _ when ext == ".json":
              final jsonBytes = entry.readBytes();
              if (jsonBytes == null) continue;
              final jsonString = utf8.decode(jsonBytes);
              final json = jsonDecode(jsonString);
              final keepNote = KeepNote.fromJson(json);
            case _ when ext == ".png":
          }
        }
      }
    }
  }

  Future<void> _openFolder() async {
    final initialDirectory = await _getInitialDirectory();
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
      initialDirectory: initialDirectory,
    );
    if (directoryPath == null) return;
    final directory = Directory(directoryPath);
    final list = directory.list(recursive: false);
    await for (final file in list) {
      if (file is! File) return;
      final path = file.path;
      final name = p.basename(path);
      final nameWithoutExtension = p.basenameWithoutExtension(path);
      final extension = p.extension(path);

      switch (nameWithoutExtension) {
        case "Labels" when extension == ".txt":
          final labels = await file.readAsString();
          // debugPrint("${labels.split("\n")}");
          break;
        case _ when extension == ".json":
          final jsonString = await file.readAsString();
          final json = jsonDecode(jsonString);
          final keepNote = KeepNote.fromJson(json);
          debugPrint("${keepNote}");
          break;
        case _ when extension == ".png":
        case _ when extension == ".jpg":
        case _ when extension == ".gif":
          break;
        case _ when extension == ".html":
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverTopAppBar.small(),
          SliverList.list(
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 24),
              //   child: Material(
              //     color: theme.colorScheme.errorContainer,
              //     shape: Shapes.extraLarge,
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              //       child: Flex.vertical(
              //         children: [
              //           Flex.horizontal(
              //             children: [
              //               Icon(
              //                 Symbols.warning,
              //                 color: theme.colorScheme.onErrorContainer,
              //               ),
              //               const Gap(16),
              //               Text(
              //                 "Warning",
              //                 style: theme.textTheme.titleMedium!.copyWith(
              //                   color: theme.colorScheme.onErrorContainer,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Accordion<int>(
                  onExpandedChanged: (value) {
                    final difference = value.difference({_expanded});
                    setState(() => _expanded = difference.singleOrNull);
                  },
                  expanded: {if (_expanded != null) _expanded!},
                  items: [
                    AccordionItem(
                      value: 0,
                      leading: Icon(Symbols.folder_zip),
                      headline: Text("Archive"),
                      supportingText: Text(
                        "Use a structured Google Takeout archive",
                      ),
                      child: Text("Expanded"),
                    ),
                    AccordionItem(
                      value: 1,
                      leading: Icon(Symbols.folder),
                      headline: Text("Folder"),
                      supportingText: Text(
                        "Use Google Takeout \"Keep\" subfolder",
                      ),
                      child: Flex.vertical(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: SizedBox(
                              width: 24,
                              child: ExpressiveListBulletIcon(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            title: Text("AAAAA"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: FilledButton(
                              onPressed: () {},
                              label: Text("Choose a folder"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AccordionItem(
                      value: 2,
                      headline: Text("Choose a folder"),
                      child: Text("Expanded"),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap:
                    () => setState(() => _expanded = _expanded != 0 ? 0 : null),
                leading: Icon(Symbols.folder),
                title: Text("Choose a folder"),
                subtitle: Text("Folder containing Google Keep Takeout files"),
                // trailing: Icon(Symbols.open_in_new),
                // trailing: Icon(Symbols.navigate_next),
                trailing: FilledButton(onPressed: () {}, label: Text("Open")),
              ),
              ListTile(
                onTap:
                    () => setState(() => _expanded = _expanded != 1 ? 1 : null),
                leading: Icon(Symbols.folder_zip),
                title: Text("Choose an archive"),
                subtitle: Text("Use full Google Takeout archive"),
                // trailing: Icon(Symbols.open_in_new),
                // trailing: Icon(Symbols.navigate_next),
                trailing: AnimatedRotation(
                  duration: Durations.medium4,
                  curve: Easing.standard,
                  turns: _expanded == 1 ? 0.5 : 0,
                  child: Icon(Symbols.keyboard_arrow_down),
                ),
              ),
              AnimatedOpacity(
                duration: Durations.medium4,
                curve: Easing.standard,
                opacity: _expanded == 1 ? 1.0 : 0.0,
                child: ClipRect(
                  child: AnimatedAlign(
                    duration: Durations.medium4,
                    curve: Easing.standard,
                    alignment: Alignment.topCenter,
                    heightFactor: _expanded == 1 ? 1.0 : 0.0,
                    child: Flex.vertical(
                      children: [
                        Text(
                          "Enim voluptate dolor nostrud nulla minim ea amet irure sunt.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Flex.horizontal(
                children: [
                  Expanded(
                    child: FilledTonalButton(
                      onPressed: _openArchive,
                      icon: const Icon(Symbols.folder_zip, fill: 1),
                      label: Text("Choose an archive"),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FilledTonalButton(
                      onPressed: _openFolder,
                      icon: const Icon(Symbols.folder, fill: 1),
                      label: Text("Choose a folder"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
