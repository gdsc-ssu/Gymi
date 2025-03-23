import 'package:eyedid_flutter_example/%08screens/exercise2.dart';
import 'package:eyedid_flutter_example/%08screens/setting_screen.dart';
import 'package:flutter/material.dart';

class BeforeGameView extends StatelessWidget {
  const BeforeGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAEC7DF),
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
            right: 30,
            top: 30,
            child: IconButton(
              onPressed: () {
                //설정 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.menu,
                color: Colors.grey,
                size: 40,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 20, // 화면 중앙 정렬
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Exercies2(),
                  ),
                );
              },
              icon: const Icon(
                Icons.chevron_right, // ▶ 아이콘
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
