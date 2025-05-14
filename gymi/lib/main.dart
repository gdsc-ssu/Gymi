import 'package:eyedid_flutter_example/%08screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eyedid_flutter_example/%08screens/calibration_screen.dart';
import 'package:eyedid_flutter_example/%08screens/color_select_screen.dart';
import 'package:eyedid_flutter_example/%08screens/home_screen.dart';
import 'package:eyedid_flutter_example/%08screens/setting_screen.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';
import 'package:eyedid_flutter_example/service/audio_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:eyedid_flutter_example/%08screens/tutorial/tutorial.dart';

import 'package:flutter/services.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_calibration.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'service/gaze_tracker_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AudioService().playMusic();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      title: 'Gaze Tracker App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF9BBEDE),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 60,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.normal,
            fontSize: 25,
          ),
        ),
      ),
      home: const LoginScreen(), // ✅ Navigator가 정상 작동하도록 변경
    );
  }
}
