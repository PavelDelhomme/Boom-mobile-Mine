import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster_plus/flutter_map_marker_cluster_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/station.dart';
import '../../../../services/layer_service.dart';
import '../../../../services/draw_service.dart';

class MapView extends StatefulWidget {
  final LatLng center;
  final List<Marker> markers;
  final Function(LatLng)? onTap;
  final bool enableDrawing;
  final Station? selectedStation;
  final MapController? mapController;

  const MapView({
    super.key,
    required this.center,
    required this.markers,
    this.onTap,
    this.enableDrawing = false,
    this.selectedStation,
    this.mapController,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController _mapController;

  // Position utilisateur
  LatLng? _userLocation;
  bool _followUserLocation = false;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
    _checkLocationPermissions();
  }

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Gérer les changements de mode d'édition
    if (widget.enableDrawing != oldWidget.enableDrawing) {
      if (!widget.enableDrawing) {
        // Désactiver le mode dessin
        context.read<DrawService>().setTool(DrawTool.none);
      }
    }
  }

  // Gestion des permissions de géolocalisation
  Future<void> _checkLocationPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _hasLocationPermission = true;
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Erreur géolocalisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LayerService, DrawService>(
      builder: (context, layerService, drawService, child) {
        final layers = layerService.generateMapLayers(context, showBadges: true);

        return Stack(
          children: [
            // Carte Flutter Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.center,
                initialZoom: 13.0,
                initialRotation: 0.0,
                minZoom: 3,
                maxZoom: 19,

                // Contraintes de caméra
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    LatLng(-85.05, -180.0),
                    LatLng(85.05, 180.0),
                  ),
                ),

                // Interactions optimisées
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.scrollWheelZoom |
                  InteractiveFlag.doubleTapZoom |
                  InteractiveFlag.flingAnimation,
                  scrollWheelVelocity: 0.005,
                  pinchZoomThreshold: 0.4,
                  rotationThreshold: 20.0,
                ),

                // Gestion des événements selon le mode
                onTap: (tapPosition, point) => _handleMapTap(point, drawService),
                onLongPress: (tapPosition, point) => _handleMapLongPress(point, drawService),
                onPositionChanged: _handlePositionChanged,
              ),
              children: [
                // 1. Couches générées par LayerService (fond de carte)
                ...layers,

                // 2. Couches de géométries par ordre de priorité
                ..._buildGeometryLayers(drawService),

                // 3. Couches de marqueurs avec CLUSTERING
                ..._buildMarkerLayers(drawService),

                // 4. Position utilisateur
                if (_hasLocationPermission && _userLocation != null)
                  _buildCurrentLocationLayer(),

                // 5. Station sélectionnée
                if (widget.selectedStation != null)
                  _buildSelectedStationMarker(),

                // 6. Attributions
                _buildAttributionLayer(),
              ],
            ),

            // Interface d'édition
            if (widget.enableDrawing)
              _buildEditingToolbar(drawService),
          ],
        );
      },
    );
  }

  // Gestion des événements de tap
  void _handleMapTap(LatLng point, DrawService drawService) {
    if (widget.enableDrawing && drawService.currentTool != DrawTool.none) {
      drawService.handleMapTap(point);
    } else {
      widget.onTap?.call(point);
    }
  }

  void _handleMapLongPress(LatLng point, DrawService drawService) {
    if (widget.enableDrawing) {
      drawService.handleMapLongPress(point);
    }
  }

  void _handlePositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture && _followUserLocation) {
      setState(() => _followUserLocation = false);
    }
  }

  // Construction des couches de géométries
  List<Widget> _buildGeometryLayers(DrawService drawService) {
    return [
      // Polygones
      PolygonLayer(
        polygons: drawService.getPolygons(),
        polygonCulling: true,
        simplificationTolerance: 0.5,
      ),

      // Polylignes
      PolylineLayer(
        polylines: drawService.getPolylines(),
      ),
    ];
  }

  // Construction des couches de marqueurs
  List<Widget> _buildMarkerLayers(DrawService drawService) {
    return [
      // Clustering avec le design original
      MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          markers: widget.markers,
          maxClusterRadius: 45,
          size: const Size(40, 40),
          rotate: false,
          zoomToBoundsOnClick: true,
          builder: (context, clusterMarkers) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF3EAF6E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                clusterMarkers.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),

      // Points dessinés (au-dessus des clusters)
      MarkerLayer(
        markers: drawService.getPointMarkers(),
      ),
    ];
  }

  // Couche de position utilisateur
  Widget _buildCurrentLocationLayer() {
    return CurrentLocationLayer(
      alignPositionOnUpdate: _followUserLocation
          ? AlignOnUpdate.always
          : AlignOnUpdate.never,
      alignDirectionOnUpdate: AlignOnUpdate.never,
      style: LocationMarkerStyle(
        marker: const DefaultLocationMarker(
          child: Icon(
            Icons.navigation,
            color: Colors.white,
            size: 20,
          ),
        ),
        markerSize: const Size(40, 40),
        showAccuracyCircle: true,
        accuracyCircleColor: const Color(0xFF3EAF6E).withOpacity(0.2),
      ),
    );
  }

  // Couche station sélectionnée
  Widget _buildSelectedStationMarker() {
    if (widget.selectedStation == null) return const SizedBox.shrink();

    final station = widget.selectedStation!;
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 80,
          height: 80,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3EAF6E).withOpacity(0.3),
              border: Border.all(color: const Color(0xFF3EAF6E), width: 3),
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF3EAF6E),
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  // Barre d'outils d'édition
  Widget _buildEditingToolbar(DrawService drawService) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildModeButton('Point', DrawTool.point, Icons.place, drawService),
            _buildModeButton('Ligne', DrawTool.line, Icons.timeline, drawService),
            _buildModeButton('Polygone', DrawTool.polygon, Icons.crop_free, drawService),
            _buildModeButton('Éditer', DrawTool.edit, Icons.edit, drawService),
            _buildActionButton('Annuler', Icons.undo, () => drawService.undo()),
            _buildActionButton('Effacer', Icons.clear, () => drawService.clearAll()),
          ],
        ),
      ),
    );
  }
  void clearAll(DrawService drawService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer tout'),
        content: const Text('Voulez-vous vraiment effacer tous les dessins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              drawService.clearAll(); // Utilise la méthode que nous avons ajoutée
            },
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  void undo(DrawService drawService) {
    drawService.undo(); // Utilise la méthode que nous avons ajoutée
  }

  Widget _buildModeButton(String label, DrawTool tool, IconData icon, DrawService drawService) {
    final isActive = drawService.currentTool == tool;
    return GestureDetector(
      onTap: () => drawService.setTool(tool),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3EAF6E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // Couche d'attribution
  Widget _buildAttributionLayer() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
          ),
        ),
        child: const Text(
          '© OpenStreetMap, Esri',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  // Méthodes publiques pour le contrôle externe
  void moveToLocation(LatLng location, {double zoom = 15}) {
    _mapController.move(location, zoom);
  }

  void centerOnUserLocation() {
    if (_userLocation != null) {
      setState(() => _followUserLocation = true);
      _mapController.move(_userLocation!, 16);
    }
  }

  void clearDrawing() {
    context.read<DrawService>().clearAll();
  }

  // Getters pour récupérer les géométries créées
  List<LatLng> getDrawnPoints() => context.read<DrawService>().points;
  List<Polyline> getDrawnLines() => context.read<DrawService>().polylines;
  List<Polygon> getDrawnPolygons() => context.read<DrawService>().polygons;

  // Informations sur l'état d'édition
  DrawTool get currentEditingMode => context.read<DrawService>().currentTool;
  bool get hasUnsavedChanges =>
      context.read<DrawService>().points.isNotEmpty ||
          context.read<DrawService>().polylines.isNotEmpty ||
          context.read<DrawService>().polygons.isNotEmpty;
}

// todo ANCIENNES VERSION BONNE EN AFFICHAGE MAIS PAS EN FONCTIONNALITE ET PAS TOUS LES AFFICHAGE
/*
class MapView extends StatelessWidget {
  final LatLng center;
  final List<Marker> markers;

  const MapView({
    super.key,
    required this.center,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            markers: markers,
            maxClusterRadius: 45,
            size: const Size(40, 40),
            rotate: false, //todo A voir si utilise ou pas permet de faire en sorte que le contenu rest horizontal
            zoomToBoundsOnClick: true, // Quand on clique sur un cluster groupant plusieurs stations, la carte zoom automatiquement pour les afficher tous
            builder: (context, clusterMarkers) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4)
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  clusterMarkers.length.toString(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          )
        )
      ],
    );
  }
}
*/


// TODO VERSION RECUPERE AILLEUR MAIS PAS DESIGNER CORRECTEMENT
/*
class MapView extends StatefulWidget {
  final LatLng center;
  final List<Marker> markers;
  final Function(LatLng)? onTap;
  final bool enableDrawing;
  final Station? selectedStation;
  final MapController? mapController;

  const MapView({
    super.key,
    required this.center,
    required this.markers,
    this.onTap,
    this.enableDrawing = false,
    this.selectedStation,
    this.mapController,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late MapController _mapController;

  // ✅ Gestion des modes d'édition v8
  EditingMode _currentMode = EditingMode.none;
  List<LatLng> _currentPath = [];

  // ✅ Collections pour les différents types de géométries
  List<Marker> _drawnMarkers = [];
  List<Polyline> _drawnLines = [];
  List<Polygon> _drawnPolygons = [];

  // ✅ Position utilisateur
  LatLng? _userLocation;
  bool _followUserLocation = false;
  bool _hasLocationPermission = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
    _checkLocationPermissions();

    // ✅ Initialiser le mode d'édition si nécessaire
    if (widget.enableDrawing) {
      _currentMode = EditingMode.addingPoints;
    }
  }

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ Gérer les changements de mode d'édition
    if (widget.enableDrawing != oldWidget.enableDrawing) {
      setState(() {
        _currentMode = widget.enableDrawing ? EditingMode.addingPoints : EditingMode.none;
        if (!widget.enableDrawing) {
          _currentPath.clear();
        }
      });
    }
  }

  // ✅ Gestion des permissions de géolocalisation
  Future<void> _checkLocationPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _hasLocationPermission = true;
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Erreur géolocalisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LayerService>(
      builder: (context, layerService, child) {
        return Stack(
          children: [
            // ✅ Carte Flutter Map v8
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.center,
                initialZoom: 13.0, // ✅ Zoom par défaut fixe
                initialRotation: 0.0, // ✅ Rotation par défaut fixe
                minZoom: 3,
                maxZoom: 19,

                // ✅ Contraintes de caméra
                cameraConstraint: CameraConstraint.contain(
                  bounds: LatLngBounds(
                    LatLng(-85.05, -180.0),
                    LatLng(85.05, 180.0),
                  ),
                ),

                // ✅ Nouvelle syntaxe v8 - pas de enableScrollWheel !
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.scrollWheelZoom |
                  InteractiveFlag.doubleTapZoom |
                  InteractiveFlag.flingAnimation,

                  // ✅ Contrôles précis des interactions
                  scrollWheelVelocity: 0.005,
                  pinchZoomThreshold: 0.4,
                  rotationThreshold: 20.0,
                ),

                // ✅ Gestion des événements selon le mode
                onTap: widget.enableDrawing ? _handleDrawingTap : _handleRegularTap,
                onLongPress: _handleLongPress,
                onPositionChanged: _handlePositionChanged,
              ),

              children: [
                // ✅ 1. TileLayer TOUJOURS EN PREMIER (obligatoire v8)
                ..._buildBaseTileLayers(layerService),

                // ✅ 2. Couches de géométries par ordre de priorité
                ..._buildGeometryLayers(),

                // ✅ 3. Couches de marqueurs
                ..._buildMarkerLayers(),

                // ✅ 4. Position utilisateur
                if (_hasLocationPermission && _userLocation != null)
                  _buildCurrentLocationLayer(),

                // ✅ 5. Station sélectionnée
                if (widget.selectedStation != null)
                  _buildSelectedStationLayer(),

                // ✅ 6. Couches d'édition (mode dessin)
                if (widget.enableDrawing)
                  ..._buildEditingLayers(),

                // ✅ 7. Attributions (toujours en dernier)
                _buildAttributionLayer(),
              ],
            ),

            // ✅ Interface d'édition
            if (widget.enableDrawing)
              _buildEditingToolbar(),
          ],
        );
      },
    );
  }

  // ✅ Construction des TileLayers de base (toujours en premier)
  List<Widget> _buildBaseTileLayers(LayerService layerService) {
    final activeLayers = layerService.activeLayers
        .where((ls) => ls.layer.type == 'Fond de carte')
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (activeLayers.isEmpty) {
      // ✅ TileLayer par défaut si aucune couche de base active
      return [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.boom.boom_mobile',
          maxNativeZoom: 18,     // ✅ Limite zoom natif
          keepBuffer: 2,         // ✅ Cache intelligent
          panBuffer: 1,          // ✅ Buffer panoramique
          additionalOptions: {
            'retinaMode': 'true', // ✅ Support haute résolution
          },
        ),
      ];
    }

    return activeLayers.map((layerState) {
      final layer = layerState.layer;
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

      return TileLayer(
        urlTemplate: urlTemplate,
        userAgentPackageName: 'com.boom.boom_mobile',
        maxZoom: 19,
        maxNativeZoom: 18,     // ✅ Limite zoom natif
        keepBuffer: 2,         // ✅ Cache intelligent
        panBuffer: 1,          // ✅ Buffer panoramique
        additionalOptions: {
          'retinaMode': 'true', // ✅ Support haute résolution
        },
      );
    }).toList();
  }

  // ✅ Construction des couches de géométries v8
  List<Widget> _buildGeometryLayers() {
    return [
      // ✅ Polygones dessinés
      if (_drawnPolygons.isNotEmpty)
        PolygonLayer(
          polygons: _drawnPolygons,
          polygonCulling: true,        // ✅ Culling automatique
          simplificationTolerance: 0.5, // ✅ Simplification formes
        ),

      // ✅ Lignes dessinées
      if (_drawnLines.isNotEmpty)
        PolylineLayer(
          polylines: _drawnLines,
        ),
    ];
  }

  // ✅ Construction des couches de marqueurs v8
  List<Widget> _buildMarkerLayers() {
    return [
      // ✅ Marqueurs des stations
      MarkerLayer(markers: widget.markers),

      // ✅ Marqueurs dessinés
      if (_drawnMarkers.isNotEmpty)
        MarkerLayer(markers: _drawnMarkers),
    ];
  }

  // ✅ Couche de position utilisateur v8
  Widget _buildCurrentLocationLayer() {
    return CurrentLocationLayer(
      alignPositionOnUpdate: _followUserLocation
          ? AlignOnUpdate.always
          : AlignOnUpdate.never,
      alignDirectionOnUpdate: AlignOnUpdate.never,
      style: LocationMarkerStyle(
        marker: DefaultLocationMarker(
          child: const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 20,
          ),
        ),
        markerSize: const Size(40, 40),
        showAccuracyCircle: true,
      ),
    );
  }

  // ✅ Couche station sélectionnée
  Widget _buildSelectedStationLayer() {
    final station = widget.selectedStation!;
    return MarkerLayer(
      markers: [
        Marker(
          point: LatLng(station.latitude, station.longitude),
          width: 80,
          height: 80,
          alignment: Alignment.center, // ✅ Nouveau paramètre v8
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.3),
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Couches d'édition pour le mode dessin
  List<Widget> _buildEditingLayers() {
    List<Widget> layers = [];

    // ✅ Chemin en cours de création
    if (_currentPath.isNotEmpty) {
      switch (_currentMode) {
        case EditingMode.addingLines:
          layers.add(
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _currentPath,
                  strokeWidth: 3,
                  color: Colors.red.withValues(alpha: 0.8),
                  pattern: StrokePattern.dotted(),
                ),
              ],
            ),
          );
          break;
        case EditingMode.addingPolygons:
          if (_currentPath.length >= 2) {
            layers.add(
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _currentPath,
                    strokeWidth: 3,
                    color: Colors.red.withValues(alpha: 0.8),
                    pattern: StrokePattern.dotted(),
                  ),
                ],
              ),
            );
          }
          break;
        default:
          break;
      }

      // ✅ Points du chemin en cours
      layers.add(
        MarkerLayer(
          markers: _currentPath.map((point) => Marker(
            point: point,
            width: 16,
            height: 16,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          )).toList(),
        ),
      );
    }

    return layers;
  }

  // ✅ Barre d'outils d'édition v8
  Widget _buildEditingToolbar() {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildModeButton('Point', EditingMode.addingPoints, Icons.place),
            _buildModeButton('Ligne', EditingMode.addingLines, Icons.timeline),
            _buildModeButton('Polygone', EditingMode.addingPolygons, Icons.crop_free),
            _buildActionButton('Finir', Icons.check, _completeCurrent),
            _buildActionButton('Effacer', Icons.clear, _clearAll),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, EditingMode mode, IconData icon) {
    final isActive = _currentMode == mode;
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Couche d'attribution v8
  Widget _buildAttributionLayer() {
    return RichAttributionWidget(
      attributions: [
        TextSourceAttribution(
          '© OpenStreetMap',
          onTap: () => debugPrint('OSM attribution tapped'),
        ),
        TextSourceAttribution('© Esri'),
      ],
      alignment: AttributionAlignment.bottomRight,
    );
  }

  // ✅ Gestion des événements de tap v8
  void _handleRegularTap(TapPosition tapPosition, LatLng point) {
    widget.onTap?.call(point);
  }

  void _handleDrawingTap(TapPosition tapPosition, LatLng point) {
    if (!widget.enableDrawing || _currentMode == EditingMode.none) {
      _handleRegularTap(tapPosition, point);
      return;
    }

    setState(() {
      switch (_currentMode) {
        case EditingMode.addingPoints:
          _addPoint(point);
          break;
        case EditingMode.addingLines:
          _addLinePoint(point);
          break;
        case EditingMode.addingPolygons:
          _addPolygonPoint(point);
          break;
        default:
          break;
      }
    });
  }

  void _handleLongPress(TapPosition tapPosition, LatLng point) {
    if (_currentMode == EditingMode.addingLines || _currentMode == EditingMode.addingPolygons) {
      _completeCurrent();
    }
  }

  void _handlePositionChanged(MapCamera camera, bool hasGesture) {
    if (hasGesture && _followUserLocation) {
      setState(() => _followUserLocation = false);
    }
  }

  // ✅ Méthodes d'édition v8
  void _setMode(EditingMode mode) {
    setState(() {
      _currentMode = mode;
      _currentPath.clear();
    });
  }

  void _addPoint(LatLng point) {
    _drawnMarkers.add(
      Marker(
        point: point,
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _editMarker(point),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    );

    debugPrint('Point ajouté: ${point.latitude}, ${point.longitude}');
  }

  void _addLinePoint(LatLng point) {
    _currentPath.add(point);
    debugPrint('Point ligne ajouté: ${point.latitude}, ${point.longitude}');
  }

  void _addPolygonPoint(LatLng point) {
    _currentPath.add(point);
    debugPrint('Point polygone ajouté: ${point.latitude}, ${point.longitude}');
  }

  void _completeCurrent() {
    if (_currentPath.isEmpty) return;

    setState(() {
      switch (_currentMode) {
        case EditingMode.addingLines:
          if (_currentPath.length >= 2) {
            _drawnLines.add(
              Polyline(
                points: List.from(_currentPath),
                strokeWidth: 3,
                color: Colors.blue,
              ),
            );
          }
          break;
        case EditingMode.addingPolygons:
          if (_currentPath.length >= 3) {
            _drawnPolygons.add(
              Polygon(
                points: List.from(_currentPath),
                color: Colors.blue.withValues(alpha: 0.3),
                borderColor: Colors.blue,
                borderStrokeWidth: 2,
              ),
            );
          }
          break;
        default:
          break;
      }
      _currentPath.clear();
    });
  }

  void _clearAll() {
    setState(() {
      _drawnMarkers.clear();
      _drawnLines.clear();
      _drawnPolygons.clear();
      _currentPath.clear();
    });
  }

  void _editMarker(LatLng point) {
    // ✅ Logique d'édition de marqueur
    debugPrint('Édition du marqueur: ${point.latitude}, ${point.longitude}');
  }


  // ✅ Méthodes publiques pour le contrôle externe
  void moveToLocation(LatLng location, {double zoom = 15}) {
    _mapController.move(location, zoom);
  }

  void centerOnUserLocation() {
    if (_userLocation != null) {
      setState(() => _followUserLocation = true);
      _mapController.move(_userLocation!, 16);
    }
  }

  void clearDrawing() {
    _clearAll();
  }

  // ✅ Getters pour récupérer les géométries créées
  List<LatLng> getDrawnPoints() => _drawnMarkers.map((m) => m.point).toList();
  List<Polyline> getDrawnLines() => List.from(_drawnLines);
  List<Polygon> getDrawnPolygons() => List.from(_drawnPolygons);

  // ✅ Informations sur l'état d'édition
  EditingMode get currentEditingMode => _currentMode;
  bool get hasUnsavedChanges => _drawnMarkers.isNotEmpty ||
      _drawnLines.isNotEmpty ||
      _drawnPolygons.isNotEmpty ||
      _currentPath.isNotEmpty;
}*/