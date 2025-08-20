import 'package:boom_mobile/domain/entities/filter.dart';
import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

import '../../../../../../core/widgets/bottom_sheet/top_bottom_sheet.dart';

class FilterModalBottomSheet extends StatefulWidget {
  final Map<String, FilterData> availableFilters;
  final List<String> activeFilters;
  final Function(List<String>) onFiltersChanged;

  const FilterModalBottomSheet({
    super.key,
    required this.availableFilters,
    required this.activeFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterModalBottomSheet> createState() => _FilterModalBottomSheetState();
}

class _FilterModalBottomSheetState extends State<FilterModalBottomSheet> {
  late List<String> tempActiveFilters;

  @override
  void initState() {
    super.initState();
    tempActiveFilters = List.from(widget.activeFilters);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // En-tête avec le widget standard
              TopBottomSheet(
                title: "Filtres de carte",
                subtitle: "Personnalisez l'affichage de votre carte",
                onClose: () => Navigator.pop(context),
              ),

              // Zone scrollable pour le contenu
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Compteur de filtres
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.ligthGreenSearchBar.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "${tempActiveFilters.length} filtre(s) sélectionné(s)",
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Section des filtres disponibles
                    Text(
                      "Filtres disponibles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Grille scrollable des filtres
                    ...widget.availableFilters.entries.map((entry) {
                      final isActive = tempActiveFilters.contains(entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildFilterTile(entry.key, entry.value, isActive),
                      );
                    }),

                    const SizedBox(height: 16),

                    // ✅ Aperçu des filtres actifs
                    if (tempActiveFilters.isNotEmpty) ...[
                      Text(
                        "Filtres actifs",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tempActiveFilters.map((filterId) {
                          final filter = widget.availableFilters[filterId]!;
                          return _buildActiveFilterChip(filterId, filter);
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),

              // ✅ Boutons d'action corrigés
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            tempActiveFilters.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Tout\ndésélectionner", // ✅ Texte sur deux lignes
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onFiltersChanged(tempActiveFilters);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            const Text(
                              "Appliquer",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    /*
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filtres de carte bad dislay",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Compteur de filtres
          Text(
            "${tempActiveFilters.length} filtre(s) sélectionné(s)",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          // Grille des filtres avec état temporaire
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.availableFilters.entries.map((entry) {
                  final isActive = tempActiveFilters.contains(entry.key);
                  return GestureDetector(
                    onTap: () => _toggleTempFilter(entry.key),
                    child: _buildFilterChip(entry.key, entry.value, isActive),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      tempActiveFilters.clear();
                    });
                  },
                  child: const Text("Tout désélectionner"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onFiltersChanged(tempActiveFilters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Appliquer",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );*/
  }


  // ✅ Tuile de filtre avec design amélioré
  Widget _buildFilterTile(String filterId, FilterData filter, bool isActive) {
    return GestureDetector(
      onTap: () => _toggleTempFilter(filterId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? filter.color.withAlpha(25) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? filter.color : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? filter.color : filter.color.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filter.icon,
                color: isActive ? Colors.white : filter.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filter.label,
                    style: TextStyle(
                      color: isActive ? filter.color : AppColors.textDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    filter.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // ✅ Indicateur de sélection
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? filter.color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? filter.color : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Chip pour filtres actifs avec croix
  Widget _buildActiveFilterChip(String filterId, FilterData filter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: filter.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(filter.icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            filter.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _toggleTempFilter(filterId),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTempFilter(String filterId) {
    setState(() {
      if (tempActiveFilters.contains(filterId)) {
        tempActiveFilters.remove(filterId);
      } else {
        tempActiveFilters.add(filterId);
      }
    });
  }

  /*
  void _toggleTempFilter(String filterId) {
    setState(() {
      if (tempActiveFilters.contains(filterId)) {
        tempActiveFilters.remove(filterId);
      } else {
        tempActiveFilters.add(filterId);
      }
    });
  }
   */

  /*
  Widget _buildFilterChip(String filterId, FilterData filter, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? filter.color : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isActive ? filter.color : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: filter.color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter.icon,
            color: isActive ? Colors.white : filter.color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                filter.label,
                style: TextStyle(
                  color: isActive ? Colors.white : filter.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                filter.description,
                style: TextStyle(
                  color: isActive ? Colors.white70 : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }*/
}
