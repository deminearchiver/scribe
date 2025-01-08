import 'dart:async';
import 'dart:io';

import 'package:services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material/material.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase => Supabase.instance.client;

@immutable
abstract class _Provider {
  const _Provider();

  String get id;
  String get displayName;
  String getLocalizedName(BuildContext context) => displayName;
  Future<void> signIn();
}

@immutable
class _GoogleProvider extends _Provider {
  const _GoogleProvider();

  @override
  String get id => "google";

  @override
  String get displayName => "Google";

  Future<void> _nativeSignIn() async {
    const webClientId =
        "883534429303-fb9fefbca6cfmg6umct1hbd3qvjqpv1k.apps.googleusercontent.com";

    const iosClientId =
        "883534429303-9i60e1t0mol93i3ms8mult6qf6gcgrll.apps.googleusercontent.com";

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
    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> _oauthSignIn() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: "scribe://auth",
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signIn() async {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => _nativeSignIn(),
      _ => _oauthSignIn(),
    };
  }
}

const List<_Provider> _providers = [_GoogleProvider()];

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  static const _services = Services();

  User? _user = supabase.auth.currentSession?.user;

  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((event) {
      setState(() => _user = event.session?.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Material(
            color: Colors.red,
            borderRadius: _services.windowCorners,
            child: Column(
              children: [
                FilledButton(
                  onPressed: () => _GoogleProvider().signIn(),
                  icon: const Icon(SimpleIcons.google),
                  label: Text("Google"),
                ),
                if (_user != null) Text("Signed in as ${_user!.id}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
