import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/widgets/nav/nav_item.dart';
import 'package:boom_mobile/domain/entities/layer.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_layers_panel.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/station_details_panel.dart';
import 'package:boom_mobile/services/draw_service.dart';
import 'package:boom_mobile/services/layer_service.dart';
import 'package:boom_mobile/services/station_service.dart';
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

  // Gestion du mode dessin
  bool _drawingMode = false;
  Station? _selectedStation;

  bool _hasModifications = false;
  final Map<int, Station> _pendingModifications = {};

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
    // Différer l'initialisation des services après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
    });
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

    if (mounted) {
      setState(() {
        _isMapReady = true;
      });
    }
  }

  void _handleStationTap(Station station) {
    print("Station ${station.numeroStation} tapée");

    // Afficher la fiche de détail en bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StationDetailsPanel(station: station),
    );
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

    setState(() {
      _activeFilters = filters;
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
              // Gestion des modes de dessin
              final drawService = context.read<DrawService>();

              if (_drawingMode) {
                switch (drawService.currentTool) {
                  case DrawTool.point:
                  // Ajouter un point
                    drawService.addPoint(point);
                    if (_selectedStation != null) {
                      final stationService = context.read<StationService>();
                      stationService.addPointToStation(_selectedStation!, point);
                    }
                    break;
                  case DrawTool.line:
                  case DrawTool.polygon:
                  // Ajouter un point à la ligne/polygone en cours
                    drawService.addPoint(point);
                    break;
                  case DrawTool.edit:
                  // La sélection et l'édition sont gérées par les markers
                    break;
                  case DrawTool.delete:
                  // Supprimer la géométrie la plus proche
                    drawService.deleteGeometry(point, 0.0005); // ~50m de tolérance
                    break;
                  default:
                    break;
                }
              } else {
                // Mode normal: détection de tap sur station
                _handleMapTap(point);
              }
            },
            // Gestion du double-tap et longpress
            onLongPress: (tapPosition, point) {
              final drawService = context.read<DrawService>();
              if (_drawingMode &&
                  (drawService.currentTool == DrawTool.line ||
                      drawService.currentTool == DrawTool.polygon)) {
                // Terminer la ligne ou le polygone en cours
                drawService.completeCurrentDrawing();

                // Si une station est sélectionnée, associer la géométrie
                if (_selectedStation != null) {
                  final stationService = context.read<StationService>();
                  final points = drawService.getCurrentPoints();

                  if (drawService.currentTool == DrawTool.line) {
                    stationService.addLineToStation(_selectedStation!, points);
                  } else if (drawService.currentTool == DrawTool.polygon) {
                    stationService.addPolygonToStation(_selectedStation!, points);
                  }
                }
              }
            },
            // Support du survol pour prévisualisation
            onPointerHover: (event, point) {
              if (_drawingMode) {
                final drawService = context.read<DrawService>();
                if (drawService.currentTool == DrawTool.line ||
                    drawService.currentTool == DrawTool.polygon) {
                  drawService.setTempMarker(point);
                }
              }
            },
          ),
          children: [
            // Couches de base
            ...mapLayers,

            // Couches de dessin (Provider DrawService)
            Consumer<DrawService>(
              builder: (context, drawService, child) {
                // Récupérer tous les types de géométries
                final allMarkers = [
                  ...drawService.getPointMarkers(),
                  ...drawService.getEditVertexMarkers(),
                ];

                final allPolylines = drawService.getPolylines();
                final allPolygons = drawService.getPolygons();

                // Construire les couches dans le bon ordre
                return Stack(
                  children: [
                    // 1. Polygones (fond avec transparence)
                    if (allPolygons.isNotEmpty)
                      PolygonLayer(
                        polygons: allPolygons,
                        polygonCulling: true,
                      ),

                    // 2. Lignes
                    if (allPolylines.isNotEmpty)
                      PolylineLayer(
                        polylines: allPolylines,
                      ),

                    // 3. Points et markers d'édition (au-dessus)
                    if (allMarkers.isNotEmpty)
                      MarkerLayer(
                        markers: allMarkers,
                      ),

                    // 4. Marker temporaire (pour prévisualiser lors du dessin)
                    if (drawService.tempMarker != null)
                      MarkerLayer(
                        markers: [drawService.tempMarker!],
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  /*
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
            /*
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
             */
            Consumer<DrawService>(
              builder: (context, drawService, child) {
                final allMarkers = [
                  ...drawService.getPointMarkers(), // Points normaux
                  ...drawService.getEditVertexMarkers(), // Points d'édition (vertex)
                ];

                final allPolylines = drawService.getPolylines();
                final allPolygons = drawService.getPolygons();

                return Stack(
                  children: [
                    // Polygones (fond avec transparence)
                    if (allPolygons.isNotEmpty)
                      PolygonLayer(
                        polygons: allPolygons,
                        polygonCulling: true,
                      ),

                    // Lines
                    if (allPolylines.isNotEmpty)
                      PolylineLayer(
                        polylines: allPolylines,
                      ),

                    // Points et markers d'édition
                    if (allMarkers.isNotEmpty)
                      MarkerLayer(
                        markers: allMarkers,
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }*/

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
  void _toggleDrawingMode(dynamic tool) {
    setState(() {
      _drawingMode = tool != null;
      // Si tool est un DrawTool, utiliser le DrawService
      if (tool is DrawTool) {
        context.read<DrawService>().setTool(tool);
      }
    });
  }
  void _handleMapTap(LatLng tappedPoint) {
    // Si on est en mode dessin, ne pas traiter comme un tap sur station
    if (_drawingMode) return;

    // Trouver la station la plus proche du point tapé
    Station? nearestStation;
    double minDistance = double.infinity;

    // Distance maximale pour considérer un tap comme valide (en degrés)
    const double maxTapDistance = 0.0005; // ~50m

    // Parcourir toutes les stations pour trouver la plus proche
    for (final station in widget.dossier.stations) {
      final stationPoint = LatLng(station.latitude, station.longitude);
      final distance = _calculateDistance(tappedPoint, stationPoint);

      if (distance < minDistance) {
        minDistance = distance;
        nearestStation = station;
      }
    }

    // Si une station proche a été trouvée et est dans la zone de tap
    if (nearestStation != null && minDistance < maxTapDistance) {
      print("Station ${nearestStation.numeroStation} tapée");

      // Afficher la fiche de détail en bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => StationDetailsPanel(
          station: nearestStation!,
          onEditGeometry: () {
            // Fermer le bottom sheet et activer le mode édition
            Navigator.pop(context);

            // Montrer une popup pour choisir le type de géométrie
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Éditer géométries - Station ${nearestStation?.numeroStation}"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.add_location, color: Colors.red),
                      title: Text("Ajouter un point"),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _drawingMode = true;
                          _selectedStation = nearestStation;
                        });
                        context.read<DrawService>().setTool(DrawTool.point);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.timeline, color: Colors.blue),
                      title: Text("Dessiner une ligne"),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _drawingMode = true;
                          _selectedStation = nearestStation;
                        });
                        context.read<DrawService>().setTool(DrawTool.line);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.format_shapes, color: Colors.purple),
                      title: Text("Dessiner un polygone"),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _drawingMode = true;
                          _selectedStation = nearestStation;
                        });
                        context.read<DrawService>().setTool(DrawTool.polygon);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.edit, color: Colors.orange),
                      title: Text("Modifier géométries"),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _drawingMode = true;
                          _selectedStation = nearestStation;
                        });
                        context.read<DrawService>().setTool(DrawTool.edit);
                        context.read<DrawService>().loadStationGeometries(nearestStation!);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text("Supprimer géométries"),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _drawingMode = true;
                          _selectedStation = nearestStation;
                        });
                        context.read<DrawService>().setTool(DrawTool.delete);
                        context.read<DrawService>().loadStationGeometries(nearestStation!);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Annuler"),
                  ),
                ],
              ),
            );
          },
        ),
      );
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


  // Géolocalisation et zoom sur la position utilisateur
  void _goToUserPosition() async {
    if (_userPosition != null) {
      _mapController.move(_userPosition!, 16);
    } else {
      final position = await _getCurrentPosition();
      if (position != null && mounted) {
        setState(() => _userPosition = position);
        _mapController.move(position, 16);
      }
    }
  }

  // Gestion des modifications
  void _saveModifications() {
    final stationService = context.read<StationService>();
    stationService.saveChanges();
    setState(() {
      _hasModifications = false;
      _pendingModifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modifications sauvegardées')),
    );
  }

  void _rollbackModifications() {
    final stationService = context.read<StationService>();
    stationService.rollbackChanges();
    setState(() {
      _hasModifications = false;
      _pendingModifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modifications annulées')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMapReady) {
      return const Scaffold(
        body: BoomLoader(message: "Initialisation de la carte..."),
      );
    }

    final center = widget.dossier.center ?? const LatLng(48.1173, -1.6778);

    return Scaffold(
      drawer: const MapDrawer(),
      //todo extendBody: true,
      body: Stack(
        children: [
          //todo Carte avec couches gérées par LayerService
          //Positioned.fill(
          //  child: _buildMapWithLayers(center),
          //),
          // Carte principale (occupant tout l'écran)
          _buildMapWithLayers(center),


          // Interface par-dessus
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MapTopBar(title: widget.dossier.nom),
                ),
              ],
            ),
          ),


          // Filtres horizontaux en position correcte
          Positioned(
            top: 95,
            left: 0,
            right: 0,
            child: MapFilterTags(
              onFiltersChanged: _onFiltersChanged,
            ),
          ),

          /*
          // Interface par-dessus
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea( // a motider en utlisant directement dans le positionned le child det MapTopBar sinon avec en dessous le positionned après la sizedbox qui se trouve dans les children de la column
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MapTopBar(title: widget.dossier.nom),
                  ),
                  const SizedBox(height: 8),
                  //TODO marchait mais pas affichage correct vraiuement la a changer si ne remarche plus MapFilterTags(
                  //  onFiltersChanged: _onFiltersChanged,
                  //),
                  // Filtre horizontaux avec bouton reset intégré
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: MapFilterTags(
                      onFiltersChanged: _onFiltersChanged,
                    ),
                  ),

                  // Mode dessin : Barre d'outils et boutons
                  if (_drawingMode != null) ...[
                    Positioned(
                      top: 200,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 16), // Peut-être voir entre les deux lequel choisir
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedStation != null
                                  ? "Station ${_selectedStation!.numeroStation} - Mode édition"
                                  : "Mode édition",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => {
                                setState(() {
                                  _drawingMode = false;
                                  _selectedStation = null;
                                })
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // todo pas sur du tout pour ceci Boutons d'outils de dessin
                    Positioned(
                      top: 280,
                      right: 16,
                      child: Column(
                        children: [
                          _buildDrawingToolButton(DrawTool.point, 'Point', Icons.location_on),
                          const SizedBox(height: 8),
                          _buildDrawingToolButton(DrawTool.line, 'Ligne', Icons.timeline),
                          const SizedBox(height: 8),
                          _buildDrawingToolButton(DrawTool.polygon, 'Polygone', Icons.pentagon),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),*/
          //]
          //],
          //),
          //),
          //),

          /*
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
      ),*/

          // Mode dessin : Barre d'outils et boutons
          if (_drawingMode)
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedStation != null
                          ? "Édition de la station ${_selectedStation!.numeroStation}"
                          : "Mode dessin: ${_drawingMode.toString().split('.').last}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => _toggleDrawingMode(null),
                    ),
                  ],
                ),
              ),
            ),

          // Boutons flottants gauche et droite
          const MapFloatingButtonsLeft(),
          const MapFloatingButtonsRight(),

          // Couches actives - informations
          Positioned(
            bottom: 80,
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
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  "${_layerService.activeLayers.length}/12 couches actives",
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

  Widget _buildDrawingToolButton(DrawTool tool, String tooltip, IconData icon) {
    return Consumer<DrawService>(
      builder: (context, drawService, child) {
        final isSelected = drawService.currentTool == tool;

        return Tooltip(
          message: tooltip,
          child: GestureDetector(
            onTap: () {
              drawService.setTool(isSelected ? DrawTool.none : tool);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.green : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.26),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.green,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}