import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:eyedid_flutter_example/screens/tutorial/tutorial_ready_screen.dart';
import 'package:eyedid_flutter_example/screens/setting_screen.dart';
import 'package:audioplayers/audioplayers.dart';

class TutorialIntroScreen extends StatefulWidget {
  final bool isVibrant;
  const TutorialIntroScreen({super.key, required this.isVibrant});

  @override
  State<TutorialIntroScreen> createState() => _TutorialIntroScreenState();
}

class _TutorialIntroScreenState extends State<TutorialIntroScreen> {
  // 현재 페이지 인덱스
  int _currentPage = 0;

  final AudioPlayer _audioPlayer = AudioPlayer();

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
    _audioPlayer.dispose();
    super.dispose();
  }

  // 세 번째 인트로 페이지에서 소리 재생 함수
  void _playCorrectSound() {
    _audioPlayer.play(AssetSource('audio/correct.mp3'));
  }

  // Exercise2ReadyScreen으로 이동
  void _goToExercise2ReadyScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TutorialReadyScreen(isVibrant: widget.isVibrant)),
    );
  }

  // 다음 페이지로 이동 또는 Exercise2ReadyScreen으로 이동
  void _goToNextPageOrExercise2ReadyScreen() {
    if (_currentPage < _totalPages - 1) {
      // 아직 마지막 페이지가 아니면 다음 페이지로 이동
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 페이지라면 Exercise2ReadyScreen으로 이동
      _goToExercise2ReadyScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isVibrant
          ? const Color(0xFF9BBEDE) // Vibrant 모드 배경색
          : const Color(0xFFA38D7D), // Comfort 모드 배경색
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

              if (page == 2) {
                _playCorrectSound();
              }
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
              onTap:
                  _goToNextPageOrExercise2ReadyScreen, // 다음 페이지 또는 Exercise2ReadyScreen으로 이동
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
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                ),
                children: [
                  TextSpan(
                    text: "Let's do a ",
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
                        fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: " that can might\nhelp with your eye condition.",
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 48,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w200),
                  ),
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
                  size: 160, // 기존 80의 2배
                  color: Color(0xFF3E64FF),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          // 영어 설명 텍스트
          Text(
            "Roll your eyes to the direction of the arrow.\nStretch your eye muscle as far as you can.",
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 48,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 세 번째 인트로 페이지 (소리 설명) 수정
  Widget _buildThirdIntroPage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: GestureDetector(
              onTap: _playCorrectSound, // 클릭 시 소리 재생
              child: const Icon(
                Icons.volume_up,
                size: 160,
                color: Color(0xFF3E64FF),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // 텍스트 수정
          Text(
            "Until you hear this sound.\nTap the icon to hear an example.",
            style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 48,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
