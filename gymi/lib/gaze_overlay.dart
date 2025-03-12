import 'package:eyedid_flutter_example/widgets/eye_tracking_point.dart';
import 'package:flutter/material.dart';

class GazeOverlay {
  late var dotSize = 20.0;
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, double x, double y, Color color) {
    final overlayState = Overlay.of(context);

    // ✅ 기존 Overlay가 있으면 위치만 업데이트 (깜빡임 방지)
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) =>
          TrackingPoint(x: x, y: y, dotSize: 20.0, gazeColor: color),
    );

    overlayState.insert(_overlayEntry!);
  }

  // ✅ 필요할 때 Overlay를 제거하는 함수 추가
  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
