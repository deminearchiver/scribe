import 'dart:math' as math;
import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material/material.dart';
import 'package:scribe/accordion.dart';
import 'package:scribe/brick/repository.dart';
import 'package:scribe/gen/assets.gen.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension _UserExtension on User {
  OAuthProvider? get providerOrNull {
    final provider = appMetadata["provider"];
    if (provider != null && provider is String) {
      return OAuthProvider.values.firstWhereOrNull(
        (value) => value.name == provider,
      );
    }
    return null;
  }

  Set<OAuthProvider> get providers {
    final providers = appMetadata["providers"];
    if (providers != null && providers is List) {
      final Set<OAuthProvider> values = <OAuthProvider>{};
      for (final name in providers) {
        if (name is! String) continue;
        final value = OAuthProvider.values.firstWhereOrNull(
          (value) => value.name == name,
        );
        if (value != null) values.add(value);
      }
      return UnmodifiableSetView(values);
    }

    final provider = providerOrNull;
    return UnmodifiableSetView({if (provider != null) provider});
  }
}

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Repository _repository = Repository();

  late AuthController _controller;
  StreamSubscription<AuthState>? _subscription;

  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(
      webClientId:
          "73597778780-tuun4q8i2cbreah9603crvr4pss9cv84.apps.googleusercontent.com",
      iosClientId:
          "73597778780-8ognocm4dkbbk6p598afuun6cfkeaqth.apps.googleusercontent.com",
      redirectTo: "scribe://auth",
    )..addListener(_authListener);
    _subscription = _controller.stream.listen(_authStateListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AccountView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _signedInWith(OAuthProvider provider) {
    return _controller.session?.user.providers.contains(provider) ?? false;
  }

  void _authListener() {
    debugPrint("${_controller.event}");
    setState(() {});
  }

  void _authStateListener(AuthState state) {
    if (state.event == AuthChangeEvent.signedIn) {
      if (_isSigningIn) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            sliver: SliverList.list(
              children: [
                Text("${_controller.session?.user.providers}"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Symbols.account_circle,
                        size: 48,
                        opticalSize: 48,
                        color: theme.colorScheme.primary,
                      ),
                      const Gap(8),
                      Text(
                        "My account",
                        style: theme.textTheme.headlineLarge!.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        "Manage your Scribe account",
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Flex.vertical(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WarningCards(
                        children: [
                          WarningCard(
                            key: PageStorageKey(0),
                            icon: const Icon(Symbols.warning),
                            headline: Text("Only social accounts"),
                            supportingText: Text(
                              "Signing in with email or phone is not currently supported",
                            ),
                          ),
                          const WarningCard(
                            key: PageStorageKey(1),
                            icon: const Icon(Symbols.warning),
                            headline: Text("Unlinking not supported"),
                            supportingText: Text(
                              "After signing in with a social account you won't be able to unlink it from your Scribe account later",
                            ),
                          ),
                        ],
                      ),

                      Accordion(
                        items: [
                          AccordionItem.outlined(
                            onPressed: _controller.signInWithGoogle,
                            expanded: false,
                            borderRadius: BorderRadius.vertical(
                              top: Radii.extraLarge,
                              bottom: Radii.small,
                            ),

                            // leading: SizedBox(
                            //   width: 40,
                            //   child: Icon(SimpleIcons.google),
                            // ),
                            // headline: Text("Sign in with Google"),
                            // supportingText: Text(
                            //   "The recommended way to sign in",
                            // ),
                            // trailing: const Icon(Symbols.navigate_next),
                            leading: CircleAvatar(child: Icon(Symbols.check)),
                            headline: Text("Signed in with Google"),
                            supportingText: Text(
                              "The recommended way to sign in",
                            ),
                            // child: Padding(
                            //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            //   child: LinearProgressIndicator(value: 0.5),
                            // ),
                            child: null,
                          ),
                          AccordionItem.outlined(
                            expanded: true,
                            borderRadius: BorderRadius.all(Radii.small),
                            // leading: SizedBox(
                            //   width: 40,
                            //   child: const Icon(Symbols.apps),
                            // ),
                            // headline: Text("More ways to sign in"),
                            // supportingText: Text(
                            //   "Sign in with other social accounts",
                            // ),
                            // leading: CircularProgressIndicator(),
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Symbols.link,
                                  size: 18,
                                  opticalSize: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                CircularProgressIndicator(),
                              ],
                            ),
                            // leading: CircleAvatar(
                            //   child: CircularProgressIndicator.icon(
                            //     strokeWidth: 3,
                            //   ),
                            // ),
                            // leading: SizedBox(
                            //   width: 40,
                            //   child: const Icon(Symbols.link),
                            // ),
                            headline: Text("Link social accounts"),
                            supportingText: Text(
                              "Add other social accounts as sign in methods",
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                // Chips have a default height of 32,
                                // but the tap target height is 48
                                // (48 - 32) / 2 = 8 margin on top and bottom,
                                // which makes run spacing 8 + 8 = 16,
                                // so we subtract 8 to make run spacing be 8
                                runSpacing: -8,
                                children: [
                                  // OAuthChip(
                                  //   onPressed: _controller.signInWithGoogle,
                                  //   selected: _signedInWith(
                                  //     OAuthProvider.google,
                                  //   ),

                                  //   icon: Assets.images.brand.google.svg(
                                  //     width: 18,
                                  //     height: 18,
                                  //   ),
                                  //   selectedIcon: const Icon(
                                  //     SimpleIcons.google,
                                  //   ),
                                  //   label: const Text("Google"),
                                  // ),
                                  OAuthChip(
                                    onPressed: _controller.signInWithNotion,
                                    selected: _signedInWith(
                                      OAuthProvider.notion,
                                    ),
                                    icon: Assets.images.brand.notion.svg(
                                      width: 18,
                                      height: 18,
                                    ),
                                    selectedIcon: const Icon(
                                      SimpleIcons.notion,
                                    ),
                                    label: const Text("Notion"),
                                  ),
                                  OAuthChip(
                                    onPressed: _controller.signInWithFigma,
                                    selected: _signedInWith(
                                      OAuthProvider.figma,
                                    ),
                                    icon: Assets.images.brand.figma.svg(
                                      width: 18,
                                      height: 18,
                                    ),
                                    selectedIcon: const Icon(SimpleIcons.figma),
                                    label: const Text("Figma"),
                                  ),
                                  // if (!_signedInWith(OAuthProvider.discord))
                                  OAuthChip(
                                    onPressed: _controller.signInWithDiscord,
                                    selected: _signedInWith(
                                      OAuthProvider.discord,
                                    ),
                                    icon: Assets.images.brand.discord.svg(
                                      width: 18,
                                      height: 18,
                                    ),
                                    selectedIcon: const Icon(
                                      SimpleIcons.discord,
                                    ),
                                    label: const Text("Discord"),
                                  ),
                                  // if (!_signedInWith(OAuthProvider.github))
                                  OAuthChip(
                                    onPressed: _controller.signInWithGithub,
                                    selected: _signedInWith(
                                      OAuthProvider.github,
                                    ),
                                    icon: switch (theme.brightness) {
                                      Brightness.light => Assets
                                          .images
                                          .brand
                                          .githubLight
                                          .svg(width: 18, height: 18),

                                      Brightness.dark => Assets
                                          .images
                                          .brand
                                          .githubDark
                                          .svg(width: 18, height: 18),
                                    },
                                    selectedIcon: const Icon(
                                      SimpleIcons.github,
                                    ),
                                    label: Text("GitHub"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AccordionItem.outlined(
                            expanded: false,
                            borderRadius: BorderRadius.vertical(
                              top: Radii.small,
                              bottom: Radii.extraLarge,
                            ),
                            leading: const Icon(Symbols.lock_open),
                            headline: Text("Legacy methods"),
                            supportingText: Text(
                              "Authentication methods proven potentially unsafe",
                            ),
                            child: null,
                          ),
                        ],
                      ),

                      CommonButton.text(
                        onPressed: () => _supabase.auth.signOut(),
                        icon: const Icon(Symbols.logout),
                        label: Text("Log out"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WarningCards extends StatefulWidget {
  const WarningCards({super.key, required this.children})
    : assert(children.length >= 1);

  final List<Widget> children;

  @override
  State<WarningCards> createState() => _WarningCardsState();
}

class _WarningCardsState extends State<WarningCards> {
  int _index = 0;
  final Set<int> _expanded = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WarningCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length < oldWidget.children.length) {
      final lastIndex = widget.children.length - 1;
      _index = math.min(lastIndex, _index);
      _expanded.removeWhere((index) => index > lastIndex);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _previous() {
    if (_index <= 0) return;
    setState(() => _index -= 1);
  }

  void _next() {
    if (_index >= widget.children.length - 1) return;
    setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Flex.vertical(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flex.horizontal(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                if (_expanded.isEmpty) return;
                setState(() => _expanded.clear());
              },
              icon: const Icon(Symbols.close),
            ),
            const Flexible.expand(),
            IconButton.filledTonal(
              onPressed: _index > 0 ? _previous : null,
              icon: const Icon(Symbols.chevron_left),
              tooltip: "Previous",
            ),
            IconButton.filledTonal(
              onPressed: _index < widget.children.length - 1 ? _next : null,
              icon: const Icon(Symbols.chevron_right),
              tooltip: "Next",
            ),
          ],
        ),
        AnimatedSize(
          alignment: Alignment.topCenter,
          duration: Durations.long4,
          curve: Easing.emphasized,
          child: AnimatedSwitcher(
            duration: Durations.medium4,
            switchInCurve: const Interval(
              0.3,
              1,
              curve: Easing.emphasizedDecelerate,
            ),
            switchOutCurve: Interval(
              0.7,
              1,
              curve: Easing.emphasizedAccelerate.flipped,
            ),
            transitionBuilder: (child, animation) {
              // final offsetTween = Tween<Offset>(
              //   begin: const Offset(0, 16),
              //   end: Offset.zero,
              // );
              final scale = Tween<double>(
                begin: 0.9,
                end: 1,
              ).animate(animation);
              final opacity = Tween<double>(
                begin: 0,
                end: 1,
              ).animate(animation);
              return ScaleTransition(
                scale: scale,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.low,
                child: FadeTransition(opacity: opacity, child: child),
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  ...previousChildren.map(
                    (child) => Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 0,
                      child: child,
                    ),
                  ),
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_index),
              child: WarningCardScope(
                onExpandedChanged: (value) {
                  final changed =
                      value ? _expanded.add(_index) : _expanded.remove(_index);
                  if (changed) setState(() {});
                },
                expanded: _expanded.contains(_index),
                child: widget.children[_index],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WarningCardScope extends InheritedWidget {
  const WarningCardScope({
    super.key,
    this.onExpandedChanged,
    required this.expanded,
    required super.child,
  });
  final ValueChanged<bool>? onExpandedChanged;
  final bool expanded;

  @override
  bool updateShouldNotify(covariant WarningCardScope oldWidget) {
    return expanded != oldWidget.expanded;
  }

  static WarningCardScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WarningCardScope>();
  }
}

class WarningCard extends StatefulWidget {
  const WarningCard({
    super.key,
    required this.icon,
    required this.headline,
    required this.supportingText,
  });

  final Widget icon;
  final Widget headline;
  final Widget supportingText;

  @override
  State<WarningCard> createState() => _WarningCardState();
}

class _WarningCardState extends State<WarningCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scope = WarningCardScope.maybeOf(context);
    final expanded = scope?.expanded ?? _expanded;

    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    final backgroundColor = theme.colorScheme.errorContainer;
    final foregroundColor = theme.colorScheme.onErrorContainer;
    final secondaryForegroundColor = theme.colorScheme.onSurfaceVariant;
    return Material(
      animationDuration: Duration.zero,
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      shape: Shapes.extraLarge,
      color: backgroundColor,
      child: InkWell(
        onTap:
            scope != null
                ? () => scope.onExpandedChanged?.call(!scope.expanded)
                : () => setState(() => _expanded = !_expanded),
        overlayColor: WidgetStateLayerColor(
          foregroundColor,
          opacity: stateTheme.stateLayerOpacity,
        ),
        child: AnimatedPadding(
          duration: Durations.medium4,
          curve: Easing.emphasized,
          padding:
              expanded
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Flex.horizontal(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconTheme.merge(
                data: IconThemeData(color: foregroundColor),
                child: widget.icon,
              ),
              const Gap(16),
              Expanded(
                child: Flex.vertical(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DefaultTextStyle.merge(
                      textAlign: TextAlign.start,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: foregroundColor,
                      ),
                      child: widget.headline,
                    ),
                    AnimatedAlign(
                      duration: Durations.medium4,
                      curve: Easing.emphasized,
                      alignment: Alignment.topLeft,
                      heightFactor: expanded ? 1.0 : 0.0,
                      child: AnimatedOpacity(
                        duration: Durations.medium4,
                        curve: Easing.emphasized,
                        opacity: expanded ? 1.0 : 0.0,
                        child: DefaultTextStyle.merge(
                          textAlign: TextAlign.start,
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: secondaryForegroundColor,
                          ),
                          child: widget.supportingText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              AnimatedRotation(
                duration: Durations.medium4,
                curve: Easing.emphasized,
                turns: expanded ? 0.5 : 0.0,
                child: Icon(
                  Symbols.keyboard_arrow_down,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthController with ChangeNotifier {
  AuthController({
    required this.webClientId,
    required this.iosClientId,
    this.redirectTo,
  }) {
    _subscription = _supabase.auth.onAuthStateChange.listen(_authListener);
    _session = _supabase.auth.currentSession;
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  late final StreamSubscription<AuthState> _subscription;

  String? redirectTo;
  String webClientId;
  String iosClientId;

  Stream<AuthState> get stream => _supabase.auth.onAuthStateChange;

  AuthChangeEvent? _event;
  AuthChangeEvent get event {
    assert(_event != null);
    return _event!;
  }

  Session? _session;
  Session? get session => _session;

  void _authListener(AuthState state) {
    _event = state.event;
    _session = state.session;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<bool> signInWith(OAuthProvider provider) {
    return switch (provider) {
      OAuthProvider.google => signInWithGoogle(),
      OAuthProvider.discord => signInWithDiscord(),
      OAuthProvider.github => signInWithGithub(),
      OAuthProvider.notion => signInWithNotion(),
      OAuthProvider.figma => signInWithFigma(),
      _ => Future.value(false),
    };
  }

  Future<bool> signInWithGoogle() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android || TargetPlatform.iOS:
        return _signInWithGoogleNative()
            .then((_) => true)
            .catchError((_) => false);
      default:
        return _signInWithGoogleOAuth();
    }
  }

  Future<void> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw "No Access Token found.";
    }
    if (idToken == null) {
      throw "No ID Token found.";
    }

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<bool> _signInWithGoogleOAuth() {
    return _signInWithOAuth(OAuthProvider.google);
  }

  Future<bool> signInWithDiscord() {
    return _signInWithOAuth(OAuthProvider.discord);
  }

  Future<bool> signInWithGithub() {
    return _signInWithOAuth(OAuthProvider.github);
  }

  Future<bool> signInWithNotion() {
    return _signInWithOAuth(OAuthProvider.notion);
  }

  Future<bool> signInWithFigma() {
    return _signInWithOAuth(OAuthProvider.figma);
  }

  Future<bool> _signInWithOAuth(OAuthProvider provider) async {
    return _supabase.auth
        .signInWithOAuth(provider, redirectTo: redirectTo)
        .then((_) => true)
        .catchError((_) => false);
  }

  Future<void> signOut([SignOutScope scope = SignOutScope.local]) {
    return _supabase.auth.signOut(scope: scope);
  }
}

class OAuthChip extends StatelessWidget {
  const OAuthChip({
    super.key,
    required this.onPressed,
    this.selected = false,
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  final VoidCallback? onPressed;
  final bool selected;

  /// Can be a colorful brand avatar
  final Widget icon;

  /// Should be a themable icon
  final Widget? selectedIcon;

  final Widget label;

  Widget _buildIcon(BuildContext context) {
    if (selected) {
      return Flex.horizontal(
        spacing: 4.0,
        children: [
          const Icon(Symbols.check),
          SizedBox.square(dimension: 18.0, child: selectedIcon ?? icon),
        ],
      );
    }
    return SizedBox.square(dimension: 18.0, child: icon);
  }

  Widget _buildChip(BuildContext context) {
    return IgnorePointer(
      ignoring: selected,
      child: ActionChip(
        onPressed: onPressed,
        avatar: SizedBox(
          height: 32,
          child: Align(widthFactor: 1, child: _buildIcon(context)),
        ),
        label: SizedBox(height: 32, child: Align(widthFactor: 1, child: label)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChipTheme(
      data: ChipThemeData(
        backgroundColor:
            selected
                ? theme.colorScheme.secondaryContainer
                : Colors.transparent,
        disabledColor:
            selected
                ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
                : Colors.transparent,
        iconTheme: IconThemeData(
          color:
              selected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.primary,
        ),

        labelStyle: theme.textTheme.labelLarge!.copyWith(
          color:
              selected
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurface,
        ),
        shape: selected ? Shapes.small : Shapes.full,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        side: BorderSide(
          strokeAlign: BorderSide.strokeAlignInside,
          width: 1.0,
          color:
              selected
                  ? theme.colorScheme.secondaryContainer
                  : theme.colorScheme.outlineVariant,
        ),
        avatarBoxConstraints: const BoxConstraints.tightFor(
          // width: 18,
          height: 18,
        ),
        padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
        labelPadding: const EdgeInsetsDirectional.only(start: 8),
      ),
      child: _buildChip(context),
    );
  }
}
