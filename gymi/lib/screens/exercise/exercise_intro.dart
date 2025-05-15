import 'package:eyedid_flutter_example/screens/exercise/exercise_level10_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level1_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level2_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level3_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level4_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level5_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level6_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level7_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level8_screen.dart';
import 'package:eyedid_flutter_example/screens/exercise/exercise_level9_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
// 여기에 LevelIntro 및 Stage import 추가 필요

class ExerciseIntroScreen extends StatefulWidget {
  final bool isVibrant;
  const ExerciseIntroScreen({super.key, this.isVibrant = true});

  @override
  State<ExerciseIntroScreen> createState() => _ExercisesIntroState();
}

class _ExercisesIntroState extends State<ExerciseIntroScreen> {
  int _currentLevel = 1;

  void _incrementLevel() {
    setState(() {
      _currentLevel = _currentLevel == 10 ? 1 : _currentLevel + 1;
    });
  }

  void _decrementLevel() {
    setState(() {
      _currentLevel = _currentLevel == 1 ? 10 : _currentLevel - 1;
    });
  }

  void _startLevel(int level, {bool isSingleMode = true}) {
    Widget target;
    switch (level) {
      case 1:
        target = ExerciseLevel1Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;
      case 2:
        target = ExerciseLevel2Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;
      case 3:
        target = ExerciseLevel3Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;
      case 4:
        target = ExerciseLevel4Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;

      case 5:
        target = ExerciseLevel5Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;
      case 6:
        target = ExerciseLevel6Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;

      case 7:
        target = ExerciseLevel7Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;

      case 8:
        target = ExerciseLevel8Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;

      case 9:
        target = ExerciseLevel9Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
        break;
      case 10:
        target = ExerciseLevel10Intro(isVibrant: widget.isVibrant);
        break;
      default:
        target = ExerciseLevel1Intro(
            isVibrant: widget.isVibrant, isSingleMode: isSingleMode);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isVibrant ? const Color(0xFFAEC7DF) : const Color(0xFFA38D7D),
      body: Stack(
        children: [
          /// 오른쪽 배경 이미지
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
          // 제목 Positioned
          Positioned(
            top: 120,
            left: 80,
            child: Text(
              "Exercises",
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 128,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w300),
            ),
          ),

          // 중앙 기준 아래로 130 내려서 버튼 배치
          Align(
            alignment: const Alignment(0, 0.7), // 0.5로 하면 중심에서 조금 아래
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Full Exercise 버튼
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  onPressed: () {
                    _startLevel(1, isSingleMode: false);
                  },
                  child: Text(
                    "Full Exercise",
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 28,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w400),
                  ),
                ),

                const SizedBox(height: 20),

                // Level 선택 버튼 (누르면 바로 시작)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 왼쪽 화살표
                      IconButton(
                        icon: const Icon(Icons.arrow_left,
                            size: 32, color: Colors.white),
                        onPressed: _decrementLevel,
                      ),
                      const SizedBox(width: 10),
                      // Level 텍스트 클릭하면 해당 레벨로 이동
                      GestureDetector(
                        onTap: () {
                          _startLevel(_currentLevel, isSingleMode: true);
                        },
                        child: Text(
                          "Level $_currentLevel",
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 28,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // 오른쪽 화살표
                      IconButton(
                        icon: const Icon(Icons.arrow_right,
                            size: 32, color: Colors.white),
                        onPressed: _incrementLevel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
