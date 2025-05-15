import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_intro.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseLevel10Stage extends StatefulWidget {
  final bool isVibrant;
  const ExerciseLevel10Stage({super.key, this.isVibrant = true});

  @override
  State<ExerciseLevel10Stage> createState() => _ExerciseLevel10StageState();
}

class _ExerciseLevel10StageState extends State<ExerciseLevel10Stage> {
  bool _showSecondImage = false;
  bool _showCompletionMessage = false;

  double _progress = 0.0;
  Timer? _progressTimer;
  DateTime _startTime = DateTime.now();
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const int _totalSessionTime = 17 * 1000; // 17초
  static const int _switchTime = 7 * 1000; // 7초 후 이미지 전환
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
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final elapsed = DateTime.now().difference(_startTime).inMilliseconds;
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress = (elapsed / _totalSessionTime).clamp(0.0, 1.0);
        _showSecondImage = elapsed >= _switchTime;

        if (elapsed >= _totalSessionTime) {
          timer.cancel();
          _onSessionComplete();
        }
      });
    });
  }

  void _onSessionComplete() {
    setState(() {
      _showCompletionMessage = true;
    });
    _audioPlayer.play(AssetSource('audio/correct.mp3'));
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ExerciseIntroScreen(isVibrant: widget.isVibrant),
        ),
      );
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
                text: TextSpan(
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 36,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w300),
                  children: const [
                    TextSpan(
                      text:
                          "Rub your hands until they are warm. Place your hands over your eyes,\nand relax. Rest gently.",
                    ),
                  ],
                ),
              ),
            ),
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
                : SizedBox(
                    width: 450,
                    height: 450,
                    child: Image.asset(
                      _showSecondImage
                          ? 'assets/images/level10-2.png'
                          : 'assets/images/level10-1.png',
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
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Level 10",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 36,
                  fontStyle: FontStyle.normal,
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

class ExerciseLevel10Intro extends StatefulWidget {
  final bool isVibrant;
  const ExerciseLevel10Intro({super.key, this.isVibrant = true});

  @override
  State<ExerciseLevel10Intro> createState() => _ExerciseLevel10IntroState();
}

class _ExerciseLevel10IntroState extends State<ExerciseLevel10Intro> {
  @override
  void initState() {
    super.initState();

    // 3초 후 자동 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseLevel10Stage(
              isVibrant: widget.isVibrant,
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
              "Level 10",
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
