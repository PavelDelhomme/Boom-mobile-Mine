import 'package:flutter/material.dart';

class StationMarker extends StatelessWidget {
  final Color color;
  final int? treesToCut;
  final String? warning;
  final bool highlight;
  final int? stationNumber; // ✅ Nouveau paramètre pour le numéro

  const StationMarker({
    super.key,
    required this.color,
    this.treesToCut,
    this.warning,
    this.highlight = false,
    this.stationNumber, // ✅ Paramètre optionnel
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Gradient halo si mis en surbrillance
          if (highlight)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withAlpha(77), Colors.transparent],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),

          // Cercle central avec numéro de station
          Container(
            width: 30, // ✅ Augmenté pour permettre l'affichage du numéro
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: stationNumber != null
                ? Center(
              child: Text(
                stationNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : null,
          ),

          // Badge: arbres à abattre
          if (treesToCut != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: _buildBadge(Icons.forest, '$treesToCut', Colors.orange),
            ),

          // Badge: warning
          if (warning != null)
            Positioned(
              top: -4,
              right: -4,
              child: _buildBadge(
                Icons.warning_amber_rounded,
                warning!,
                Colors.red,
              ),
            ),

          // Badge pour le numéro de station si pas affiché au centre
          if (stationNumber != null && (treesToCut != null || warning != null))
            Positioned(
              left: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 3)
                  ],
                ),
                child: Text(
                  stationNumber.toString(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 10),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}