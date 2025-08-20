import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/bottom_sheet/top_bottom_sheet.dart';

import '../../../../../../domain/entities/layer.dart';

class LayerState {
  final Layer layer;
  bool isActive;
  double opacity;
  int order;

  LayerState({
    required this.layer,
    this.isActive = false,
    this.opacity = 1.0,
    this.order = 0,
  });

  LayerState copyWith({
    Layer? layer,
    bool? isActive,
    double? opacity,
    int? order,
  }) {
    return LayerState(
      layer: layer ?? this.layer,
      isActive: isActive ?? this.isActive,
      opacity: opacity ?? this.opacity,
      order: order ?? this.order,
    );
  }
}

class MapLayersPanel extends StatefulWidget {
  final List<Layer> availableLayers;
  final Function(List<LayerState>) onLayersChanged;
  final List<LayerState>? initialLayerStates;

  const MapLayersPanel({
    super.key,
    required this.availableLayers,
    required this.onLayersChanged,
    this.initialLayerStates,
  });

  @override
  State<MapLayersPanel> createState() => _MapLayersPanelState();
}

class _MapLayersPanelState extends State<MapLayersPanel> {
  late List<LayerState> _layerStates;
  String _selectedCategory = 'Toutes';

  // Catégories de couches simplifiées
  final Map<String, List<String>> _layerCategories = {
    'Toutes': [],
    'Fond de carte': ['Fond de carte', 'Imagerie'],
    'Données métier': ['Données métier'],
    'Référentiel': ['Référentiel', 'Administratif'],
    'Environnement': ['Environnement', 'Réglementaire'],
    'Transport': ['Transport', 'Hydrographie'],
    'Urbanisme': ['Urbanisme', 'Bâti'],
  };

  @override
  void initState() {
    super.initState();
    _initializeLayerStates();
  }

  void _initializeLayerStates() {
    if (widget.initialLayerStates != null) {
      _layerStates = List.from(widget.initialLayerStates!);
    } else {
      _layerStates = widget.availableLayers.asMap().entries.map((entry) {
        final index = entry.key;
        final layer = entry.value;

        // Couche de base active par défaut
        final isBaseLayer = layer.type == 'Fond de carte' && layer.nom == 'OpenStreetMap';

        return LayerState(
          layer: layer,
          isActive: isBaseLayer,
          opacity: isBaseLayer ? 1.0 : 0.8,
          order: index,
        );
      }).toList();
    }

    // Trier par ordre
    _layerStates.sort((a, b) => a.order.compareTo(b.order));
  }

  List<LayerState> _getFilteredLayers() {
    if (_selectedCategory == 'Toutes') return _layerStates;

    final categoryTypes = _layerCategories[_selectedCategory] ?? [];
    return _layerStates
        .where((layerState) => categoryTypes.contains(layerState.layer.type))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLayers = _getFilteredLayers();
    final activeLayers = _layerStates.where((ls) => ls.isActive).length;

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
              TopBottomSheet(
                title: "Gestion des couches",
                subtitle: "$activeLayers couche(s) active(s) • ${_layerStates.length} disponible(s)",
                onClose: () => Navigator.pop(context),
              ),

              // Informations sur l'état des services
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tous les services cartographiques sont opérationnels",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filtres par catégorie
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _layerCategories.keys.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _layerCategories.keys.elementAt(index);
                    final isSelected = _selectedCategory == category;

                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: AppColors.primaryGreen.withAlpha(50),
                      checkmarkColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredLayers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final layerState = filteredLayers[index];
                    return _buildLayerTile(layerState);
                  },
                ),
              ),

              // Actions rapides
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleAllLayers,
                        icon: Icon(
                          activeLayers == _layerStates.length
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 16,
                        ),
                        label: Text(
                          activeLayers == _layerStates.length
                              ? "Masquer tout"
                              : "Afficher tout",
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryGreen),
                          foregroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _resetToDefault,
                        icon: const Icon(Icons.restore, size: 16),
                        label: const Text("Réinitialiser", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.orange),
                          foregroundColor: AppColors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _applyChanges,
                        icon: const Icon(Icons.check, size: 16, color: Colors.white),
                        label: const Text(
                          "Appliquer",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
  }

  Widget _buildLayerTile(LayerState layerState) {
    final layer = layerState.layer;
    final isActive = layerState.isActive;

    // Déterminer si la couche est disponible (toutes le sont maintenant)
    final isAvailable = true;

    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen.withAlpha(25) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.primaryGreen.withAlpha(80) : Colors.grey[300]!,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // En-tête de la couche
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryGreen
                    : (isAvailable ? Colors.grey[400] : Colors.red[300]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getLayerIcon(layer.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    layer.nom,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive ? AppColors.primaryGreen : Colors.black87,
                    ),
                  ),
                ),
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "✓",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layer.type,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  "Mis à jour: ${layer.date}",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicateur d'ordre
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryGreen : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${layerState.order + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Switch d'activation
                Switch(
                  value: isActive && isAvailable,
                  onChanged: isAvailable ? (value) => _toggleLayer(layerState, value) : null,
                  thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    return Colors.white;
                  }),
                  trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primaryGreen.withAlpha(50);
                    }
                    return Colors.grey.shade400;
                  }),
                ),
              ],
            ),
            onTap: isAvailable ? () => _toggleLayer(layerState, !isActive) : null,
          ),

          // Contrôles d'opacité (si active)
          if (isActive && isAvailable) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.opacity, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text("Opacité:", style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryGreen,
                            inactiveTrackColor: AppColors.primaryGreen.withAlpha(77),
                            thumbColor: AppColors.primaryGreen,
                            overlayColor: AppColors.primaryGreen.withAlpha(80),
                            trackHeight: 3,
                          ),
                          child: Slider(
                            value: layerState.opacity,
                            onChanged: (value) => _updateOpacity(layerState, value),
                            min: 0.1,
                            max: 1.0,
                          ),
                        ),
                      ),
                      Text(
                        "${(layerState.opacity * 100).round()}%",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  // Contrôles d'ordre
                  Row(
                    children: [
                      const Icon(Icons.layers, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Text("Ordre:", style: TextStyle(fontSize: 12)),
                      const Spacer(),
                      IconButton(
                        onPressed: layerState.order > 0 ? () => _moveLayer(layerState, -1) : null,
                        icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      IconButton(
                        onPressed: layerState.order < _layerStates.length - 1
                            ? () => _moveLayer(layerState, 1)
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

  void _toggleLayer(LayerState layerState, bool isActive) {
    setState(() {
      final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerState.layer.nom);
      if (index != -1) {
        _layerStates[index] = layerState.copyWith(isActive: isActive);
      }
    });
  }

  void _updateOpacity(LayerState layerState, double opacity) {
    setState(() {
      final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerState.layer.nom);
      if (index != -1) {
        _layerStates[index] = layerState.copyWith(opacity: opacity);
      }
    });
  }

  void _moveLayer(LayerState layerState, int direction) {
    setState(() {
      final currentIndex = _layerStates.indexWhere((ls) => ls.layer.nom == layerState.layer.nom);
      final newIndex = currentIndex + direction;

      if (newIndex >= 0 && newIndex < _layerStates.length) {
        // Échanger les ordres
        final temp = _layerStates[currentIndex].order;
        _layerStates[currentIndex] = _layerStates[currentIndex].copyWith(order: _layerStates[newIndex].order);
        _layerStates[newIndex] = _layerStates[newIndex].copyWith(order: temp);

        // Retrier
        _layerStates.sort((a, b) => a.order.compareTo(b.order));
      }
    });
  }

  void _toggleAllLayers() {
    setState(() {
      final activeLayers = _layerStates.where((ls) => ls.isActive).length;
      final shouldActivate = activeLayers != _layerStates.length;

      for (int i = 0; i < _layerStates.length; i++) {
        _layerStates[i] = _layerStates[i].copyWith(isActive: shouldActivate);
      }
    });
  }

  void _resetToDefault() {
    setState(() {
      _initializeLayerStates();
      _selectedCategory = 'Toutes';
    });
  }

  void _applyChanges() {
    widget.onLayersChanged(_layerStates);
    Navigator.pop(context);
  }
}