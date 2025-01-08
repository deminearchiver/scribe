import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:painting/painting.dart';
import 'package:scribe/brick/repository.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:material/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:scribe/services.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' show sqfliteFfiInit;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:win32_registry/win32_registry.dart';
import 'app.dart';

@pragma("vm:entry-point")
void main() async {
  // timeDilation = 5.0;

  final binding = WidgetsFlutterBinding.ensureInitialized();

  // FlutterNativeSplash.preserve(widgetsBinding: binding);

  await NoiseGradientDelegate.ensureInitialized();

  // URI scheme protocol

  if (Platform.isWindows) await _register("scribe");

  // Database
  sqfliteFfiInit();
  // databaseFactory = databaseFactoryFfi;

  // Offline repository

  await Supabase.initialize(
    url: "https://yxumyouzbebhebyzylyp.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dW15b3V6YmViaGVieXp5bHlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzMzU2NjUsImV4cCI6MjA1MTkxMTY2NX0.SHHyDOQ8txR3z3t6dwmjyFSrA9SucjX-PNPcSGD6HiM",
  );
  // await Repository.configure(
  //   supabaseUrl: "https://svtqcwmqmrkyibsrrrkm.supabase.co",
  //   supabaseAnonKey:
  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2dHFjd21xbXJreWlic3JycmttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM3NjA3NDUsImV4cCI6MjA0OTMzNjc0NX0.DNOFzB8J7muFA97pmmPe5SGEoy81PQOlfK-fqPJcUBU",
  // );
  // await Repository.instance.initialize();

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
