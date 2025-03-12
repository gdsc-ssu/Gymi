# Eyedid_flutter

#### Eyedid SDK Flutter plugin project.

`Eyedid SDK` is a Eye Tracking library that calculates where the user is looking at on the screen in real time using RGB image from the camera.

All computation is done locally on the device.

## Getting Started

### 1. Install 
- Check the Development key.

- Create the new flutter project from terminal.
  ```bash
  flutter create --platforms android,ios sample_app
  ```

- Added `eyedid_flutter` to sample_app's `pubspec.yaml` file.
  ```yaml
  dependencies:
  flutter:
    sdk: flutter
  eyedid_flutter:1.0.0
  ```

- Install pub packge from terminal.

  ```bash
  flutter pub get
  ```

### Android

- Add the maven repository URL `https://seeso.jfrog.io/artifactory/visualcamp-eyedid-sdk-android-release` to the build.gradle file where seeso is located.

  ```gradle
  allprojects {
      repositories {
          ...
          maven {
              url "https://seeso.jfrog.io/artifactory/visualcamp-eyedid-sdk-android-release"
          }
      }
  }
  ```

- Add the following dependencies to the app/build.gradle file.

  ```gradle
  dependencies {
    ...
    implementation "camp.visual.eyedid.android.gazetracker:eyedid-gazetracker:{version}"
  }
  ```
### **Environment Set-ups** (iOS)

- Add permission to your Info.plist file. 
  ```
    <key>NSCameraUsageDescription</key>
    <string></string>
  ```
- Add `PERMISSION_CAMERA=1` to your Podfile.

  ```
  target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        ...
        'PERMISSION_CAMERA=1'
      ]
  end
  ```
- Pod install from terminal.
  ```bash
  pod install
  ```

### 2. Obtain a License Key
  Eyedid SDK requires a License Key for operation. You can obtain the key from [manage.eyedid.ai](https://manage.eyedid.ai).

### 3. How to use

1. Add code to check if you have camera permission.

    ```dart
    Future<void> checkCameraPermission() async {
        _hasCameraPermission = await _eyedidFlutterPlugin.checkCameraPermission();
      }
    ```
2. Add a function to request camera permission.

    ```dart
    Future<void> checkCameraPermission() async {
      _hasCameraPermission = await _eyedidFlutterPlugin.checkCameraPermission();
      ///If you do not have camera permission, call the requesting function.
      if (!_hasCameraPermission) {
        _hasCameraPermission = await _eyedidFlutterPlugin.requestCameraPermission();
      }
    }
    ```
3. When camera permission is obtained through the user, authentication begins by calling the initGazeTracker function.

    ```dart
      Future<void> initSeeSo() async {
        await checkCameraPermission();
        String requestInitGazeTracker = "failed Request";
        if (_hasCameraPermission) {
          try {
            InitializedResult? initializedResult =
                await _eyedidFlutterPlugin.initGazeTracker(licenseKey: _licenseKey);
          } on PlatformException catch (e) {
            print( "Occur PlatformException (${e.message})");
          }
        }
      }
    ```
4. When authentication is successful, eye tracking begins.
    ```dart
     if (initializedResult!.result) {
        try {
          _eyedidFlutterPlugin.startTracking();
        } on PlatformException catch (e) {
          print("Occur PlatformException (${e.message})");
        }
      }
    ```
5. Set a listener to receive MetricsInfo.
    ```dart
      _eyedidFlutterPlugin.getTrackingEvent().listen((event) {
        final info = MetricsInfo(event);
        if (info.gazeInfo.trackingState == TrackingState.success) {
          setState(() {
            _x = info.gazeInfo.gaze.x;
            _y = info.gazeInfo.gaze.y;
            _gazeColor = Colors.green;
          });
        } else {
          setState(() {
            _gazeColor = Colors.red;
          });
        }
      });
    ```

    ### API
    https://docs.eyedid.ai/docs/api/flutter-api-docs

    ### Contact Us

    If you have any problems, feel free to [development@eyedid.ai](mailto:development@visual.camp)

    ### License

    Copyright (c) VisualCamp. All rights reserved.