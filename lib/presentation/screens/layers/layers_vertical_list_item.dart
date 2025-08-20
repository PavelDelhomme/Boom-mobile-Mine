import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/list/vertical_list_item.dart';
import '../../../../core/widgets/buttons/generic_options_button.dart';

class LayersVerticalListItem extends StatelessWidget {
  final String name;
  final String type;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;
  final bool isActive;

  const LayersVerticalListItem({
    super.key,
    required this.name,
    required this.type,
    required this.date,
    required this.onTap,
    required this.onOptionsTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return VerticalListItem(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen.withAlpha(50) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(17.6),
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          _getLayerIcon(type),
          color: isActive ? AppColors.primaryGreen : Colors.grey[600],
          size: 24,
        ),
      ),
      title: name,
      subtitle: type,
      subtitle2: "Mis à jour: $date",
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicateur de statut
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryGreen : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // Menu options
          GenericOptionsButton(
            onEdit: () {
              log('Configure layer: $name');
              onOptionsTap();
            },
            onDelete: () {
              log('Toggle layer: $name');
              onOptionsTap();
            },
            menuColor: AppColors.backgroundColorThreePointsListDossier,
            icon: Icons.more_vert,
          ),
        ],
      ),
    );
  }

  IconData _getLayerIcon(String layerType) {
    switch (layerType.toLowerCase()) {
      case 'fond de carte':
        return Icons.map;
      case 'imagerie':
        return Icons.satellite_alt;
      case 'référentiel':
        return Icons.grid_on;
      case 'administratif':
        return Icons.border_outer;
      case 'transport':
        return Icons.route;
      case 'hydrographie':
        return Icons.water;
      case 'données métier':
        return Icons.business_center;
      case 'réglementaire':
        return Icons.gavel;
      case 'environnement':
        return Icons.park;
      case 'urbanisme':
        return Icons.location_city;
      case 'bâti':
        return Icons.business;
      default:
        return Icons.layers;
    }
  }
}