import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_drop.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter_example/%08screens/color_select_screen.dart';
import 'package:eyedid_flutter_example/%08screens/second_screen.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:eyedid_flutter_example/%08screens/exercise2.dart';
import 'package:eyedid_flutter_example/%08screens/exercise2_intro.dart';

import 'package:flutter/services.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_calibration.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'service/gaze_tracker_service.dart';

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
      // 첫 화면을 FirstScreen으로 변경
      home: const FirstScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// main.dart 파일의 _MyHomePageState 클래스 수정 부분

class _MyHomePageState extends State<MyHomePage> {
  final _gazeService = GazeTrackerService();
  var _hasCameraPermission = false;
  var _isInitialied = false;
  final _licenseKey = "dev_pfst1u7ac35i0k94ia0crcapirnrjrznalqb92bu";
  var _version = 'Unknown';
  var _stateString = "IDLE";
  var _hasCameraPermissionString = "NO_GRANTED";
  var _trackingBtnText = "STOP TRACKING";
  var _showingGaze = false;
  var _isCaliMode = false;

  var _x = 0.0, _y = 0.0;
  Color _gazeColor = Colors.red;
  var _nextX = 0.0, _nextY = 0.0, _calibrationProgress = 0.0;
  late var _dotSize = 10.0;

  StreamSubscription<dynamic>? _gazeSubscription;
  StreamSubscription<dynamic>? _calibrationSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 컨텍스트를 안전하게 업데이트 (빌드 프로세스 이후에 실행됨)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context);
    });
  }

  Future<void> checkCameraPermission() async {
    _hasCameraPermission = await _gazeService.checkCameraPermission();

    if (!_hasCameraPermission) {
      _hasCameraPermission = await _gazeService.requestCameraPermission();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _hasCameraPermissionString = _hasCameraPermission ? "granted" : "denied";
    });
  }

  Future<void> initPlatformState() async {
    await checkCameraPermission();
    if (_hasCameraPermission) {
      String platformVersion;
      try {
        platformVersion = await _gazeService.getPlatformVersion();
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
    final initialized =
        await _gazeService.initialize(_licenseKey, context: context);

    if (initialized) {
      final isTracking = await _gazeService.isTrackingNow();

      if (!isTracking) {
        await _gazeService.startTracking();
      }

      // 시선 위치 업데이트를 위한 구독
      _gazeSubscription = _gazeService.gazePositionStream.listen((data) {
        if (mounted) {
          setState(() {
            _x = data['x'];
            _y = data['y'];
            _gazeColor = data['color'];
            _dotSize = data['size'];
            _showingGaze = data['isTracking'];
          });
        }
      });

      // 캘리브레이션 상태 업데이트를 위한 구독
      _calibrationSubscription = _gazeService.calibrationStream.listen((data) {
        if (mounted) {
          setState(() {
            _isCaliMode = data['isCalibrationMode'];
            _nextX = data['nextX'];
            _nextY = data['nextY'];
            _calibrationProgress = data['progress'];
          });
        }
      });

      setState(() {
        _isInitialied = true;
        _stateString = "Initialized and tracking";
      });
    } else {
      setState(() {
        _stateString = "Failed to initialize";
      });
    }
  }

  void _trackingBtnPressed() {
    if (_isInitialied) {
      if (_trackingBtnText == "START TRACKING") {
        try {
          _gazeService.startTracking();
          setState(() {
            _trackingBtnText = "STOP TRACKING";
          });
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      } else {
        try {
          _gazeService.stopTracking();
          setState(() {
            _trackingBtnText = "START TRACKING";
          });
        } on PlatformException catch (e) {
          setState(() {
            _stateString = "Occur PlatformException (${e.message})";
          });
        }
      }
    }
  }

  void _calibrationBtnPressed() {
    if (_isInitialied && _showingGaze) {
      try {
        _gazeService.startCalibration(
          CalibrationMode.five,
          usePreviousCalibration: true,
        );
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
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecondScreen(
                            x: _x,
                            y: _y,
                            gazeColor: _gazeColor,
                          ),
                        ),
                      );
                    },
                    child: const Text("SECOND SCREEN"),
                  ),
                  // Exercies2 화면 버튼 추가 (import 필요)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Exercies2(),
                        ),
                      );
                    },
                    child: const Text("Exercise2"),
                  ),
                  if (_isInitialied)
                    ElevatedButton(
                      onPressed: _trackingBtnPressed,
                      child: Text(_trackingBtnText),
                    ),
                  if (_isInitialied && _showingGaze)
                    ElevatedButton(
                      onPressed: _calibrationBtnPressed,
                      child: const Text("START CALIBRATION"),
                    ),
                ],
              ),
            ),
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
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gazeSubscription?.cancel();
    _calibrationSubscription?.cancel();
    super.dispose();
  }
}
