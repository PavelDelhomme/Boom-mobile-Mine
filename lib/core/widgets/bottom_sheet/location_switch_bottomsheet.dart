import 'package:boom_mobile/core/widgets/bottom_sheet/top_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/domain/entities/user.dart';

class LocationSwitchBottomSheet extends StatelessWidget {
  final List<User> users;
  final void Function(User user) onSwitch;
  final VoidCallback onClose;

  const LocationSwitchBottomSheet({
    super.key,
    required this.users,
    required this.onSwitch,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TopBottomSheet(
              title: "Changer de compte",
              subtitle: "Choisissez un utilisateur actif",
              onClose: onClose,
            ),
            const SizedBox(height: 16),
            ...users.map(
                  (user) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withAlpha(60),
                  child: const Icon(Icons.person),
                ),
                title: Text(user.name),
                subtitle: Text(user.role),
                trailing: Switch(
                  value: user.isActive,
                  thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    // Couleur du pouce
                    return Colors.white;
                  }),
                  trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    // Couleur de la piste
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primaryGreen.withAlpha(50);
                    }
                    return Colors.grey.shade600;
                  }),
                  onChanged: (_) => onSwitch(user),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
