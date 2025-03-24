import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final bool isVibrant;
  const HomeScreen({super.key, required this.isVibrant});
  // widget.isVibrant ? const Color(0xFFAEC7DF) 파랑 : const Color(0xFFA38D7D) 갈색
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isVibrant
              ?
              // 배경 : 하늘색 배경
              Image.asset(
                  'assets/images/HomeScreen1.png',
                  fit: BoxFit.cover, // ✅ fill은 왜곡될 수 있으니 cover 추천
                  width: double.infinity,
                  height: double.infinity,
                )
              : Image.asset(
                  'assets/images/HomeScreen2.png',
                  fit: BoxFit.cover, // ✅ fill은 왜곡될 수 있으니 cover 추천
                  width: double.infinity,
                  height: double.infinity,
                ),

          // 좌측 상단의 Gymi 로고
          Positioned(
            top: 125,
            left: 30,
            child: isVibrant
                ? Image.asset(
                    'assets/images/HomeGymi.png', // 로고 이미지
                    width: 500,
                  )
                : Image.asset(
                    'assets/images/HomeGymi2.png', // 로고 이미지
                    width: 500,
                  ),
          ),

          // 오른쪽 상단의 캐릭터 (파란 새)
          Positioned(
            top: 280,
            right: 180,
            child: isVibrant
                ? Image.asset(
                    'assets/images/bird.png', // 파란 새 캐릭터 이미지
                    width: 200,
                  )
                : Image.asset(
                    'assets/images/Talpidae.png', // 파란 새 캐릭터 이미지
                    width: 200,
                  ),
          ),

          // 오른쪽 메뉴 버튼들
          Positioned(
            right: 150,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tutorial 버튼
                _buildMenuButton(context, 'Tutorial', const Color(0xFF333333),
                    FontWeight.bold, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TutorialScreen()),
                  );
                }),

                const SizedBox(height: 20),

                // Calibrate 버튼
                _buildMenuButton(
                    context, 'Calibrate', Colors.grey, FontWeight.normal, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CalibrateScreen()),
                  );
                }),

                const SizedBox(height: 20),

                // Start exercise 버튼
                _buildMenuButton(
                    context, 'Start exercise', Colors.grey, FontWeight.normal,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExerciseScreen()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 버튼 위젯
  Widget _buildMenuButton(BuildContext context, String text, Color textColor,
      FontWeight fontWeight, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 48,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

// 네비게이션 대상 화면들
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tutorial Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalibrateScreen extends StatelessWidget {
  const CalibrateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calibrate')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Calibration Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Exercise Screen', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
