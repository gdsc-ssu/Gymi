import 'dart:ui';

import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_device_orientation.dart';
import 'package:eyedid_flutter/eyedid_flutter_camera_position.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'eyedid_flutter_method_channel.dart';

abstract class EyedidFlutterPlatform extends PlatformInterface {
  /// Constructs a EyedidFlutterPlatform.
  EyedidFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static EyedidFlutterPlatform _instance = MethodChannelEyedidFlutter();

  /// The default instance of [EyedidFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelEyedidFlutter].
  static EyedidFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EyedidFlutterPlatform] when
  /// they register themselves.
  static set instance(EyedidFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<InitializedResult> init(
      String licenseKey, GazeTrackerOptions options) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<void> release() {
    throw UnimplementedError('release() has not been implemented.');
  }

  Future<String> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startTracking() {
    throw UnimplementedError('startTracking() has not been implemented.');
  }

  Future<void> stopTracking() {
    throw UnimplementedError('stopTracking() has not been implemented.');
  }

  Future<bool> isTracking() {
    throw UnimplementedError('isTracking() has not been implemented.');
  }

  Future<bool> hasCameraPositions() {
    throw UnimplementedError('hasCameraPositions() has not been implemented.');
  }

  Future<void> addCameraPosition(CameraPosition cameraPosition) {
    throw UnimplementedError('addCameraPosition() has not been implemented.');
  }

  Future<CameraPosition?> getCameraPosition() {
    throw UnimplementedError('getCameraPosition() has not been implemented.');
  }

  Future<List<CameraPosition>> getCameraPositionList() {
    throw UnimplementedError(
        'getCameraPositionList() has not been implemented.');
  }

  Future<void> selectCameraPosition(int idx) {
    throw UnimplementedError(
        'selectCameraPosition() has not been implemented.');
  }

  Future<bool> setTrackingFPS(int fps) {
    throw UnimplementedError('setTrackingFPS() has not been implemented.');
  }

  Future<void> startCalibration(
      CalibrationMode calibrationMode,
      CalibrationCriteria calibrationCriteria,
      Rect? region,
      bool usePreviousCalibration) {
    throw UnimplementedError('startCalibration() has not been implemented.');
  }

  Future<void> stopCalibration() {
    throw UnimplementedError('stopCalibration() has not been implemented.');
  }

  Future<bool> isCalibrating() {
    throw UnimplementedError('isCalibrating() has not been implemented.');
  }

  Future<void> startCollectSamples() {
    throw UnimplementedError('startCollectSamples() has not been implemented.');
  }

  Future<void> setCalibrationData(List<double> data) {
    throw UnimplementedError('setCalibrationData() has not been implemented.');
  }

  Future<void> setAttentionRegion(Rect region) {
    throw UnimplementedError('setAttentionRegion() has not been implemented.');
  }

  Future<Rect?> getAttentionRegion() {
    throw UnimplementedError('getAttentionRegion() has not been implemented.');
  }

  Future<void> removeAttentionRegion() {
    throw UnimplementedError(
        'removeAttentionRegion() has not been implemented.');
  }

  Stream<dynamic> getTrackingEventStream() {
    throw UnimplementedError(
        'getTrackingEventStream() has not been implemented.');
  }

  Stream<dynamic> getDropEventStream() {
    throw UnimplementedError('getDropEventStream() has not been implemented.');
  }

  Stream<dynamic> getStatusEventStream() {
    throw UnimplementedError(
        'getStatusEventStream() has not been implemented.');
  }

  Stream<dynamic> getCalibrationEventStream() {
    throw UnimplementedError(
        'getCalibrationEventStream() has not been implemented.');
  }

  Future<bool> setForcedOrientation(EyedidDeviceOrientation orientation) {
    throw UnimplementedError(
        'setForcedOrientation() has not been implemented.');
  }

  Future<bool> resetForcedOrientation() {
    throw UnimplementedError(
        'resetForcedOrientation() has not been implemented.');
  }
}
