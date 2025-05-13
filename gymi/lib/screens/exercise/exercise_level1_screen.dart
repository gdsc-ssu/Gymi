import 'dart:async';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_intro.dart';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_level2_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../service/gaze_tracker_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ExerciseLevel1Stage extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;

  const ExerciseLevel1Stage(
      {super.key, this.isVibrant = true, this.isSingleMode = false});

  @override
  State<ExerciseLevel1Stage> createState() => _ExerciseLevel1StageState();
}

class _ExerciseLevel1StageState extends State<ExerciseLevel1Stage>
    with WidgetsBindingObserver {
  final _gazeService = GazeTrackerService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  double _x = 0.0;
  double _y = 0.0;

  String _currentTarget = 'up'; // 'up' 또는 'down'
  DateTime? _gazeStartTime;
  Timer? _gazeTimer;
  Timer? _progressTimer;

  bool _showCompletionMessage = false;
  bool _screenActive = true;
  final bool _showTrackingFocus = true;

  final int _dwellTime = 3000; // 3초
  final int _totalSessionTime = 30; // 30초

  Color _gazeColor = Colors.blue;
  double _dotSize = 20.0;

  StreamSubscription<dynamic>? _gazeSubscription;

  // 🔥 진행도 변수
  double _progress = 0.0;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupGazeTracking();
    _gazeService.setShowOverlay(true);

    _startTime = DateTime.now();

    // ✅ progressTimer만 사용 (sessionTimer 삭제)
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress = (elapsed / (_totalSessionTime * 1000)).clamp(0.0, 1.0);
      });
      if (_progress >= 1.0) {
        timer.cancel();
        _showCompletion();
      }
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context);
      _screenActive = true;
      if (_showTrackingFocus) {
        _gazeService.refreshOverlay();
      }
    });
  }

  @override
  void dispose() {
    _gazeSubscription?.cancel();
    _gazeTimer?.cancel();
    _progressTimer?.cancel();
    _audioPlayer.dispose();
    // _gazeService.setShowOverlay(true);

    WidgetsBinding.instance.removeObserver(this);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  void _setupGazeTracking() {
    _gazeSubscription = _gazeService.gazePositionStream.listen((data) {
      if (!mounted || !_screenActive) return;

      setState(() {
        _x = data['x'];
        _y = data['y'];
        _gazeColor = data['color'];
        _dotSize = data['size'];
      });

      _detectUpDown();
    });
  }

  void _detectUpDown() {
    if (_showCompletionMessage) return;

    final screenHeight = MediaQuery.of(context).size.height;
    final centerY = screenHeight / 2;

    String detectedDirection = _y < centerY ? 'up' : 'down';

    if (detectedDirection == _currentTarget) {
      if (_gazeStartTime == null) {
        _gazeStartTime = DateTime.now();
        _startGazeTimer();
      }
    } else {
      _resetGazeTimer();
    }
  }

  void _startGazeTimer() {
    _gazeTimer?.cancel();
    _gazeTimer = Timer(Duration(milliseconds: _dwellTime), () {
      if (!mounted || !_screenActive) return;

      _audioPlayer.play(AssetSource('audio/correct.mp3'));
      HapticFeedback.mediumImpact();

      setState(() {
        _currentTarget = _currentTarget == 'up' ? 'down' : 'up';
        _gazeStartTime = null;
      });
    });
  }

  void _resetGazeTimer() {
    _gazeTimer?.cancel();
    _gazeStartTime = null;
  }

  void _showCompletion() {
    setState(() {
      _showCompletionMessage = true;
    });

    _gazeService.setShowOverlay(false);

    Timer(const Duration(seconds: 3), () {
      if (mounted && _screenActive) {
        if (widget.isSingleMode) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExerciseIntroScreen(isVibrant: widget.isVibrant),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseLevel2Intro(
                  isVibrant: widget.isVibrant, isSingleMode: false),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isVibrant ? const Color(0xFF9BBEDE) : const Color(0xFFA38D7D),
      body: Stack(
        children: [
          if (!_showCompletionMessage)
            Positioned(
              top: 100,
              left: 150,
              right: 50,
              child: RichText(
                textAlign: TextAlign.left,
                text: const TextSpan(
                  style: TextStyle(fontSize: 36, color: Colors.white),
                  children: [
                    TextSpan(
                        text:
                            "Move your eyes up and down until you see the green check.\nKeep your head still. (30 seconds)"),
                  ],
                ),
              ),
            ),
          // 중앙 콘텐츠
          Center(
            child: _showCompletionMessage
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 100),
                      SizedBox(height: 40),
                      Text(
                        "Workout is done!\nThank you for your effort!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentTarget == 'up'
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Colors.white,
                        size: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _currentTarget == 'up'
                            ? "Move your eyes up "
                            : "Move your eyes down",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ],
                  ),
          ),

          // 🔥 왼쪽 상단: 뒤로 가기 버튼
          Positioned(
            top: 40,
            left: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 30,
                  color: Colors.black54,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // 🔥 오른쪽 상단: 진행도 인디케이터
          Positioned(
            top: 40,
            right: 40,
            child: SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.black26,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 6,
                  ),
                  const Icon(
                    Icons.access_time,
                    color: Colors.black45,
                    size: 32,
                  ),
                ],
              ),
            ),
          ) /*,

          // 🔥 왼쪽 상단 두 번째 줄: Focus 버튼
          Positioned(
            left: 40,
            top: 120,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showTrackingFocus = !_showTrackingFocus;
                });
                _gazeService.setShowOverlay(_showTrackingFocus);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _showTrackingFocus
                      ? Colors.blue.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showTrackingFocus
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Focus",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),*/
          ,
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Level 1",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseLevel1Intro extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;
  const ExerciseLevel1Intro(
      {super.key, this.isVibrant = true, this.isSingleMode = false});

  @override
  State<ExerciseLevel1Intro> createState() => _ExerciseLevel1IntroState();
}

class _ExerciseLevel1IntroState extends State<ExerciseLevel1Intro> {
  @override
  void initState() {
    super.initState();

    // 3초 후 자동 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseLevel1Stage(
                isVibrant: widget.isVibrant, isSingleMode: widget.isSingleMode),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isVibrant ? const Color(0xFFAEC7DF) : const Color(0xFFA38D7D),
      body: Stack(
        children: [
          /// 1️⃣ PNG 이미지를 오른쪽 정렬(Align.end) + 자연스럽게 잘리도록 ClipRect 사용
          Align(
            alignment: Alignment.centerRight, // 👉 오른쪽 정렬
            child: ClipRect(
              child: Image.asset(
                'assets/images/gymiBackground.png', // ✅ PNG 이미지 경로
                fit: BoxFit.fitHeight, // ✅ 화면 크기에 맞춰 자연스럽게 채우기
                width: 650,
                height: 900,
              ),
            ),
          ),
          const Center(
            child: Text(
              "Level 1",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 128,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
