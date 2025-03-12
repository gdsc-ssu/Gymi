import 'dart:async';

import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/eyedid_flutter_camera_position.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_device_orientation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'eyedid_flutter_platform_interface.dart';

class EyedidFlutter {
  /// Checks if the camera permission is granted for the Eyedid SDK.
  ///
  /// This function asynchronously checks whether the camera permission
  /// is granted for the Eyedid SDK. It returns a [Future] that resolves
  /// to a boolean value:
  /// - `true` if the camera permission has been granted.
  /// - `false` if the camera permission has not been granted or is denied.
  Future<bool> checkCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  /// Requests camera permission and returns whether the permission is granted.
  ///
  /// This function asynchronously requests camera permission from the user. It returns
  /// a [Future] that resolves to a boolean value:
  /// - `true` if the user grants the camera permission.
  /// - `false` if the user denies the camera permission or if the permission was previously denied.
  Future<bool> requestCameraPermission() async {
    return await Permission.camera.request().isGranted;
  }

  /// Initializes the GazeTracker with the given license key and options.
  ///
  /// This function asynchronously initializes the GazeTracker using the provided
  /// [licenseKey] and optional [options]. If no options are provided, default options
  /// are created using [GazeTrackerOptionsBuilder].
  ///
  /// - [licenseKey] is required and used to authorize the GazeTracker.
  /// - [options] are the optional configuration settings for the GazeTracker. If null,
  ///   default options are used.
  ///
  /// Returns a [FutureOr] containing an [InitializedResult], which provides information
  /// on whether the initialization was successful or not. If the result is null,
  /// the initialization failed or was interrupted.
  FutureOr<InitializedResult> initGazeTracker(
      {required String licenseKey, GazeTrackerOptions? options}) {
    GazeTrackerOptions options0 =
        options ?? GazeTrackerOptionsBuilder().build();
    return EyedidFlutterPlatform.instance.init(licenseKey, options0);
  }

  /// Releases the GazeTracker resources.
  ///
  /// This function asynchronously releases all resources associated with the GazeTracker.
  /// It should be called when the GazeTracker is no longer needed to free up memory and
  /// system resources.
  Future<void> releaseGazeTracker() async {
    EyedidFlutterPlatform.instance.release();
  }

  /// Retrieves the version of the Eyedid SDK for the current platform.
  ///
  /// This method returns the version of the Eyedid eye-tracking module for the
  /// specific platform (iOS/Android). The version string provides insight into
  /// the currently installed release of the Eyedid SDK.
  ///
  /// Returns a [Future] that resolves with the version string.
  Future<String> getPlatformVersion() {
    return EyedidFlutterPlatform.instance.getPlatformVersion();
  }

  /// Starts the gaze tracking process.
  ///
  /// This function initiates tracking of the user's gaze. Before calling this function,
  /// ensure that the gaze tracker has been initialized using [initGazeTracker].
  ///
  /// If the camera permission has not been granted or if the gaze tracker has not been
  /// initialized correctly, this function may throw a [PlatformException].
  ///
  /// Returns a [Future] that completes when the tracking process has started successfully.
  Future<void> startTracking() async {
    EyedidFlutterPlatform.instance.startTracking();
  }

  /// Stops the ongoing gaze tracking process.
  ///
  /// This function halts the current gaze tracking operation. Before calling this function,
  /// ensure that the gaze tracker has been initialized using [initGazeTracker].
  ///
  /// Throws a [PlatformException] if the camera permission is not granted or if the gaze tracker
  /// has not been properly initialized.
  Future<void> stopTracking() async {
    EyedidFlutterPlatform.instance.stopTracking();
  }

  /// Checks if gaze tracking is currently active.
  ///
  /// Returns:
  /// - `true` if tracking is active.
  /// - `false` if tracking is inactive or not properly initialized.
  Future<bool> isTracking() async {
    return EyedidFlutterPlatform.instance.isTracking();
  }

  /// Checks if the required device information is available for the Eyedid SDK.
  ///
  /// Determines if the necessary device information is present for optimal gaze tracking.
  ///
  /// Returns:
  /// - `true` if the device information is available.
  /// - `false` if it is not available.
  ///
  /// Note: This function is Android-specific.
  Future<bool> hasCameraPositions() async {
    return EyedidFlutterPlatform.instance.hasCameraPositions();
  }

  /// Adds camera position information to the Eyedid SDK.
  ///
  /// Provides the necessary camera position data to improve gaze tracking accuracy.
  /// The [cameraPosition] parameter contains the relevant data.
  ///
  /// Parameters:
  /// - [cameraPosition]: The camera position data.
  ///
  /// Note: This function is Android-specific.
  Future<void> addCameraPosition(CameraPosition cameraPosition) async {
    EyedidFlutterPlatform.instance.addCameraPosition(cameraPosition);
  }

  /// Retrieves the current camera position used by the Eyedid SDK.
  ///
  /// Returns the [CameraPosition] currently in use, or null if unavailable.
  ///
  /// Note: This function is Android-specific.
  Future<CameraPosition?> getCameraPosition() async {
    return EyedidFlutterPlatform.instance.getCameraPosition();
  }

  /// Retrieves the list of current camera positions used by the Eyedid SDK.
  ///
  /// Returns a list of [CameraPosition] objects, or null if unavailable.
  ///
  /// Note: This function is Android-specific.
  Future<List<CameraPosition>> getCameraPositionList() async {
    return EyedidFlutterPlatform.instance.getCameraPositionList();
  }

  /// Selects a specific camera position in the Eyedid SDK by index.
  ///
  /// Chooses a camera position from the available list using the provided [idx].
  ///
  /// Parameters:
  /// - [idx]: The index of the camera position to select.
  ///
  /// Note: This function is Android-specific.
  Future<void> selectCameraPosition(int idx) async {
    EyedidFlutterPlatform.instance.selectCameraPosition(idx);
  }

  /// Sets the frames per second (FPS) for gaze tracking in the Eyedid SDK.
  ///
  /// Specifies the desired FPS for gaze tracking. By default, the FPS is set to 30 for
  /// the front camera, but higher values can be set if supported by the device.
  ///
  /// Parameters:
  /// - [fps]: The desired frames per second for gaze tracking.
  ///
  /// Returns:
  /// - `true` if the FPS is successfully updated.
  /// - `false` if the FPS is out of range (below 1) or if an error occurs.
  ///
  /// Note: A [PlatformException] may be thrown if the gaze tracker is not properly initialized.
  Future<bool> setTrackingFPS(int fps) async {
    return EyedidFlutterPlatform.instance.setTrackingFPS(fps);
  }

  /// Initiates the calibration process in the Eyedid SDK.
  ///
  /// Parameters:
  /// - [calibrationMode]: The mode to use (1, 5 targets).
  /// - [calibrationCriteria]: The criteria for calibration (default is [CalibrationCriteria.standard]).
  /// - [region]: The screen region where targets will appear (default is the full screen).
  /// - [usePreviousCalibration]: Whether to use the previous calibration data (default is false).
  ///
  /// Note: A [PlatformException] may be thrown if the gaze tracker is not initialized.
  Future<void> startCalibration(CalibrationMode calibrationMode,
      {CalibrationCriteria calibrationCriteria = CalibrationCriteria.high,
      Rect? region,
      bool usePreviousCalibration = false}) async {
    EyedidFlutterPlatform.instance.startCalibration(
        calibrationMode, calibrationCriteria, region, usePreviousCalibration);
  }

  /// Stops the current calibration process in the Eyedid SDK.
  ///
  /// Any progress made before stopping will not be saved.
  ///
  /// Note: A [PlatformException] may be thrown if the gaze tracker is not initialized.
  Future<void> stopCalibration() async {
    EyedidFlutterPlatform.instance.stopCalibration();
  }

  /// Checks if the Eyedid SDK is currently performing calibration.
  ///
  /// Returns:
  /// - `true` if calibration is in progress.
  /// - `false` if calibration is not active or if an error occurs.
  ///
  /// Note: A [PlatformException] may be thrown if the gaze tracker is not initialized.
  Future<bool> isCalibrating() async {
    return EyedidFlutterPlatform.instance.isCalibrating();
  }

  /// Informs the Eyedid SDK to start collecting samples for the current calibration target.
  ///
  /// Call this function when the calibration target is displayed on the UI and you are
  /// ready to collect calibration data.
  ///
  /// Note: Ensure the calibration target is displayed before calling this function.
  /// A [PlatformException] may be thrown if the gaze tracker is not initialized.
  Future<void> startCollectSamples() async {
    EyedidFlutterPlatform.instance.startCollectSamples();
  }

  /// Sets calibration data in the Eyedid SDK for refinement.
  ///
  /// Provides the Eyedid SDK with calibration data for adjustment or refinement.
  ///
  /// Parameters:
  /// - [data]: A list of doubles containing the calibration data.
  ///
  /// Note: Ensure the gaze tracker is initialized a [PlatformException] may be thrown.
  Future<void> setCalibrationData(List<double> data) async {
    return EyedidFlutterPlatform.instance.setCalibrationData(data);
  }

  /// Sets the region of interest (ROI) for the Attention feature in the Eyedid SDK.
  ///
  /// The [region] parameter specifies the area of interest as a [Rect] on the device screen.
  ///
  /// Note: Ensure the gaze tracker is initialized a [PlatformException] may be thrown.
  Future<void> setAttentionRegion(Rect region) async {
    EyedidFlutterPlatform.instance.setAttentionRegion(region);
  }

  /// Retrieves the currently set region of interest (ROI) for the Attention feature.
  ///
  /// Returns the current [Rect] representing the ROI, or null if not set.
  ///
  /// Note: Ensure the gaze tracker is initialized a [PlatformException] may be thrown.
  Future<Rect?> getAttentionRegion() async {
    return EyedidFlutterPlatform.instance.getAttentionRegion();
  }

  /// Removes the region of interest (ROI) for the Attention feature.
  ///
  /// After removal, attention-related information will no longer be provided.
  ///
  /// Note: Ensure the gaze tracker is initialized a [PlatformException] may be thrown.
  Future<void> removeAttentionRegion() async {
    EyedidFlutterPlatform.instance.removeAttentionRegion();
  }

  /// Manually changes the device orientation in the Eyedid SDK (iOS only).
  ///
  /// Changes the device orientation using [EyedidDeviceOrientation].
  ///
  /// Returns:
  /// - `true` if successful.
  /// - `false` if failed or unsupported.
  /// - `null` if an error occurs.
  ///
  /// Note: Ensure the gaze tracker is initialized.
  /// This function is iOS-specific.
  Future<bool> setForcedOrientation(EyedidDeviceOrientation orientation) async {
    return EyedidFlutterPlatform.instance.setForcedOrientation(orientation);
  }

  /// Resets the forced orientation in the Eyedid SDK (iOS only).
  ///
  /// After calling, the device's orientation will revert to automatic.
  ///
  /// Returns:
  /// - `true` if the reset was successful.
  /// - `false` if failed or unsupported.
  /// - `null` if an error occurs.
  ///
  /// Note: Ensure the gaze tracker is initialized.
  /// This function is iOS-specific.
  Future<bool> resetForcedOrientation() async {
    return EyedidFlutterPlatform.instance.resetForcedOrientation();
  }

  /// Returns an event stream that provides camera tracking data.
  ///
  /// This stream delivers real-time tracking matrix information from the camera.
  /// Subscribe to the stream to process tracking data.
  Stream<dynamic> getTrackingEvent() {
    return EyedidFlutterPlatform.instance.getTrackingEventStream();
  }

  /// Returns a stream of events triggered when an input image frame is dropped due to performance constraints.
  Stream<dynamic> getDropEvent() {
    return EyedidFlutterPlatform.instance.getDropEventStream();
  }

  /// Returns a stream of calibration events from the Eyedid SDK.
  ///
  /// The stream provides updates about the calibration process through
  /// `CalibrationEvent` objects, allowing subscribers to receive real-time
  /// calibration data.
  ///
  /// Consumers can listen to this stream to track calibration progress or changes.
  Stream<dynamic> getCalibrationEvent() {
    return EyedidFlutterPlatform.instance.getCalibrationEventStream();
  }

  /// Returns an event stream that provides status updates for the Eyedid GazeTracker.
  ///
  /// This stream notifies when the tracking starts or stops, providing real-time updates
  /// on the GazeTracker's status.
  Stream<dynamic> getStatusEvent() {
    return EyedidFlutterPlatform.instance.getStatusEventStream();
  }
}
