/// Defines the calibration modes for the Eyedid SDK.
///
/// - [one]: Calibration with a single target point.
/// - [five]: Calibration with five target points for greater accuracy.
enum CalibrationMode { one, five }

/// Represents different calibration criteria levels.
///
/// - [low]: Low accuracy, faster calibration.
/// - [standard]: Default level for general use.
/// - [high]: High accuracy for precise calibration.
enum CalibrationCriteria { low, standard, high }
