import Foundation

enum MethodName: String {
  case initGazeTracker
  case releaseGazeTracker
  case getVersionName
  case startTracking
  case stopTracking
  case isTracking
  case hasCameraPositions
  case addCameraPosition
  case getCameraPosition
  case getCameraPositionList
  case selectCameraPosition
  case setTrackingFPS
  case startCalibration
  case stopCalibration
  case isCalibrating
  case startCollectSamples
  case setCalibrationData
  case setAttentionRegion
  case getAttentionRegion
  case removeAttentionRegion
  case setForcedOrientation
  case resetForcedOrientation
}