/// A class that represents the status information for Eyedid SDK's GazeTracker status event.
/// It contains the status type (e.g., start, stop, unknown) and an optional error type if any error occurs when stopping.
class StatusInfo {
  // The type of status event: 'start', 'stop', or 'unknown' if the status is not recognized.
  late final StatusType type;

  // The type of error that occurred when the status is 'stop'. Can be null if no error occurs or if the status is not 'stop'.
  late final StatusErrorType? errorType;

  StatusInfo(Map<dynamic, dynamic> event) {
    final String typeValue = event["statusEventType"] ?? "";
    if (typeValue == "start") {
      // If the event type is "start", set the status type to start and error type to null.
      type = StatusType.start;
      errorType = null;
    } else if (typeValue == "stop") {
      // If the event type is "stop", set the status type to stop and determine the error type if available.
      type = StatusType.stop;

      final String errorTypeValue = event["statusFailedReason"] ?? "error";
      if (errorTypeValue == "ERROR_NONE") {
        // No error occurred.
        errorType = StatusErrorType.none;
      } else if (errorTypeValue == "ERROR_CAMERA_START") {
        // An error occurred while starting the camera.
        errorType = StatusErrorType.cameraStart;
      } else if (errorTypeValue == "ERROR_CAMERA_INTERRUPT") {
        // An error occurred due to camera interruption.
        errorType = StatusErrorType.cameraInterrupt;
      } else {
        // If the error type is unknown, set it to unknown.
        errorType = StatusErrorType.unknown;
      }
    } else {
      // If the event type is not recognized, set type to unknown and errorType to unknown.
      // This means we cannot determine if it is a start or stop event.
      type = StatusType.unknown;
      errorType = StatusErrorType.unknown;
    }
  }

  @override
  String toString() {
    // Returns a string representation of the status information.
    return "[type: ${type.name}, error: ${errorType?.name ?? "null"}]";
  }
}

// Enum representing the different types of status events.
enum StatusType { start, stop, unknown }

// Enum representing the different types of errors that can occur when the status is 'stop'.
enum StatusErrorType {
  none, // No error occurred.
  cameraStart, // Error when starting the camera.
  cameraInterrupt, // Error due to camera interruption.
  unknown, // An unknown error occurred.
}
