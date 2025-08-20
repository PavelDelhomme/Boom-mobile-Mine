import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class GenericOptionsButton extends StatefulWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color iconColor;
  final IconData icon;
  final double iconSize;
  final Color? menuColor;
  final Color? debugColor;

  const GenericOptionsButton({
    super.key,
    this.onEdit,
    this.onDelete,
    this.iconColor = Colors.green,
    this.icon = Icons.more_vert,
    this.iconSize = 24,
    this.menuColor,
    this.debugColor,
  });

  @override
  State<GenericOptionsButton> createState() => _GenericOptionsButtonState();
}


class _GenericOptionsButtonState extends State<GenericOptionsButton> {
  final GlobalKey iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: AppColors.primaryGreen,
      hoverColor: AppColors.ligthGreenSearchBar,
      key: iconKey,
      icon: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
      onPressed: () async {
        final currentContext = context;
        final button = iconKey.currentContext?.findRenderObject() as RenderBox?;
        final overlay = Overlay.of(currentContext).context.findRenderObject() as RenderBox?;

        if (button == null || overlay == null) return;

        final position = button.localToGlobal(Offset.zero, ancestor: overlay);
        final size = button.size;

        await showMenu(
          context: currentContext,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy + size.height,
            position.dx + size.width,
            position.dy,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: widget.menuColor ?? AppColors.ligthGreenSearchBar,
          items: [
            PopupMenuItem(
              value: 1,
              onTap: widget.onEdit,
              child: const Text('Modifier',),// style: TextStyle(color: AppColors.primaryGreen)),
            ),
            PopupMenuItem(
              value: 2,
              onTap: widget.onDelete,
              child: const Text('Supprimer',),// style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        );
      },
    );
  }
}