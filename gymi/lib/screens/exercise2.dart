import 'dart:async';
import 'package:flutter/material.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:eyedid_flutter/eyedid_flutter.dart';
import '../service/gaze_tracker_service.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';

class Exercies2 extends StatefulWidget {
  const Exercies2({super.key});

  @override
  State<Exercies2> createState() => _Exercies2State();
}

class _Exercies2State extends State<Exercies2> with WidgetsBindingObserver {
  final _gazeService = GazeTrackerService();

  // 현재 시선 위치
  double _x = 0.0;
  double _y = 0.0;

  // 현재 방향 (기본값은 중앙)
  String _currentDirection = 'center';

  // 실시간 시선 방향 (완료 체크용이 아닌, 현재 실제 바라보는 방향)
  String _realTimeDirection = 'center';

  // 각 방향 완료 상태 트래킹
  final Map<String, bool> _completedDirections = {
    'up': false,
    'down': false,
    'left': false,
    'right': false,
  };

  // 각 방향별 타이머
  Timer? _upTimer;
  Timer? _downTimer;
  Timer? _leftTimer;
  Timer? _rightTimer;

  // 홈 화면 자동 복귀 타이머
  Timer? _homeNavigationTimer;

  // 각 방향별 응시 시작 시간
  DateTime? _upStartTime;
  DateTime? _downStartTime;
  DateTime? _leftStartTime;
  DateTime? _rightStartTime;

  // 응시 판정을 위한 체류 시간 (밀리초)
  final int _dwellTime = 2000; // 2초로 단축

  // 각 영역의 경계를 정의하기 위한 비율 (전체 화면 크기 대비)
  final double _centerThreshold = 0.3; // 중앙 영역의 크기

  StreamSubscription<dynamic>? _gazeSubscription;
  bool _screenActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupGazeTracking();

    // GazeOverlay 숨기기 (우리가 직접 그린 점만 사용)
    _gazeService.setShowOverlay(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 컨텍스트를 안전하게 업데이트 (빌드 프로세스 이후에 실행됨)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context);
      _screenActive = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _screenActive) {
      // 앱이 포그라운드로 돌아왔을 때 오버레이는 계속 숨김 상태 유지
      _gazeService.setShowOverlay(false);
    }
  }

  @override
  void dispose() {
    _gazeSubscription?.cancel();
    _cancelAllTimers();
    WidgetsBinding.instance.removeObserver(this);
    _screenActive = false;

    // 화면을 나갈 때 GazeOverlay 다시 활성화
    _gazeService.setShowOverlay(true);

    super.dispose();
  }

  void _cancelAllTimers() {
    _upTimer?.cancel();
    _downTimer?.cancel();
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    _homeNavigationTimer?.cancel();
  }

  Future<void> _setupGazeTracking() async {
    // 싱글톤 서비스의 스트림을 구독
    _gazeSubscription = _gazeService.gazePositionStream.listen((data) {
      if (mounted && _screenActive) {
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
      setState(() {
        _realTimeDirection = 'center';
      });
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

    // 실시간 방향 업데이트
    if (_realTimeDirection != direction) {
      setState(() {
        _realTimeDirection = direction;
      });
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
            _completedDirections['up'] = true;
          });
          _checkAllDirectionsCompleted();
        });
      }
    } else if (direction == 'down') {
      if (_downStartTime == null) {
        _resetGazeTimeExcept('down');
        _downStartTime = DateTime.now();
        _downTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'down';
            _completedDirections['down'] = true;
          });
          _checkAllDirectionsCompleted();
        });
      }
    } else if (direction == 'left') {
      if (_leftStartTime == null) {
        _resetGazeTimeExcept('left');
        _leftStartTime = DateTime.now();
        _leftTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'left';
            _completedDirections['left'] = true;
          });
          _checkAllDirectionsCompleted();
        });
      }
    } else if (direction == 'right') {
      if (_rightStartTime == null) {
        _resetGazeTimeExcept('right');
        _rightStartTime = DateTime.now();
        _rightTimer = Timer(Duration(milliseconds: _dwellTime), () {
          setState(() {
            _currentDirection = 'right';
            _completedDirections['right'] = true;
          });
          _checkAllDirectionsCompleted();
        });
      }
    }
  }

  void _checkAllDirectionsCompleted() {
    if (_completedDirections['up']! &&
        _completedDirections['down']! &&
        _completedDirections['left']! &&
        _completedDirections['right']!) {
      // 모든 방향 완료 시 2초 후 홈 화면으로 이동
      _homeNavigationTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && _screenActive) {
          Navigator.of(context).pop();
        }
      });
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

  // 방향에 따른 텍스트 반환 (한글)
  String _getDirectionText(String direction) {
    switch (direction) {
      case 'up':
        return '위';
      case 'down':
        return '아래';
      case 'left':
        return '왼쪽';
      case 'right':
        return '오른쪽';
      default:
        return '중앙';
    }
  }

  // 남은 방향을 한글로 반환
  String _getRemainingDirections() {
    List<String> remaining = [];

    if (!_completedDirections['up']!) remaining.add('위');
    if (!_completedDirections['down']!) remaining.add('아래');
    if (!_completedDirections['left']!) remaining.add('왼쪽');
    if (!_completedDirections['right']!) remaining.add('오른쪽');

    if (remaining.isEmpty) {
      return '모든 방향 완료!';
    } else {
      return remaining.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        _screenActive = false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Eye Direction Detection'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // 세로 중앙선 (위치 정확히 중앙에 배치)
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: 1,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),

            // 가로 중앙선 (위치 정확히 중앙에 배치)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),

            // 방향별 경계선 표시 (실시간 방향 기준)
            // 위쪽 경계선
            if (_realTimeDirection == 'up')
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: Colors.blue,
                ),
              ),

            // 아래쪽 경계선
            if (_realTimeDirection == 'down')
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: Colors.blue,
                ),
              ),

            // 왼쪽 경계선
            if (_realTimeDirection == 'left')
              Positioned(
                top: 0,
                bottom: 0,
                left: 10,
                child: Container(
                  width: 3,
                  color: Colors.blue,
                ),
              ),

            // 오른쪽 경계선
            if (_realTimeDirection == 'right')
              Positioned(
                top: 0,
                bottom: 0,
                right: 10,
                child: Container(
                  width: 3,
                  color: Colors.blue,
                ),
              ),

            // 방향 완료 상태 표시 (각 방향에 작은 체크 마크)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: _completedDirections['up']!
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 24)
                    : const Text('위',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ),

            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: _completedDirections['down']!
                    ? const Icon(Icons.check_circle,
                        color: Colors.green, size: 24)
                    : const Text('아래',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 12,
              left: MediaQuery.of(context).size.width * 0.15,
              child: _completedDirections['left']!
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 24)
                  : const Text('왼쪽',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 12,
              right: MediaQuery.of(context).size.width * 0.15,
              child: _completedDirections['right']!
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 24)
                  : const Text('오른쪽',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),

            // 시선 좌표 표시 원 (단일 원으로 표시)
            Positioned(
              left: _x - 10,
              top: _y - 10,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 5,
                      )
                    ]),
              ),
            ),

            // 정보 표시 영역 (하단)
            Positioned(
              left: 0,
              right: 0,
              bottom: 100,
              child: Column(
                children: [
                  Text(
                    'Current Direction: ${_realTimeDirection == 'center' ? '중앙' : _getDirectionText(_realTimeDirection)}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gaze Coordinates: (${_x.toStringAsFixed(1)}, ${_y.toStringAsFixed(1)})',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      // 완료된 방향과 남은 방향을 한글로 표시
                      '남은 방향: ${_getRemainingDirections()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _completedDirections.values.every((v) => v)
                            ? Colors.green
                            : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gaze at a direction for 2 seconds\nto change the displayed icon.',
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
}
