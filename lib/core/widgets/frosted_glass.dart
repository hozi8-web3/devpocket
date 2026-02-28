import 'dart:ui';
import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color color;
  final BorderRadius? borderRadius;

  const FrostedGlass({
    super.key,
    required this.child,
    this.blur = 10.0,
    required this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
