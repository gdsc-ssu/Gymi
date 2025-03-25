import 'dart:async';
import 'package:eyedid_flutter_example/%08screens/exercise2.dart';
import 'package:eyedid_flutter_example/%08screens/calibration_screen.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:eyedid_flutter_example/%08screens/exercise2_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final bool isVibrant;
  const HomeScreen({super.key, required this.isVibrant});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _gazeService = GazeTrackerService();
  var _hasCameraPermission = false;
  var _isInitialied = false;
  final _licenseKey = "dev_pfst1u7ac35i0k94ia0crcapirnrjrznalqb92bu";
  var _version = 'Unknown';
  var _stateString = "IDLE";
  var _hasCameraPermissionString = "NO_GRANTED";
  final _trackingBtnText = "STOP TRACKING";
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
    // TODO: implement initState
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.isVibrant
              ?
              // 배경
              Image.asset(
                  'assets/images/HomeScreen1.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.asset(
                  'assets/images/HomeScreen2.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),

          // 좌측 상단의 Gymi 로고
          Positioned(
            top: 125,
            left: 30,
            child: widget.isVibrant
                ? Image.asset(
                    'assets/images/HomeGymi.png', // 로고 이미지
                    width: 500,
                  )
                : Image.asset(
                    'assets/images/HomeGymi2.png', // 로고 이미지
                    width: 500,
                  ),
          ),

          // 오른쪽 상단의 캐릭터
          Positioned(
            top: 280,
            right: 180,
            child: widget.isVibrant
                ? Image.asset(
                    'assets/images/bird.png', // 파란 새 캐릭터 이미지
                    width: 200,
                  )
                : Image.asset(
                    'assets/images/Talpidae.png', // 두더지 캐릭터 이미지
                    width: 200,
                  ),
          ),

          // 오른쪽 메뉴 버튼들
          Positioned(
            right: 150,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tutorial 버튼
                _buildMenuButton(context, 'Tutorial', const Color(0xFF333333),
                    FontWeight.bold, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Exercise2IntroScreen(
                              isVibrant: widget.isVibrant,
                            )),
                  );
                }),

                const SizedBox(height: 20),

                // Calibrate 버튼
                _buildMenuButton(
                    context, 'Calibrate', Colors.grey, FontWeight.normal, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CalibrationScreen(
                        gazeService: _gazeService,
                        isVibrant: widget.isVibrant,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Start exercise 버튼
                _buildMenuButton(
                    context, 'Start exercise', Colors.grey, FontWeight.normal,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExerciseScreen()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 버튼 위젯
  Widget _buildMenuButton(BuildContext context, String text, Color textColor,
      FontWeight fontWeight, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 48,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

// 네비게이션 대상 화면들
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tutorial Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Exercise Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
