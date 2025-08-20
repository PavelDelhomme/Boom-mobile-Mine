import 'package:boom_mobile/core/widgets/icon/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

class MapTopBar extends StatelessWidget {
  final String title;

  const MapTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            IconButton(
              icon: AppIcon(
                  assetPath: 'assets/icons/switch.png',
                  size: 24,
                color: Colors.white,
              ),
              onPressed: () {}, // action refresh
            ),
          ],
        ),
      ),
    );
  }
}
