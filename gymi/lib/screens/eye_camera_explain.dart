import 'package:eyedid_flutter_example/%08screens/eye_judge_screen.dart';
import 'package:eyedid_flutter_example/%08screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EyeCameraExplainScreen extends StatefulWidget {
  final bool isVibrant;
  const EyeCameraExplainScreen({super.key, required this.isVibrant});

  @override
  State<EyeCameraExplainScreen> createState() => _EyeCameraExplainState();
}

class _EyeCameraExplainState extends State<EyeCameraExplainScreen> {
  bool isVibrant = true;

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
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 150,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 150,
                        ),
                        Text(
                          "Would you like to check your eye",
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.w200),
                        ),
                        Text(
                          "alignment before starting?",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "It's completely optional,",
                              style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "but it can help",
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(" customize ",
                                    style: GoogleFonts.roboto(
                                        color: const Color(0xFFBBFF00),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic)),
                                Text(
                                  "your training better.",
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
          // line.png
          Positioned(
              bottom: 250,
              left: 544,
              child: Center(
                  child: Row(
                children: [
                  Image.asset(
                    'assets/images/line.png',
                  ),
                ],
              ))),
          // 하단 중앙 버튼 컨테이너
          Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: Container(
                width: 590,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Row(
                  children: [
                    /// Open Camera 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EyeJudgeScreen(
                                    isVibrant: widget.isVibrant)),
                          );
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(25),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Open Camera',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF0069D7),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/camera_icon.png',
                                  width: 28,
                                  height: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// 중간 구분선
                    Container(
                      width: 1,
                      color: Colors.grey[300],
                    ),

                    /// Skip 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen(isVibrant: widget.isVibrant)),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                !isVibrant ? Colors.white : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(25),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Skip',
                                  style: GoogleFonts.roboto(
                                    color: const Color(0xFF59302D),
                                    fontSize: 30,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/skip_icon.png',
                                  width: 28,
                                  height: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
