import Foundation

struct TrackingEventKey {
    // Timestamp
    static let timestamp = "timestamp"
    
    // GazeInfo
    static let gazeX = "gazeX"
    static let gazeY = "gazeY"
    static let fixationX = "fixationX"
    static let fixationY = "fixationY"
    static let trackingState = "trackingState"
    static let eyeMovementState = "eyeMovementState"
    static let screenState = "screenState"
    
    // FaceInfo
    static let faceScore = "faceScore"
    static let frameWidth = "frameWidth"
    static let frameHeight = "frameHeight"
    static let faceLeft = "faceLeft"
    static let faceTop = "faceTop"
    static let faceRight = "faceRight"
    static let faceBottom = "faceBottom"
    static let facePitch = "facePitch"
    static let faceYaw = "faceYaw"
    static let faceRoll = "faceRoll"
    static let faceCenterX = "faceCenterX"
    static let faceCenterY = "faceCenterY"
    static let faceCenterZ = "faceCenterZ"
    
    // BlinkInfo
    static let isBlink = "isBlink"
    static let isBlinkLeft = "isBlinkLeft"
    static let isBlinkRight = "isBlinkRight"
    static let leftOpenness = "leftOpenness"
    static let rightOpenness = "rightOpenness"
    
    // UserStatusInfo
    static let isDrowsy = "isDrowsy"
    static let drowsinessIntensity = "drowsinessIntensity"
    static let attentionScore = "attentionScore"
}