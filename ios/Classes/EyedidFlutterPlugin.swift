import Flutter
import Eyedid
import UIKit
import AVFoundation

public class EyedidFlutterPlugin: NSObject, FlutterPlugin {

  private var trackingEventSink: FlutterEventSink? = nil
  private var statusEventSink: FlutterEventSink? = nil
  private var calibrationEventSink: FlutterEventSink? = nil
  private var dropEventSink: FlutterEventSink? = nil
  private var tracker: GazeTracker? = nil
  private var attempting: Bool = false
  private var initResult: FlutterResult? = nil

  public var trackingEventChannel: FlutterEventChannel? = nil
  public var statusEventChannel: FlutterEventChannel? = nil
  public var calibrationEventChannel: FlutterEventChannel? = nil
  public var dropEventChannel: FlutterEventChannel? = nil
  public let trackingChName = "eyedid.flutter.event.tracking"
  public let calibrationChName = "eyedid.flutter.event.calibration"
  public let statusChName = "eyedid.flutter.event.status"
  public let dropChName = "eyedid.flutter.event.drop"
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "eyedid.flutter.common.method", binaryMessenger: registrar.messenger())
    let instance = EyedidFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    instance.trackingEventChannel = FlutterEventChannel(name: "eyedid.flutter.event.tracking", binaryMessenger: registrar.messenger())
    instance.dropEventChannel = FlutterEventChannel(name: "eyedid.flutter.event.drop", binaryMessenger: registrar.messenger())
    instance.statusEventChannel = FlutterEventChannel(name: "eyedid.flutter.event.status", binaryMessenger: registrar.messenger())
    instance.calibrationEventChannel = FlutterEventChannel(name: "eyedid.flutter.event.calibration", binaryMessenger: registrar.messenger())

    instance.trackingEventChannel?.setStreamHandler(instance)
    instance.statusEventChannel?.setStreamHandler(instance)
    instance.calibrationEventChannel?.setStreamHandler(instance)
    instance.dropEventChannel?.setStreamHandler(instance)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    releaseGazeTracker()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case MethodName.getVersionName.rawValue:
        getVersionName(result: result)
      case MethodName.initGazeTracker.rawValue:
        initGazeTracker(call, result: result)
      case MethodName.releaseGazeTracker.rawValue:
        if(checkCameraPermission()) {
          releaseGazeTracker()
          result(ResultKey.released)
        } else {
          throwException(result, message: ErrorMessage.cameraPermissionErrorMessage)
        }
      case MethodName.startTracking.rawValue:
        startTracking(result: result)
      case MethodName.stopTracking.rawValue:
        stopTracking(result: result)
      case MethodName.isTracking.rawValue:
        isTracking(result: result)
      case MethodName.hasCameraPositions.rawValue, MethodName.addCameraPosition.rawValue, MethodName.getCameraPosition.rawValue, MethodName.getCameraPositionList.rawValue, MethodName.selectCameraPosition.rawValue :
        result("iOS platform not supported")
      case MethodName.setTrackingFPS.rawValue:
        setTrackingFPS(call, result: result)
      case MethodName.startCalibration.rawValue:
        DispatchQueue.main.async {
          self.startCalibration(call, result: result)
        }
      case MethodName.stopCalibration.rawValue:
        stopCalibration(result: result)
      case MethodName.isCalibrating.rawValue:
        isCalibrating(result: result)
      case MethodName.startCollectSamples.rawValue:
        startCollectSamples(result: result)
      case MethodName.setCalibrationData.rawValue:
        setCalibrationData(call, result: result)
      case MethodName.setAttentionRegion.rawValue:
        setAttentionRegion(call, result: result)
      case MethodName.getAttentionRegion.rawValue:
        getAttentionRegion(result: result)
      case MethodName.removeAttentionRegion.rawValue:
        removeAttentionRegion(result: result)
      case MethodName.setForcedOrientation.rawValue:
        setForcedOrientation(call, result: result)
      case MethodName.resetForcedOrientation.rawValue:
        resetForcedOrientation(result: result)
      default:
        result(FlutterMethodNotImplemented)
    }
  }

  private func resetForcedOrientation(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      let value = gazeTracker.resetForcedOrientation()
      result(value)
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func setForcedOrientation(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      if let arguments = call.arguments as? [String: String],
         let orientationValue : String = arguments[ArgumentKey.orientation] as? String {
        var orientation : UIInterfaceOrientation = .portrait
        if (orientationValue == "portraitUpsideDown") {
          orientation = .portraitUpsideDown
        } else if (orientationValue == "landscapeLeft") {
          orientation = .landscapeLeft
        } else if (orientationValue == "landscapeRight") {
          orientation = .landscapeRight
        }
        let value = gazeTracker.setForcedOrientation(orientation: orientation)
        result(value)
      } else {
        throwException(result, message: ErrorMessage.argumentNullErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func removeAttentionRegion(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      gazeTracker.removeAttentionRegion()
      result(nil)
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func getAttentionRegion(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      if let region = gazeTracker.getAttentionRegion() {
        var regionMap = [String: Any]()
        regionMap[ArgumentKey.attentionRegionLeft] = region.minX
        regionMap[ArgumentKey.attentionRegionTop] = region.minY
        regionMap[ArgumentKey.attentionRegionRight] = region.maxX
        regionMap[ArgumentKey.attentionRegionBottom] = region.maxY
        result(regionMap)
      } else {
        result(nil)
      }
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func setAttentionRegion(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      if let arguments = call.arguments as? [String: Any],
         let left = arguments[ArgumentKey.attentionRegionLeft] as? Double,
         let top = arguments[ArgumentKey.attentionRegionTop] as? Double,
         let right = arguments[ArgumentKey.attentionRegionRight] as? Double,
         let bottom = arguments[ArgumentKey.attentionRegionBottom] as? Double {
        gazeTracker.setAttentionRegion(region:  CGRect(x: left, y: top, width: right - left, height: bottom - top))
        result(nil)
      } else {
        throwException(result, message: ErrorMessage.argumentNullErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func setCalibrationData(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      if let arguments = call.arguments as? [String: Any], let data = arguments[ArgumentKey.calibrationData] as? [Double] {
        gazeTracker.setCalibrationData(calibrationData: data)
        result(nil)
      } else {
        throwException(result, message: ErrorMessage.argumentNullErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func startCollectSamples(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      gazeTracker.startCollectSamples()
      result(nil)
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func isCalibrating(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      let isCalibratingValue = gazeTracker.isCalibrating()
      result(isCalibratingValue)
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func stopCalibration(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      gazeTracker.stopCalibration()
      result(nil)
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  @MainActor private func startCalibration(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      if let arguments = call.arguments as? [String: Any],
         let modeValue = arguments[ArgumentKey.calibrationMode] as? Int,
         let criteriaValue = arguments[ArgumentKey.calibrationCriteria] as? Int {

        var mode: CalibrationMode = .fivePoint
        if modeValue == 1 {
          mode = .onePoint
        }

        var criteria: AccuracyCriteria = .default
        if criteriaValue == -1 {
          criteria = .low
        } else if criteriaValue == 1 {
          criteria = .high
        }

        var usePrevCalibration: Bool = false
        if let usePreviousCalibration = arguments[ArgumentKey.usePreviousCalibration] as? Bool {
          usePrevCalibration = usePreviousCalibration
        }
           
        if let left = arguments[ArgumentKey.calibrationRegionLeft] as? Double,
           let top = arguments[ArgumentKey.calibrationRegionTop] as? Double,
           let right = arguments[ArgumentKey.calibrationRegionRight] as? Double,
           let bottom = arguments[ArgumentKey.calibrationRegionBottom] as? Double {

          let rect = CGRect(x: left, y: top, width: right - left, height: bottom - top)
          gazeTracker.startCalibration(mode: mode, criteria: criteria, region: rect, usePreviousCalibration: usePrevCalibration)
        } else {
          gazeTracker.startCalibration(mode: mode, criteria: criteria, region: UIScreen.main.bounds, usePreviousCalibration: usePrevCalibration)
        }
        result(nil)
      } else {
        throwException(result, message: ErrorMessage.argumentNullErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }


  private func setTrackingFPS(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      if let arguments = call.arguments as? [String : Any], let fps : Int = arguments[ArgumentKey.trackingFPS] as? Int {
        let value = gazeTracker.setTrackingFPS(fps: fps)
        result(value)
      } else {
        throwException(result, message: ErrorMessage.argumentNullErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func isTracking(result: @escaping FlutterResult) {
    if let gazeTracker = self.tracker {
      let isTrackingResult = gazeTracker.isTracking()
      result(isTrackingResult)
    } else {
      throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
    }
  }

  private func stopTracking(result: @escaping FlutterResult) {
    if (checkCameraPermission()) {
      if let gazeTracker = self.tracker {
        gazeTracker.stopTracking()
        result(nil)
      } else {
        throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.cameraPermissionErrorMessage)
    }
  }

  private func startTracking(result: @escaping FlutterResult) {
    if (checkCameraPermission()) {
      if let gazeTracker = self.tracker {
        gazeTracker.startTracking()
        result(nil)
      } else {
        throwException(result, message: ErrorMessage.eyedidNotInitializedErrorMessage)
      }
    } else {
      throwException(result, message: ErrorMessage.cameraPermissionErrorMessage)
    }
  }


  private func throwException(_ result: @escaping FlutterResult, message: String) {
    result(FlutterError(code: "Eyedid SDK Error", message: message, details: nil))
  }

  private func checkCameraPermission() -> Bool {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    return status == .authorized
  }

  private func releaseGazeTracker() {
    self.tracker?.stopTracking()
    self.trackingEventChannel?.setStreamHandler(nil)
    self.statusEventChannel?.setStreamHandler(nil)
    self.calibrationEventChannel?.setStreamHandler(nil)
    self.trackingEventChannel = nil
    self.statusEventChannel = nil
    self.calibrationEventChannel = nil
    self.initResult = nil
    GazeTracker.releaseGazeTracker(tracker: tracker)
    self.tracker = nil
  }

  private func initGazeTracker(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(checkCameraPermission()) {
      if(tracker == nil) {
        if (attempting) {
          var resultMap = [String: Any]()
          resultMap[ResultKey.initializedResultKey] = false
          resultMap[ResultKey.initializedResultMessageKey] = ErrorMessage.isAlreadyAttempting
          result(resultMap)
        } else {
          attempting = true
          if let licenseKey = generateLicenseKey(call), let options = generateGazeTrackerOptions(call) {
            initResult = result
            GazeTracker.initGazeTracker(license: licenseKey, delegate: self, options: options)
          } else {
            attempting = false
            throwException(result, message: ErrorMessage.contextNull)
          }
        }
      } else {
        var resultMap = [String: Any]()
        resultMap[ResultKey.initializedResultKey] = false
        resultMap[ResultKey.initializedResultMessageKey] = ErrorMessage.gazeTrackerAlreadyInitialized
        result(resultMap)
      }
    } else {
      throwException(result, message: ErrorMessage.cameraPermissionErrorMessage)
    }
  }

  private func generateGazeTrackerOptions(_ call: FlutterMethodCall) -> GazeTrackerOptions? {
    guard let args = call.arguments as? [String: Any] else { return nil }

    let useBlink = args[ArgumentKey.useBlink] as? Bool
    let useUserStatus = args[ArgumentKey.useUserStatus] as? Bool
    let useGazeFilter = args[ArgumentKey.useGazeFilter] as? Bool
    let maxConcurrency = args[ArgumentKey.maxConcurrency] as? Int
    let cameraPresetString = args[ArgumentKey.cameraPreset] as? String

    if useBlink != nil || useUserStatus != nil || useGazeFilter != nil || maxConcurrency != nil || cameraPresetString != nil {
      var builder = GazeTrackerOptions.Builder()

      if let useBlink = useBlink {
        builder = builder.setUseBlink(useBlink)
      }

      if let useUserStatus = useUserStatus {
        builder = builder.setUseUserStatus(useUserStatus)
      }

      if let useGazeFilter = useGazeFilter {
        builder = builder.setUseGazeFilter(useGazeFilter)
      }

      if let maxConcurrency = maxConcurrency {
        builder = builder.setMaxConcurrency(maxConcurrency)
      }

      if let preset = cameraPresetString {
        var cameraPreset : CameraPreset = .vga
        if preset == "hd1280x720" {
          cameraPreset = .hd
        } else if preset == "fhd1920x1080" {
          cameraPreset = .fullHD
        }
        builder = builder.setCameraPreset(cameraPreset)
      }

      return builder.build()
    }
    return nil
  }


  private func generateLicenseKey(_ call: FlutterMethodCall) -> String? {
    let args = call.arguments as? [String: Any]
    return args?[ArgumentKey.license] as? String
  }

  private func getVersionName(result: @escaping FlutterResult) {
    var versionMap = [String: String]()
    versionMap[ResultKey.eyedidVersion] = GazeTracker.getFrameworkVersion()
    result(versionMap)
  }
}

extension EyedidFlutterPlugin: InitializationDelegate, TrackingDelegate, StatusDelegate, CalibrationDelegate, FlutterStreamHandler  {
  public func onInitialized(tracker: GazeTracker?, error: InitializationError) {
    attempting = false
    var result = false
    var message = "";
    if (tracker != nil) {
      self.tracker = tracker
      self.tracker?.trackingDelegate = self
      self.tracker?.calibrationDelegate = self
      self.tracker?.statusDelegate = self
      result = true;
    }
    message = error.description;
    var eventData = [String: Any]()
    eventData[ResultKey.initializedResultKey] = result
    eventData[ResultKey.initializedResultMessageKey] = message
    initResult?(eventData)
    initResult = nil
  }

  private func generateTrackingStateString(_ state: TrackingState) -> String {
    switch state {
      case .success:
        return "SUCCESS"
      case .gazeNotFound:
        return "GAZE_NOT_FOUND"
      case .faceMissing:
        return "FACE_MISSING"
    }
  }

  private func generateEyeMovementStateString(_ state: EyeMovementState) -> String {
    switch state {
      case .fixation:
        return "FIXATION"
      case .saccade:
        return "SACCADE"
      case .unknown:
        return "UNKNOWN"
    }
  }

  private func generateScreenStateString(_ state: ScreenState) -> String {
    switch state {
      case .insideOfScreen:
        return "INSIDE_OF_SCREEN"
      case .outsideOfScreen:
        return "OUTSIDE_OF_SCREEN"
      case .unknown:
        return "UNKNOWN"
    }
  }
  public func onMetrics(timestamp: Int, gazeInfo: GazeInfo, faceInfo: FaceInfo, blinkInfo: BlinkInfo, userStatusInfo: UserStatusInfo) {
    if let sink = self.trackingEventSink {
      var eventData = [String: Any]()

      eventData[TrackingEventKey.timestamp] = timestamp

      eventData[TrackingEventKey.gazeX] = gazeInfo.x
      eventData[TrackingEventKey.gazeY] = gazeInfo.y
      eventData[TrackingEventKey.fixationX] = gazeInfo.fixationX
      eventData[TrackingEventKey.fixationY] = gazeInfo.fixationY
      eventData[TrackingEventKey.trackingState] = generateTrackingStateString(gazeInfo.trackingState)
      eventData[TrackingEventKey.eyeMovementState] = generateEyeMovementStateString(gazeInfo.eyeMovementState)
      eventData[TrackingEventKey.screenState] = generateScreenStateString(gazeInfo.screenState)

      eventData[TrackingEventKey.faceScore] = faceInfo.score
      eventData[TrackingEventKey.faceLeft] = Double(faceInfo.rect.minX)
      eventData[TrackingEventKey.faceTop] = Double(faceInfo.rect.minY)
      eventData[TrackingEventKey.faceRight] = Double(faceInfo.rect.maxX)
      eventData[TrackingEventKey.faceBottom] = Double(faceInfo.rect.maxY)
      eventData[TrackingEventKey.facePitch] = faceInfo.pitch
      eventData[TrackingEventKey.faceYaw] = faceInfo.yaw
      eventData[TrackingEventKey.faceRoll] = faceInfo.roll
      eventData[TrackingEventKey.frameWidth] = Int(faceInfo.imageSize.width)
      eventData[TrackingEventKey.frameHeight] = Int(faceInfo.imageSize.height)
      eventData[TrackingEventKey.faceCenterX] = faceInfo.centerX
      eventData[TrackingEventKey.faceCenterY] = faceInfo.centerY
      eventData[TrackingEventKey.faceCenterZ] = faceInfo.centerZ

      eventData[TrackingEventKey.isBlink] = blinkInfo.isBlink
      eventData[TrackingEventKey.isBlinkLeft] = blinkInfo.isBlinkLeft
      eventData[TrackingEventKey.isBlinkRight] = blinkInfo.isBlinkRight
      eventData[TrackingEventKey.leftOpenness] = blinkInfo.leftOpenness
      eventData[TrackingEventKey.rightOpenness] = blinkInfo.rightOpenness

      eventData[TrackingEventKey.isDrowsy] = userStatusInfo.isDrowsy
      eventData[TrackingEventKey.drowsinessIntensity] = userStatusInfo.drowsinessIntensity
      eventData[TrackingEventKey.attentionScore] = userStatusInfo.attentionScore

      DispatchQueue.main.async {
        sink(eventData)
      }
    }

  }

  public func onDrop(timestamp: Int) {
    if let sink = self.dropEventSink {
      var eventData = [String: Any]()
      eventData[DropEventKey.timestamp] = timestamp
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onStarted() {
    if let sink = self.statusEventSink {
      var eventData = [String: Any]()
      eventData[StatusEventKey.typeKey] = StatusEventKey.startType
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onStopped(error: StatusError) {
    if let sink = self.statusEventSink {
      var eventData = [String: Any]()
      eventData[StatusEventKey.typeKey] = StatusEventKey.stopType
      eventData[StatusEventKey.failedReasonKey] = error.description
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onCalibrationNextPoint(x: Double, y:Double) {
    if let sink = self.calibrationEventSink {
      var eventData = [String: Any]()
      eventData[CalibrationEventKey.calibrationType] = CalibrationEventType.calibrationNextXY
      eventData[CalibrationEventKey.nextX] = x
      eventData[CalibrationEventKey.nextY] = y
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onCalibrationProgress(progress: Double) {
    if let sink = self.calibrationEventSink {
      var eventData = [String: Any]()
      eventData[CalibrationEventKey.calibrationType] = CalibrationEventType.calibrationProgress
      eventData[CalibrationEventKey.progress] = progress
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onCalibrationFinished(calibrationData: [Double]) {
    if let sink = self.calibrationEventSink {
      var eventData = [String: Any]()
      eventData[CalibrationEventKey.calibrationType] = CalibrationEventType.calibrationFinished
      eventData[CalibrationEventKey.calibrationData] = calibrationData
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onCalibrationCanceled(calibrationData: [Double]) {
    if let sink = self.calibrationEventSink {
      var eventData = [String: Any]()
      eventData[CalibrationEventKey.calibrationType] = CalibrationEventType.calibrationCanceled
      eventData[CalibrationEventKey.calibrationData] = calibrationData
      DispatchQueue.main.async {
        sink(eventData)
      }
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    if let channelName = arguments as? String {
      if channelName == trackingChName {
        trackingEventSink = events
      } else if channelName == calibrationChName {
        calibrationEventSink = events
      } else if channelName == statusChName {
        statusEventSink = events
      } else if channelName == dropChName {
        dropEventSink = events
      }
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let channelName = arguments as? String {
      if channelName == trackingChName {
        trackingEventSink = nil
      } else if channelName == calibrationChName {
        calibrationEventSink = nil
      } else if channelName == statusChName {
        statusEventSink = nil
      } else if channelName == dropChName {
        dropEventSink = nil
      }
    }
    return nil
  }
}
