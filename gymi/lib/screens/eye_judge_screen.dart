import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:eyedid_flutter_example/%08screens/bad_screen.dart';
import 'package:eyedid_flutter_example/%08screens/good_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EyeJudgeScreen extends StatefulWidget {
  final bool isVibrant;
  const EyeJudgeScreen({super.key, required this.isVibrant});

  @override
  State<EyeJudgeScreen> createState() => _EyeJudgeScreenState();
}

class _EyeJudgeScreenState extends State<EyeJudgeScreen> {
  late CameraController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller.initialize();
    setState(() => _isReady = true);
  }

  Future<void> _takeAndSendPicture() async {
    final file = await _controller.takePicture();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://gymi.com/upload-eyes'),  // TODO: api 명세 정해지면 바꾸기
    );
    request.files.add(await http.MultipartFile.fromPath('image', file.path)); // TODO: api 명세 정해지면 바꾸기

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final result = jsonDecode(body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eyeStatus', result['eyeStatus']); // TODO: api 명세 정해지면 바꾸기

    // var result = {
    //   'eyeStatus': 'BAD', // TODO: api 명세 정해지기 전 테스트용
    // };

    if (result['eyeStatus'] == 'GOOD') { // TODO: api 명세 정해지면 바꾸기
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GoodScreen(isVibrant: widget.isVibrant), // widget.isVibrant으로 접근
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BadScreen(isVibrant: widget.isVibrant), // widget.isVibrant으로 접근
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return const Center(child: CircularProgressIndicator());

    final screenHeight = MediaQuery.of(context).size.height;
    final rectTop = screenHeight / 3;
    const rectHeight = 150.0;

    return Stack(
      children: [
        CameraPreview(_controller),
        // 가이드 박스 (이미지로 대체 가능)
        Positioned(
          top: rectTop,
          left: 30,
          right: 30,
          child: Image.asset('assets/images/eye_guide.png', height: rectHeight),
        ),
        // 안내 텍스트
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Text(
            "Please align your eyes within the highlighted area\nand make sure your face is well lit.",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
        // 촬영 버튼
        Positioned(
          bottom: 40,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: GestureDetector(
            onTap: _takeAndSendPicture,
            child: Image.asset('assets/images/camera_btn.png', width: 60),
          ),
        ),
      ],
    );
  }

  Widget _overlayGuide(double rectTop, double rectHeight) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        Positioned(
          top: rectTop,
          left: 30,
          right: 30,
          child: Container(
            height: rectHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
