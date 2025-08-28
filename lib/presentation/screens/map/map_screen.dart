// map_screen.dart corrigé avec AppData.stations
import 'package:boom_mobile/core/widgets/nav/nav_item.dart';
import 'package:boom_mobile/data/interfaces/draw_service_interface.dart';
import 'package:boom_mobile/data/services/layer_service.dart';
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/station_details_panel.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/map_editor.dart';
import 'package:boom_mobile/data/services/draw_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:boom_mobile/presentation/screens/map/widgets/filters/map_filter_tags.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/map_floating_buttons_left.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/map_floating_buttons_right.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/map_bottom_nav.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/map_drawer.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/map_top_bar.dart';
import 'package:boom_mobile/domain/entities/dossier.dart';
import 'package:boom_mobile/core/widgets/loaders/boom_loader.dart';
import 'package:boom_mobile/presentation/screens/accueil/accueil_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_data.dart';

class MapScreen extends StatefulWidget {
  final Dossier dossier;

  const MapScreen({super.key, required this.dossier});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _currentIndex = 1;
  final _mapController = MapController();
  late LayerService _layerService;
  Future<List<Marker>>? _markersFuture;
  LatLng? _userPosition;
  List<String> _activeFilters = [];
  bool _isMapReady = false;

  // Gestion du mode dessin et édition
  bool _drawingMode = false;
  Station? _selectedStation;
  bool _showMapEditor = false;

  // Timer pour différencier tap et long press
  DateTime? _lastTapTime;
  static const Duration _doubleTapTimeout = Duration(milliseconds: 300);
  static const Duration _longPressDelay = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _layerService = LayerService();
    _initializeMap();
  }

  void _initializeMap() async {
    // Utiliser les vraies méthodes de votre LayerService
    _layerService.initialize(AppData.layers);
    _markersFuture = _buildMarkers();
    setState(() {
      _isMapReady = true;
    });
  }

  Future<List<Marker>> _buildMarkers() async {
    final stationService = context.read<StationService>();

    // ✅ CORRIGÉ: Utilise maintenant AppData.stations qui existe
    final stations = AppData.stations;

    return stations.map((station) {
      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => _handleStationTap(station),
          onLongPress: () => _handleStationLongPress(station),
          child: Container(
            decoration: BoxDecoration(
              color: _selectedStation?.numeroStation == station.numeroStation
                  ? Colors.orange
                  : Colors.blue,
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
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  void _handleStationTap(Station station) {
    if (_drawingMode) {
      // En mode dessin, sélectionner la station pour l'édition
      _toggleDrawingMode(station);
    } else {
      // Mode normal: afficher les détails
      _showStationDetails(station);
    }
  }

  void _handleStationLongPress(Station station) {
    // Long press: ouvrir le menu contextuel ou basculer en mode édition
    _showStationContextMenu(station);
  }

  void _showStationContextMenu(Station station) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Voir les détails'),
                onTap: () {
                  Navigator.pop(context);
                  _showStationDetails(station);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_location),
                title: const Text('Éditer la géométrie'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleDrawingMode(station);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Ouvrir l\'éditeur de carte'),
                onTap: () {
                  Navigator.pop(context);
                  _openMapEditor(station);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStationDetails(Station station) {
    setState(() {
      _selectedStation = station;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationDetailsPanel(
        station: station,
        onEditGeometry: () {
          Navigator.pop(context);
          _toggleDrawingMode(station);
        },
      ),
    );
  }

  void _openMapEditor(Station station) {
    final drawService = context.read<DrawService>();
    drawService.setCurrentStation(station);
    setState(() {
      _selectedStation = station;
      _showMapEditor = true;
    });
  }

  void _toggleDrawingMode(Station? station) {
    final drawService = context.read<DrawService>();

    setState(() {
      _drawingMode = !_drawingMode;
      _selectedStation = station;
    });

    if (_drawingMode && station != null) {
      drawService.setCurrentStation(station);
      drawService.setTool(DrawTool.point);
      drawService.enableEditMode();
    } else {
      drawService.setTool(DrawTool.none);
      drawService.disableEditMode();
      drawService.setCurrentStation(null);
    }
  }

  // Gestion des interactions tactiles sur la carte
  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    final drawService = context.read<DrawService>();
    final now = DateTime.now();

    // Détection du double tap
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < _doubleTapTimeout) {
      _handleMapDoubleTap(point);
      _lastTapTime = null;
      return;
    }

    _lastTapTime = now;

    // Délai pour vérifier si c'est un long press
    Future.delayed(_longPressDelay, () {
      if (_lastTapTime == now) {
        _handleMapSingleTap(point);
        _lastTapTime = null;
      }
    });
  }

  void _handleMapSingleTap(LatLng point) {
    final drawService = context.read<DrawService>();

    if (_drawingMode) {
      // Mode dessin: ajouter ou sélectionner un point
      if (drawService.currentTool == DrawTool.point) {
        if (drawService.editMode) {
          // Vérifier si on tap sur un point existant
          if (!drawService.handlePointTap(point)) {
            // Ajouter un nouveau point
            drawService.addPoint(point);
            if (_selectedStation != null) {
              final stationService = context.read<StationService>();
              stationService.addPointToStation(_selectedStation!, point);
            }
          }
        } else {
          // Mode ajout simple
          drawService.addPoint(point);
          if (_selectedStation != null) {
            final stationService = context.read<StationService>();
            stationService.addPointToStation(_selectedStation!, point);
          }
        }
      } else {
        // Autres outils de dessin
        drawService.handleTap(point);
      }
    } else {
      // Mode normal: vérifier s'il y a une station à proximité
      _handleNormalMapTap(point);
    }
  }

  void _handleMapDoubleTap(LatLng point) {
    final drawService = context.read<DrawService>();

    if (_drawingMode) {
      drawService.handleDoubleTap(point);
    }
  }

  void _handleMapLongPress(TapPosition tapPosition, LatLng point) {
    final drawService = context.read<DrawService>();

    if (_drawingMode) {
      drawService.handleLongPress(point);
    } else {
      // En mode normal, long press pour entrer en mode édition rapide
      _showQuickEditMenu(point);
    }
  }

  void _handleNormalMapTap(LatLng point) {
    // ✅ CORRIGÉ: Utilise maintenant AppData.stations qui existe
    final stations = AppData.stations;

    for (final station in stations) {
      final stationPoint = LatLng(station.latitude, station.longitude);
      final distance = _calculateDistance(point, stationPoint);

      if (distance < 50) { // 50 mètres de tolérance
        _handleStationTap(station);
        return;
      }
    }

    // Aucune station trouvée, désélectionner
    setState(() {
      _selectedStation = null;
    });
  }

  void _showQuickEditMenu(LatLng point) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_location),
                title: const Text('Ajouter une station ici'),
                onTap: () {
                  Navigator.pop(context);
                  _createStationAt(point);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Mode édition'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleDrawingMode(null);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _createStationAt(LatLng point) {
    // TODO: Implémenter la création d'une nouvelle station
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité de création de station à implémenter')),
    );
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude, point1.longitude,
      point2.latitude, point2.longitude,
    );
  }

  void _saveChanges() {
    final stationService = context.read<StationService>();
    final drawService = context.read<DrawService>();

    if (_selectedStation != null) {
      stationService.updateStation(
        _selectedStation!,
        points: drawService.points,
        lignes: drawService.lines,
        polygones: drawService.polygons,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modifications sauvegardées'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildMapWithLayers() {
    final drawService = context.read<DrawService>();

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(48.8566, 2.3522),
        initialZoom: 13.0,
        onTap: _handleMapTap,
        onLongPress: _handleMapLongPress,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // Couche de tuiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.boom.boom_mobile',
        ),

        // Couches du LayerService - utiliser la vraie méthode
        ..._layerService.generateMapLayers(context),

        // Polygones
        if (drawService.getPolygons().isNotEmpty)
          PolygonLayer(
            polygons: drawService.getPolygons(),
            polygonCulling: true,
            simplificationTolerance: 0.5,
          ),

        // Polylignes
        if (drawService.getPolylines().isNotEmpty)
          PolylineLayer(
            polylines: drawService.getPolylines(),
          ),

        // Marqueurs de stations
        if (_markersFuture != null)
          FutureBuilder<List<Marker>>(
            future: _markersFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return MarkerLayer(markers: snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),

        // Marqueurs de points dessinés
        if (drawService.getPointMarkers().isNotEmpty)
          MarkerLayer(
            markers: drawService.getPointMarkers(),
          ),

        // Marqueurs d'édition
        if (drawService.getEditVertexMarkers().isNotEmpty)
          MarkerLayer(
            markers: drawService.getEditVertexMarkers(),
          ),
      ],
    );
  }

  final List<NavItem> _navItems = [
    NavItem(label: "Accueil", icon: Icons.home),
    NavItem(label: "Carte", icon: Icons.map),
    NavItem(label: "Couches", icon: Icons.layers),
    NavItem(label: "Profil", icon: Icons.person),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AccueilScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMapReady) {
      return const Scaffold(
        body: Center(child: BoomLoader()),
      );
    }

    return Scaffold(
      drawer: const MapDrawer(),
      body: Stack(
        children: [
          // Carte principale
          _buildMapWithLayers(),

          // Barre du haut
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: const MapTopBar(title: "Carte")
          ),

          // Tags de filtres
          Positioned(
            top: 85,
            left: 0,
            right: 0,
            child: MapFilterTags(
              onFiltersChanged: (filters) {
                setState(() {
                  _activeFilters = filters;
                });
              },
            ),
          ),

          // Éditeur de carte (si activé)
          if (_showMapEditor)
            Positioned.fill(
              child: MapEditor(
                station: _selectedStation,
                onClose: () {
                  setState(() {
                    _showMapEditor = false;
                  });
                },
                onSave: _saveChanges,
              ),
            ),

          // Barre d'état du mode dessin
          if (_drawingMode)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStation != null
                          ? "Édition de la station ${_selectedStation!.numeroStation}"
                          : "Mode dessin activé",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save, color: Colors.white),
                          onPressed: _saveChanges,
                          tooltip: 'Sauvegarder',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => _toggleDrawingMode(null),
                          tooltip: 'Fermer',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Boutons flottants
          const MapFloatingButtonsLeft(),
          const MapFloatingButtonsRight(),

          // Informations des couches actives
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  "${_layerService.activeLayers.length}/${_layerService.availableLayers.length} couches actives",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MapBottomNav(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              navItems: _navItems,
            ),
          ],
        ),
      ),
    );
  }
}