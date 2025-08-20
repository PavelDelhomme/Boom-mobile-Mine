import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final double size;
  final Offset offset;
  final double scale;
  final Color color;

  const AppIcon({
    super.key,
    this.icon,
    this.assetPath,
    this.size = 24,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.color = Colors.white,
  }) : assert(icon != null || assetPath != null,
        'Either icon or assetPath must be provided.');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (assetPath != null) {
      child = Image.asset(assetPath!, width: size, height: size, fit: BoxFit.contain);
    } else {
      child = Icon(icon, size: size, color: color);
    }

    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}