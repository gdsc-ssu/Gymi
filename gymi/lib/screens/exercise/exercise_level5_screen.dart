import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_level6_screen.dart';
import 'package:eyedid_flutter_example/%08screens/exercise/exercise_intro.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ExerciseLevel5Stage extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;

  const ExerciseLevel5Stage({
    super.key,
    this.isVibrant = true,
    this.isSingleMode = false,
  });

  @override
  State<ExerciseLevel5Stage> createState() => _ExerciseLevel5StageState();
}

class _ExerciseLevel5StageState extends State<ExerciseLevel5Stage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  double _progress = 0.0;
  DateTime _startTime = DateTime.now();
  Timer? _progressTimer;
  late final AnimationController _lottieController;
  bool _showCompletionMessage = false;
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
    WidgetsBinding.instance.addObserver(this);

    _lottieController = AnimationController(vsync: this);
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
        _progress = (elapsed / (30 * 1000)).clamp(0.0, 1.0);
      });
      if (_progress >= 1.0) {
        timer.cancel();
        _showCompletion();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context); // 👈 overlay에 context 반영
      _gazeService.refreshOverlay(); // 👈 overlay 다시 그리기
    });
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

  void _showCompletion() {
    setState(() {
      _showCompletionMessage = true;
    });

    _gazeService.setShowOverlay(false); // 👈 다음 스테이지로 넘어가기 전에 끄기
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
            builder: (context) => ExerciseLevel6Intro(
                isVibrant: widget.isVibrant, isSingleMode: false),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gazeSubscription?.cancel();
    _lottieController.dispose();
    _progressTimer?.cancel();
    _audioPlayer.dispose();
    _gazeService.setShowOverlay(true); // 초기화용 true 설정
    super.dispose();
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
                            "Draw a circle with your eyes clockwise until you see the green check. (30s)"),
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
                : Lottie.asset(
                    'assets/animations/spin.json',
                    controller: _lottieController,
                    onLoaded: (composition) {
                      _lottieController.duration = composition.duration * 2;
                      _lottieController.repeat();
                    },
                    width: 700,
                    height: 700,
                    repeat: true,
                    animate: true,
                    fit: BoxFit.contain,
                  ),
          ),

          // 상단 우측: 진행도
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

          // 상단 좌측: 뒤로가기
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // 하단 중앙: Level 표시
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              "Level 5",
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

class ExerciseLevel5Intro extends StatefulWidget {
  final bool isVibrant;
  final bool isSingleMode;
  const ExerciseLevel5Intro(
      {super.key, this.isVibrant = true, this.isSingleMode = false});

  @override
  State<ExerciseLevel5Intro> createState() => _ExerciseLevel5IntroState();
}

class _ExerciseLevel5IntroState extends State<ExerciseLevel5Intro> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseLevel5Stage(
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
          Align(
            alignment: Alignment.centerRight,
            child: ClipRect(
              child: Image.asset(
                'assets/images/gymiBackground.png',
                fit: BoxFit.fitHeight,
                width: 650,
                height: 900,
              ),
            ),
          ),
          Center(
            child: Text(
              "Level 5",
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
