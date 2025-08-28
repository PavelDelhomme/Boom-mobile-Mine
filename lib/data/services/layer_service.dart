// Ex service layer
/*import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../domain/entities/layer.dart';
import '../presentation/screens/map/widgets/floating_buttons/widgets/map_layers_panel.dart';
import '../core/constants/ign_keys.dart';

class LayerService with ChangeNotifier {
  List<LayerState> _layerStates = [];
  List<Layer> _availableLayers = [];

  List<LayerState> get layerStates => _layerStates;
  List<LayerState> get activeLayers => _layerStates.where((ls) => ls.isActive).toList();
  List<Layer> get availableLayers => _availableLayers;

  // Initialiser avec les couches par défaut
  void initialize(List<Layer> layers) {
    _availableLayers = List.from(layers);
    _layerStates = _createDefaultLayerStates(layers);
    ensureBaseLayerActive();
    notifyListeners();
  }

  List<LayerState> _createDefaultLayerStates(List<Layer> layers) {
    return layers.asMap().entries.map((entry) {
      final index = entry.key;
      final layer = entry.value;
      bool isActive = false;
      double opacity = 0.8;

      // Couche de base OpenStreetMap active par défaut
      if (layer.type == 'Fond de carte' && layer.nom == 'OpenStreetMap') {
        isActive = true;
        opacity = 1.0;
      }

      return LayerState(
        layer: layer,
        isActive: isActive,
        opacity: opacity,
        order: index,
      );
    }).toList();
  }

  // Mettre à jour les états des couches
  void updateLayerStates(List<LayerState> newStates) {
    _layerStates = newStates;

    // ✅ CORRECTION : Toujours s'assurer qu'une couche de base reste active
    //ensureBaseLayerActive();
    notifyListeners();
  }

  // Activer/désactiver une couche
  void toggleLayer(String layerName, bool isActive) {
    /*final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerName);
    if (index != -1) {
      final layerState = _layerStates[index];

      // ✅ CORRECTION : Empêcher de désactiver la dernière couche de base
      if (!isActive && layerState.layer.type == 'Fond de carte') {
        final activeBaseLayers = _layerStates.where((ls) =>
        ls.isActive && ls.layer.type == 'Fond de carte' && ls.layer.nom != layerName
        );

        if (activeBaseLayers.isEmpty) {
          // Ne pas permettre de désactiver la dernière couche de base
          debugPrint('⚠️ Impossible de désactiver la dernière couche de base');
          return;
        }
      }

      _layerStates[index] = _layerStates[index].copyWith(isActive: isActive);
      notifyListeners();
    }*/
    final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerName);
    if (index != -1) {
      _layerStates[index] = _layerStates[index].copyWith(isActive: isActive);
      notifyListeners();
    }
  }

  // Modifier l'opacité d'une couche
  void updateLayerOpacity(String layerName, double opacity) {
    final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerName);
    if (index != -1) {
      _layerStates[index] = _layerStates[index].copyWith(opacity: opacity);
      notifyListeners();
    }
  }

  // Réorganiser l'ordre des couches
  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _layerStates.removeAt(oldIndex);
    _layerStates.insert(newIndex, item);

    // Mettre à jour les ordres
    for (int i = 0; i < _layerStates.length; i++) {
      _layerStates[i] = _layerStates[i].copyWith(order: i);
    }

    notifyListeners();
  }

  // Ajouter une nouvelle couche
  void addLayer(Layer layer, {bool isActive = false, double opacity = 0.8}) {
    // Vérifier si la couche existe déjà
    final existingIndex = _availableLayers.indexWhere((l) => l.nom == layer.nom);
    if (existingIndex != -1) {
      // Mettre à jour la couche existante
      _availableLayers[existingIndex] = layer;
      final stateIndex = _layerStates.indexWhere((ls) => ls.layer.nom == layer.nom);
      if (stateIndex != -1) {
        _layerStates[stateIndex] = _layerStates[stateIndex].copyWith(
          layer: layer,
          isActive: isActive,
          opacity: opacity,
        );
      }
    } else {
      // Ajouter nouvelle couche
      _availableLayers.add(layer);
      final newLayerState = LayerState(
        layer: layer,
        isActive: isActive,
        opacity: opacity,
        order: _layerStates.length,
      );
      _layerStates.add(newLayerState);
    }
    notifyListeners();
  }

  // Supprimer une couche
  void removeLayer(String layerName) {
    /*
    final layerState = _layerStates.firstWhere((ls) => ls.layer.nom == layerName);

    // ✅ CORRECTION : Empêcher de supprimer la dernière couche de base
    if (layerState.layer.type == 'Fond de carte') {
      final activeBaseLayers = _layerStates.where((ls) =>
      ls.layer.type == 'Fond de carte' && ls.layer.nom != layerName
      );

      if (activeBaseLayers.length <= 1) {
        debugPrint('⚠️ Impossible de supprimer la dernière couche de base disponible');
        return;
      }
    }

    _layerStates.removeWhere((ls) => ls.layer.nom == layerName);
    _availableLayers.removeWhere((layer) => layer.nom == layerName);

    // Réorganiser les ordres
    for (int i = 0; i < _layerStates.length; i++) {
      _layerStates[i] = _layerStates[i].copyWith(order: i);
    }

    ensureBaseLayerActive();
    notifyListeners();*/
    _layerStates.removeWhere((ls) => ls.layer.nom == layerName);
    _availableLayers.removeWhere((layer) => layer.nom == layerName);

    // Réorganiser les ordres
    for (int i = 0; i < _layerStates.length; i++) {
      _layerStates[i] = _layerStates[i].copyWith(order: i);
    }

    notifyListeners();
  }

  // Réinitialiser aux couches par défaut
  void resetToDefault() {
    _layerStates = _createDefaultLayerStates(_availableLayers);
    notifyListeners();
  }

  // Générer les couches pour Flutter Map
  List<Widget> generateMapLayers(BuildContext context, {bool showBadges = false}) {
    final activeLayers = _layerStates
        .where((ls) => ls.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    List<Widget> mapLayers = [];

    for (final layerState in activeLayers) {
      final layer = layerState.layer;

      // Couche de tuiles (fond de carte) - Seulement OpenStreetMap pour l'instant
      if (layer.type == 'Fond de carte') {
        mapLayers.add(_buildTileLayer(layer, layerState.opacity));
      }

      // Couches de marqueurs (données métier)
      else if (layer.type == 'Données métier') {
        final markers = layer.markerBuilder(context, showBadges: showBadges);
        if (markers.isNotEmpty) {
          mapLayers.add(_buildMarkerLayer(markers, layerState.opacity));
        }
      }
    }

    return mapLayers;
  }

  Widget _buildTileLayer(Layer layer, double opacity) {
    String urlTemplate;

    // Pour l'instant, seulement OpenStreetMap
    switch (layer.nom) {
      case 'OpenStreetMap':
        urlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
        break;
      default:
        urlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
    }

    return Opacity(
      opacity: opacity,
      child: TileLayer(
        urlTemplate: urlTemplate,
        userAgentPackageName: 'com.boom.boom_mobile',
        maxZoom: 19,
        fallbackUrl: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
      ),
    );
  }

  Widget _buildMarkerLayer(List<Marker> markers, double opacity) {
    return Opacity(
      opacity: opacity,
      child: MarkerLayer(markers: markers),
    );
  }

  // Sauvegarder la configuration des couches
  Map<String, dynamic> exportConfiguration() {
    return {
      'layerStates': _layerStates.map((ls) => {
        'layerName': ls.layer.nom,
        'isActive': ls.isActive,
        'opacity': ls.opacity,
        'order': ls.order,
      }).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Charger une configuration sauvegardée
  void importConfiguration(Map<String, dynamic> config) {
    final layerStatesConfig = config['layerStates'] as List<dynamic>?;
    if (layerStatesConfig == null) return;

    for (final stateConfig in layerStatesConfig) {
      final layerName = stateConfig['layerName'] as String;
      final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerName);

      if (index != -1) {
        _layerStates[index] = _layerStates[index].copyWith(
          isActive: stateConfig['isActive'] as bool? ?? false,
          opacity: (stateConfig['opacity'] as num?)?.toDouble() ?? 0.8,
          order: stateConfig['order'] as int? ?? index,
        );
      }
    }

    // Retrier par ordre
    _layerStates.sort((a, b) => a.order.compareTo(b.order));
    notifyListeners();
  }

  // Obtenir les statistiques des couches
  Map<String, dynamic> getLayerStatistics() {
    final totalLayers = _layerStates.length;
    final activeLayers = _layerStates.where((ls) => ls.isActive).length;
    final layersByType = <String, int>{};

    for (final layerState in _layerStates) {
      final type = layerState.layer.type;
      layersByType[type] = (layersByType[type] ?? 0) + 1;
    }

    return {
      'totalLayers': totalLayers,
      'activeLayers': activeLayers,
      'inactiveLayers': totalLayers - activeLayers,
      'layersByType': layersByType,
      'averageOpacity': totalLayers > 0 ? _layerStates.fold(0.0, (sum, ls) => sum + ls.opacity) / totalLayers : 0.0,
    };
  }

  // Valider qu'au moins une couche de base est active
  bool hasActiveBaseLayer() {
    return _layerStates.any((ls) =>
    ls.isActive && ls.layer.type == 'Fond de carte'
    );
  }

  // Activer une couche de base par défaut si aucune n'est active
  void ensureBaseLayerActive() {
    if (!_layerStates.any((ls) => ls.isActive && ls.layer.type == 'Fond de carte')) {
      final osmLayerIndex = _layerStates.indexWhere((ls) => ls.layer.type == 'Fond de carte' && ls.layer.nom == 'OpenStreetMap');
      if (osmLayerIndex != -1) {
        _layerStates[osmLayerIndex] = _layerStates[osmLayerIndex].copyWith(isActive: true);
        notifyListeners();
      }
    }
  }
}*/

// New service layer
import 'package:boom_mobile/data/services/offline_cache_service.dart';
import 'package:boom_mobile/data/services/offline_tile_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/layer.dart';
import '../../presentation/screens/map/widgets/floating_buttons/widgets/map_layers_panel.dart';

class LayerService with ChangeNotifier {
  List<LayerState> _layerStates = [];
  List<Layer> _availableLayers = [];
  OfflineCacheService? _cacheService;

  List<LayerState> get layerStates => _layerStates;
  List<LayerState> get activeLayers => _layerStates.where((ls) => ls.isActive).toList();
  List<Layer> get availableLayers => _availableLayers;

  // ✅ Initialiser avec le service de cache
  void initialize(List<Layer> layers, {OfflineCacheService? cacheService}) {
    _availableLayers = List.from(layers);
    _layerStates = _createDefaultLayerStates(layers);
    _cacheService = cacheService;
    ensureBaseLayerActive();
  }

  List<LayerState> _createDefaultLayerStates(List<Layer> layers) {
    return layers.asMap().entries.map((entry) {
      final index = entry.key;
      final layer = entry.value;
      bool isActive = false;
      double opacity = 0.8;

      // Couche de base OpenStreetMap active par défaut
      if (layer.type == 'Fond de carte' && layer.nom == 'OpenStreetMap') {
        isActive = true;
        opacity = 1.0;
      }

      return LayerState(
        layer: layer,
        isActive: isActive,
        opacity: opacity,
        order: index,
      );
    }).toList();
  }

  // Mettre à jour les états des couches
  void updateLayerStates(List<LayerState> newStates) {
    _layerStates = newStates;
    ensureBaseLayerActive();
    notifyListeners();
  }

  // Activer/désactiver une couche
  void toggleLayer(String layerName, bool isActive) {
    final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerName);
    if (index != -1) {
      _layerStates[index] = _layerStates[index].copyWith(isActive: isActive);
      ensureBaseLayerActive();
      notifyListeners();
    }
  }

  // Modifier l'opacité d'une couche
  void setLayerOpacity(String layerName, double opacity) {
    final index = _layerStates.indexWhere((ls) => ls.layer.nom == layerName);
    if (index != -1) {
      _layerStates[index] = _layerStates[index].copyWith(opacity: opacity);
      notifyListeners();
    }
  }

  // Réorganiser l'ordre des couches
  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final LayerState item = _layerStates.removeAt(oldIndex);
    _layerStates.insert(newIndex, item);

    // Mettre à jour les indices d'ordre
    for (int i = 0; i < _layerStates.length; i++) {
      _layerStates[i] = _layerStates[i].copyWith(order: i);
    }

    notifyListeners();
  }

  // S'assurer qu'au moins une couche de base est active
  void ensureBaseLayerActive() {
    final baseLayers = _layerStates.where((ls) => ls.layer.type == 'Fond de carte').toList();
    final hasActiveBaseLayer = baseLayers.any((ls) => ls.isActive);

    if (!hasActiveBaseLayer && baseLayers.isNotEmpty) {
      // Activer OpenStreetMap par défaut
      final osmIndex = _layerStates.indexWhere(
              (ls) => ls.layer.type == 'Fond de carte' && ls.layer.nom == 'OpenStreetMap'
      );
      if (osmIndex != -1) {
        _layerStates[osmIndex] = _layerStates[osmIndex].copyWith(isActive: true);
      } else {
        // Activer la première couche de base disponible
        final firstBaseIndex = _layerStates.indexWhere((ls) => ls.layer.type == 'Fond de carte');
        if (firstBaseIndex != -1) {
          _layerStates[firstBaseIndex] = _layerStates[firstBaseIndex].copyWith(isActive: true);
        }
      }
    }
  }

  // Ajouter une nouvelle couche
  void addLayer(Layer layer, {bool isActive = false, double opacity = 0.8}) {
    final existingIndex = _availableLayers.indexWhere((l) => l.nom == layer.nom);

    if (existingIndex == -1) {
      // Ajouter la nouvelle couche
      _availableLayers.add(layer);
      final newLayerState = LayerState(
        layer: layer,
        isActive: isActive,
        opacity: opacity,
        order: _layerStates.length,
      );
      _layerStates.add(newLayerState);

      // ✅ Utiliser addPostFrameCallback pour éviter setState pendant build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // Supprimer une couche
  void removeLayer(String layerName) {
    _layerStates.removeWhere((ls) => ls.layer.nom == layerName);
    _availableLayers.removeWhere((layer) => layer.nom == layerName);

    // Réorganiser les ordres
    for (int i = 0; i < _layerStates.length; i++) {
      _layerStates[i] = _layerStates[i].copyWith(order: i);
    }

    notifyListeners();
  }

  // Réinitialiser aux couches par défaut
  void resetToDefault() {
    _layerStates = _createDefaultLayerStates(_availableLayers);
    notifyListeners();
  }

  // ✅ Générer les couches pour Flutter Map avec support offline
  List<Widget> generateMapLayers(BuildContext context, {bool showBadges = false}) {
    final activeLayers = _layerStates
        .where((ls) => ls.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    List<Widget> mapLayers = [];

    for (final layerState in activeLayers) {
      final layer = layerState.layer;

      // ✅ Couche de tuiles avec cache offline
      if (layer.type == 'Fond de carte') {
        mapLayers.add(_buildOfflineTileLayer(layer, layerState.opacity));
      }

      // Couches de marqueurs (données métier)
      else if (layer.type == 'Données métier') {
        final markers = layer.markerBuilder(context, showBadges: showBadges);
        if (markers.isNotEmpty) {
          mapLayers.add(_buildMarkerLayer(markers, layerState.opacity));
        }
      }

      // Couches de polygones
      else if (layer.type == 'Polygones') {
        final polygons = layer.polygonBuilder?.call(context) ?? [];
        if (polygons.isNotEmpty) {
          mapLayers.add(_buildPolygonLayer(polygons, layerState.opacity));
        }
      }

      // Couches de polylignes
      else if (layer.type == 'Polylignes') {
        final polylines = layer.polylineBuilder?.call(context) ?? [];
        if (polylines.isNotEmpty) {
          mapLayers.add(_buildPolylineLayer(polylines, layerState.opacity));
        }
      }
    }

    return mapLayers;
  }

  // ✅ Construction des couches de tuiles avec cache offline
  Widget _buildOfflineTileLayer(Layer layer, double opacity) {
    String urlTemplate;

    switch (layer.nom) {
      case 'OpenStreetMap':
        urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
        break;
      case 'Plan IGN':
        urlTemplate = 'https://wxs.ign.fr/cartes/geoportail/wmts?REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&STYLE=normal&TILEMATRIXSET=PM&FORMAT=image/png&LAYER=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}';
        break;
      case 'Photographies aériennes':
        urlTemplate = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        break;
      default:
        urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }

    // ✅ Utiliser la couche de tuiles offline
    return OfflineTileLayer(
      urlTemplate: urlTemplate,
      userAgentPackageName: 'com.boom.boom_mobile',
      maxZoom: 19,
      maxNativeZoom: 18,
      keepBuffer: 2,
      panBuffer: 1,
      additionalOptions: const {'retinaMode': 'true'},
      enableOfflineCache: _cacheService != null,
      errorTileWidget: _buildOfflineErrorTile(layer.nom),
    );
  }

  // Widget d'erreur personnalisé pour chaque type de couche
  Widget _buildOfflineErrorTile(String layerName) {
    IconData icon;
    String label;

    switch (layerName) {
      case 'Plan IGN':
        icon = Icons.map;
        label = 'Plan';
        break;
      case 'Photographies aériennes':
        icon = Icons.satellite_alt;
        label = 'Satellite';
        break;
      default:
        icon = Icons.map_outlined;
        label = 'Carte';
    }

    return Container(
      width: 256,
      height: 256,
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 30,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Méthodes d'optimisation pour les marqueurs v8
  Widget _buildMarkerLayer(List<Marker> markers, double opacity) {
    return MarkerLayer(
      markers: markers.map((marker) {
        return Marker(
          point: marker.point,
          width: marker.width,
          height: marker.height,
          alignment: marker.alignment ?? Alignment.center,
          child: Opacity(
            opacity: opacity,
            child: marker.child,
          ),
        );
      }).toList(),
    );
  }

  // ✅ Méthodes d'optimisation pour les polygones - CORRIGÉ
  Widget _buildPolygonLayer(List<Polygon> polygons, double opacity) {
    return PolygonLayer(
      polygons: polygons.map((polygon) {
        return Polygon(
          points: polygon.points,
          // ✅ Correction: utiliser withValues au lieu de withAlpha
          color: polygon.color?.withValues(alpha: polygon.color!.a * opacity) ??
              Colors.blue.withValues(alpha: 0.3 * opacity),
          borderColor: polygon.borderColor,
          borderStrokeWidth: polygon.borderStrokeWidth,
          label: polygon.label,
          // ✅ CORRECTION du problème labelStyle
          labelStyle: polygon.labelStyle ?? const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList(),
      // ✅ Optimisations de performance v8
      polygonCulling: true,
      simplificationTolerance: 0.5,
    );
  }

  // ✅ Méthodes d'optimisation pour les polylignes v8
  Widget _buildPolylineLayer(List<Polyline> polylines, double opacity) {
    return PolylineLayer(
      polylines: polylines.map((polyline) {
        return Polyline(
          points: polyline.points,
          strokeWidth: polyline.strokeWidth,
          color: polyline.color.withValues(alpha: polyline.color.a * opacity),
          pattern: polyline.pattern,
        );
      }).toList(),
    );
  }

  // ✅ Méthode pour créer un polygone compatible flutter_map v8
  Polygon createPolygon({
    required List<LatLng> points,
    Color? fillColor,
    Color? borderColor,
    double borderStrokeWidth = 1.0,
    String? label,
    TextStyle? labelStyle,
  }) {
    return Polygon(
      points: points,
      color: fillColor ?? Colors.blue.withValues(alpha: 0.3),
      borderColor: borderColor ?? Colors.blue,
      borderStrokeWidth: borderStrokeWidth,
      label: label,
      labelStyle: labelStyle ?? const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ✅ Méthode utilitaire pour vérifier si un polygone est rempli
  bool isPolygonFilled(Polygon polygon) {
    // Dans flutter_map v8, un polygone est considéré comme rempli
    // si il a une couleur de remplissage avec une opacité > 0
    return polygon.color != null && polygon.color!.a > 0;
  }

  // ✅ Méthode pour modifier la transparence d'un polygone
  Polygon setPolygonOpacity(Polygon polygon, double opacity) {
    return Polygon(
      points: polygon.points,
      color: polygon.color?.withValues(alpha: opacity),
      borderColor: polygon.borderColor,
      borderStrokeWidth: polygon.borderStrokeWidth,
      label: polygon.label,
      labelStyle: polygon.labelStyle ?? const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ✅ Méthodes pour le mode offline
  bool get hasOfflineCache => _cacheService != null;

  OfflineCacheService? get cacheService => _cacheService;

  Future<void> preloadLayerArea({
    required String layerName,
    required LatLng center,
    required double radiusKm,
    int minZoom = 10,
    int maxZoom = 16,
    Function(int current, int total)? onProgress,
  }) async {
    if (_cacheService == null) {
      debugPrint('❌ Service de cache non disponible');
      return;
    }

    final layer = _availableLayers.firstWhere(
          (l) => l.nom == layerName,
      orElse: () => throw Exception('Couche $layerName non trouvée'),
    );

    if (layer.type != 'Fond de carte') {
      debugPrint('❌ Seules les couches de fond de carte peuvent être pré-téléchargées');
      return;
    }

    String urlTemplate;
    switch (layerName) {
      case 'OpenStreetMap':
        urlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
        break;
      case 'Plan IGN':
        urlTemplate = 'https://wxs.ign.fr/cartes/geoportail/wmts?REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&STYLE=normal&TILEMATRIXSET=PM&FORMAT=image/png&LAYER=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&TILEMATRIX={z}&TILEROW={y}&TILECOL={x}';
        break;
      case 'Photographies aériennes':
        urlTemplate = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        break;
      default:
        throw Exception('Type de couche non supporté pour le pré-téléchargement');
    }

    await _cacheService!.preloadArea(
      center: center,
      radiusKm: radiusKm,
      minZoom: minZoom,
      maxZoom: maxZoom,
      tileUrlTemplate: urlTemplate,
      onProgress: onProgress,
    );
  }

  Future<Map<String, dynamic>> getOfflineStats() async {
    if (_cacheService == null) return {};
    return await _cacheService!.getCacheStats();
  }

  Future<void> clearOfflineCache() async {
    if (_cacheService == null) return;
    await _cacheService!.clearCache();
  }


  // Obtenir les statistiques des couches
  Map<String, dynamic> getLayerStatistics() {
    final totalLayers = _layerStates.length;
    final activeLayers = _layerStates.where((ls) => ls.isActive).length;
    final layersByType = <String, int>{};

    for (final layerState in _layerStates) {
      final type = layerState.layer.type;
      layersByType[type] = (layersByType[type] ?? 0) + 1;
    }

    return {
      'totalLayers': totalLayers,
      'activeLayers': activeLayers,
      'inactiveLayers': totalLayers - activeLayers,
      'layersByType': layersByType,
      'averageOpacity': totalLayers > 0 ? _layerStates.fold(0.0, (sum, ls) => sum + ls.opacity) / totalLayers : 0.0,
    };
  }

}