import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum EditingMode {
  none,
  addingPoints,
  addingLines,
  addingPolygons,
  editing,
  selecting
}

class MapEditor extends StatefulWidget {
  final MapController? mapController;
  final Function(List<Marker>)? onMarkersChanged;
  final Function(List<Polyline>)? onPolylinesChanged;
  final Function(List<Polygon>)? onPolygonsChanged;

  const MapEditor({
    super.key,
    this.mapController,
    this.onMarkersChanged,
    this.onPolylinesChanged,
    this.onPolygonsChanged,
  });

  @override
  _MapEditorState createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  EditingMode _currentMode = EditingMode.none;
  List<LatLng> _currentPath = [];
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<Polygon> _polygons = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar d'édition
        Container(
          height: 60,
          color: Colors.grey.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModeButton(
                'Point',
                Icons.place,
                EditingMode.addingPoints,
              ),
              _buildModeButton(
                'Ligne',
                Icons.timeline,
                EditingMode.addingLines,
              ),
              _buildModeButton(
                'Polygone',
                Icons.change_history,
                EditingMode.addingPolygons,
              ),
              _buildActionButton(
                'Effacer',
                Icons.clear,
                _clearAll,
              ),
            ],
          ),
        ),

        // Carte
        Expanded(
          child: FlutterMap(
            mapController: widget.mapController,
            options: MapOptions(
              initialCenter: const LatLng(48.8566, 2.3522),
              initialZoom: 13.0,
              onTap: _handleMapTap,
            ),
            children: [
              // Couche de fond
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.boom.boom_mobile',
              ),

              // Polygones
              if (_polygons.isNotEmpty)
                PolygonLayer(polygons: _polygons),

              // Polygone en cours de création
              if (_currentMode == EditingMode.addingPolygons && _currentPath.length >= 2)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _currentPath,
                      color: Colors.red.withOpacity(0.3),
                      borderColor: Colors.red,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // Polylignes
              if (_polylines.isNotEmpty)
                PolylineLayer(polylines: _polylines),

              // Ligne en cours de création
              if (_currentMode == EditingMode.addingLines && _currentPath.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _currentPath,
                      strokeWidth: 3,
                      color: Colors.red,
                    ),
                  ],
                ),

              // Marqueurs
              if (_markers.isNotEmpty)
                MarkerLayer(markers: _markers),

              // Points du tracé en cours
              if (_currentPath.isNotEmpty)
                MarkerLayer(
                  markers: _currentPath.asMap().entries.map((entry) {
                    final index = entry.key;
                    final point = entry.value;
                    return Marker(
                      point: point,
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),

        // Instructions
        if (_currentMode != EditingMode.none)
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.blue.shade50,
            child: Text(
              _getInstructions(),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildModeButton(String label, IconData icon, EditingMode mode) {
    final isActive = _currentMode == mode;
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _getInstructions() {
    switch (_currentMode) {
      case EditingMode.addingPoints:
        return 'Cliquez sur la carte pour ajouter des points';
      case EditingMode.addingLines:
        return 'Cliquez pour ajouter des points à la ligne. Double-clic pour terminer.';
      case EditingMode.addingPolygons:
        return 'Cliquez pour ajouter des points au polygone. Double-clic pour terminer.';
      default:
        return '';
    }
  }

  void _setMode(EditingMode mode) {
    setState(() {
      _currentMode = mode;
      _currentPath.clear();
    });
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      switch (_currentMode) {
        case EditingMode.addingPoints:
          _addMarker(point);
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

  void _addMarker(LatLng point) {
    final marker = Marker(
      point: point,
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _editMarker(point),
        child: const Icon(
          Icons.location_on,
          size: 40,
          color: Colors.red,
        ),
      ),
    );

    _markers.add(marker);
    widget.onMarkersChanged?.call(_markers);
    debugPrint('Marqueur ajouté: ${point.latitude}, ${point.longitude}');
  }

  void _addLinePoint(LatLng point) {
    _currentPath.add(point);
    debugPrint('Point ligne ajouté: ${point.latitude}, ${point.longitude}');
  }

  void _addPolygonPoint(LatLng point) {
    _currentPath.add(point);
    debugPrint('Point polygone ajouté: ${point.latitude}, ${point.longitude}');
  }

  void _editMarker(LatLng point) {
    debugPrint('Édition du marqueur: ${point.latitude}, ${point.longitude}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Éditer le marqueur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Latitude: ${point.latitude.toStringAsFixed(6)}'),
            Text('Longitude: ${point.longitude.toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _markers.removeWhere((marker) => marker.point == point);
                widget.onMarkersChanged?.call(_markers);
              });
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _completePath() {
    if (_currentPath.isEmpty) return;

    setState(() {
      switch (_currentMode) {
        case EditingMode.addingLines:
          if (_currentPath.length >= 2) {
            final polyline = Polyline(
              points: List.from(_currentPath),
              strokeWidth: 3,
              color: Colors.blue,
            );
            _polylines.add(polyline);
            widget.onPolylinesChanged?.call(_polylines);
            debugPrint('Ligne créée avec ${_currentPath.length} points');
          }
          break;
        case EditingMode.addingPolygons:
          if (_currentPath.length >= 3) {
            final polygon = Polygon(
              points: List.from(_currentPath),
              color: Colors.blue.withOpacity(0.3),
              borderColor: Colors.blue,
              borderStrokeWidth: 2,
            );
            _polygons.add(polygon);
            widget.onPolygonsChanged?.call(_polygons);
            debugPrint('Polygone créé avec ${_currentPath.length} points');
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
      _markers.clear();
      _polylines.clear();
      _polygons.clear();
      _currentPath.clear();
      _currentMode = EditingMode.none;
    });

    widget.onMarkersChanged?.call(_markers);
    widget.onPolylinesChanged?.call(_polylines);
    widget.onPolygonsChanged?.call(_polygons);

    debugPrint('Toutes les géométries ont été effacées');
  }

  // Méthode pour gérer le double-clic (terminer le tracé)
  void handleDoubleTap() {
    if (_currentMode == EditingMode.addingLines || _currentMode == EditingMode.addingPolygons) {
      _completePath();
    }
  }

  // Getters pour accéder aux données
  List<Marker> get markers => List.from(_markers);
  List<Polyline> get polylines => List.from(_polylines);
  List<Polygon> get polygons => List.from(_polygons);
  EditingMode get currentMode => _currentMode;
}