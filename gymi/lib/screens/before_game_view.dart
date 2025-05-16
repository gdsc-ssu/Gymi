import 'package:eyedid_flutter_example/screens/tutorial/tutorial.dart';
import 'package:eyedid_flutter_example/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BeforeGameView extends StatelessWidget {
  final bool isVibrant;
  const BeforeGameView({super.key, required this.isVibrant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isVibrant ? const Color(0xFFAEC7DF) : const Color(0xFFA38D7D),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                    children: [
                      TextSpan(
                        text: "Let’s do a ",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 48,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w200),
                      ),
                      TextSpan(
                        text: "simple workout",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 48,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: " that can might",
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 48,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w200),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "help with your eye condition.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 48,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w200),
                ),
              ],
            ),
          ),
          Positioned(
            right: 50,
            top: 50,
            child: IconButton(
              onPressed: () {
                //설정 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(isVibrant: isVibrant),
                  ),
                );
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.black87,
                size: 40,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 85, // 화면 중앙 정렬
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tutorial()
                      // 예시로 secondScreen을 넣으면 수정할 것
                      ),
                );
              },
              child: Image.asset(
                'assets/images/Vector.png',
                height: 170,
                width: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
