import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class GoodScreen extends StatefulWidget {
  final bool isVibrant;

  const GoodScreen({Key? key, required this.isVibrant}) : super(key: key);

  @override
  _GoodScreenState createState() => _GoodScreenState();
}

class _GoodScreenState extends State<GoodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isVibrant ? const Color(0xFFAEC7DF) : const Color(0xFFA38D7D),
      body: Stack(
        children: [
          // 배경 이미지 (오른쪽)
          Align(
            alignment: Alignment.centerRight,
            child: ClipRect(
              child: Image.asset(
                'assets/images/gymiBackground.png',
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          // 메인 메시지: 화면 정중앙
          Center(
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: GoogleFonts.roboto(
                  fontSize: 38,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                      text: 'Our AI model suggests that\n',
                      style: GoogleFonts.roboto(
                          fontSize: 64,
                          fontWeight: FontWeight.w200,
                      )
                  ),
                  TextSpan(
                    text: 'your eye alignment appears to be within the ',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold, fontSize: 40),
                  ),
                  TextSpan(
                    text: 'normal range.',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Color(0xFFCCF436), // lime green
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 안내 메시지: 하단 중앙
          Positioned(
            left: 64,
            right: 0,
            bottom: 147,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                      text: 'Please note that this is ',
                      style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                      ) // white
                  ),
                  TextSpan(
                    text: 'NOT a medical diagnosis.\n',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  TextSpan(
                      text: 'If you have concerns about your vision, we recommend visiting an eye specialist for a professional evaluation.',
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ) // white
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 40),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen(isVibrant: widget.isVibrant)),
                  );
                },
                child: Image.asset(
                  'assets/images/Vector.png',
                  height: 170,
                  width: 50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
