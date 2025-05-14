import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eyedid_flutter_example/%08screens/tutorial/tutorial.dart';
import 'package:eyedid_flutter_example/%08screens/setting_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialReadyScreen extends StatefulWidget {
  final bool isVibrant;
  const TutorialReadyScreen({super.key, this.isVibrant = true});

  @override
  State<TutorialReadyScreen> createState() => _TutorialReadyScreenState();
}

class _TutorialReadyScreenState extends State<TutorialReadyScreen> {
  @override
  void initState() {
    super.initState();

    // 화면 방향을 가로로 유지
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // 3초 후 자동으로 Exercise2로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Tutorial(isVibrant: widget.isVibrant),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // dispose는 하지 않음 - Exercise2IntroScreen에서 이미 방향 복원을 처리함
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isVibrant
          ? const Color(0xFF9BBEDE) // Vibrant 모드 배경색
          : const Color(0xFFA38D7D), // Comfort 모드 배경색
      body: Stack(
        children: [
          // 중앙 텍스트
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: "Let's give it a try !",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 48,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: "Look at the direction of the arrow,",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 48,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: "and hold until you hear the sound.",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 48,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 오른쪽 상단에 설정 버튼 추가
          Positioned(
            right: 50,
            top: 50,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(isVibrant: widget.isVibrant),
                  ),
                );
              },
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          // 오른쪽 하단에 건너뛰기 버튼 (즉시 Exercise2로 이동)
          Positioned(
            right: 40,
            bottom: 40,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Tutorial(isVibrant: widget.isVibrant),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "SKIP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
