import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gap/gap.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material/material.dart';
import 'package:scribe/gen/assets.gen.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _LegacyMethod { email, phone }

class OnboardingAuth extends StatefulWidget {
  const OnboardingAuth({super.key});

  @override
  State<OnboardingAuth> createState() => _OnboardingAuthState();
}

class _OnboardingAuthState extends State<OnboardingAuth> {
  late final SupabaseClient _supabase;

  _LegacyMethod? _legacyMethod;

  OAuthProvider? _provider;
  bool get _isSigningIn => _provider != null;
  bool get _isSigningInWithGoogle => _provider == OAuthProvider.google;
  bool get _isSigningInWithOther =>
      _isSigningIn && _provider != OAuthProvider.google;

  StreamSubscription<AuthState>? _authStateSubscription;
  Session? session;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _authStateSubscription = _supabase.auth.onAuthStateChange.listen(
      (event) {},
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _signInWith(OAuthProvider provider) async {
    switch (provider) {
      case OAuthProvider.google:
        setState(() => _provider = provider);
        const webClientId =
            "73597778780-tuun4q8i2cbreah9603crvr4pss9cv84.apps.googleusercontent.com";
        const iosClientId =
            "73597778780-8ognocm4dkbbk6p598afuun6cfkeaqth.apps.googleusercontent.com";
        switch (defaultTargetPlatform) {
          case TargetPlatform.android || TargetPlatform.iOS:
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
          default:
            await _supabase.auth.signInWithOAuth(
              OAuthProvider.google,
              redirectTo:
                  "scribe://auth", // Optionally set the redirect link to bring back the user via deeplink.
              // authScreenLaunchMode: LaunchMode.externalApplication,
            );
        }
      case OAuthProvider.github ||
          OAuthProvider.figma ||
          OAuthProvider.notion ||
          OAuthProvider.discord:
        setState(() => _provider = provider);
        await _supabase.auth.signInWithOAuth(
          provider,
          redirectTo: "scribe://auth",
        );
      default:
        throw UnsupportedError("Unsupported OAuth provider: $provider");
    }
  }

  Future<void> _performAuth(OAuthProvider provider) async {
    try {
      await _signInWith(provider);
    } catch (_) {}
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return const CircularProgressIndicator.icon(strokeWidth: 3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverList.list(
            children: [
              const Gap(48),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Flex.vertical(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Symbols.login,
                      color: theme.colorScheme.primary,
                      size: 48,
                      opticalSize: 48,
                    ),
                    const Gap(16),
                    Text(
                      "Sign in",
                      style: theme.textTheme.headlineLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      "If you don't have an account, it will be automatically created.",
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Flex.vertical(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    Material(
                      animationDuration: Duration.zero,
                      type: MaterialType.card,
                      clipBehavior: Clip.antiAlias,
                      // color: theme.colorScheme.surface,
                      color: theme.colorScheme.surfaceContainerHighest,
                      // color: theme.colorScheme.secondaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radii.extraLarge,
                          bottom: Radii.small,
                        ),
                      ),
                      child: Flex.vertical(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            onTap:
                                !_isSigningIn
                                    ? () => _performAuth(OAuthProvider.google)
                                    : null,
                            // contentPadding: const EdgeInsets.symmetric(
                            //   horizontal: 24,
                            // ),
                            // horizontalTitleGap: 24,
                            // leading: Assets.images.brand.google.svg(
                            //   width: 24,
                            //   height: 24,
                            // ),
                            leading: switch (_provider) {
                              null => const CircleAvatar(
                                child: Icon(SimpleIcons.google),
                              ),
                              OAuthProvider.google => const CircleAvatar(
                                child: CircularProgressIndicator.icon(
                                  strokeWidth: 3,
                                ),
                              ),
                              _ => const SizedBox(
                                width: 40,
                                child: Icon(SimpleIcons.google),
                              ),
                            },

                            // _isSigningInWithGoogle
                            //     ? const CircularProgressIndicator.icon(
                            //       strokeWidth: 3,
                            //     )
                            //     : const Icon(SimpleIcons.google),
                            title: Text("Sign in with Google"),
                            subtitle: Text("The recommended way of signing in"),
                            trailing: const Icon(Symbols.navigate_next),
                          ),
                        ],
                      ),
                    ),

                    Material(
                      animationDuration: Duration.zero,
                      type: MaterialType.card,
                      clipBehavior: Clip.antiAlias,
                      // color: theme.colorScheme.surface,
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.vertical(
                          top: Radii.small,
                          bottom: Radii.small,
                        ),
                        // side: BorderSide(
                        //   color: theme.colorScheme.outlineVariant,
                        // ),
                      ),
                      child: Flex.vertical(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            enabled: _isSigningInWithOther || !_isSigningIn,
                            // leading: const SizedBox(
                            //   width: 40,
                            //   child: Icon(Symbols.apps),
                            // ),
                            leading:
                                _isSigningInWithOther
                                    ? const CircleAvatar(
                                      child: CircularProgressIndicator.icon(
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : const SizedBox.square(
                                      dimension: 40,
                                      child: Icon(Symbols.apps),
                                    ),
                            title: Text("More ways to sign in"),
                            subtitle: Text(
                              "Other third-party apps you can sign in with",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            child: ChipTheme(
                              data: ChipThemeData(
                                shape: Shapes.full,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                runSpacing: 0,
                                children: [
                                  ActionChip(
                                    onPressed:
                                        !_isSigningIn
                                            ? () => _performAuth(
                                              OAuthProvider.discord,
                                            )
                                            : null,
                                    // avatar: const Icon(SimpleIcons.discord),
                                    avatar: Assets.images.brand.discord.svg(
                                      width: 18,
                                      height: 18,
                                    ),
                                    label: Text("Discord"),
                                  ),
                                  ActionChip(
                                    onPressed:
                                        !_isSigningIn
                                            ? () => _performAuth(
                                              OAuthProvider.notion,
                                            )
                                            : null,
                                    // avatar: const Icon(SimpleIcons.notion),
                                    avatar: Assets.images.brand.notion.svg(
                                      width: 18,
                                      height: 18,
                                    ),
                                    label: Text("Notion"),
                                  ),
                                  ActionChip(
                                    onPressed:
                                        !_isSigningIn
                                            ? () => _performAuth(
                                              OAuthProvider.figma,
                                            )
                                            : null,
                                    // avatar: const Icon(SimpleIcons.figma),
                                    avatar: Assets.images.brand.figma.svg(
                                      width: 18,
                                      height: 18,
                                    ),
                                    label: Text("Figma"),
                                  ),
                                  // ActionChip(
                                  //   onPressed: () {},
                                  //   avatar: const Icon(Symbols.password),
                                  //   label: Text("Password"),
                                  // ),
                                  ActionChip(
                                    onPressed:
                                        !_isSigningIn
                                            ? () => _performAuth(
                                              OAuthProvider.github,
                                            )
                                            : null,

                                    avatar: switch (theme.brightness) {
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
                                    // avatar: Assets.images.brand.github.svg(
                                    //   width: 18,
                                    //   height: 18,
                                    //   colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                                    // ),
                                    label: Text("GitHub"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      animationDuration: Duration.zero,
                      type: MaterialType.card,
                      clipBehavior: Clip.antiAlias,
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.vertical(
                          top: Radii.small,
                          bottom: Radii.extraLarge,
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Flex.vertical(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            enabled: !_isSigningIn,
                            leading: const SizedBox(
                              width: 40,
                              child: Icon(Symbols.lock_open),
                            ),
                            title: Text("Legacy methods"),
                            subtitle: Text(
                              "Sign in using legacy methods proven potentially unsafe",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SegmentedButton<_LegacyMethod>(
                              onSelectionChanged:
                                  (value) => setState(
                                    () => _legacyMethod = value.singleOrNull,
                                  ),
                              selected: {
                                if (_legacyMethod != null) _legacyMethod!,
                              },
                              emptySelectionAllowed: true,
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: _LegacyMethod.email,
                                  icon: Icon(Symbols.email),
                                  label: Text("E-mail"),
                                ),
                                ButtonSegment(
                                  value: _LegacyMethod.phone,
                                  icon: Icon(Symbols.phone),
                                  label: Text("Phone"),
                                ),
                              ],
                            ),
                          ),
                          AnimatedSize(
                            duration: Durations.medium4,
                            curve: Easing.standard,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: Durations.short4,
                              switchInCurve: const Interval(0.3, 1),

                              switchOutCurve: const Interval(0.7, 1),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              layoutBuilder:
                                  (currentChild, previousChildren) => Stack(
                                    children: [
                                      ...previousChildren.map(
                                        (child) => Align(
                                          alignment: Alignment.topCenter,
                                          heightFactor: 0.0,
                                          child: child,
                                        ),
                                      ),
                                      if (currentChild != null) currentChild,
                                    ],
                                  ),
                              child: KeyedSubtree(
                                key: ValueKey(_legacyMethod),
                                child: switch (_legacyMethod) {
                                  _LegacyMethod.email => Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      12,
                                    ),
                                    child: Flex.horizontal(
                                      spacing: 8.0,
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () {},
                                            label: Text("Sign up"),
                                          ),
                                        ),

                                        Expanded(
                                          child: FilledTonalButton(
                                            onPressed: () {},
                                            label: Text("Sign in"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _LegacyMethod.phone => Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      bottom: 16,
                                    ),
                                    child: ListTile(
                                      leading: const SizedBox(
                                        width: 40,
                                        child: Icon(Symbols.error),
                                      ),
                                      title: Text("Not supported"),
                                      subtitle: Text(
                                        "Authenticating with phone number is not supported currently",
                                      ),
                                      trailing: FilledButton(
                                        onPressed: () {},
                                        label: Text("Use e-mail"),
                                      ),
                                    ),
                                  ),
                                  null => SizedBox(height: 12),
                                },
                              ),
                            ),
                          ),

                          // Padding(
                          //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          //   child: Wrap(
                          //     alignment: WrapAlignment.end,
                          //     spacing: 12.0,
                          //     runSpacing: 0.0,
                          //     children: [
                          //       // Tooltip(
                          //       //   message:
                          //       //       "Signing in with a phone number is not supported yet",
                          //       //   child: TextButton(
                          //       //     onPressed: null,
                          //       //     icon: const Icon(Symbols.phone),
                          //       //     label: Text("Sign in with phone number"),
                          //       //   ),
                          //       // ),
                          //       // TextButton(
                          //       //   onPressed: !_isSigningIn ? () {} : null,
                          //       //   icon: const Icon(Symbols.email),
                          //       //   label: Text("Sign in with E-mail"),
                          //       // ),
                          //       Tooltip(
                          //         message:
                          //             "Signing in with a phone number is not supported yet",
                          //         child: Flex.horizontal(
                          //           mainAxisSize: MainAxisSize.min,
                          //           spacing: 4.0,
                          //           children: [
                          //             IconButton.outlined(
                          //               onPressed: null,
                          //               icon: const Icon(Symbols.person_add),
                          //             ),
                          //             OutlinedButton(
                          //               onPressed: null,
                          //               icon: const Icon(Symbols.phone),
                          //               label: Text(
                          //                 "Sign in with phone number",
                          //               ),
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //       Flex.horizontal(
                          //         mainAxisSize: MainAxisSize.min,
                          //         spacing: 4.0,
                          //         children: [
                          //           IconButton.outlined(
                          //             onPressed: () {},
                          //             icon: const Icon(Symbols.person_add),
                          //           ),
                          //           TextButton(
                          //             onPressed: () {},
                          //             label: Text("Sign up"),
                          //           ),
                          //           OutlinedButton(
                          //             onPressed: () {},
                          //             label: Text("Sign in with e-mail"),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                TextButton(onPressed: () {}, label: Text("Skip")),
                const Spacer(),
                FilledButton(onPressed: null, label: Text("Continue")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
