import 'package:flutter/material.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/map_action_button.dart';

class MapFloatingButtons extends StatelessWidget {
  const MapFloatingButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Boutons du haut à gauche (PDF, DATA, FILTRE)
        Positioned(
          top: 160,
          left: 16,
          child: Column(
            children: [
              MapActionButton(iconName: 'Export PDF', size: 32, onTap: () {}),
              const SizedBox(height: 12),
              MapActionButton(iconName: 'Export Data', size: 32, onTap: () {}),
              const SizedBox(height: 12),
              MapActionButton(icon: Icons.filter_alt, size: 32, onTap: () {}),
            ],
          ),
        ),

        // Boutons du haut à droite (LAYERS, GPS)
        Positioned(
          top: 160,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MapActionButton(iconName: 'Layer', size: 32, onTap: () {}),
              const SizedBox(height: 12),
              MapActionButton(iconName: 'Location', size: 32, onTap: () {}),
            ],
          ),
        ),

        // Boutons du bas à droite (LOCK, SAVE, EDIT)
        Positioned(
          bottom: 100,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MapActionButton(icon: Icons.lock_reset, size: 34, onTap: () {}),
              const SizedBox(height: 12),
              MapActionButton(iconName: 'Export Database', onTap: () {}),
              const SizedBox(height: 12),
              MapActionButton(iconName: 'Edit', onTap: () {}),
            ],
          ),
        ),
      ],
    );
  }
}
