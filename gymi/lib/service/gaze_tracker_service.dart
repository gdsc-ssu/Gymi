import 'dart:async';
import 'package:eyedid_flutter/eyedid_flutter.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_metrics.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eyedid_flutter/gaze_tracker_options.dart';
import 'package:eyedid_flutter/eyedid_flutter_initialized_result.dart';
import 'package:eyedid_flutter_example/gaze_overlay.dart';
import 'package:eyedid_flutter/constants/eyedid_flutter_calibration_option.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_calibration.dart';
import 'package:eyedid_flutter/events/eyedid_flutter_drop.dart';

// 싱글톤 패턴으로 구현한 시선 추적 서비스
class GazeTrackerService {
  // 싱글톤 인스턴스
  static final GazeTrackerService _instance = GazeTrackerService._internal();
  factory GazeTrackerService() => _instance;
  GazeTrackerService._internal();

  // EyedidFlutter 인스턴스
  final EyedidFlutter eyedidFlutterPlugin = EyedidFlutter();

  // 시선 좌표
  double x = 0.0;
  double y = 0.0;
  Color gazeColor = Colors.red;
  double dotSize = 10.0;

  // 캘리브레이션 상태
  double calibrationProgress = 0.0;
  double nextX = 0.0;
  double nextY = 0.0;
  bool isCalibrationMode = false;

  // 추적 상태
  bool isInitialized = false;
  bool isTracking = false;

  // 컨텍스트 및 오버레이 관리
  BuildContext? _lastContext;
  bool _showOverlay = true;

  // 스트림 구독
  StreamSubscription<dynamic>? _trackingEventSubscription;
  StreamSubscription<dynamic>? _statusEventSubscription;
  StreamSubscription<dynamic>? _dropEventSubscription;
  StreamSubscription<dynamic>? _calibrationEventSubscription;

  // 상태 변경 알림을 위한 스트림 컨트롤러
  final _gazePositionController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get gazePositionStream =>
      _gazePositionController.stream;

  // 캘리브레이션 상태 알림을 위한 스트림 컨트롤러
  final _calibrationController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get calibrationStream =>
      _calibrationController.stream;

  // 권한 체크 메서드
  Future<bool> checkCameraPermission() async {
    bool hasCameraPermission =
        await eyedidFlutterPlugin.checkCameraPermission();
    return hasCameraPermission;
  }

  // 권한 요청 메서드
  Future<bool> requestCameraPermission() async {
    return await eyedidFlutterPlugin.requestCameraPermission();
  }

  // 플랫폼 버전 가져오기 메서드
  Future<String> getPlatformVersion() async {
    try {
      return await eyedidFlutterPlugin.getPlatformVersion();
    } on PlatformException catch (e) {
      return 'Failed to get platform version: ${e.message}';
    }
  }

  // 초기화 메서드
  Future<bool> initialize(String licenseKey, {BuildContext? context}) async {
    if (context != null) {
      _lastContext = context;
    }

    if (isInitialized) return true;

    // 초기화
    try {
      final options = GazeTrackerOptionsBuilder()
          .setPreset(CameraPreset.vga640x480)
          .setUseGazeFilter(true)
          .setUseBlink(false)
          .setUseUserStatus(false)
          .build();

      final result = await eyedidFlutterPlugin.initGazeTracker(
        licenseKey: licenseKey,
        options: options,
      );

      if (result.result ||
          result.message == InitializedResult.isAlreadyAttempting ||
          result.message == InitializedResult.gazeTrackerAlreadyInitialized) {
        isInitialized = true;
        _setupListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('초기화 오류: $e');
      return false;
    }
  }

  // 리스너 설정
  void _setupListeners() {
    // 기존 구독 취소
    _cancelAllSubscriptions();

    // 추적 이벤트 구독
    _trackingEventSubscription = eyedidFlutterPlugin.getTrackingEvent().listen(
      (event) {
        final info = MetricsInfo(event);
        if (info.gazeInfo.trackingState == TrackingState.success) {
          x = info.gazeInfo.gaze.x;
          y = info.gazeInfo.gaze.y;
          gazeColor = Colors.blueAccent;
          dotSize = 20.0;
          isTracking = true;

          // 컨텍스트가 있고 오버레이 표시가 활성화되었을 때만 오버레이 표시
          if (_lastContext != null && _showOverlay) {
            // 비동기 실행으로 빌드 중 setState 호출 방지
            Future.microtask(() {
              if (_lastContext != null) {
                GazeOverlay.show(_lastContext!, x, y, gazeColor);
              }
            });
          }
        } else {
          gazeColor = Colors.redAccent;
          dotSize = 20.0;
          isTracking = false;

          if (_showOverlay) {
            GazeOverlay.remove();
          }
        }

        // 상태 변경 알림
        if (!_gazePositionController.isClosed) {
          _gazePositionController.add({
            'x': x,
            'y': y,
            'color': gazeColor,
            'size': dotSize,
            'isTracking': isTracking
          });
        }
      },
    );

    // 상태 이벤트 구독
    _statusEventSubscription = eyedidFlutterPlugin.getStatusEvent().listen(
      (event) {
        final info = StatusInfo(event);
        isTracking = (info.type == StatusType.start);

        // 상태 변경 알림
        if (!_gazePositionController.isClosed) {
          _gazePositionController.add({
            'x': x,
            'y': y,
            'color': gazeColor,
            'size': dotSize,
            'isTracking': isTracking
          });
        }
      },
    );

    // 드롭 이벤트 구독
    _dropEventSubscription = eyedidFlutterPlugin.getDropEvent().listen(
      (event) {
        final info = DropInfo(event);
        print("Dropped at timestamp: ${info.timestamp}");
      },
    );

    // 캘리브레이션 이벤트 구독
    _calibrationEventSubscription =
        eyedidFlutterPlugin.getCalibrationEvent().listen(
      (event) {
        final info = CalibrationInfo(event);

        if (info.type == CalibrationType.nextPoint) {
          nextX = info.next!.x;
          nextY = info.next!.y;
          calibrationProgress = 0.0;
          isCalibrationMode = true;

          Future.delayed(const Duration(milliseconds: 500), () {
            eyedidFlutterPlugin.startCollectSamples();
          });
        } else if (info.type == CalibrationType.progress) {
          calibrationProgress = info.progress!;
        } else if (info.type == CalibrationType.finished) {
          isCalibrationMode = false;
          // 캘리브레이션이 끝나면 오버레이 다시 표시
          _showOverlay = true;
        } else if (info.type == CalibrationType.canceled) {
          print("Calibration canceled ${info.data?.length}");
          isCalibrationMode = false;
          // 캘리브레이션이 취소되면 오버레이 다시 표시
          _showOverlay = true;
        }

        // 캘리브레이션 상태 알림
        if (!_calibrationController.isClosed) {
          _calibrationController.add({
            'type': info.type.toString(),
            'nextX': nextX,
            'nextY': nextY,
            'progress': calibrationProgress,
            'isCalibrationMode': isCalibrationMode
          });
        }
      },
    );
  }

  // 추적 시작
  Future<void> startTracking() async {
    if (!isInitialized) return;
    await eyedidFlutterPlugin.startTracking();
  }

  // 추적 중지
  Future<void> stopTracking() async {
    if (!isInitialized) return;

    // 오버레이 먼저 제거
    GazeOverlay.remove();

    await eyedidFlutterPlugin.stopTracking();
  }

  // 보정 시작
  Future<void> startCalibration(CalibrationMode mode,
      {bool usePreviousCalibration = true}) async {
    if (!isInitialized) return;

    // 캘리브레이션 중에도 점을 계속 표시하려면 아래 라인을 주석 처리하거나 제거하세요.
    // _showOverlay = false;

    isCalibrationMode = true;
    await eyedidFlutterPlugin.startCalibration(
      mode,
      usePreviousCalibration: usePreviousCalibration,
    );
  }

  // 현재 추적 중인지 확인
  Future<bool> isTrackingNow() async {
    return await eyedidFlutterPlugin.isTracking();
  }

  // 컨텍스트 업데이트 - 안전하게 비동기로 처리
  // 컨텍스트 업데이트 - 더 안전하게
  void updateContext(BuildContext context) {
    // 이전 컨텍스트와 새 컨텍스트가 다른 경우에만 처리
    if (_lastContext != context) {
      _lastContext = context;

      // 화면이 변경되었으므로 일단 오버레이 제거
      GazeOverlay.remove();

      // 새 컨텍스트로 오버레이 다시 표시 (추적 중인 경우에만)
      if (isTracking && _showOverlay) {
        // 약간 지연시켜 화면 전환이 완료된 후 실행
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_lastContext != null) {
            GazeOverlay.show(_lastContext!, x, y, gazeColor);
          }
        });
      }
    }
  }

  // 오버레이 표시 설정
  void setShowOverlay(bool show) {
    _showOverlay = show;
    if (!show) {
      GazeOverlay.remove();
    } else if (isTracking && _lastContext != null) {
      Future.microtask(() {
        GazeOverlay.show(_lastContext!, x, y, gazeColor);
      });
    }
  }

  // 모든 구독 취소
  void _cancelAllSubscriptions() {
    _trackingEventSubscription?.cancel();
    _statusEventSubscription?.cancel();
    _dropEventSubscription?.cancel();
    _calibrationEventSubscription?.cancel();
  }

  // 리소스 해제
  void dispose() {
    GazeOverlay.remove();
    _cancelAllSubscriptions();

    if (!_gazePositionController.isClosed) {
      _gazePositionController.close();
    }

    if (!_calibrationController.isClosed) {
      _calibrationController.close();
    }
  }

  // 오버레이 강제 갱신
  void refreshOverlay() {
    if (_lastContext != null && isTracking) {
      Future.microtask(() {
        // 먼저 기존 오버레이 제거
        GazeOverlay.remove();

        // 새 오버레이 추가
        if (_lastContext != null) {
          GazeOverlay.show(_lastContext!, x, y, gazeColor);
        }
      });
    }
  }
}
