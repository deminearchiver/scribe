import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'services_platform_interface.dart';

const _kIosCornersMapping = {
  "iPhone11,2": 39.0,
  "iPhone11,4": 39.0,
  "iPhone11,8": 41.5,
  "iPhone12,1": 41.5,
  "iPhone12,3": 39.0,
  "iPhone12,5": 39.0,
  "iPhone12,8": 0.0,
  "iPhone13,1": 44.0,
  "iPhone13,2": 47.33000183105469,
  "iPhone13,3": 47.33000183105469,
  "iPhone13,4": 53.33000183105469,
  "iPhone14,2": 47.33000183105469,
  "iPhone14,3": 53.33000183105469,
  "iPhone14,4": 44.0,
  "iPhone14,5": 47.33000183105469,
  "iPhone14,6": 0.0,
  "iPhone14,7": 47.33000183105469,
  "iPhone14,8": 53.33000183105469,
  "iPhone15,2": 55.0,
  "iPhone15,3": 55.0,
  "iPhone15,4": 55.0,
  "iPhone15,5": 55.0,
  "iPhone16,1": 55.0,
  "iPhone16,2": 55.0,
  "iPhone17,1": 62.0,
  "iPhone17,2": 62.0,
  "iPhone17,3": 55.0,
  "iPhone17,4": 55.0,
  "iPad7,12": 0.0,
  "iPad8,1": 18.0,
  "iPad8,5": 18.0,
  "iPad8,9": 18.0,
  "iPad8,12": 18.0,
  "iPad11,1": 0.0,
  "iPad11,3": 0.0,
  "iPad11,7": 0.0,
  "iPad12,2": 0.0,
  "iPad13,2": 18.0,
  "iPad13,5": 18.0,
  "iPad13,10": 18.0,
  "iPad13,17": 18.0,
  "iPad13,18": 25.0,
  "iPad14,1": 21.5,
  "iPad14,3": 18.0,
  "iPad14,4": 18.0,
  "iPad14,5": 18.0,
  "iPad14,9": 18.0,
  "iPad14,11": 18.0,
  "iPad16,2": 21.5,
  "iPad16,4": 30.0,
  "iPad16,6": 30.0,
};

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
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await DeviceInfoPlugin().iosInfo;
        final radius = _kIosCornersMapping[iosInfo.utsname.machine];
        if (radius == null) return null;
        return BorderRadius.circular(radius);
      }
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
