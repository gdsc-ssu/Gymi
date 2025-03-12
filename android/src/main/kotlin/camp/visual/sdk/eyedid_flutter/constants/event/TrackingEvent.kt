package camp.visual.sdk.eyedid_flutter.constants.event

object TrackingEvent {
    object Key {
        const val TIMESTAMP = "timestamp"

        /// GazeInfo
        const val GAZE_X = "gazeX"
        const val GAZE_Y = "gazeY"
        const val FIXATION_X = "fixationX"
        const val FIXATION_Y = "fixationY"
        const val TRACKING_STATE = "trackingState"
        const val EYE_MOVEMENT_STATE = "eyeMovementState"
        const val SCREEN_STATE= "screenState"

        /// FaceInfo
        const val FACE_SCORE = "faceScore"
        const val FRAME_WIDTH = "frameWidth"
        const val FRAME_HEIGHT = "frameHeight"
        const val FACE_LEFT = "faceLeft"
        const val FACE_TOP = "faceTop"
        const val FACE_RIGHT = "faceRight"
        const val FACE_BOTTOM = "faceBottom"
        const val FACE_PITCH = "facePitch"
        const val FACE_YAW = "faceYaw"
        const val FACE_ROLL = "faceRoll"
        const val FACE_CENTER_X = "faceCenterX"
        const val FACE_CENTER_Y = "faceCenterY"
        const val FACE_CENTER_Z = "faceCenterZ"

        /// BlinkInfo
        const val IS_BLINK = "isBlink"
        const val IS_BLINK_LEFT = "isBlinkLeft"
        const val IS_BLINK_RIGHT = "isBlinkRight"
        const val LEFT_OPENNESS = "leftOpenness"
        const val RIGHT_OPENNESS = "rightOpenness"

        /// UserStatusInfo
        const val IS_DROWSY = "isDrowsy"
        const val DROWSINESS_INTENSITY = "drowsinessIntensity"
        const val ATTENTION_SCORE = "attentionScore"
    }
}