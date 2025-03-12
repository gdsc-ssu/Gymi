import 'dart:ui';

import 'package:eyedid_flutter/eyedid_flutter_camera_position.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'package:eyedid_flutter/eyedid_flutter_platform_interface.dart';
import 'package:eyedid_flutter/eyedid_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockEyedidFlutterPlatform
    with MockPlatformInterfaceMixin
    implements EyedidFlutterPlatform {
  @override
  Future<String> getPlatformVersion() => Future.value('42');

  @override
  Future<void> addCameraPosition(CameraPosition cp) async {}

  @override
  Future<Rect?> getAttentionRegion() async =>
      Future.value(const Rect.fromLTRB(0, 0, 100, 100)) as Rect?;

  @override
  Stream<dynamic> getCalibrationEventStream() => const Stream.empty();

  @override
  Future<CameraPosition?> getCameraPosition() async {
    String modelName = "test";
    double screenWidth = 720;
    double screenHeight = 1080;
    double screenOriginX = -35;
    double screenOriginY = 1;
    final cp = CameraPosition(
        modelName: modelName,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        screenOriginX: screenOriginX,
        screenOriginY: screenOriginY,
        cameraOnLongerAxis: false);

    return Future.value(cp);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final EyedidFlutterPlatform initialPlatform = EyedidFlutterPlatform.instance;

  test('$MethodChannelEyedidFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelEyedidFlutter>());
  });

  test('getPlatformVersion', () async {
    EyedidFlutter eyedidFlutterPlugin = EyedidFlutter();
    MockEyedidFlutterPlatform fakePlatform = MockEyedidFlutterPlatform();
    EyedidFlutterPlatform.instance = fakePlatform;

    expect(await eyedidFlutterPlugin.getPlatformVersion(), '42');
  });
}
