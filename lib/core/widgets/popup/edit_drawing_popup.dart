import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/icon/icon_service.dart';

class EditDrawingPopup extends StatelessWidget {
  final VoidCallback onClose;
  final void Function(String toolName) onToolSelected;
  final String? selectedTool;

  const EditDrawingPopup({
    super.key,
    required this.onClose,
    required this.onToolSelected,
    this.selectedTool,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onClose,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 140, right: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOption("Dessin Point", 'Draw point'),
                      _buildOption("Dessin ligne", 'Draw line'),
                      _buildOption("Dessin Polygon", 'Draw polygon'),
                      _buildOption("Modifier les dessins", 'Edit draw'),
                      _buildOption("Supprimer un dessin", 'Delete draw'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildOption(String label, String iconName) {
    final bool isActive = iconName == selectedTool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () {
          onToolSelected(iconName);
          onClose(); // Ferme le popup après sélection
        },
        child: SizedBox(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  decoration: isActive ? TextDecoration.underline : null,
                ),
              ),
              Image.asset(
                IconService.getAsset(iconName),
                width: 20,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
