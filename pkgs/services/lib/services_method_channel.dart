import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'services_platform_interface.dart';

/// An implementation of [ServicesPlatform] that uses method channels.
class MethodChannelServices extends ServicesPlatform {
  MethodChannelServices() {
    methodChannel.setMethodCallHandler(_onMethodCall);
    getWindowCorners()
        .then((windowCorners) {
          if (windowCorners != null) {
            _updateWindowCorners(windowCorners);
          }
        })
        .catchError((_) {});
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel("services");

  Future<void> _onMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        case "updateWindowCorners":
          final map =
              (call.arguments as Map<dynamic, dynamic>).cast<String, double>();
          final windowCorners = _parseWindowCorners(map);
          if (windowCorners != null) {
            _updateWindowCorners(windowCorners);
          }
        default:
      }
    } catch (_) {}
    return Future.value(null);
  }

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod<String>("getPlatformVersion");
  }

  @override
  Future<BorderRadius?> getWindowCorners() async {
    try {
      final map = await methodChannel.invokeMapMethod<String, double>(
        "getWindowCorners",
      );
      if (map == null) return null;
      return _parseWindowCorners(map);
    } catch (_) {
      return null;
    }
  }

  static const _defaultWindowCorner = Radius.zero;
  static const _defaultWindowCorners = BorderRadius.zero;

  BorderRadius? _windowCorners;

  @override
  BorderRadius get windowCorners => _windowCorners ?? _defaultWindowCorners;

  final StreamController<BorderRadius> _windowCornersController =
      StreamController.broadcast();

  @override
  Stream<BorderRadius> get onWindowCornersChange =>
      _windowCornersController.stream;

  void _updateWindowCorners(BorderRadius windowCorners) {
    if (_windowCorners != windowCorners) {
      _windowCorners = windowCorners;
      _windowCornersController.add(windowCorners);
    }
  }

  BorderRadius? _parseWindowCorners(Map<String, double> map) {
    final topLeft = map["topLeft"];
    final topRight = map["topRight"];
    final bottomRight = map["bottomRight"];
    final bottomLeft = map["bottomLeft"];

    return BorderRadius.only(
      topLeft:
          topLeft != null ? Radius.circular(topLeft) : _defaultWindowCorner,
      topRight:
          topRight != null ? Radius.circular(topRight) : _defaultWindowCorner,
      bottomRight:
          bottomRight != null
              ? Radius.circular(bottomRight)
              : _defaultWindowCorner,
      bottomLeft:
          bottomLeft != null
              ? Radius.circular(bottomLeft)
              : _defaultWindowCorner,
    );
  }
}
