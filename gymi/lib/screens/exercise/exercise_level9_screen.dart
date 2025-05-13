import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_intro.dart';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_level10_screen.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:flutter/material.dart';

class ExerciseLevel9Stage extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;

  const ExerciseLevel9Stage({
    super.key,
    this.isVibrant = true,
    this.isSingleMode = false,
  });

  @override
  State<ExerciseLevel9Stage> createState() => _ExerciseLevel9StageState();
}

class _ExerciseLevel9StageState extends State<ExerciseLevel9Stage> {
  double _progress = 0.0;
  Timer? _progressTimer;
  Timer? _imageTimer;
  DateTime _startTime = DateTime.now();
  bool _showImage2 = false;
  bool _showCompletionMessage = false;
  int _switchCount = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  double _x = 0.0;
  double _y = 0.0;
  double _dotSize = 20.0;
  Color _gazeColor = Colors.blue;

  final _gazeService = GazeTrackerService();
  StreamSubscription<dynamic>? _gazeSubscription;
  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _gazeService.setShowOverlay(true);
    _setupGazeTracking();
    _startImageSwitching();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress = (elapsed / (32 * 1000)).clamp(0.0, 1.0);
      });

      if (_progress >= 1.0) {
        timer.cancel();
        _onSessionComplete();
      }
    });
  }

  void _startImageSwitching() {
    _imageTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;
      setState(() {
        _showImage2 = true;
      });
      Future.delayed(const Duration(seconds: 6), () {
        if (!mounted) return;
        setState(() {
          _showImage2 = false;
        });
      });

      _switchCount++;
      if (_switchCount >= 3) {
        timer.cancel();
      }
    });
  }

  void _onSessionComplete() {
    setState(() {
      _showCompletionMessage = true;
    });
    _audioPlayer.play(AssetSource('audio/correct.mp3'));
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
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
            builder: (context) =>
                ExerciseLevel10Intro(isVibrant: widget.isVibrant),
          ),
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context);
      _gazeService.refreshOverlay();
    });
  }

  @override
  void dispose() {
    _gazeSubscription?.cancel();
    _progressTimer?.cancel();
    _audioPlayer.dispose();
    _gazeService.setShowOverlay(true);
    super.dispose();
  }

  void _setupGazeTracking() {
    _gazeSubscription = _gazeService.gazePositionStream.listen((data) {
      if (!mounted) return;
      setState(() {
        _x = data['x'];
        _y = data['y'];
        _gazeColor = data['color'];
        _dotSize = data['size'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isVibrant ? const Color(0xFFAEC7DF) : const Color(0xFFA38D7D),
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
                    TextSpan(text: "Focus on your "),
                    TextSpan(
                      text: "nose",
                      style: TextStyle(color: Colors.lightGreenAccent),
                    ),
                    TextSpan(text: " tip. Then slowly look straight again."),
                  ],
                ),
              ),
            ),
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: 450,
                    height: 450,
                    child: Image.asset(
                      _showImage2
                          ? 'assets/images/level9-2.png'
                          : 'assets/images/level9-1.png',
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
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
                  const Icon(Icons.access_time,
                      color: Colors.black45, size: 32),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Level 9",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 40,
            left: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    size: 30, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseLevel9Intro extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;
  const ExerciseLevel9Intro(
      {super.key, this.isVibrant = true, this.isSingleMode = false});

  @override
  State<ExerciseLevel9Intro> createState() => _ExerciseLevel9IntroState();
}

class _ExerciseLevel9IntroState extends State<ExerciseLevel9Intro> {
  @override
  void initState() {
    super.initState();

    // 3초 후 자동 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseLevel9Stage(
              isVibrant: widget.isVibrant,
              isSingleMode: widget.isSingleMode, // Single Mode 여부 전달
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
          const Center(
            child: Text(
              "Level 9",
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
