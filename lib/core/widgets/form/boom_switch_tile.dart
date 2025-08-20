import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BoomSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const BoomSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
            // Retourne la couleur du pouce selon l'état
            return Colors.white;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
            // Retourne la couleur de la piste selon l'état
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryGreen.withAlpha(50);
            }
            return Colors.grey.shade600;
          }),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}