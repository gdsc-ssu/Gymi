import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_drop.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter_example/%08screens/color_select_screen.dart';
import 'package:eyedid_flutter_example/%08screens/second_screen.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_calibration.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'Gaze Tracker App',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF9BBEDE),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 60,
            ),
            headlineMedium: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.normal,
              fontSize: 25,
            ),
          ),
          primarySwatch: Colors.blue),
      home: const FirstScreen(), // ✅ Navigator가 정상 작동하도록 변경
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _eyedidFlutterPlugin = EyedidFlutter();
  var _hasCameraPermission = false;
  var _isInitialied = false;
  final _licenseKey = "dev_pfst1u7ac35i0k94ia0crcapirnrjrznalqb92bu";
  var _version = 'Unknown';
  var _stateString = "IDLE";
  var _hasCameraPermissionString = "NO_GRANTED";
  var _trackingBtnText = "STOP TRACKING";
  var _showingGaze = false;
  var _isCaliMode = false;

  StreamSubscription<dynamic>? _trackingEventSubscription;
  StreamSubscription<dynamic>? _dropEventSubscription;
  StreamSubscription<dynamic>? _statusEventSubscription;
  StreamSubscription<dynamic>? _calibrationEventSubscription;

  var _x = 0.0, _y = 0.0;
  Color _gazeColor = Colors.red;
  var _nextX = 0.0, _nextY = 0.0, _calibrationProgress = 0.0;
  late var _dotSize = 10.0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> checkCameraPermission() async {
    _hasCameraPermission = await _eyedidFlutterPlugin.checkCameraPermission();

    if (!_hasCameraPermission) {
      _hasCameraPermission =
          await _eyedidFlutterPlugin.requestCameraPermission();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasCameraPermissionString = _hasCameraPermission ? "granted" : "denied";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await checkCameraPermission();
    if (_hasCameraPermission) {
      String platformVersion;
      try {
        platformVersion = await _eyedidFlutterPlugin.getPlatformVersion();
      } on PlatformException catch (error) {
        print(error);
        platformVersion = 'Failed to get platform version.';
      }

      if (!mounted) return;
      initEyedidPlugin();
      setState(() {
        _version = platformVersion;
      });
    }
  }

  Future<void> initEyedidPlugin() async {
    String requestInitGazeTracker = "failed Request";
    try {
      final options = GazeTrackerOptionsBuilder()
          .setPreset(CameraPreset.vga640x480)
          .setUseGazeFilter(true)
          .setUseBlink(false)
          .setUseUserStatus(false)
          .build();
      final result = await _eyedidFlutterPlugin.initGazeTracker(
          licenseKey: _licenseKey, options: options);
      var enable = false;
      var showGaze = false;
      if (result.result) {
        enable = true;
        listenEvents();
        _eyedidFlutterPlugin.startTracking();
      } else if (result.message == InitializedResult.isAlreadyAttempting ||
          result.message == InitializedResult.gazeTrackerAlreadyInitialized) {
        enable = true;
        listenEvents();
        final isTracking = await _eyedidFlutterPlugin.isTracking();
        if (isTracking) {
          showGaze = true;
        }
      }
      setState(() {
        _isInitialied = enable;
        _stateString = "${result.result} : (${result.message})";
        _showingGaze = showGaze;
      });
    } on PlatformException catch (e) {
      requestInitGazeTracker = "Occur PlatformException (${e.message})";
      setState(() {
        _stateString = requestInitGazeTracker;
      });
    }
  }

  void listenEvents() {
    _trackingEventSubscription?.cancel();
    _dropEventSubscription?.cancel();
    _statusEventSubscription?.cancel();
    _calibrationEventSubscription?.cancel();
    _trackingEventSubscription =
        _eyedidFlutterPlugin.getTrackingEvent().listen((event) {
      final info = MetricsInfo(event);
      if (info.gazeInfo.trackingState == TrackingState.success) {
        setState(() {
          _x = info.gazeInfo.gaze.x;
          _y = info.gazeInfo.gaze.y;
          _gazeColor = Colors.blueAccent;
          _dotSize = 20.0;

          // Overlay를 통해 모든 화면에서 원 표시
          GazeOverlay.show(context, _x, _y, _gazeColor);
        });
      } else {
        setState(() {
          _gazeColor = Colors.redAccent;
          _dotSize = 20.0;
          // ❌ 실패한 경우 Overlay 제거 (점이 남지 않도록)
          GazeOverlay.remove();
        });
      }
    });

    _dropEventSubscription =
        _eyedidFlutterPlugin.getDropEvent().listen((event) {
      final info = DropInfo(event);
      debugPrint("Dropped at timestamp: ${info.timestamp}");
    });

    _statusEventSubscription =
        _eyedidFlutterPlugin.getStatusEvent().listen((event) {
      final info = StatusInfo(event);
      if (info.type == StatusType.start) {
        setState(() {
          _stateString = "start Tracking";
          _showingGaze = true;
        });
      } else {
        setState(() {
          _stateString = "stop Trakcing : ${info.errorType?.name}";
          _showingGaze = false;
        });
      }
    });

    _calibrationEventSubscription =
        _eyedidFlutterPlugin.getCalibrationEvent().listen((event) {
      final info = CalibrationInfo(event);
      if (info.type == CalibrationType.nextPoint) {
        setState(() {
          _nextX = info.next!.x;
          _nextY = info.next!.y;
          _calibrationProgress = 0.0;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          _eyedidFlutterPlugin.startCollectSamples();
        });
      } else if (info.type == CalibrationType.progress) {
        setState(() {
          _calibrationProgress = info.progress!;
        });
      } else if (info.type == CalibrationType.finished) {
        setState(() {
          _isCaliMode = false;
        });
      } else if (info.type == CalibrationType.canceled) {
        debugPrint("Calibration canceled ${info.data?.length}");
        setState(() {
          _isCaliMode = false;
        });
      }
    });
  }

  void _trackingBtnPressed() {
    if (_isInitialied) {
      if (_trackingBtnText == "START TRACKING") {
        try {
          _eyedidFlutterPlugin
              .startTracking(); // Call the function to start tracking
          _trackingBtnText = "STOP TRACKING";
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      } else {
        try {
          _eyedidFlutterPlugin
              .stopTracking(); // Call the function to stop tracking
          _trackingBtnText = "START TRACKING";
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      }
      setState(() {
        _trackingBtnText = _trackingBtnText;
      });
    }
  }

  void _calibrationBtnPressed() {
    if (_isInitialied) {
      try {
        _eyedidFlutterPlugin.startCalibration(CalibrationMode.five,
            usePreviousCalibration: true);
        setState(() {
          _isCaliMode = true;
        });
      } on PlatformException catch (e) {
        setState(() {
          _stateString = "Occur PlatformException (${e.message})";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // Hide the AppBar
      body: Stack(
        children: <Widget>[
          if (!_isCaliMode)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Eyedid SDK version: $_version'),
                  Text('App has CameraPermission: $_hasCameraPermissionString'),
                  Text('Eyedid initState : $_stateString'),
                  const SizedBox(
                      height: 20), // Adding spacing between Text and Button
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SecondScreen(x: _x, y: _y, gazeColor: _gazeColor),
                        ),
                      );
                    },
                    child: const Text("SECOND SCREEN"),
                  ),
                  if (_isInitialied)
                    ElevatedButton(
                      onPressed: _trackingBtnPressed,
                      child: Text(_trackingBtnText),
                    ),
                  if (_isInitialied && _showingGaze)
                    ElevatedButton(
                        onPressed: _calibrationBtnPressed,
                        child: const Text("START CALIBRATION"))
                ],
              ),
            ),
          /*if (_showingGaze && !_isCaliMode)
            TrackingPoint(
                x: _x, y: _y, dotSize: _dotSize, gazeColor: _gazeColor),*/
          if (_isCaliMode)
            Positioned(
                left: _nextX - 10,
                top: _nextY - 10,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: _calibrationProgress,
                    backgroundColor: Colors.grey,
                  ),
                ))
        ],
      ),
    );
  }
}
