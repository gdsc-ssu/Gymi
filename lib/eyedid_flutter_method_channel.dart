import 'package:eyedid_flutter/constants/eyedid_flutter_argument_key.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_device_orientation.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_method.dart';
import 'package:eyedid_flutter/eyedid_flutter_camera_position.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'eyedid_flutter_platform_interface.dart';

/// An implementation of [EyedidFlutterPlatform] that uses method channels.
class MethodChannelEyedidFlutter extends EyedidFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('eyedid.flutter.common.method');
  @visibleForTesting
  final trackingEventChannel =
      const EventChannel('eyedid.flutter.event.tracking');
  final dropEventChannel = const EventChannel('eyedid.flutter.event.drop');
  final calibrationEventChannel =
      const EventChannel('eyedid.flutter.event.calibration');
  final statusEventChannel = const EventChannel('eyedid.flutter.event.status');

  @override
  Future<InitializedResult> init(
      String licenseKey, GazeTrackerOptions options) async {
    final methodName = EyedidMethodName.initGazeTracker.name;
    final Map<String, dynamic> argumentMap = {
      EyedidArgumentKey.license.name: licenseKey,
      EyedidArgumentKey.useBlink.name: options.useBlink,
      EyedidArgumentKey.useUserStatus.name: options.useUserStatus,
      EyedidArgumentKey.useGazeFilter.name: options.useGazeFilter,
      EyedidArgumentKey.maxConcurrency.name: options.maxConcurrency,
      EyedidArgumentKey.cameraPreset.name: options.preset.name
    };
    final result = await methodChannel.invokeMethod(methodName, argumentMap);
    return InitializedResult(result);
  }

  @override
  Future<void> release() async {
    final methodName = EyedidMethodName.releaseGazeTracker.name;
    await methodChannel.invokeMethod(methodName);
  }

  @override
  Future<String> getPlatformVersion() async {
    final methodName = EyedidMethodName.getVersionName.name;
    final versionMap =
        await methodChannel.invokeMethod<Map<dynamic, dynamic>>(methodName);
    return versionMap?[EyedidArgumentKey.eyedidVersion.name] ?? "";
  }

  @override
  Future<void> startTracking() async {
    final methodName = EyedidMethodName.startTracking.name;
    await methodChannel.invokeMethod(methodName);
  }

  @override
  Future<void> stopTracking() async {
    final methodName = EyedidMethodName.stopTracking.name;
    await methodChannel.invokeMethod(methodName);
  }

  @override
  Future<bool> isTracking() async {
    final methodName = EyedidMethodName.isTracking.name;
    final isTracking = await methodChannel.invokeMethod<bool>(methodName);
    return isTracking ?? false;
  }

  @override
  Future<bool> hasCameraPositions() async {
    final methodName = EyedidMethodName.hasCameraPositions.name;
    final hasCameraPosition =
        await methodChannel.invokeMethod<bool>(methodName);
    return hasCameraPosition ?? false;
  }

  @override
  Future<void> addCameraPosition(CameraPosition cameraPosition) async {
    final methodName = EyedidMethodName.addCameraPosition.name;
    final Map<String, dynamic> argumentMap = {
      EyedidArgumentKey.modelName.name: cameraPosition.modelName,
      EyedidArgumentKey.screenWidth.name: cameraPosition.screenWidth,
      EyedidArgumentKey.screenHeight.name: cameraPosition.screenHeight,
      EyedidArgumentKey.screenOriginX.name: cameraPosition.screenOriginX,
      EyedidArgumentKey.screenOriginY.name: cameraPosition.screenOriginY,
      EyedidArgumentKey.cameraOnLongerAxis.name:
          cameraPosition.cameraOnLongerAxis
    };

    await methodChannel.invokeMethod(methodName, argumentMap);
  }

  @override
  Future<CameraPosition?> getCameraPosition() async {
    final methodname = EyedidMethodName.getCameraPosition.name;
    try {
      Map<dynamic, dynamic>? cameraPositionMap =
          await methodChannel.invokeMethod(methodname);
      if (cameraPositionMap != null) {
        final position = _generateCameraPositionWithMap(cameraPositionMap);
        return position;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching camera position: $e');
      }
    }
    return null;
  }

  CameraPosition _generateCameraPositionWithMap(Map<dynamic, dynamic> map) {
    String modelName = map[EyedidArgumentKey.modelName.name] as String;
    double screenWidth = map[EyedidArgumentKey.screenWidth.name] as double;
    double screenHeight = map[EyedidArgumentKey.screenHeight.name] as double;
    double screenOriginX = map[EyedidArgumentKey.screenOriginX.name] as double;
    double screenOriginY = map[EyedidArgumentKey.screenOriginY.name] as double;
    bool cameraOnLongerAxis =
        map[EyedidArgumentKey.cameraOnLongerAxis.name] as bool;
    return CameraPosition(
        modelName: modelName,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        screenOriginX: screenOriginX,
        screenOriginY: screenOriginY,
        cameraOnLongerAxis: cameraOnLongerAxis);
  }

  @override
  Future<List<CameraPosition>> getCameraPositionList() async {
    final methodName = EyedidMethodName.getCameraPositionList.name;
    try {
      List<Map<dynamic, dynamic>>? camerapositionMapList =
          await methodChannel.invokeListMethod(methodName);
      if (camerapositionMapList != null) {
        final list = _generateCameraPositionListWithList(camerapositionMapList);
        return list;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching camera position list: $e');
      }
    }

    return [];
  }

  List<CameraPosition> _generateCameraPositionListWithList(
      List<Map<dynamic, dynamic>> cameraPositionList) {
    List<CameraPosition> cameraPositions = [];

    for (final cameraPositionMap in cameraPositionList) {
      CameraPosition position =
          _generateCameraPositionWithMap(cameraPositionMap);
      cameraPositions.add(position);
    }
    return cameraPositions;
  }

  @override
  Future<void> selectCameraPosition(int idx) async {
    final methodName = EyedidMethodName.selectCameraPosition.name;
    final Map<String, int> argumentMap = {
      EyedidArgumentKey.cameraPositionListIndex.name: idx
    };
    await methodChannel.invokeMethod(methodName, argumentMap);
  }

  @override
  Future<bool> setTrackingFPS(int fps) async {
    final methodName = EyedidMethodName.setTrackingFPS.name;
    final Map<String, int> argumentMap = {
      EyedidArgumentKey.trackingFPS.name: fps
    };

    final isResult =
        await methodChannel.invokeMethod<bool>(methodName, argumentMap);
    return isResult ?? false;
  }

  @override
  Future<void> startCalibration(
      CalibrationMode calibrationMode,
      CalibrationCriteria calibrationCriteria,
      Rect? region,
      bool usePreviousCalibration) async {
    final methodName = EyedidMethodName.startCalibration.name;
    final argumentMap = _generateCalibrationOptionMap(
        calibrationMode, calibrationCriteria, region, usePreviousCalibration);

    await methodChannel.invokeMethod(methodName, argumentMap);
  }

  Map<String, dynamic> _generateCalibrationOptionMap(
      CalibrationMode calibrationMode,
      CalibrationCriteria calibrationCriteria,
      Rect? region,
      bool usePreviousCalibration) {
    Map<String, dynamic> argumentMap = {};

    int caliMode = calibrationMode == CalibrationMode.one ? 1 : 5;
    argumentMap[EyedidArgumentKey.calibrationMode.name] = caliMode;

    int caliCriteria = 0;
    if (calibrationCriteria == CalibrationCriteria.high) {
      caliCriteria = 1;
    } else if (calibrationCriteria == CalibrationCriteria.low) {
      caliCriteria = -1;
    }

    argumentMap[EyedidArgumentKey.calibrationCriteria.name] = caliCriteria;

    if (region != null) {
      argumentMap[EyedidArgumentKey.calibrationRegionLeft.name] = region.left;
      argumentMap[EyedidArgumentKey.calibrationRegionTop.name] = region.top;
      argumentMap[EyedidArgumentKey.calibrationRegionRight.name] = region.right;
      argumentMap[EyedidArgumentKey.calibrationRegionBottom.name] =
          region.bottom;
    }

    argumentMap[EyedidArgumentKey.usePreviousCalibration.name] =
        usePreviousCalibration;
    return argumentMap;
  }

  @override
  Future<void> stopCalibration() async {
    final methodName = EyedidMethodName.stopCalibration.name;
    await methodChannel.invokeMethod(methodName);
  }

  @override
  Future<bool> isCalibrating() async {
    final methodName = EyedidMethodName.isCalibrating.name;
    final isCalibrating = await methodChannel.invokeMethod<bool>(methodName);
    return isCalibrating ?? false;
  }

  @override
  Future<void> startCollectSamples() async {
    final methodName = EyedidMethodName.startCollectSamples.name;
    await methodChannel.invokeMethod(methodName);
  }

  @override
  Future<void> setCalibrationData(List<double> data) async {
    final methodName = EyedidMethodName.setCalibrationData.name;
    Map<String, dynamic> argumentMap = {
      EyedidArgumentKey.calibrationData.name: data
    };

    await methodChannel.invokeMethod<bool>(methodName, argumentMap);
  }

  @override
  Future<void> setAttentionRegion(Rect region) async {
    final methodName = EyedidMethodName.setAttentionRegion.name;

    Map<String, dynamic> argumentMap = {
      EyedidArgumentKey.attentionRegionLeft.name: region.left,
      EyedidArgumentKey.attentionRegionTop.name: region.top,
      EyedidArgumentKey.attentionRegionRight.name: region.right,
      EyedidArgumentKey.attentionRegionBottom.name: region.bottom,
    };

    await methodChannel.invokeMethod(methodName, argumentMap);
  }

  @override
  Future<Rect?> getAttentionRegion() async {
    final methodName = EyedidMethodName.getAttentionRegion.name;
    Map<dynamic, dynamic>? argumentsMap =
        await methodChannel.invokeMapMethod(methodName);
    if (argumentsMap != null) {
      final rect = _generateRectWithMap(argumentsMap);
      return rect;
    }
    return null;
  }

  Rect _generateRectWithMap(Map<dynamic, dynamic> map) {
    double left = map[EyedidArgumentKey.attentionRegionLeft.name] as double;
    double top = map[EyedidArgumentKey.attentionRegionTop.name] as double;
    double right = map[EyedidArgumentKey.attentionRegionRight.name] as double;
    double bottom = map[EyedidArgumentKey.attentionRegionBottom.name] as double;
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Future<void> removeAttentionRegion() async {
    final methodName = EyedidMethodName.removeAttentionRegion.name;
    await methodChannel.invokeMethod(methodName);
  }

  @override
  Future<bool> setForcedOrientation(EyedidDeviceOrientation orientation) async {
    final methodName = EyedidMethodName.setForcedOrientation.name;
    Map<String, dynamic> argumentMap = {
      EyedidArgumentKey.orientation.name: orientation.name
    };
    final isResult =
        await methodChannel.invokeMethod<bool>(methodName, argumentMap);
    return isResult ?? false;
  }

  @override
  Future<bool> resetForcedOrientation() async {
    final isResult = await methodChannel
        .invokeMethod<bool>(EyedidMethodName.resetForcedOrientation.name);
    return isResult ?? false;
  }

  @override
  Stream<dynamic> getTrackingEventStream() {
    return trackingEventChannel
        .receiveBroadcastStream(trackingEventChannel.name);
  }

  @override
  Stream<dynamic> getDropEventStream() {
    return dropEventChannel.receiveBroadcastStream(dropEventChannel.name);
  }

  @override
  Stream getStatusEventStream() {
    return statusEventChannel.receiveBroadcastStream(statusEventChannel.name);
  }

  @override
  Stream getCalibrationEventStream() {
    return calibrationEventChannel
        .receiveBroadcastStream(calibrationEventChannel.name);
  }
}
