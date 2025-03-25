import 'package:eyedid_flutter_example/%08screens/exercise2.dart';
import 'package:eyedid_flutter_example/%08screens/setting_screen.dart';
import 'package:flutter/material.dart';

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
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                    children: [
                      TextSpan(text: "Let’s do a "),
                      TextSpan(
                        text: "simple workout",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold, // 강조
                        ),
                      ),
                      TextSpan(text: " that can might"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "help with your eye condition.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
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
                  MaterialPageRoute(builder: (context) => const Exercies2()
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
