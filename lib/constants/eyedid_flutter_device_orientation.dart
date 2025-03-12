/// Represents different gaze event orientations for tracking in the Eyedid SDK on iOS.
/// Used to adjust the direction of gaze coordinates based on the device orientation.
///
/// - [portrait]: Device is in portrait mode, Home button at the bottom.
/// - [portraitUpsideDown]: Device is in portrait mode, Home button at the top.
/// - [landscapeLeft]: Device is in landscape mode, Home button on the left.
/// - [landscapeRight]: Device is in landscape mode, Home button on the right.
enum EyedidDeviceOrientation {
  portrait,
  portraitUpsideDown,
  landscapeLeft,
  landscapeRight,
}
