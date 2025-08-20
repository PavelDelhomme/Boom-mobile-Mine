import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/domain/entities/filter.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/filter_modal_bottom_sheet.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_export_database_panel.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_export_pdf_panel.dart';
import 'package:flutter/material.dart';
import '../map_action_button.dart';

class MapFloatingButtonsLeft extends StatelessWidget {
  const MapFloatingButtonsLeft({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 170, // En dessous des MapFilterTags
      left: 16,
      child: Column(
        children: [
          MapActionButton(
            iconName: 'Export Data',
            size: 48,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MapExportDatabasePanel(),
              );
            },
          ),
          const SizedBox(height: 12),
          MapActionButton(
            iconName: 'Export PDF',
            size: 48,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const MapExportPdfPanel(),
              );
            },
          ),
          const SizedBox(height: 12),
          MapActionButton(
              iconName: 'Filter',
              size: 48,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => FilterModalBottomSheet(
                    availableFilters: _getAvailableFilters(),
                    activeFilters: _getCurrentActiveFilters(),
                    onFiltersChanged: (newFilters) {
                      // ✅ TODO: Implémenter la logique de filtrage
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${newFilters.length} filtres appliqués'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                    },
                  ),
                );
              },
          ),
        ],
      ),
    );
  }

  Map<String, FilterData> _getAvailableFilters() {
    return {
      'stations': FilterData(
        label: 'Station 512',
        icon: Icons.location_on,
        description: '512 stations actives',
        color: AppColors.primaryGreen,
      ),
      'sanitaire': FilterData(
        label: 'État sanitaire Bon',
        icon: Icons.health_and_safety,
        description: 'Arbres en bon état',
        color: Colors.green.shade600,
      ),
      'annee': FilterData(
        label: '2025',
        icon: Icons.calendar_today,
        description: 'Données de l\'année courante',
        color: AppColors.darkGreen,
      ),
      'essence': FilterData(
        label: 'Chêne',
        icon: Icons.nature,
        description: 'Essence principale',
        color: Colors.brown.shade600,
      ),
      'protection': FilterData(
        label: 'Zone protégée',
        icon: Icons.shield,
        description: 'Espaces classés',
        color: Colors.orange.shade600,
      ),
      'intervention': FilterData(
        label: 'À intervenir',
        icon: Icons.warning,
        description: 'Nécessite une action',
        color: Colors.red.shade600,
      ),
    };
  }


  // ✅ Filtres actifs par défaut (peut être récupéré d'un state management)
  List<String> _getCurrentActiveFilters() {
    return ['stations', 'sanitaire', 'annee'];
  }
}