import 'package:eyedid_flutter_example/widgets/tracking_point.dart';
import 'package:flutter/material.dart';

class GazeOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isActive = false;

  static void show(BuildContext context, double x, double y, Color color) {
    try {
      // 오버레이 동시 접근 방지
      if (_isActive) return;
      _isActive = true;

      // 이미 있는 오버레이 안전하게 제거
      if (_overlayEntry != null) {
        try {
          _overlayEntry!.remove();
        } catch (e) {
          print("Safely ignoring overlay removal error: $e");
        }
        _overlayEntry = null;
      }

      // 새 오버레이 생성
      _overlayEntry = OverlayEntry(
        builder: (context) => TrackingPoint(
          x: x,
          y: y,
          dotSize: 20.0,
          gazeColor: color,
        ),
      );

      // 오버레이 삽입 시도
      try {
        final overlayState = Overlay.of(context);
        overlayState.insert(_overlayEntry!);
      } catch (e) {
        print("Error inserting overlay: $e");
        _overlayEntry = null;
      }

      _isActive = false;
    } catch (e) {
      _isActive = false;
      print("General overlay error: $e");
    }
  }

  static void remove() {
    try {
      // 오버레이 동시 접근 방지
      if (_isActive) return;
      _isActive = true;

      if (_overlayEntry != null) {
        try {
          _overlayEntry!.remove();
        } catch (e) {
          print("Safely ignoring overlay removal error: $e");
        }
        _overlayEntry = null;
      }

      _isActive = false;
    } catch (e) {
      _isActive = false;
      print("Error removing overlay: $e");
    }
  }
}
