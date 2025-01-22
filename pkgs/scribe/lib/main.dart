import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:painting/painting.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:scribe/brick/repository.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:material/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:scribe/debug.dart';
import 'package:scribe/i18n/strings.g.dart';
import 'package:scribe/services.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show sqfliteFfiInit;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:widgets/widgets.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:slang_flutter/slang_flutter.dart';
import 'app.dart';

@pragma("vm:entry-point")
void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  await LocaleSettings.useDeviceLocale();

  // FlutterNativeSplash.preserve(widgetsBinding: binding);

  await NoiseGradientDelegate.ensureInitialized();

  // URI scheme protocol

  if (Platform.isWindows) await _register("scribe");

  // Database
  sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  // Offline repository
  const supabaseUrl = "https://yxumyouzbebhebyzylyp.supabase.co";
  const supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dW15b3V6YmViaGVieXp5bHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzMzU2NjUsImV4cCI6MjA1MTkxMTY2NX0.SHHyDOQ8txR3z3t6dwmjyFSrA9SucjX-PNPcSGD6HiM";
  // await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  await Repository.configure(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  await Repository.instance.initialize();

  // Media player

  MediaKit.ensureInitialized();

  const AppServices().hideSplashScreen();

  // FlutterNativeSplash.remove();

  runApp(const App());
}

Future<void> _register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = "Software\\Classes\\$scheme";
  RegistryValue protocolRegValue = const RegistryValue(
    "URL Protocol",
    RegistryValueType.string,
    "",
  );
  String protocolCmdRegKey = "shell\\open\\command";
  RegistryValue protocolCmdRegValue = RegistryValue(
    "",
    RegistryValueType.string,
    "\"$appPath\" \"%1\"",
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

void translucent() {}
