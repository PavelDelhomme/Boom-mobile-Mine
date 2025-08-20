import 'package:flutter/material.dart';

class NavItem {
  final String label;
  final IconData? icon;
  final String? assetPath;
  final bool useAsset;
  final bool isEnabled;
  final bool isVisible;

  NavItem({
    required this.label,
    this.icon,
    this.assetPath,
    this.useAsset = false,
    this.isEnabled = true,
    this.isVisible = true,
  });
}
