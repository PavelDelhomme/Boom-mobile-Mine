/*import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/widgets/nav/nav_item.dart';
import 'package:boom_mobile/domain/entities/layer.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_layers_panel.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/station_details_panel.dart';
import 'package:boom_mobile/services/draw_service.dart';
import 'package:boom_mobile/services/layer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

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
  List<String> _activeFilters = []; // ← Ajout pour gérer les filtres
  bool _isMapReady = false;

  List<NavItem> get _navItems => [
    NavItem(
      label: 'Accueil',
      icon: Icons.home_outlined,
      isEnabled: true,
      isVisible: true,
    ),
    NavItem(
      label: 'Cartographie',
      assetPath: kNavMap,
      useAsset: true,
      isEnabled: true,
      isVisible: true,
    ),
    NavItem(
      label: 'Interventions',
      assetPath: kNavIntervention,
      useAsset: true,
      isEnabled: true,
      isVisible: true,
    ),
    NavItem(
      label: 'Utilisateurs',
      assetPath: kNavUser,
      useAsset: true,
      isEnabled: true,
      isVisible: true,
    ),
  ];

  final Map<LatLng, Station> _stationMap = {};

  @override
  void initState() {
    super.initState();
    _initializeServices();
    //_markersFuture = _loadInitialMarkers();
    _getUserPosition();
  }

  void _initializeServices() {
    // Récupération de LayerService depuis le Provider
    _layerService = context.read<LayerService>();

    // Ajouter la couche spécifique au dossier dynamiquement
    _layerService.addLayer(
      Layer(
        nom: 'Stations ${widget.dossier.nom}',
        type: 'Données métier',
        date: widget.dossier.date,
        center: widget.dossier.center,
        markerBuilder: widget.dossier.markerBuilder,
      ),
      isActive: true,
      opacity: 1.0,
    );

    // S'assurer qu'une couche de base est active
    _layerService.ensureBaseLayerActive();

    setState(() {
      _isMapReady = true;
    });
  }


  Future<List<Marker>> _loadMarkers(BuildContext context, {bool showBadges = false}) async {
    // Appel avec contexte et paramètre showBadges
    final markers = widget.dossier.markerBuilder(context, showBadges: showBadges);

    // Filtrage des marqueurs selon les filtres actifs
    final filteredMarkers = _applyFilters(markers);

    return filteredMarkers;
  }

  // Méthode pour appliquer les filtres
  List<Marker> _applyFilters(List<Marker> markers) {
    if (_activeFilters.isEmpty) return markers;

    _buildStationMap(markers);

    return markers.where((marker) {
      final station = _getStationFromMarker(marker);
      if (station == null) return true;

      //todo Logique de filtrage selon les filtres actifs
      for (final filterId in _activeFilters) {
        switch (filterId) {
          case 'stations':
            return true; // Toutes les stations
          case 'sanitaire':
          // Exemple : filtrer les stations en bon état
            return station.highlight == true; // Adaptez selon votre logique
          case 'intervention':
            return station.treesToCut != null || station.warning != null;
          case 'protection':
            return station.meriteProtection == true;
        // Ajoutez d'autres filtres selon vos besoins
        }
      }
      return true;
    }).toList();
  }

  void _buildStationMap(List<Marker> markers) {
    _stationMap.clear();
    for (int i = 0; i < markers.length && i < widget.dossier.stations.length; i++) {
      _stationMap[markers[i].point] = widget.dossier.stations[i];
    }
  }


  Station? _getStationFromMarker(Marker marker) {
    //return _stationMap[marker.point];
    return Station(
      numeroStation: _stationMap.length + 1, // ID Unique
      latitude: marker.point.latitude,
      longitude: marker.point.longitude,
      treesToCut: 0, // Valeur par défaut
      warning: null,
      highlight: false,
    );
  }

  Future<void> _getUserPosition() async {
    final position = await _getCurrentPosition();
    if (mounted) {
      setState(() => _userPosition = position);
    }
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccueilScreen()),
      );
      return;
    }

    //final showBadges = index == 2;

    setState(() {
      _currentIndex = index;
      /*_markersFuture = Future.delayed(
        const Duration(milliseconds: 300),
            () {
          if (!mounted) return <Marker>[]; // ← Vérification ajoutée
          return _loadMarkers(context, showBadges: showBadges);
        },
      );*/
    });
  }


  // Méthode pour gérer les changements de filtres
  void _onFiltersChanged(List<String> filters) {
    if (!mounted) return;

    final currentContext = context;
    setState(() {
      _activeFilters = filters;
      /*_markersFuture = Future.delayed(
        const Duration(milliseconds: 100),
            () => _loadMarkers(currentContext, showBadges: _currentIndex == 2),
      );*/
    });

    _applyFiltersToLayers(filters);
  }


  void _applyFiltersToLayers(List<String> filters) {
    // Logique de filtrage des couches selon les filtres actifs
    for (final layerState in _layerService.layerStates) {
      final layer = layerState.layer;
      bool shouldBeVisible = true;

      // Exemples de logique de filtrage
      if (filters.contains('stations') && !layer.nom.contains('Station')) {
        shouldBeVisible = false;
      }

      if (filters.contains('intervention') &&
          !layer.nom.contains('intervention') &&
          !layer.nom.contains('Station')) {
        shouldBeVisible = false;
      }

      // Activer/désactiver la couche selon la logique de filtrage
      if (layerState.isActive != shouldBeVisible) {
        _layerService.toggleLayer(layer.nom, shouldBeVisible);
      }
    }
  }

  void _showLayersPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapLayersPanel(
        availableLayers: _layerService.availableLayers,
        initialLayerStates: _layerService.layerStates,
        onLayersChanged: (newLayerStates) {
          _layerService.updateLayerStates(newLayerStates);
        },
      ),
    );
  }




  Widget _buildMapWithLayers(LatLng center) {
    return Consumer<LayerService>(
      builder: (context, layerService, child) {
        final showBadges = _currentIndex == 2;
        final mapLayers = layerService.generateMapLayers(context, showBadges: showBadges);

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
            onTap: (tapPosition, point) {
              _handleMapTap(point);
            },
          ),
          children: [
            // Les couches de base sont gérées par le LayerService
            ...mapLayers,

            // Couches de dessin (Provider DrawService)
            Consumer<DrawService>(
              builder: (context, drawService, child) {
                return MarkerLayer(markers: drawService.getPointMarkers());
              },
            ),
            Consumer<DrawService>(
              builder: (context, drawService, child) {
                return PolylineLayer(polylines: drawService.getPolylines());
              },
            ),
            Consumer<DrawService>(
              builder: (context, drawService, child) {
                return PolygonLayer(polygons: drawService.getPolygons());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSimpleMap(LatLng center, List<Marker> markers) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 13,
        onTap: (tapPosition, point) {
          _handleMapTap(point);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.boom.boom_mobile',
          fallbackUrl: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  void _handleMapTap(LatLng tappedPoint) {
    Station? nearestStation;
    double minDistance = double.infinity;

    for (final entry in _stationMap.entries) {
      final distance = _calculateDistance(tappedPoint, entry.key);
      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = entry.value;
      }
    }

    if (nearestStation != null) {
      _showStationDetails(context, nearestStation);
    }
  }


  double _calculateDistance(LatLng p1, LatLng p2) {
    return math.sqrt(math.pow(p1.latitude - p2.latitude, 2) +
        math.pow(p1.longitude - p2.longitude, 2));
  }

  void _showStationDetails(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StationDetailsPanel(station: station),
    );
  }

  Future<LatLng?> _getCurrentPosition() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    if (!_isMapReady) {
      return const Scaffold(
        body: BoomLoader(message: "Initialisation de la carte..."),
      );
    }

    final center = widget.dossier.center ?? LatLng(48.1173, -1.6778);

    return Scaffold(
      drawer: const MapDrawer(),
      extendBody: true,
      body: Stack(
        children: [
          // Carte avec couches gérées par LayerService
          Positioned.fill(
            child: _buildMapWithLayers(center),
          ),

          // Interface par-dessus
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MapTopBar(title: widget.dossier.nom),
                  ),
                  const SizedBox(height: 8),
                  MapFilterTags(
                    onFiltersChanged: _onFiltersChanged,
                  ),
                ],
              ),
            ),
          ),

          // Boutons flottants avec panneau des couches
          Positioned(
            top: 170,
            right: 16,
            child: Column(
              children: [
                // Bouton des couches connecté au LayerService
                GestureDetector(
                  onTap: _showLayersPanel,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.26),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.layers,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Autres boutons
                GestureDetector(
                  onTap: () async {
                    final position = await _getCurrentPosition();
                    if (position != null && mounted) {
                      _mapController.move(position, 16);
                    }
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.26),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const MapFloatingButtonsLeft(),
          const MapFloatingButtonsRight(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Statistiques des couches
            Consumer<LayerService>(
              builder: (context, layerService, child) {
                final stats = layerService.getLayerStatistics();
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "${stats['activeLayers']}/${stats['totalLayers']} couches actives",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),

            // Barre de navigation
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

  @override
  void dispose() {
    super.dispose();
  }

/*
  void _handleMapTap(LatLng tappedPoint) {
    Station? nearestStation;
    double minDistance = double.infinity;

    for (final entry in _stationMap.entries) {
      final distance = _calculateDistance(tappedPoint, entry.key);
      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = entry.value;
      }
    }

    if (nearestStation != null && minDistance < 0.0001) {
      _showStationDetails(context, nearestStation);
    }
  }
   */

/*
  void _handleMapTap(LatLng tappedPoint) {
    Station? nearestStation;
    double minDistance = double.infinity;

    // Rechercher dans toutes les stations actives
    for (final layerState in _layerService.activeLayers) {
      if (layerState.layer.nom.contains('Station')) {
        final markers = layerState.layer.markerBuilder(context, showBadges: _currentIndex == 2);

        for (final marker in markers) {
          final distance = _calculateDistance(tappedPoint, marker.point);
          if (distance < minDistance) {
            minDistance = distance;
            // Ici on devrait avoir une référence à la station correspondante
            // Pour l'instant, on utilise les stations du dossier principal
            final stationIndex = markers.indexOf(marker);
            if (stationIndex < widget.dossier.stations.length) {
              nearestStation = widget.dossier.stations[stationIndex];
            }
          }
        }
      }
    }

    if (nearestStation != null && minDistance < 0.0001) {
      _showStationDetails(context, nearestStation);
    }
  }*/

/*
  @override
  Widget build(BuildContext context) {
    final center = widget.dossier.center ?? LatLng(48.1, -1.6);

    return Scaffold(
      drawer: const MapDrawer(),
      extendBody: true,
      body: FutureBuilder<List<Marker>>(
        future: _markersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return const BoomLoader(message: "Chargement de la carte...");
          }

          final markers = snapshot.data!;

          // Provider autour de tout le contenu
          return Stack(
              children: [
                Positioned.fill(
                  child: _buildSimpleMap(center, markers),
                ),

                // Interface par-dessus
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: MapTopBar(title: widget.dossier.nom),
                        ),
                        const SizedBox(height: 8),
                        MapFilterTags(
                          onFiltersChanged: _onFiltersChanged, // Connexion des filtres
                        ),
                      ],
                    ),
                  ),
                ),

                const MapFloatingButtonsLeft(),
                const MapFloatingButtonsRight(),
              ],
            );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: MapBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            navItems: _navItems
        ),
      ),
    );
  }
   */
}*/