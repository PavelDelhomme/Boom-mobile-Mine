import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/ok_constants.dart';

class IconService {
  static String getAsset(String name) {
    if (okIcons.containsKey(name)) {
      return okIcons[name]!;
    } else {
      throw Exception('Icône non trouvée dans okIcons: $name');
    }
  }

  static Widget buildIcon(String name, {double size = 24, Color? color}) {
    final path = getAsset(name);
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );
  }
}