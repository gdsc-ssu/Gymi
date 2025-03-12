/// Provides options for configuring the Gaze Tracker.
///
/// Use [GazeTrackerOptions.builder] to customize options such as blink detection,
/// user status tracking, gaze filtering, concurrency control, and camera presets.
///
/// Example usage:
/// ```dart
/// var options = GazeTrackerOptions.builder
///   .setUseBlink(true)
///   .setMaxConcurrency(2)
///   .setPreset(CameraPreset.fhd1920x1080)
///   .build();
/// ```
class GazeTrackerOptions {
  final bool useBlink;
  final bool useUserStatus;
  final bool useGazeFilter;
  final int maxConcurrency;
  final CameraPreset preset;

  GazeTrackerOptions._builder(GazeTrackerOptionsBuilder builder)
      : useBlink = builder._useBlink,
        useUserStatus = builder._useUserStatus,
        useGazeFilter = builder._useGazeFilter,
        maxConcurrency = builder._maxConcurrency,
        preset = builder._preset;

  /// Returns a new [GazeTrackerOptionsBuilder] to configure the options.
  static GazeTrackerOptionsBuilder get builder => GazeTrackerOptionsBuilder();
}

/// A builder class for constructing instances of [GazeTrackerOptions].
///
/// The [GazeTrackerOptionsBuilder] provides a fluent interface for configuring
/// the options used by the gaze tracker. This includes settings such as blink detection,
/// user status tracking, gaze filtering, concurrency limits, and camera presets.
///
/// Example usage:
/// ```dart
/// var options = GazeTrackerOptionsBuilder()
///   .setUseBlink(true)
///   .setMaxConcurrency(2)
///   .setPreset(CameraPreset.fhd1920x1080)
///   .build();
/// ```
/// This allows for flexible and readable configuration of the [GazeTrackerOptions].
class GazeTrackerOptionsBuilder {
  bool _useBlink = false;
  bool _useUserStatus = false;
  bool _useGazeFilter = true;
  int _maxConcurrency = 4;
  CameraPreset _preset = CameraPreset.vga640x480;

  /// Sets whether to use the blink detection feature.
  ///
  /// [useBlink] determines if the blink detection feature should be enabled.
  /// Returns the [GazeTrackerOptionsBuilder] for method chaining.
  GazeTrackerOptionsBuilder setUseBlink(bool useBlink) {
    _useBlink = useBlink;
    return this;
  }

  /// Sets whether to use user status tracking.
  ///
  /// [useUserStatus] determines if the user status tracking should be enabled.
  /// Returns the [GazeTrackerOptionsBuilder] for method chaining.
  GazeTrackerOptionsBuilder setUseUserStatus(bool useUserStatus) {
    _useUserStatus = useUserStatus;
    return this;
  }

  /// Sets whether to use gaze filtering for stabilization.
  ///
  /// [useGazeFilter] determines if gaze filtering should be applied to the tracking data.
  /// Returns the [GazeTrackerOptionsBuilder] for method chaining.
  GazeTrackerOptionsBuilder setUseGazeFilter(bool useGazeFilter) {
    _useGazeFilter = useGazeFilter;
    return this;
  }

  /// Sets the maximum number of concurrent gaze tracking processes.
  ///
  /// [maxConcurrency] specifies the maximum number of threads to be used for gaze tracking.
  /// If [maxConcurrency] is 0, it will use as many threads as possible without limitation.
  /// If [maxConcurrency] is less than 1, it defaults to 1.
  /// Returns the [GazeTrackerOptionsBuilder] for method chaining.
  GazeTrackerOptionsBuilder setMaxConcurrency(int maxConcurrency) {
    if (maxConcurrency < 0) {
      _maxConcurrency = 1;
    } else {
      _maxConcurrency = maxConcurrency;
    }
    return this;
  }

  /// Sets the camera preset for the gaze tracker.
  ///
  /// [preset] specifies the camera resolution to be used.
  /// Returns the [GazeTrackerOptionsBuilder] for method chaining.
  GazeTrackerOptionsBuilder setPreset(CameraPreset preset) {
    _preset = preset;
    return this;
  }

  /// Builds and returns a [GazeTrackerOptions] instance with the configured settings.
  ///
  /// This method finalizes the configuration and returns an instance of [GazeTrackerOptions].
  GazeTrackerOptions build() {
    return GazeTrackerOptions._builder(this);
  }
}

/// Enum representing the available camera resolution presets.
///
/// This enum allows the user to select a specific camera resolution for the application.
///
/// Available Presets:
/// - `vga640x480`: 640x480 resolution (VGA).
/// - `hd1280x720`: 1280x720 resolution (HD).
/// - `fhd1920x1080`: 1920x1080 resolution (Full HD).
enum CameraPreset {
  vga640x480,
  hd1280x720,
  fhd1920x1080,
}
