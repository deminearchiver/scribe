import 'package:flutter/services.dart';
import 'package:material/material.dart';
import 'package:widgets/widgets.dart';

typedef AndroidResourceIdentifier = int;

class AppServices {
  const AppServices();

  Future<AndroidResourceIdentifier?> getResourceIdentifier(String name) {
    return AppServicesPlatform.instance.getResourceIdentifier(name);
  }

  Future<void> hideSplashScreen() {
    return AppServicesPlatform.instance.hideSplashScreen();
  }

  Future<String?> getShapePathData() {
    return AppServicesPlatform.instance.getShapePathData();
  }

  Future<Map<String, String>?> getShapesPathData(bool? radial) {
    return AppServicesPlatform.instance.getShapesPathData(radial);
  }
}

class AppServicesPlatform {
  const AppServicesPlatform();

  static AppServicesPlatform instance = MethodChannelAppServices();

  Future<AndroidResourceIdentifier?> getResourceIdentifier(String name) {
    throw UnimplementedError(
      "getResourceIdentifier() has not been implemented.",
    );
  }

  Future<void> hideSplashScreen() {
    throw UnimplementedError("hideSplashScreen() has not been implemented.");
  }

  Future<String?> getShapePathData() {
    throw UnimplementedError("getShapePathData() has not been implemented.");
  }

  Future<Map<String, String>?> getShapesPathData(bool? radial) {
    throw UnimplementedError("getShapesPathData() has not been implemented.");
  }
}

class MethodChannelAppServices extends AppServicesPlatform {
  MethodChannelAppServices();

  @visibleForTesting
  final methodChannel = const MethodChannel("scribe.deminearchiver.dev");

  final Map<String, AndroidResourceIdentifier> _resourceIdentifiersCache = {};

  @override
  Future<AndroidResourceIdentifier?> getResourceIdentifier(String name) async {
    if (_resourceIdentifiersCache.containsKey(name)) {
      return _resourceIdentifiersCache[name];
    }
    try {
      final result = await methodChannel
          .invokeMethod<AndroidResourceIdentifier?>(
            "getResourceIdentifier",
            name,
          );
      if (result != null) {
        _resourceIdentifiersCache[name] = result;
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> hideSplashScreen() async {
    try {
      await methodChannel.invokeMethod("hideSplashScreen");
    } catch (_) {}
  }

  @override
  Future<String?> getShapePathData() async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        "getShapePathData",
      );
      if (result is! String) return null;
      return result;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Map<String, String>?> getShapesPathData(bool? radial) async {
    try {
      return await methodChannel.invokeMapMethod<String, String>(
        "getShapesPathData",
        radial,
      );
    } catch (_) {
      return null;
    }
  }
}
