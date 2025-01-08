import 'dart:async';

import 'package:flutter/painting.dart';

import 'services_platform_interface.dart';

class Services {
  const Services();

  Future<String?> getPlatformVersion() async {
    try {
      return await ServicesPlatform.instance.getPlatformVersion();
    } catch (_) {
      return null;
    }
  }

  BorderRadius get windowCorners => ServicesPlatform.instance.windowCorners;

  Stream<BorderRadius> get onWindowCornersChange =>
      ServicesPlatform.instance.onWindowCornersChange;
}
