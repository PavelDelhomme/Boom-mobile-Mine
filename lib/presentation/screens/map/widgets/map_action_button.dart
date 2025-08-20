import 'package:flutter/material.dart';

import '../../../../core/widgets/icon/icon_service.dart';

class MapActionButton extends StatelessWidget {
  final String? iconName;
  final IconData? icon;
  final VoidCallback? onTap;
  final double size;
  final bool showClose;
  final VoidCallback? onCloseTap;
  final bool enabled;


  const MapActionButton({
    super.key,
    this.iconName,
    this.icon,
    this.size = 48,
    this.onTap,
    this.showClose = false,
    this.onCloseTap,
    this.enabled = true
  }) : assert(iconName != null || icon != null,
  'Either iconName or icon must be provided.');

  @override
  Widget build(BuildContext context) {
    final base = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? Colors.white : Colors.grey[300], // ← Couleur conditionnelle
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: enabled ? 0.26 : 0.1),
              blurRadius: 4,
              spreadRadius: 0, // ← Aucun rayonnement
          )
        ],
      ),
      child: Center( // Utilisation de Center pour centrer parfaitement
        child: iconName != null
            ? IconService.buildIcon(
          iconName!,
          size: size, // 60% de taille du bouton pour éviter les bordures // todo : ici prendre toute la place car l'icon est déjà le bouton en lui même
          color: enabled ? null : Colors.grey[500],
        )
            : Icon(
          icon,
          size: size, // 60% de taille du bouton pour éviter les bordures // todo : ici prendre toute la place car l'icon est deja le bouton en lui meme
          color: enabled ? Colors.green : Colors.grey[500],
        ),
      ),
    );

    if (!showClose) {
      return GestureDetector(
        onTap: enabled ? onTap : null, // ← Désactivé si enabled = false
        child: Opacity(
          opacity: enabled ? 1.0 : 0.6, // ← Opacité réduite si désactivé
          child: base,
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.6,
            child: base,
          ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: GestureDetector(
            onTap: onCloseTap,
            child: Container(
              width: 20, // Reduction de la taille du bouton close
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
