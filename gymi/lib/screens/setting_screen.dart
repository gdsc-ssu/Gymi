import 'package:eyedid_flutter_example/%08screens/calibration_screen.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isBackgroundMusicEnabled = true;
  final _gazeService = GazeTrackerService();
  void toggleBackgroundMusic(bool value) {
    setState(() {
      isBackgroundMusicEnabled = value;
    });
    // Here you would add code to actually turn on/off background music
  }

  void performRecalibration() {
    // Navigate to calibration screen or show calibration dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eye Tracking Calibration'),
        content: const Text(
            'This would navigate to the eye tracking calibration screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                const SizedBox(
                  height: 173,
                ),
                Container(
                  width: 650,
                  height: 500,
                  padding: const EdgeInsets.fromLTRB(110, 0, 0, 0),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Settings container
                      Container(
                        padding: const EdgeInsets.fromLTRB(40, 40, 75, 60),
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.grey[400]!, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Audio section
                            const Text(
                              'Audio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Background music',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 36,
                                  ),
                                ),
                                Switch(
                                  value: isBackgroundMusicEnabled,
                                  onChanged: toggleBackgroundMusic,
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 55),
                            // Eye tracking section
                            const Text(
                              'Eye tracking',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Perform Re-calibration',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 36,
                                  ),
                                ),
                                IconButton(
                                    icon: const Icon(
                                      Icons.keyboard_arrow_right_outlined,
                                      color: Colors.white70,
                                      size: 40,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CalibrationScreen(
                                                  gazeService: _gazeService,
                                                )
                                            // 예시로 secondScreen을 넣으면 수정할 것
                                            ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            right: 50,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                // Pop the current screen
                Navigator.of(context).pop();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight, // 👉 오른쪽 정렬
            child: ClipRect(
              child: Image.asset(
                'assets/images/Settings.png', // ✅ PNG 이미지 경로
                fit: BoxFit.fitHeight, // ✅ 화면 크기에 맞춰 자연스럽게 채우기
                width: 950,
                height: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
