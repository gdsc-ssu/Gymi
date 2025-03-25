import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:eyedid_flutter_example/%08screens/exercise2.dart';

class Exercise2IntroScreen extends StatefulWidget {
  const Exercise2IntroScreen({super.key});

  @override
  State<Exercise2IntroScreen> createState() => _Exercise2IntroScreenState();
}

class _Exercise2IntroScreenState extends State<Exercise2IntroScreen> {
  // 현재 페이지 인덱스
  int _currentPage = 0;

  // 총 페이지 수
  final int _totalPages = 3;

  // 페이지 컨트롤러
  final PageController _pageController = PageController(initialPage: 0);

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

    _pageController.dispose();
    super.dispose();
  }

  // Exercise2로 이동
  void _goToExercise2() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Exercies2()),
    );
  }

  // 다음 페이지로 이동 또는 Exercise2로 이동
  void _goToNextPageOrExercise2() {
    if (_currentPage < _totalPages - 1) {
      // 아직 마지막 페이지가 아니면 다음 페이지로 이동
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지라면 Exercise2로 이동
      _goToExercise2();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BBEDE), // 하늘색 배경
      body: Stack(
        children: [
          // 페이지 뷰
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // 사용자 스와이프 비활성화
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              // 첫 번째 페이지 - 인트로
              _buildFirstIntroPage(),

              // 두 번째 페이지 - 눈 굴리는 설명
              _buildSecondIntroPage(),

              // 세 번째 페이지 - 소리 설명
              _buildThirdIntroPage(),
            ],
          ),

          // 하단 페이지 인디케이터
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _totalPages,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),

          // Vector 화살표 (모든 페이지에 표시)
          Positioned(
            right: 40,
            top: MediaQuery.of(context).size.height / 2 - 85,
            child: GestureDetector(
              onTap: _goToNextPageOrExercise2, // 다음 페이지 또는 Exercise2로 이동
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

  // 첫 번째 인트로 페이지 (소개 화면)
  Widget _buildFirstIntroPage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
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
          ],
        ),
      ),
    );
  }

  // 두 번째 인트로 페이지 (눈 굴리는 방향 설명)
  Widget _buildSecondIntroPage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 회색 박스 제거하고 애니메이션 직접 표시
          Center(
            // 크기를 2배로 키운 애니메이션
            child: Lottie.asset(
              'assets/AnimationEye.json',
              repeat: true,
              fit: BoxFit.contain,
              width: MediaQuery.of(context).size.width * 0.5, // 너비 50%로 설정
              height: MediaQuery.of(context).size.height * 0.5, // 높이 50%로 설정
              errorBuilder: (context, error, stackTrace) {
                print('Lottie 로드 에러: $error');
                return const Icon(
                  Icons.remove_red_eye,
                  size: 300,
                  color: Color(0xFF3E64FF),
                );
              },
            ),
          ),
          const SizedBox(height: 150),
          // 영어 설명 텍스트
          const Text(
            "Roll your eyes to the direction of the arrow.\nStretch your eye muscle as far as you can.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 세 번째 인트로 페이지 (소리 설명)
  Widget _buildThirdIntroPage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 회색 박스 제거하고 아이콘 직접 표시
          Center(
            child: Icon(
              Icons.volume_up,
              size: 300,
              color: Color(0xFF3E64FF),
            ),
          ),
          SizedBox(height: 150),
          // 영어 설명 텍스트
          Text(
            "Until you hear this sound.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
