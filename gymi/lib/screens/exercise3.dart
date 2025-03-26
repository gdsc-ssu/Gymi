import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../service/gaze_tracker_service.dart';

class Exercise3 extends StatefulWidget {
  const Exercise3({super.key});

  @override
  State<Exercise3> createState() => _Exercise3State();
}

class _Exercise3State extends State<Exercise3> with WidgetsBindingObserver {
  final _gazeService = GazeTrackerService();

  // 현재 시선 위치
  double _x = 0.0;
  double _y = 0.0;

  // 게임 상태 변수
  bool _isGameActive = false;
  bool _isGameOver = false;
  int _score = 0;
  int _remainingTime = 180; // 3분 = 180초

  // 두더지 상태 관리
  List<bool> _moleVisible = List.generate(9, (_) => false);
  List<DateTime?> _moleAppearTime = List.generate(9, (_) => null);
  List<bool> _moleGazing = List.generate(9, (_) => false);
  List<DateTime?> _moleGazeStartTime = List.generate(9, (_) => null);

  // 타이머
  Timer? _gameTimer;
  Timer? _moleTimer;
  Timer? _gazeCheckTimer;

  // 오디오 플레이어
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 게임 시간 표시용 포맷팅
  String get formattedTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  StreamSubscription<dynamic>? _gazeSubscription;
  bool _screenActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupGazeTracking();

    // GazeOverlay 숨기기 (우리가 직접 그릴 점만 사용)
    _gazeService.setShowOverlay(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 컨텍스트를 안전하게 업데이트 (빌드 프로세스 이후에 실행됨)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gazeService.updateContext(context);
      _screenActive = true;
      _startGame();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _screenActive) {
      // 앱이 포그라운드로 돌아왔을 때 오버레이는 계속 숨김 상태 유지
      _gazeService.setShowOverlay(false);
    } else if (state == AppLifecycleState.paused) {
      // 앱이 백그라운드로 갔을 때 게임 일시정지
      _pauseGame();
    }
  }

  @override
  void dispose() {
    _gazeSubscription?.cancel();
    _cancelAllTimers();
    WidgetsBinding.instance.removeObserver(this);
    _screenActive = false;
    _audioPlayer.dispose();

    // 화면을 나갈 때 GazeOverlay 다시 활성화
    _gazeService.setShowOverlay(true);

    super.dispose();
  }

  void _cancelAllTimers() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    _gazeCheckTimer?.cancel();
  }

  Future<void> _setupGazeTracking() async {
    // 싱글톤 서비스의 스트림을 구독
    _gazeSubscription = _gazeService.gazePositionStream.listen((data) {
      if (mounted && _screenActive) {
        setState(() {
          _x = data['x'];
          _y = data['y'];
        });
      }
    });
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _isGameOver = false;
      _score = 0;
      _remainingTime = 180;
      _moleVisible = List.generate(9, (_) => false);
      _moleAppearTime = List.generate(9, (_) => null);
      _moleGazing = List.generate(9, (_) => false);
      _moleGazeStartTime = List.generate(9, (_) => null);
    });

    // 게임 타이머 시작 (1초마다 시간 업데이트)
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });

      if (_remainingTime <= 0) {
        _endGame();
      }
    });

    // 두더지 생성 타이머 시작 (1.5초마다 두더지 생성)
    _moleTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _spawnMole();
    });

    // 시선 체크 타이머 (100ms마다 시선이 두더지 위에 있는지 체크)
    _gazeCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _checkGazeOnMoles();
    });
  }

  void _pauseGame() {
    _cancelAllTimers();
    _isGameActive = false;
  }

  void _endGame() {
    _cancelAllTimers();

    setState(() {
      _isGameActive = false;
      _isGameOver = true;
    });
  }

  void _spawnMole() {
    if (!_isGameActive) return;

    // 랜덤한 위치 선택
    final random = Random();
    List<int> availableSlots = [];

    // 현재 두더지가 없는 슬롯만 선택
    for (int i = 0; i < 9; i++) {
      if (!_moleVisible[i]) {
        availableSlots.add(i);
      }
    }

    if (availableSlots.isEmpty) return;

    final selectedSlot = availableSlots[random.nextInt(availableSlots.length)];

    setState(() {
      _moleVisible[selectedSlot] = true;
      _moleAppearTime[selectedSlot] = DateTime.now();
    });

    // 3초 후 두더지 제거
    Timer(const Duration(seconds: 3), () {
      if (mounted && _screenActive) {
        setState(() {
          if (_moleVisible[selectedSlot] && !_moleGazing[selectedSlot] && _moleGazeStartTime[selectedSlot] != null) {
            _playFailSound();
          }
          _moleVisible[selectedSlot] = false;
          _moleGazing[selectedSlot] = false;
          _moleGazeStartTime[selectedSlot] = null;
        });
      }
    });
  }

  void _checkGazeOnMoles() {
    if (!_isGameActive) return;

    // 화면 크기 가져오기
    final size = MediaQuery.of(context).size;
    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    // 각 셀에 대해 시선이 그 위에 있는지 확인
    for (int i = 0; i < 9; i++) {
      if (!_moleVisible[i] || _moleGazing[i]) continue;

      int row = i ~/ 3;
      int col = i % 3;

      double left = col * cellWidth;
      double top = row * cellHeight;

      // 시선이 현재 셀 안에 있는지 확인
      if (_x >= left && _x < left + cellWidth && _y >= top && _y < top + cellHeight) {
        // 시선이 두더지 위에 있는 경우
        if (_moleGazeStartTime[i] == null) {
          setState(() {
            _moleGazeStartTime[i] = DateTime.now();
          });
        } else {
          // 응시 시간 계산
          final gazeTime = DateTime.now().difference(_moleGazeStartTime[i]!).inMilliseconds;

          // 2초 이상 응시했으면 두더지 잡기 성공
          if (gazeTime >= 2000) {
            setState(() {
              _moleGazing[i] = true;
              _score++;
              _moleVisible[i] = false; // 두더지 제거
            });
            _playSuccessSound();
          }
        }
      } else {
        // 시선이 두더지 위에 없는 경우, 응시 시간 초기화
        setState(() {
          _moleGazeStartTime[i] = null;
        });
      }
    }
  }

  Future<void> _playSuccessSound() async {
    await _audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  Future<void> _playFailSound() async {
    await _audioPlayer.play(AssetSource('sounds/fail.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final safeArea = MediaQuery.of(context).padding;
    
    // 앱바 및 상태표시줄 높이를 고려한 실제 사용 가능 영역 계산
    final appBarHeight = AppBar().preferredSize.height;
    final usableHeight = size.height - appBarHeight - safeArea.top - safeArea.bottom;
    
    // 가로/세로 모드에 따라 그리드 최대 크기 계산
    final gridMaxSize = isLandscape 
        ? min(usableHeight * 0.9, size.width * 0.6) // 가로모드
        : min(size.width * 0.95, usableHeight * 0.7); // 세로모드
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        _screenActive = false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('두더지 잡기 게임'),
          backgroundColor: Colors.brown[700],
          elevation: 0,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // 배경
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.brown[400]!, Colors.brown[800]!],
                  ),
                ),
              ),
              
              // 메인 콘텐츠 영역 - 가로/세로 모드에 따라 레이아웃 조정
              Column(
                children: [
                  // 게임 상태 표시 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 점수
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '점수: $_score',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        // 남은 시간
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '남은 시간: $formattedTime',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 게임 그리드 - 화면 크기에 맞게 조정
                  Expanded(
                    child: Center(
                      child: !_isGameOver
                        ? SizedBox(
                            width: gridMaxSize,
                            height: gridMaxSize,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.0,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: 9,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.brown[600],
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _moleVisible[index]
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // 두더지 이미지
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Image.asset(
                                              'assets/images/mole.png',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          
                                          // 응시 진행 표시기
                                          if (_moleGazeStartTime[index] != null && !_moleGazing[index])
                                            CircularProgressIndicator(
                                              value: min(DateTime.now().difference(_moleGazeStartTime[index]!).inMilliseconds / 2000, 1.0),
                                              strokeWidth: 5,
                                              backgroundColor: Colors.grey.withOpacity(0.3),
                                              color: Colors.green,
                                            ),
                                        ],
                                      )
                                    : Container(),
                                );
                              },
                            ),
                          )
                        : Container(
                            width: min(300, size.width * 0.8),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '게임 종료!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '최종 점수: $_score',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _startGame();
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('다시 시작'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.home),
                                      label: const Text('홈으로'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),

              // 시선 표시 점
              Positioned(
                left: _x - 10,
                top: _y - 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
