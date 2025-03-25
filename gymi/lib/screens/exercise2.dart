import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/gaze_tracker_service.dart';

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

  // 현재 응시 중인 방향
  String _currentGazeDirection = 'center';

  // 현재 제시된 방향 (시계 방향으로 순서대로)
  final List<String> _directions = ['up', 'right', 'down', 'left'];
  int _currentDirectionIndex = 0;

  // 각 방향 완료 상태
  final Map<String, bool> _completedDirections = {
    'up': false,
    'right': false,
    'down': false,
    'left': false,
  };

  // 방향 응시 타이머
  Timer? _gazeTimer;

  // 완료 메시지 표시 여부
  bool _showCompletionMessage = false;

  // 홈 화면 자동 복귀 타이머
  Timer? _homeNavigationTimer;

  StreamSubscription<dynamic>? _gazeSubscription;
  bool _screenActive = true;

  // 현재 방향에 대한 응시 시작 시간
  DateTime? _gazeStartTime;

  // 응시 판정을 위한 체류 시간 (밀리초)
  final int _dwellTime = 2000; // 2초

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupGazeTracking();

    // GazeOverlay 숨기기 (직접 화살표만 표시)
    _gazeService.setShowOverlay(false);

    // 화면 방향을 가로로 고정
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

    // 화면 방향 복원
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  void _cancelAllTimers() {
    _gazeTimer?.cancel();
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
    if (_showCompletionMessage) return; // 완료 메시지 표시 중이면 감지 중단

    // 화면 크기 구하기
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 화면 중앙 좌표
    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    // 현재 시선의 상대적 위치 계산
    final offsetX = _x - centerX;
    final offsetY = _y - centerY;

    // 중앙 영역 안에 있는 경우 (중앙 영역은 화면의 30%)
    const centerThreshold = 0.3;
    final centerWidthThreshold = screenWidth * centerThreshold / 2;
    final centerHeightThreshold = screenHeight * centerThreshold / 2;

    if (offsetX.abs() < centerWidthThreshold &&
        offsetY.abs() < centerHeightThreshold) {
      _resetGazeTimer();
      setState(() {
        _currentGazeDirection = 'center';
      });
      return;
    }

    // 상하좌우 판단 (가장 큰 벗어남을 기준으로)
    String direction;
    if (offsetX.abs() > offsetY.abs()) {
      // 좌우 방향이 더 강함
      direction = offsetX > 0 ? 'right' : 'left';
    } else {
      // 상하 방향이 더 강함
      direction = offsetY > 0 ? 'down' : 'up';
    }

    // 방향이 바뀌면 타이머 재설정
    if (_currentGazeDirection != direction) {
      _resetGazeTimer();
      setState(() {
        _currentGazeDirection = direction;
      });
    }

    // 현재 제시된 방향과 일치하면 타이머 시작
    final currentTargetDirection = _directions[_currentDirectionIndex];
    if (direction == currentTargetDirection &&
        !_completedDirections[currentTargetDirection]!) {
      if (_gazeStartTime == null) {
        _gazeStartTime = DateTime.now();
        _startGazeTimer();
      }
    } else {
      _resetGazeTimer();
    }
  }

  void _startGazeTimer() {
    _gazeTimer?.cancel();
    _gazeTimer = Timer(Duration(milliseconds: _dwellTime), () {
      if (!mounted || !_screenActive) return;

      // 현재 방향 완료 처리
      final currentDirection = _directions[_currentDirectionIndex];
      setState(() {
        _completedDirections[currentDirection] = true;
      });

      // 효과음 재생 또는 햅틱 피드백 추가 가능
      HapticFeedback.mediumImpact();

      // 0.5초 후 다음 방향으로 이동
      Timer(const Duration(milliseconds: 500), () {
        if (!mounted || !_screenActive) return;

        // 모든 방향 완료 확인
        if (_allDirectionsCompleted()) {
          _showCompletion();
        } else {
          // 다음 방향으로 이동
          setState(() {
            _currentDirectionIndex =
                (_currentDirectionIndex + 1) % _directions.length;
            while (_completedDirections[_directions[_currentDirectionIndex]]!) {
              _currentDirectionIndex =
                  (_currentDirectionIndex + 1) % _directions.length;
            }
          });
        }

        _resetGazeTimer();
      });
    });
  }

  void _resetGazeTimer() {
    _gazeTimer?.cancel();
    _gazeTimer = null;
    _gazeStartTime = null;
  }

  bool _allDirectionsCompleted() {
    return _completedDirections.values.every((completed) => completed);
  }

  void _showCompletion() {
    setState(() {
      _showCompletionMessage = true;
    });

    // 3초 후 자동으로 홈 화면으로 이동
    _homeNavigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _screenActive) {
        Navigator.of(context).pop();
      }
    });
  }

  // 방향에 따른 아이콘 반환
  IconData _getDirectionIcon(String direction) {
    switch (direction) {
      case 'up':
        return Icons.arrow_upward;
      case 'right':
        return Icons.arrow_forward;
      case 'down':
        return Icons.arrow_downward;
      case 'left':
        return Icons.arrow_back;
      default:
        return Icons.arrow_upward;
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
        backgroundColor: const Color(0xFF9BBEDE), // 하늘색 배경
        body: Stack(
          children: [
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

            // 중앙에 방향 아이콘 또는 완료 메시지
            Center(
              child: _showCompletionMessage
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 200,
                        ),
                        SizedBox(height: 40),
                        Text(
                          "Great Job!\nAll directions completed!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : _completedDirections[_directions[_currentDirectionIndex]]!
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 200,
                        )
                      : Icon(
                          _getDirectionIcon(
                              _directions[_currentDirectionIndex]),
                          color: Colors.white,
                          size: 200,
                        ),
            ),

            // 오른쪽 상단에 건너뛰기 버튼
            Positioned(
              right: 40,
              top: 40,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "SKIP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 하단에 진행 상태 표시 (선택적)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _directions.map((direction) {
                  final isCompleted = _completedDirections[direction]!;
                  final isCurrent =
                      direction == _directions[_currentDirectionIndex];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : (isCurrent
                              ? Colors.white
                              : Colors.white.withOpacity(0.4)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
