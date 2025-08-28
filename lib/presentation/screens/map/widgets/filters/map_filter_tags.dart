import 'package:boom_mobile/domain/entities/filter.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/filter_modal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

class MapFilterTags extends StatefulWidget {
  final Function(List<String>)? onFiltersChanged;

  const MapFilterTags({super.key, this.onFiltersChanged});

  @override
  State<MapFilterTags> createState() => _MapFilterTagsState();
}

class _MapFilterTagsState extends State<MapFilterTags> {
  List<String> activeFilters = ['stations', 'sanitaire', 'annee'];
  String selectedYear = '2025'; // ✅ Année sélectionnée

  // ✅ Années disponibles pour la sélection
  final List<String> availableYears = [
    '2025', '2024', '2023', '2022', '2021', '2020'
  ];

  // Filtres disponibles avec leurs données
  Map<String, FilterData> get availableFilters => {
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
      label: selectedYear, // ✅ Affichage dynamique de l'année
      icon: Icons.calendar_today,
      description: 'Données de l\'année $selectedYear',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          // Partie scrollable avec filtres
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildAddFilterButton(),
                  const SizedBox(width: 12),

                  // Tags de filtres actifs avec animation
                  ...activeFilters.map((filterId) {
                    final filter = availableFilters[filterId]!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: _buildFilterChip(filterId, filter, true),
                      ),
                    );
                  }),

                  // ✅ Bouton reset intégré dans la liste des filtres
                  if (activeFilters.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _buildResetButton(),
                  ],

                  // Espace pour éviter que le dernier élément soit coupé
                  const SizedBox(width: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFilterButton() {
    return GestureDetector(
      onTap: _showFilterDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryGreen, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: AppColors.primaryGreen,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              "Filtrer",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterId, FilterData filter, bool isActive) {
    return GestureDetector(
      onTap: () {
        // ✅ Gestion spéciale pour le filtre année
        if (filterId == 'annee') {
          _showYearSelectionDialog();
        } else {
          _toggleFilter(filterId);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? filter.color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? filter.color : Colors.grey.shade300,
            width: isActive ? 0 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isActive ? 0.15 : 0.05),
              blurRadius: isActive ? 6 : 2,
              offset: Offset(0, isActive ? 3 : 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              color: isActive ? Colors.white : filter.color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: TextStyle(
                color: isActive ? Colors.white : filter.color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _removeFilter(filterId),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: _resetFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20), // ✅ Même style que les autres chips
          border: Border.all(color: Colors.red.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.refresh,
              color: Colors.red.shade600,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              "Reset",
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Dialog pour sélectionner l'année
  void _showYearSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner une année'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableYears.length,
              itemBuilder: (context, index) {
                final year = availableYears[index];
                final isSelected = year == selectedYear;

                return ListTile(
                  title: Text(year),
                  leading: Radio<String>(
                    value: year,
                    groupValue: selectedYear,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedYear = value;
                        });
                        Navigator.pop(context);
                        widget.onFiltersChanged?.call(activeFilters);
                      }
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                    });
                    Navigator.pop(context);
                    widget.onFiltersChanged?.call(activeFilters);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterModalBottomSheet(
        availableFilters: availableFilters,
        activeFilters: activeFilters,
        onFiltersChanged: (newFilters) {
          setState(() {
            activeFilters = newFilters;
          });
          widget.onFiltersChanged?.call(activeFilters);
        },
      ),
    );
  }

  void _toggleFilter(String filterId) {
    setState(() {
      if (activeFilters.contains(filterId)) {
        activeFilters.remove(filterId);
      } else {
        activeFilters.add(filterId);
      }
    });
    widget.onFiltersChanged?.call(activeFilters);
  }

  void _removeFilter(String filterId) {
    setState(() {
      activeFilters.remove(filterId);
    });
    widget.onFiltersChanged?.call(activeFilters);
  }

  void _resetFilters() {
    setState(() {
      activeFilters.clear();
      selectedYear = '2025'; // Reset à l'année par défaut
    });
    widget.onFiltersChanged?.call(activeFilters);
  }
}
