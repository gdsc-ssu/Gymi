import 'dart:async';

import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'package:flutter/material.dart';
import '../service/gaze_tracker_service.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';

class Exercies2 extends StatefulWidget {
  const Exercies2({super.key});

  @override
  State<Exercies2> createState() => _Exercies2State();
}

class _Exercies2State extends State<Exercies2> {
  final _gazeService = GazeTrackerService();

  // 현재 시선 위치
  double _x = 0.0;
  double _y = 0.0;

  // 현재 방향 (기본값은 중앙)
  String _currentDirection = 'center';

  // 각 방향별 타이머
  Timer? _upTimer;
  Timer? _downTimer;
  Timer? _leftTimer;
  Timer? _rightTimer;

  // 각 방향별 응시 시작 시간
  DateTime? _upStartTime;
  DateTime? _downStartTime;
  DateTime? _leftStartTime;
  DateTime? _rightStartTime;

  // 응시 판정을 위한 체류 시간 (밀리초)
  final int _dwellTime = 3000;

  // 방향별 아이콘
  final Map<String, IconData> _directionIcons = {
    'center': Icons.adjust, // 중앙
    'up': Icons.arrow_upward, // 위
    'down': Icons.arrow_downward, // 아래
    'left': Icons.arrow_back, // 왼쪽
    'right': Icons.arrow_forward, // 오른쪽
  };

  // 각 영역의 경계를 정의하기 위한 비율 (전체 화면 크기 대비)
  final double _centerThreshold = 0.3; // 중앙 영역의 크기

  StreamSubscription<dynamic>? _gazeSubscription;

  @override
  void initState() {
    super.initState();
    _setupGazeTracking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 컨텍스트를 안전하게 업데이트 (빌드 프로세스 이후에 실행됨)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context);
    });
  }

  @override
  void dispose() {
    _gazeSubscription?.cancel();
    _cancelAllTimers();
    super.dispose();
  }

  void _cancelAllTimers() {
    _upTimer?.cancel();
    _downTimer?.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();
  }

  Future<void> _setupGazeTracking() async {
    // 싱글톤 서비스의 스트림을 구독
    _gazeSubscription = _gazeService.gazePositionStream.listen((data) {
      if (mounted) {
        setState(() {
          _x = data['x'];
          _y = data['y'];
        });

        // 시선 위치에 따른 방향 감지
        _detectDirection();
      }
    });
  }

  void _detectDirection() {
    // 화면 크기 구하기
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면 중앙 좌표
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    // 중앙 영역의 크기 계산
    final centerWidthThreshold = screenWidth * _centerThreshold / 2;
    final centerHeightThreshold = screenHeight * _centerThreshold / 2;

    // 현재 시선의 상대적 위치 계산
    final offsetX = _x - centerX;
    final offsetY = _y - centerY;

    // 중앙 영역 안에 있는 경우
    if (offsetX.abs() < centerWidthThreshold &&
        offsetY.abs() < centerHeightThreshold) {
      _resetAllGazeTimes();
      if (_currentDirection != 'center') {
        setState(() {
          _currentDirection = 'center';
        });
      }
      return;
    }

    // 상하좌우 판단 (가장 큰 벗어남을 기준으로)
    final String direction;

    if (offsetX.abs() > offsetY.abs()) {
      // 좌우 방향이 더 강함
      direction = offsetX > 0 ? 'right' : 'left';
    } else {
      // 상하 방향이 더 강함
      direction = offsetY > 0 ? 'down' : 'up';
    }

    // 각 방향에 따른 타이머 처리
    _handleDirectionTimer(direction);
  }

  void _handleDirectionTimer(String direction) {
    // 현재 응시 중인 방향이 변경된 경우, 다른 방향의 타이머들을 모두 초기화
    if (direction == 'up') {
      if (_upStartTime == null) {
        _resetGazeTimeExcept('up');
        _upStartTime = DateTime.now();
        _upTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'up';
          });
        });
      }
    } else if (direction == 'down') {
      if (_downStartTime == null) {
        _resetGazeTimeExcept('down');
        _downStartTime = DateTime.now();
        _downTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'down';
          });
        });
      }
    } else if (direction == 'left') {
      if (_leftStartTime == null) {
        _resetGazeTimeExcept('left');
        _leftStartTime = DateTime.now();
        _leftTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'left';
          });
        });
      }
    } else if (direction == 'right') {
      if (_rightStartTime == null) {
        _resetGazeTimeExcept('right');
        _rightStartTime = DateTime.now();
        _rightTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'right';
          });
        });
      }
    }
  }

  void _resetGazeTimeExcept(String direction) {
    if (direction != 'up') {
      _upStartTime = null;
      _upTimer?.cancel();
      _upTimer = null;
    }
    if (direction != 'down') {
      _downStartTime = null;
      _downTimer?.cancel();
      _downTimer = null;
    }
    if (direction != 'left') {
      _leftStartTime = null;
      _leftTimer?.cancel();
      _leftTimer = null;
    }
    if (direction != 'right') {
      _rightStartTime = null;
      _rightTimer?.cancel();
      _rightTimer = null;
    }
  }

  void _resetAllGazeTimes() {
    _upStartTime = null;
    _downStartTime = null;
    _leftStartTime = null;
    _rightStartTime = null;

    _upTimer?.cancel();
    _downTimer?.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();

    _upTimer = null;
    _downTimer = null;
    _leftTimer = null;
    _rightTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        // 뒤로 가기 전에 오버레이 제거
        GazeOverlay.remove();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('시선 방향 인식 연습'),
        ),
        body: Stack(
          children: [
            // 화면을 4분할하여 각 영역의 경계를 시각화
            _buildScreenDividers(),

            // 중앙에 현재 방향을 나타내는 큰 아이콘 표시
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _directionIcons[_currentDirection] ?? Icons.adjust,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '현재 방향: $_currentDirection',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '시선 좌표: (${_x.toStringAsFixed(1)}, ${_y.toStringAsFixed(1)})',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    '특정 방향을 3초간 응시하면\n해당 방향의 아이콘으로 변경됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenDividers() {
    return CustomPaint(
      size: Size.infinite,
      painter: ScreenDividerPainter(centerThreshold: _centerThreshold),
    );
  }
}

// 화면 분할 시각화를 위한 CustomPainter
class ScreenDividerPainter extends CustomPainter {
  final double centerThreshold;

  ScreenDividerPainter({required this.centerThreshold});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 2;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final double centerWidthThreshold = size.width * centerThreshold / 2;
    final double centerHeightThreshold = size.height * centerThreshold / 2;

    // 중앙 영역 사각형
    canvas.drawRect(
      Rect.fromLTRB(
        centerX - centerWidthThreshold,
        centerY - centerHeightThreshold,
        centerX + centerWidthThreshold,
        centerY + centerHeightThreshold,
      ),
      paint,
    );

    // 가로 분할선
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // 세로 분할선
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );

    // 각 영역의 이름 표시
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 위쪽 영역
    textPainter.text = const TextSpan(
      text: '위',
      style: TextStyle(color: Colors.grey, fontSize: 24),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2,
            centerY - centerHeightThreshold - 50));

    // 아래쪽 영역
    textPainter.text = const TextSpan(
      text: '아래',
      style: TextStyle(color: Colors.grey, fontSize: 24),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(centerX - textPainter.width / 2,
            centerY + centerHeightThreshold + 20));

    // 왼쪽 영역
    textPainter.text = const TextSpan(
      text: '왼쪽',
      style: TextStyle(color: Colors.grey, fontSize: 24),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(centerX - centerWidthThreshold - 70,
            centerY - textPainter.height / 2));

    // 오른쪽 영역
    textPainter.text = const TextSpan(
      text: '오른쪽',
      style: TextStyle(color: Colors.grey, fontSize: 24),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(centerX + centerWidthThreshold + 20,
            centerY - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant ScreenDividerPainter oldDelegate) {
    return oldDelegate.centerThreshold != centerThreshold;
  }
}
