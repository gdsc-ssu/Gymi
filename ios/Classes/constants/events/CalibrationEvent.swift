struct CalibrationEventKey {
    static let calibrationType = "calibrationType"
    static let progress = "calibrationProgress"
    static let nextX = "calibrationNextX"
    static let nextY = "calibrationNextY"
    static let calibrationData = "calibrationData"
}

struct CalibrationEventType {
    static let calibrationProgress = "onCalibrationProgress"
    static let calibrationNextXY = "onCalibrationNextXY"
    static let calibrationFinished = "onCalibrationFinished"
    static let calibrationCanceled = "onCalibrationCanceled"
}