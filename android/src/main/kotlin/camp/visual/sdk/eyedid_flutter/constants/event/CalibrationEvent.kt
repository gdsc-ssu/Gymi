package camp.visual.sdk.eyedid_flutter.constants.event

object CalibrationEvent {
    object Key {
        const val CALIBRATION_TYPE = "calibrationType"
        const val PROGRESS = "calibrationProgress"
        const val NEXT_X = "calibrationNextX"
        const val NEXT_Y = "calibrationNextY"
        const val CALIBRATION_DATA = "calibrationData"
    }
    object Type {
        const val CALIBRATION_PROGRESS = "onCalibrationProgress"
        const val CALIBRATION_NEXT_XY = "onCalibrationNextXY"
        const val CALIBRATION_FINISHED = "onCalibrationFinished"
        const val CALIBRATION_CANCELED = "onCalibrationCanceled"
    }
}