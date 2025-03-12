/// Represents the camera position for Android devices.
///
/// This class provides the necessary device information for accurate gaze tracking on Android.
///
class CameraPosition {
  /// The model name of the device.
  final String modelName;

  /// Screen width in pixels.
  final double screenWidth;

  /// Screen height in pixels.
  final double screenHeight;

  /// X-axis distance (mm) from the front camera to screen origin (0, 0).
  final double screenOriginX;

  /// Y-axis distance (mm) from the front camera to screen origin (0, 0).
  final double screenOriginY;

  /// Whether the camera is mounted on the longer side of the device (default is false).
  final bool cameraOnLongerAxis;

  /// Creates a [CameraPosition] with the required device information.
  CameraPosition({
    required this.modelName,
    required this.screenWidth,
    required this.screenHeight,
    required this.screenOriginX,
    required this.screenOriginY,
    this.cameraOnLongerAxis = false,
  });

  @override
  String toString() {
    return "ModelName : $modelName, screen size : ($screenWidth, $screenHeight), screenOriginX: $screenOriginX, screenOriginY: $screenOriginY, cameraOnlongerAxis: $cameraOnLongerAxis";
  }
}
