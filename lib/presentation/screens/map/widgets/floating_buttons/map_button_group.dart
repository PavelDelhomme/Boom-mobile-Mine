import 'package:flutter/material.dart';

import '../map_action_button.dart';

class MapButtonGroup extends StatelessWidget {
  final List<MapActionButton> buttons;
  final double spacing;

  const MapButtonGroup({
    super.key,
    required this.buttons,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(buttons.length * 2 - 1, (index) {
        if (index.isEven) {
          return buttons[index ~/ 2];
        } else {
          return SizedBox(height: spacing);
        }
      }),
    );
  }
}
