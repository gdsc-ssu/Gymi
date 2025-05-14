import 'dart:async';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_intro.dart';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_level5_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../service/gaze_tracker_service.dart';
import 'package:audioplayers/audioplayers.dart';

class ExerciseLevel4Stage extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;
  const ExerciseLevel4Stage(
      {super.key, this.isVibrant = true, this.isSingleMode = false});

  @override
  State<ExerciseLevel4Stage> createState() => _ExerciseLevel4StageState();
}

class _ExerciseLevel4StageState extends State<ExerciseLevel4Stage>
    with WidgetsBindingObserver {
  final _gazeService = GazeTrackerService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  double _x = 0.0;
  double _y = 0.0;

  String _currentTarget = 'left-down'; // 'left-down' 또는 'right-up'
  DateTime? _gazeStartTime;
  Timer? _gazeTimer;
  Timer? _progressTimer;

  bool _showCompletionMessage = false;
  bool _screenActive = true;
  final bool _showTrackingFocus = true; // final 제거

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

    // ✅ sessionTimer 삭제, progressTimer만 사용
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
    _gazeService.setShowOverlay(true);

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

      _detectDiagonal();
    });
  }

  void _detectDiagonal() {
    if (_showCompletionMessage) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    bool inTarget = false;

    if (_currentTarget == 'left-down') {
      if (_x < centerX && _y > centerY) {
        inTarget = true;
      }
    } else {
      if (_x > centerX && _y < centerY) {
        inTarget = true;
      }
    }

    if (inTarget) {
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
        _currentTarget =
            _currentTarget == 'left-down' ? 'right-up' : 'left-down';
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
              builder: (context) => ExerciseLevel5Intro(
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
                text: TextSpan(
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 36,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w300),
                  children: const [
                    TextSpan(
                        text:
                            "Look bottom-left to top-right until you see the green check. (30s)"),
                  ],
                ),
              ),
            ),
          // 중앙 콘텐츠
          Center(
            child: _showCompletionMessage
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 100),
                      const SizedBox(height: 40),
                      Text(
                        "Workout is done!\nThank you for your effort!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 50,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _currentTarget == 'left-down'
                            ? Icons.south_west
                            : Icons.north_east,
                        color: Colors.white,
                        size: 200,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _currentTarget == 'left-down'
                            ? "Move your eyes bottom-left"
                            : "Move your eyes top-right",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 40,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w300),
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

          // 🔥 오른쪽 상단: 진행 인디케이터
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

          // 🔥 왼쪽 상단 두번째 줄 : Focus 버튼
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
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Level 4",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 36,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseLevel4Intro extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;
  const ExerciseLevel4Intro(
      {super.key, this.isVibrant = true, this.isSingleMode = false});

  @override
  State<ExerciseLevel4Intro> createState() => _ExerciseLevel4IntroState();
}

class _ExerciseLevel4IntroState extends State<ExerciseLevel4Intro> {
  @override
  void initState() {
    super.initState();

    // 3초 후 자동 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseLevel4Stage(
              isVibrant: widget.isVibrant,
              isSingleMode: widget.isSingleMode,
            ),
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
          Center(
            child: Text(
              "Level 4",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 128,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w200),
            ),
          ),
        ],
      ),
    );
  }
}
