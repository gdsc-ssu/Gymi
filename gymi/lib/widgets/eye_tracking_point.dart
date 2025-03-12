import 'package:flutter/material.dart';

class TrackingPoint extends StatelessWidget {
  const TrackingPoint({
    super.key,
    required double x,
    required double y,
    required double dotSize,
    required Color gazeColor,
  })  : _x = x,
        _y = y,
        _dotSize = dotSize,
        _gazeColor = gazeColor;

  final double _x;
  final double _y;
  final double _dotSize;
  final Color _gazeColor;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x - 5,
      top: _y - 5,
      child: Stack(alignment: Alignment.center, children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 30, end: _dotSize),
          builder: (context, size, child) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: _gazeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade300,
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
            );
          },
        ),
      ]),
    );
  }
}
