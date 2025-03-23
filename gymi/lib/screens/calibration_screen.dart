import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter_example/service/gaze_tracker_service.dart';
import 'package:flutter/material.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';

class CalibrationScreen extends StatefulWidget {
  final GazeTrackerService gazeService;

  const CalibrationScreen({super.key, required this.gazeService});

  @override
  _CalibrationScreenState createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  double _nextX = 0.0, _nextY = 0.0, _calibrationProgress = 0.0;
  bool _isCalibrating = true;
  bool isFinish = false;

  @override
  void initState() {
    super.initState();
    startCalibration();
  }

  /// 캘리브레이션 시작 함수
  Future<void> startCalibration() async {
    try {
      widget.gazeService.startCalibration(
        CalibrationMode.five,
        usePreviousCalibration: false,
      );

      widget.gazeService.calibrationStream.listen((data) {
        if (mounted) {
          setState(() {
            _nextX = data['nextX'];
            _nextY = data['nextY'];
            _calibrationProgress = data['progress'];
            _isCalibrating = data['isCalibrationMode'];
          });

          // 캘리브레이션이 완료되면 화면 닫기
          if (!_isCalibrating) {
            // Navigator.pop(context, true); // 결과값 반환
            setState(() {
              isFinish = true;
            });
          }
        }
      });
    } catch (e) {
      Navigator.pop(context, false); // 실패 시 false 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAEC7DF),
      body: Stack(
        children: [
          if (isFinish)
            const Center(
              child: Text(
                "Calibration Successfully Completed !",
                style: TextStyle(
                  fontSize: 64,
                  color: Colors.white,
                ),
              ),
            ),
          if (!isFinish)
            const Column(
              children: [
                SizedBox(
                  height: 600,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Focus on",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        Text(
                          " This dot",
                          style: TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.normal,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "until it is",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        Text(
                          " colored fully",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          if (!isFinish && _isCalibrating)
            Positioned(
              left: _nextX - 10,
              top: _nextY - 10,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: _calibrationProgress,
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
