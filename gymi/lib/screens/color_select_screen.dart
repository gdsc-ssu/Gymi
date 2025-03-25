import 'dart:async';

import 'package:eyedid_flutter_example/%08screens/calibration_screen.dart';
import 'package:eyedid_flutter_example/%08screens/home_screen.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorSelectScreen extends StatefulWidget {
  const ColorSelectScreen({super.key});

  @override
  State<ColorSelectScreen> createState() => _ColorSelectState();
}

class _ColorSelectState extends State<ColorSelectScreen> {
  bool isVibrant = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isVibrant ? const Color(0xFFAEC7DF) : const Color(0xFFA38D7D),
      body: Stack(
        children: [
          /// 1️⃣ PNG 이미지를 오른쪽 정렬(Align.end) + 자연스럽게 잘리도록 ClipRect 사용
          Align(
            alignment: Alignment.centerRight, // 👉 오른쪽 정렬
            child: ClipRect(
              child: Image.asset(
                'assets/images/gymiBackground.png', // ✅ PNG 이미지 경로
                fit: BoxFit.fitHeight, // ✅ 화면 크기에 맞춰 자연스럽게 채우기
                width: 650,
                height: 900,
              ),
            ),
          ),
          Column(
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
                          "Choose a color mode for",
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .fontSize,
                            fontStyle: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .fontStyle,
                          ),
                        ),
                        Text(
                          " your experience",
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color,
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .fontSize,
                            fontStyle: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .fontStyle,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 70,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 40, 0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(isVibrant: isVibrant)
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
              const SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "You can choose between two modes - ",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .color,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .fontSize,
                            ),
                          ),
                          Text(
                            "Vibrant mode",
                            style: TextStyle(
                                color: const Color(0xFFBBFF00),
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .fontSize,
                                fontWeight: isVibrant ? FontWeight.bold : null),
                          ),
                          Text(
                            " for an engaging",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .color,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .fontSize,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "feel or ",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .color,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .fontSize,
                            ),
                          ),
                          Text(
                            "Eye comfort mode",
                            style: TextStyle(
                                color: const Color(0xFF43221F),
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .fontSize,
                                fontWeight:
                                    !isVibrant ? FontWeight.bold : null),
                          ),
                          Text(
                            " to reduce eye strain.",
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .color,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .fontSize,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 63,
              ),
              Container(
                width: 590,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Row(
                  children: [
                    /// Vibrant Mode 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isVibrant = true;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isVibrant
                                ? Colors.white // 선택된 경우 → 흰색 배경
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(25),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Vibrant Mode',
                              style: TextStyle(
                                color: isVibrant ? Colors.blue : Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 30,
                              ),
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

                    /// Comfort Mode 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            isVibrant = false;
                          });
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
                            child: Text(
                              'Comfort Mode',
                              style: TextStyle(
                                  color:
                                      !isVibrant ? Colors.brown : Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
