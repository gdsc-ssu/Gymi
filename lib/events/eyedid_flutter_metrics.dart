import 'dart:math';
import 'dart:ui';

/// [MetricsInfo] is a data structure designed to collect and organize
/// various information from the tracking event stream.
///
/// This class gathers multiple types of tracking data, including:
/// - [timestamp]: The timestamp of the event.
/// - [gazeInfo]: Information about the user's gaze, such as coordinates and tracking state.
/// - [faceInfo]: Details regarding the user's face position and orientation.
/// - [blinkInfo]: Blink detection data.
/// - [userStatusInfo]: Additional status information about the user, such as attention level.
///
/// [MetricsInfo] helps structure this data for further analysis or UI updates.
class MetricsInfo {
  late final int timestamp;
  late final GazeInfo gazeInfo;
  late final FaceInfo faceInfo;
  late final BlinkInfo blinkInfo;
  late final UserStatusInfo userStatusInfo;

  MetricsInfo(Map<dynamic, dynamic> event) {
    timestamp = event[MetricsInfoKey.timestamp.name] ?? -1;
    gazeInfo = GazeInfo(event);
    faceInfo = FaceInfo(event);
    blinkInfo = BlinkInfo(event);
    userStatusInfo = UserStatusInfo(event);
  }

  @override
  String toString() {
    return "[timestamp: $timestamp, gazeInfo: ${gazeInfo.toString()}, faceInfo: ${faceInfo.toString()}, blinkInfo: ${blinkInfo.toString()}, userStatusInfo: ${userStatusInfo.toString()}]";
  }
}

/// [GazeInfo] represents the data collected from gaze tracking events,
/// providing detailed information about the user's gaze and related states.
///
/// This class includes the following properties:
/// - [gaze]: The current gaze point on the screen, represented as coordinates (x, y).
/// - [fixation]: The most recently detected fixation point, providing stable coordinates where the user's gaze was fixated.
/// - [trackingState]: The state of the gaze tracking, indicating whether tracking is successful, lost, or in progress.
/// - [eyemovementState]: Information about the user's eye movement, such as fixation or saccade.
/// - [screenState]: Indicates whether the user's gaze is within the device screen boundaries or outside of it.
///
/// [GazeInfo] is essential for interpreting the user's gaze behavior and determining their interaction with the screen in real-time.
class GazeInfo {
  late final Point<double> gaze;
  late final Point<double> fixation;
  late final TrackingState trackingState;
  late final EyemovementState eyemovementState;
  late final ScreenState screenState;

  GazeInfo(Map<dynamic, dynamic> event) {
    final double x = event[MetricsInfoKey.gazeX.name] ?? -1001;
    final double y = event[MetricsInfoKey.gazeY.name] ?? -1001;
    gaze = Point(x, y);
    var fixationX = event[MetricsInfoKey.fixationX.name] ?? -1001;
    var fixationY = event[MetricsInfoKey.fixationY.name] ?? -1001;
    fixation = Point(fixationX, fixationY);

    final trackingValue = event[MetricsInfoKey.trackingState.name] ?? "";
    if (trackingValue == "SUCCESS") {
      trackingState = TrackingState.success;
    } else if (trackingValue == "GAZE_NOT_FOUND") {
      trackingState = TrackingState.gazeNotFound;
    } else {
      trackingState = TrackingState.faceMissing;
    }

    final movenmentValue = event[MetricsInfoKey.eyeMovementState.name] ?? "";
    if (movenmentValue == "FIXATION") {
      eyemovementState = EyemovementState.fixation;
    } else if (movenmentValue == "SACCADE") {
      eyemovementState = EyemovementState.saccade;
    } else {
      eyemovementState = EyemovementState.unknown;
    }

    final screenValue = event[MetricsInfoKey.screenState.name] ?? "";
    if (screenValue == "INSIDE_OF_SCREEN") {
      screenState = ScreenState.insideOfScreen;
    } else if (screenValue == "OUTSIDE_OF_SCREEN") {
      screenState = ScreenState.outsideOfScreen;
    } else {
      screenState = ScreenState.unknown;
    }
  }

  @override
  String toString() {
    return "[gaze: ${gaze.toString()}, fixation: ${fixation.toString()}, trackingState: ${trackingState.name}, eyeMovementState: ${eyemovementState.name}], screenState: ${screenState.name}";
  }
}

/// [FaceInfo] represents the data collected from face tracking events,
/// providing information about the detected face and its orientation in space.
///
/// This class includes the following properties:
/// - [score]: A confidence score (0.0 to 1.0) indicating the accuracy of the face detection.
/// - [rect]: The bounding rectangle of the detected face, represented as a [Rect] object with coordinates relative to [imageSize].
/// - [imageSize]: The size of the image used by the camera during face detection, represented as a [Size] object.
/// - [pitch]: The pitch angle of the face, representing the up and down tilt.
/// - [yaw]: The yaw angle of the face, representing the left and right rotation.
/// - [roll]: The roll angle of the face, representing the tilt to the left or right side.
/// - [centerX]: The distance of the face's center from the camera along the X-axis.
/// - [centerY]: The distance of the face's center from the camera along the Y-axis.
/// - [centerZ]: The distance of the face's center from the camera along the Z-axis (depth).
///
/// [FaceInfo] is useful for understanding the face orientation and its position relative to the camera,
/// aiding in gaze tracking and other facial interactions.
class FaceInfo {
  late final double score;
  late final Rect rect;
  late final Size imageSize;
  late final double pitch;
  late final double yaw;
  late final double roll;
  late final double centerX;
  late final double centerY;
  late final double centerZ;

  FaceInfo(Map<dynamic, dynamic> event) {
    score = event[MetricsInfoKey.faceScore.name] ?? -1001;
    final double left = event[MetricsInfoKey.faceLeft.name] ?? -1001;
    final double top = event[MetricsInfoKey.faceTop.name] ?? -1001;
    final double right = event[MetricsInfoKey.faceRight.name] ?? -1001;
    final double bottom = event[MetricsInfoKey.faceBottom.name] ?? -1001;
    rect = Rect.fromLTRB(left, top, right, bottom);
    pitch = event[MetricsInfoKey.facePitch.name] ?? -1001;
    yaw = event[MetricsInfoKey.faceYaw.name] ?? -1001;
    roll = event[MetricsInfoKey.faceRoll.name] ?? -1001;
    final width = (event[MetricsInfoKey.frameWidth.name] ?? -1001) as num;
    final height = (event[MetricsInfoKey.frameHeight.name] ?? -1001) as num;
    imageSize = Size(width.toDouble(), height.toDouble());

    centerX = event[MetricsInfoKey.faceCenterX.name] ?? -1001;
    centerY = event[MetricsInfoKey.faceCenterY.name] ?? -1001;
    centerZ = event[MetricsInfoKey.faceCenterZ.name] ?? -1001;
  }

  @override
  String toString() {
    return "[score: $score, rect: ${rect.toString()}, pitch: $pitch, yaw: $yaw, roll: $roll, centerX: $centerX, centerY: $centerY, centerZ: $centerZ]";
  }
}

/// [BlinkInfo] represents the data related to eye blink detection,
/// providing information about whether a blink occurred and the openness level of each eye.
///
/// This class includes the following properties:
/// - [isBlink]: A boolean value indicating whether a blink (both eyes) is detected.
/// - [isBlinkLeft]: A boolean value indicating whether the left eye is detected as blinking.
/// - [isBlinkRight]: A boolean value indicating whether the right eye is detected as blinking.
/// - [leftOpenness]: A double value (0.0 to 1.0) representing the openness level of the left eye,
///   where 0.0 means fully closed and 1.0 means fully open.
/// - [rightOpenness]: A double value (0.0 to 1.0) representing the openness level of the right eye,
///   where 0.0 means fully closed and 1.0 means fully open.
///
/// [BlinkInfo] is used to monitor and interpret the blinking state of the user's eyes,
/// aiding in detecting attention levels and gaze-based interactions.
class BlinkInfo {
  late final bool isBlink;
  late final bool isBlinkLeft;
  late final bool isBlinkRight;
  late final double leftOpenness;
  late final double rightOpenness;

  BlinkInfo(Map<dynamic, dynamic> event) {
    isBlink = event[MetricsInfoKey.isBlink.name] ?? false;
    isBlinkLeft = event[MetricsInfoKey.isBlinkLeft.name] ?? false;
    isBlinkRight = event[MetricsInfoKey.isBlinkRight.name] ?? false;
    leftOpenness = event[MetricsInfoKey.leftOpenness.name] ?? -1001;
    rightOpenness = event[MetricsInfoKey.rightOpenness.name] ?? -1001;
  }

  @override
  String toString() {
    return "[isBlink: $isBlink, isBlinkLeft: $isBlinkLeft, isBlinkRight: $isBlinkRight, leftOpenness: $leftOpenness, rightOpenness: $rightOpenness]";
  }
}

/// [UserStatusInfo] provides information about the user's status, such as drowsiness and attention level,
/// based on gaze and eye tracking data.
///
/// This class includes the following properties:
/// - [isDrowsy]: A boolean value indicating whether the user is detected as drowsy.
/// - [drowsinessIntensity]: A double value (0.0 to 1.0) representing the intensity of drowsiness,
///   where 0.0 indicates no drowsiness and 1.0 indicates extreme drowsiness.
/// - [attentionScore]: A double value (0.0 to 1.0) representing the user's attention level,
///   where 0.0 means no attention and 1.0 means full attention.
///
/// [UserStatusInfo] is useful for monitoring the user's state in real-time,
/// helping to detect signs of drowsiness and measure attention levels during interactions.
class UserStatusInfo {
  late final bool isDrowsy;
  late final double drowsinessIntensity;
  late final double attentionScore;

  UserStatusInfo(Map<dynamic, dynamic> event) {
    isDrowsy = event[MetricsInfoKey.isDrowsy.name] ?? false;
    drowsinessIntensity =
        event[MetricsInfoKey.drowsinessIntensity.name] ?? -1001;
    attentionScore = event[MetricsInfoKey.attentionScore.name] ?? -1001;
  }

  @override
  String toString() {
    return "[isDrowsy: $isDrowsy, drowsinessIntensity: $drowsinessIntensity, attentionScore: $attentionScore]";
  }
}

enum MetricsInfoKey {
  timestamp,
  gazeX,
  gazeY,
  fixationX,
  fixationY,
  trackingState,
  eyeMovementState,
  screenState,
  faceScore,
  frameWidth,
  frameHeight,
  faceLeft,
  faceTop,
  faceRight,
  faceBottom,
  facePitch,
  faceYaw,
  faceRoll,
  faceCenterX,
  faceCenterY,
  faceCenterZ,
  isBlink,
  isBlinkLeft,
  isBlinkRight,
  leftOpenness,
  rightOpenness,
  isDrowsy,
  drowsinessIntensity,
  attentionScore,
}

/// [TrackingState] represents the different states that the tracking system can be in
/// during gaze and face tracking.
///
/// This enum includes the following states:
/// - [success]: The tracking is successful, and the gaze is detected correctly.
/// - [gazeNotFound]: The tracking system is active, but the gaze could not be detected.
/// - [faceMissing]: The tracking system cannot detect the face, making gaze tracking impossible.
///
/// Use [TrackingState] to check the status of the tracking system and respond accordingly
/// based on whether the gaze or face is detected.
enum TrackingState { success, gazeNotFound, faceMissing }

/// [EyemovementState] represents the different states of eye movement detected by the tracking system.
///
/// This enum includes the following states:
/// - [fixation]: The eye is fixated on a specific point, indicating stable gaze.
/// - [saccade]: A rapid movement of the eye between fixation points, indicating quick gaze shifts.
/// - [unknown]: The state of the eye movement is undetermined or not recognized.
///
/// Use [EyemovementState] to identify the type of eye movement detected
/// and to analyze or respond to changes in the user’s gaze behavior.
enum EyemovementState { fixation, saccade, unknown }

/// [ScreenState] represents the different states of the user's gaze in relation to the screen boundaries.
///
/// This enum includes the following states:
/// - [insideOfScreen]: The user's gaze is detected within the screen boundaries.
/// - [outsideOfScreen]: The user's gaze is detected outside of the screen boundaries.
/// - [unknown]: The state of the user's gaze in relation to the screen cannot be determined.
///
/// Use [ScreenState] to check if the user's gaze is within the screen area or outside, and
/// to take appropriate actions based on the user's gaze location.
enum ScreenState { insideOfScreen, outsideOfScreen, unknown }
