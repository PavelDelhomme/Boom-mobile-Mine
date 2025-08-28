// map_floating_buttons_left.dart corrigé avec FilterData
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/domain/entities/filter.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/filter_modal_bottom_sheet.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_export_database_panel.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_export_pdf_panel.dart';
import 'package:flutter/material.dart';
import '../map_action_button.dart';

class MapFloatingButtonsLeft extends StatefulWidget {
  final bool showExportButtons;

  const MapFloatingButtonsLeft({
    super.key,
    this.showExportButtons = false, // Par défaut masqués pour gagner de la place
  });

  @override
  State<MapFloatingButtonsLeft> createState() => _MapFloatingButtonsLeftState();
}

class _MapFloatingButtonsLeftState extends State<MapFloatingButtonsLeft> {
  bool _showAllButtons = false;
  List<String> _activeFilters = [];

  void _toggleButtonsVisibility() {
    setState(() {
      _showAllButtons = !_showAllButtons;
    });
  }

  Map<String, FilterData> _getAvailableFilters() {
    return {
      'landscape': FilterData(
        label: 'Paysage',
        icon: Icons.landscape,
        description: 'Filtrer par type de paysage',
        color: Colors.green,
      ),
      'frequency': FilterData(
        label: 'Fréquentation',
        icon: Icons.people,
        description: 'Filtrer par niveau de fréquentation',
        color: Colors.blue,
      ),
      'protection': FilterData(
        label: 'Protection',
        icon: Icons.shield,
        description: 'Filtrer par niveau de protection',
        color: Colors.orange,
      ),
      'modifications': FilterData(
        label: 'Modifiées',
        icon: Icons.edit,
        description: 'Stations récemment modifiées',
        color: Colors.purple,
      ),
    };
  }

  List<String> _getCurrentActiveFilters() {
    return _activeFilters;
  }

  Widget _buildToggleButton() {
    return MapActionButton(
      icon: _showAllButtons ? Icons.expand_less : Icons.expand_more,
      size: 48,
      onTap: _toggleButtonsVisibility,
    );
  }

  Widget _buildMainButtons() {
    return Column(
      children: [
        // Bouton de filtre (toujours visible)
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
                  setState(() {
                    _activeFilters = newFilters;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${newFilters.length} filtres appliqués'),
                      backgroundColor: AppColors.primaryGreen,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        // Bouton toggle pour afficher/masquer les autres boutons
        _buildToggleButton(),
      ],
    );
  }

  Widget _buildExpandedButtons() {
    if (!_showAllButtons && !widget.showExportButtons) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 8),

        // Boutons d'export (seulement si activés)
        if (_showAllButtons || widget.showExportButtons) ...[
          // Export Data
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
          const SizedBox(height: 8),

          // Export PDF
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
          const SizedBox(height: 8),
        ],

        // Boutons additionnels quand développé
        if (_showAllButtons) ...[
          // Bouton de reset des filtres
          if (_activeFilters.isNotEmpty)
            MapActionButton(
              icon: Icons.filter_alt_off,
              size: 48,
              onTap: () {
                setState(() {
                  _activeFilters.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtres supprimés'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

          if (_activeFilters.isNotEmpty)
            const SizedBox(height: 8),

          // Bouton d'information
          MapActionButton(
            icon: Icons.info_outline,
            size: 48,
            onTap: () {
              _showInfoDialog();
            },
          ),
        ],
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informations de la carte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtres actifs: ${_activeFilters.length}'),
              if (_activeFilters.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Filtres appliqués:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...(_activeFilters.map((filter) => Text('• $filter'))),
              ],
              const SizedBox(height: 12),
              const Text('Actions disponibles:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('• Touchez une station pour voir les détails'),
              const Text('• Long press sur une station pour le menu contextuel'),
              const Text('• Utilisez les boutons d\'édition à droite'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBadge() {
    if (_activeFilters.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 145,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          '${_activeFilters.length} filtre${_activeFilters.length > 1 ? 's' : ''}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Boutons principaux
        Positioned(
          top: 170,
          left: 16,
          child: Column(
            children: [
              _buildMainButtons(),
              _buildExpandedButtons(),
            ],
          ),
        ),

        // Badge des filtres actifs
        _buildFilterBadge(),
      ],
    );
  }
}