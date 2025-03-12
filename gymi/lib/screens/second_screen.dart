import 'package:flutter/material.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';

class SecondScreen extends StatefulWidget {
  final double x;
  final double y;
  final Color gazeColor;

  const SecondScreen({
    super.key,
    required this.x,
    required this.y,
    required this.gazeColor,
  });

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ SecondScreen이 생성될 때 Overlay 업데이트
      GazeOverlay.show(context, widget.x, widget.y, widget.gazeColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Second Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "이 화면에서도 시선 원이 유지됩니다!",
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("뒤로 가기"),
            ),
          ],
        ),
      ),
    );
  }
}
