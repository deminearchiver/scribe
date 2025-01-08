import 'package:flutter_test/flutter_test.dart';
import 'package:services/services.dart';
import 'package:services/services_platform_interface.dart';
import 'package:services/services_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockServicesPlatform
    with MockPlatformInterfaceMixin
    implements ServicesPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ServicesPlatform initialPlatform = ServicesPlatform.instance;

  test('$MethodChannelServices is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelServices>());
  });

  test('getPlatformVersion', () async {
    Services servicesPlugin = Services();
    MockServicesPlatform fakePlatform = MockServicesPlatform();
    ServicesPlatform.instance = fakePlatform;

    expect(await servicesPlugin.getPlatformVersion(), '42');
  });
}
