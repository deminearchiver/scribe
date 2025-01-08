import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'services_method_channel.dart';

abstract class ServicesPlatform extends PlatformInterface {
  /// Constructs a ServicesPlatform.
  ServicesPlatform() : super(token: _token);

  static final Object _token = Object();

  static ServicesPlatform _instance = MethodChannelServices();

  /// The default instance of [ServicesPlatform] to use.
  ///
  /// Defaults to [MethodChannelServices].
  static ServicesPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ServicesPlatform] when
  /// they register themselves.
  static set instance(ServicesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError("platformVersion() has not been implemented.");
  }

  Future<BorderRadius?> getWindowCorners() {
    throw UnimplementedError("windowCorners() has not been implemented.");
  }

  BorderRadius get windowCorners;
  Stream<BorderRadius> get onWindowCornersChange;
}
