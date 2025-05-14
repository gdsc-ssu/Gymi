import 'package:eyedid_flutter_example/%08screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eyedid_flutter_example/service/audio_service.dart';
import 'package:flutter/material.dart';

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
