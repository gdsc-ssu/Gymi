import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:eyedid_flutter_example/screens/bad_screen.dart';
import 'package:eyedid_flutter_example/screens/good_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

import 'home_screen.dart';

class EyeJudgeScreen extends StatefulWidget {
  final bool isVibrant;
  const EyeJudgeScreen({super.key, required this.isVibrant});

  @override
  State<EyeJudgeScreen> createState() => _EyeJudgeScreenState();
}

class _EyeJudgeScreenState extends State<EyeJudgeScreen> {
  late CameraController _controller;
  bool _isReady = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isError = false;
  final GlobalKey _guideKey = GlobalKey();
  var rectWidth = 600.0;
  var rectHeight = 170.0;

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

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isError = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _handleRetry() {
    setState(() {
      _isError = false;
      _errorMessage = null;
    });
  }

  void _handleSkip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(isVibrant: widget.isVibrant),
      ),
    );
  }

  Future<void> _takeAndSendPicture() async {
    setState(() => _isLoading = true);

    try {
      // 화면 스크린샷 캡처
      final RenderRepaintBoundary boundary =
      _guideKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final imageFile = img.decodeImage(bytes);
      if (imageFile == null) return;

      // 화면 크기
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      // eye_guide.png의 위치와 크기
      final rectTop = screenHeight / 3;
      final rectLeft = (screenWidth - rectWidth) / 2;

      // 스크린샷에서의 크롭 영역 계산
      final cropX = (rectLeft * 3.0).round(); // pixelRatio 고려
      final cropY = (rectTop * 3.0).round();
      final cropWidth = (rectWidth * 3.0).round();
      final cropHeight = (rectHeight * 3.0).round();

      // 이미지 크롭
      final croppedImage = img.copyCrop(
        imageFile,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // 크롭된 이미지 저장
      final croppedBytes = img.encodeJpg(croppedImage);
      final tempDir = await Directory.systemTemp.createTemp();
      final croppedFile = File(
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await croppedFile.writeAsBytes(croppedBytes);

      if (!mounted) return;

      // 크롭된 이미지 확인 다이얼로그 표시
      final shouldProceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(widget.isVibrant ? 0xFFAEC7DF : 0xFFA38D7D),
            title: Text('Check Cropped Image',
                style: GoogleFonts.lato(
                  color: Color(widget.isVibrant ? 0xFF0069D7 : 0xFF59302D),
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                )),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(croppedFile),
                  const SizedBox(height: 16),
                  Text('Would you like to proceed using this image?',
                      style: GoogleFonts.lato(
                        color:
                        Color(widget.isVibrant ? 0xFF0069D7 : 0xFF59302D),
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Try Again',
                    style: GoogleFonts.lato(
                      color: Color(widget.isVibrant ? 0xFF0069D7 : 0xFF59302D),
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    )),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Proceed',
                    style: GoogleFonts.lato(
                      color: Color(widget.isVibrant ? 0xFF0069D7 : 0xFF59302D),
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    )),
              ),
            ],
          );
        },
      );

      if (shouldProceed != true) {
        setState(() => _isLoading = false);
        return;
      }

      // API 요청
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://strabismus-detector-149475634578.asia-northeast3.run.app/predict/'),
      );

      request.files
          .add(await http.MultipartFile.fromPath('file', croppedFile.path));
      request.fields['name'] = 'Gym:i';
      request.fields['age'] = '20';
      request.fields['sex'] = 'woman';

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final result = jsonDecode(body);

      if (!mounted) return;

      if (result.containsKey('error')) {
        _showError(result['error']);
        return;
      }

      final prediction = result['prediction'];
      print('AI result: $result');
      final isAbnormal =
          prediction['class'] != 'normal' && prediction['confidence'] >= 90;

      final geminiResult = await detectStrabismus(croppedFile);
      print('Gemini Result: $geminiResult');
      if (geminiResult == null) {
        _showError('Error with Gemini API');
        return;
      }


      if (isAbnormal && geminiResult == 'yes') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BadScreen(isVibrant: widget.isVibrant),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GoodScreen(isVibrant: widget.isVibrant),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError('ERROR! Try Again!');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> detectStrabismus(File imageFile) async {
    const apiKey = '';
    const endpoint = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=$apiKey';

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text": "Determine if strabismus. Result should be only 'yes' or 'no'."
            },
            {
              "inlineData": {
                "mimeType": "image/jpeg",
                "data": base64Image
              }
            }
          ]
        }
      ]
    };

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final candidates = json['candidates'];
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'];
        if (parts != null && parts.isNotEmpty) {
          final text = parts[0]['text'];
          return text;
        }
      }
    } else {
      print('Gemini API 오류: ${response.statusCode}, ${response.body}');
    }

    return null;
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return const Center(child: CircularProgressIndicator());

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final rectTop = screenHeight / 3;
    final rectLeft = (screenWidth - rectWidth) / 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RepaintBoundary(
        key: _guideKey,
        child: Stack(
          children: [
            CameraPreview(_controller),
            // 반투명한 검은색 오버레이 (가이드 영역 제외)
            Positioned.fill(
              child: ClipPath(
                clipper: EyeGuideClipper(
                  guideRect: Rect.fromLTWH(
                    rectLeft,
                    rectTop,
                    rectWidth,
                    rectHeight,
                  ),
                ),
                child: Container(
                  color: Colors.black.withOpacity(0.34),
                ),
              ),
            ),
            // 눈 가이드 이미지
            Positioned(
              top: rectTop,
              left: rectLeft,
              child: Image.asset(
                _isError
                    ? 'assets/images/eye_guide_error.png'
                    : 'assets/images/eye_guide.png',
                width: rectWidth,
                height: rectHeight,
              ),
            ),
            // 안내 텍스트
            Positioned(
                bottom: screenHeight -
                    rectTop -
                    rectHeight -
                    rectHeight -
                    rectHeight,
                left: 0,
                right: 0,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 150,
                      ),
                      if (!_isError) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Please align your eyes within the ",
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              "hilighted",
                              style: GoogleFonts.lato(
                                color: const Color(0xFFBBFF00),
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "area and make sure your face is well lit,",
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: rectLeft),
                              child: GestureDetector(
                                onTap: _handleRetry,
                                child: Text(
                                  '>     Retry',
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.only(left: rectLeft),
                              child: GestureDetector(
                                onTap: _handleSkip,
                                child: Text(
                                  '>    Skip',
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ])),

            // 촬영 버튼
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width / 2 - 30,
              child: GestureDetector(
                onTap: _isLoading ? null : _takeAndSendPicture,
                child: Image.asset(
                  'assets/images/camera_btn.png',
                  width: 60,
                  color: _isLoading ? Colors.grey : null,
                ),
              ),
            ),

            // 로딩 인디케이터
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '분석 중...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 에러 메시지
            if (_errorMessage != null)
              Positioned(
                bottom: MediaQuery.of(context).size.height / 2,
                left: MediaQuery.of(context).size.width * 0.2,
                right: MediaQuery.of(context).size.width * 0.2,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EyeGuideClipper extends CustomClipper<Path> {
  final Rect guideRect;

  EyeGuideClipper({required this.guideRect});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(guideRect)
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
