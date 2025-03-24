import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eyedid_flutter_example/%08screens/exercise2.dart';

class Exercise2IntroScreen extends StatefulWidget {
  const Exercise2IntroScreen({super.key});

  @override
  State<Exercise2IntroScreen> createState() => _Exercise2IntroScreenState();
}

class _Exercise2IntroScreenState extends State<Exercise2IntroScreen> {
  @override
  void initState() {
    super.initState();

    // 화면 방향을 가로로 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 화면 방향 복원
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // Exercise2로 이동
  void _goToExercise2() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Exercies2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF9BBEDE), // 하늘색 배경
      body: Stack(
        children: [
          // 중앙 텍스트
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 120,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(text: "Let's do a "),
                  TextSpan(
                    text: "simple workout",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                      text: " that can might\nhelp with your eye condition."),
                ],
              ),
            ),
          ),

          // 오른쪽 화살표
          Positioned(
            right: 40,
            top: screenSize.height / 2 - 85,
            child: GestureDetector(
              onTap: _goToExercise2,
              child: Image.asset(
                'assets/images/Vector.png',
                height: 170,
                width: 50,
                errorBuilder: (context, error, stackTrace) {
                  // 이미지가 없는 경우 기본 아이콘으로 대체
                  return Container(
                    height: 170,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF3E64FF),
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
