import 'dart:math';

/// A class that represents calibration status information for the Eyedid SDK.
/// It contains the type of calibration event, progress percentage, the next calibration point, and calibration data if available.
class CalibrationInfo {
  // The type of calibration event: progress, nextPoint, finished, or unknown.
  late final CalibrationType type;

  // The progress of the calibration process (0.0 to 1.0). Can be null if not applicable.
  late final double? progress;

  // The next point for calibration. This is used when the event indicates the next calibration point.
  // Can be null if not applicable.
  late final Point<double>? next;

  // Calibration data collected when the calibration is finished. Can be null if not applicable.
  late final List<double>? data;

  CalibrationInfo(Map<dynamic, dynamic> event) {
    final typeValue = event["calibrationType"] ?? "unknown";
    if (typeValue == "onCalibrationProgress") {
      // When the calibration is in progress, set the type to progress and update the progress value.
      type = CalibrationType.progress;
      progress = event["calibrationProgress"] ?? -1001;
      next = null;
      data = null;
    } else if (typeValue == "onCalibrationNextXY") {
      // When the next calibration point is available, set the type to nextPoint and store the point's coordinates.
      type = CalibrationType.nextPoint;
      progress = null;
      final double x = event["calibrationNextX"] ?? -1001;
      final double y = event["calibrationNextY"] ?? -1001;
      next = Point(x, y);
      data = null;
    } else if (typeValue == "onCalibrationFinished") {
      // When the calibration is finished, set the type to finished and store the calibration data.
      type = CalibrationType.finished;
      progress = null;
      next = null;
      data = List<double>.from(event["calibrationData"] as List);
    } else if (typeValue == "onCalibrationCanceled") {
      // When the calibration is canceled, set the type to canceled and store the calibration data.
      type = CalibrationType.canceled;
      progress = null;
      next = null;
      data = List<double>.from(event["calibrationData"] as List);
    } else {
      // If the event type is unknown, set type to unknown and all other fields to null.
      type = CalibrationType.unknown;
      progress = null;
      next = null;
      data = null;
    }
  }

  @override
  String toString() {
    // Returns a string representation of the calibration information based on the type.
    var context = "[type: ${type.name},";
    if (type == CalibrationType.progress) {
      context += " progress: ${progress!}]";
    } else if (type == CalibrationType.nextPoint) {
      context += " next : ${next.toString()}]";
    } else if (type == CalibrationType.finished) {
      context += " data : ${data.toString()}]";
    } else if (type == CalibrationType.canceled) {
      context += " data : ${data.toString()}]";
    }

    return context;
  }
}

// Enum representing the different types of calibration events.
enum CalibrationType {
  progress, // Calibration is in progress.
  nextPoint, // Next calibration point is available.
  finished, // Calibration has finished and data is available.
  canceled, // Calibration has been canceled.
  unknown // Unknown calibration type.
}
