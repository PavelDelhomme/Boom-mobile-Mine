// draw_service.dart corrigé avec toutes les méthodes de l'interface
import 'dart:math' as math;

import 'package:boom_mobile/data/interfaces/draw_service_interface.dart';
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DrawService with ChangeNotifier implements DrawServiceInterface {
  // Attributs privés
  final StationService? _stationService;
  Station? _currentStation;
  Station? _selectedStation;
  DrawTool _currentTool = DrawTool.none;
  final List<LatLng> _currentPoints = [];
  final List<LatLng> _points = [];
  final List<List<LatLng>> _lines = [];
  final List<List<LatLng>> _polygons = [];
  final bool _isEditing = false;
  int? _editingIndex;
  DrawTool? _editingType;
  final List<Marker> _editMarkers = [];
  Marker? _tempMarker;

  // Variables pour le mode édition de points
  bool _editMode = false;
  LatLng? _selectedPoint;
  int? _selectedPointIndex;
  bool _showEditVertices = false;

  // Variables pour le drag & drop (pas utilisées mais gardées pour compatibilité)
  LatLng? _draggingPoint;
  int? _draggingPointIndex;
  DrawTool? _draggingGeometryType;
  int? _draggingGeometryIndex;

  // Constructeur
  DrawService({StationService? stationService}) : _stationService = stationService;

  // Implémentation des getters requis par l'interface
  @override
  StationService? get stationService => _stationService;

  @override
  DrawTool get currentTool => _currentTool;

  @override
  Station? get currentStation => _currentStation;

  @override
  Marker? get tempMarker => _tempMarker;

  @override
  List<LatLng> get points => _points;

  @override
  List<List<LatLng>> get polylines => _lines;

  @override
  List<List<LatLng>> get polygons => _polygons;

  @override
  List<LatLng> get currentPoints => _currentPoints;

  // Getters additionnels
  Station? get selectedStation => _selectedStation;
  List<List<LatLng>> get lines => _lines;
  bool get isEditing => _isEditing;
  bool get editMode => _editMode;
  LatLng? get selectedPoint => _selectedPoint;
  List<Marker> get editMarkers => _editMarkers;

  // Méthodes pour la gestion des outils
  @override
  void setTool(DrawTool tool) {
    _currentTool = tool;
    _clearCurrentPath();
    _updateEditMarkers();
    notifyListeners();
  }

  void _clearCurrentPath() {
    _currentPoints.clear();
  }

  // Gestion du mode édition
  void toggleEditMode() {
    _editMode = !_editMode;
    _selectedPoint = null;
    _selectedPointIndex = null;
    _showEditVertices = _editMode;
    _updateEditMarkers();
    notifyListeners();
  }

  void enableEditMode() {
    _editMode = true;
    _showEditVertices = true;
    _updateEditMarkers();
    notifyListeners();
  }

  void disableEditMode() {
    _editMode = false;
    _selectedPoint = null;
    _selectedPointIndex = null;
    _showEditVertices = false;
    _clearEditMarkers();
    notifyListeners();
  }

  // Gestion des points
  @override
  void addPoint(LatLng point) {
    if (_currentTool == DrawTool.point) {
      _points.add(point);
      notifyListeners();

      // Ajouter le point à la station si une est sélectionnée
      if (_selectedStation != null && _stationService != null) {
        _stationService.addPointToStation(_selectedStation!, point);
      }
    }
  }

  @override
  void addLinePoint(LatLng point) {
    if (_currentTool == DrawTool.line) {
      _currentPoints.add(point);
      notifyListeners();
    }
  }

  @override
  void addPolygonPoint(LatLng point) {
    if (_currentTool == DrawTool.polygon) {
      _currentPoints.add(point);
      notifyListeners();
    }
  }

  @override
  void completeCurrentDrawing() {
    switch (_currentTool) {
      case DrawTool.line:
        if (_currentPoints.length >= 2) {
          _lines.add(List.from(_currentPoints));
          _currentPoints.clear();

          if (_selectedStation != null && _stationService != null) {
            _stationService.addLineToStation(_selectedStation!, _lines.last);
          }
        }
        break;
      case DrawTool.polygon:
        if (_currentPoints.length >= 3) {
          _polygons.add(List.from(_currentPoints));
          _currentPoints.clear();

          if (_selectedStation != null && _stationService != null) {
            _stationService.addPolygonToStation(_selectedStation!, _polygons.last);
          }
        }
        break;
      case DrawTool.point:
      case DrawTool.none:
      case DrawTool.edit:
      case DrawTool.delete:
        break;
    }
    notifyListeners();
  }

  @override
  void cancelDrawing() {
    _currentPoints.clear();
    _tempMarker = null;
    notifyListeners();
  }

  void selectPoint(LatLng point, int index) {
    _selectedPoint = point;
    _selectedPointIndex = index;
    notifyListeners();
  }

  void movePoint(int index, LatLng newPosition) {
    if (index >= 0 && index < _points.length) {
      _points[index] = newPosition;
      _selectedPoint = newPosition;
      notifyListeners();

      // Mettre à jour la station si nécessaire
      if (_selectedStation != null && _stationService != null) {
        _updateStationPoint(index, newPosition);
      }
    }
  }

  void deletePoint(int index) {
    if (index >= 0 && index < _points.length) {
      _points.removeAt(index);
      if (_selectedPointIndex == index) {
        _selectedPoint = null;
        _selectedPointIndex = null;
      }
      notifyListeners();

      // Supprimer de la station si nécessaire
      if (_selectedStation != null && _stationService != null) {
        _removeStationPoint(index);
      }
    }
  }

  // Méthodes de station
  void setCurrentStation(Station? station) {
    _currentStation = station;
    _selectedStation = station;
    if (station != null) {
      _loadStationGeometries(station);
    }
    notifyListeners();
  }

  @override
  void loadStationGeometries(Station station) {
    _loadStationGeometries(station);
  }

  @override
  void selectStation(Station station) {
    setCurrentStation(station);
  }

  @override
  Map<String, dynamic> getGeometriesForStation() {
    return {
      'points': _points,
      'lines': _lines,
      'polygons': _polygons,
    };
  }

  void _loadStationGeometries(Station station) {
    _points.clear();
    _lines.clear();
    _polygons.clear();

    // Charger les points de la station
    if (station.points != null) {
      _points.addAll(station.points!);
    }

    // Charger les lignes de la station
    if (station.lignes != null) {
      _lines.addAll(station.lignes!);
    }

    // Charger les polygones de la station
    if (station.polygones != null) {
      _polygons.addAll(station.polygones!);
    }
  }

  void _updateStationPoint(int index, LatLng newPosition) {
    if (_selectedStation?.points != null &&
        index >= 0 && index < _selectedStation!.points!.length) {
      final updatedPoints = List<LatLng>.from(_selectedStation!.points!);
      updatedPoints[index] = newPosition;

      _stationService?.updateStation(
        _selectedStation!,
        points: updatedPoints,
      );
    }
  }

  void _removeStationPoint(int index) {
    if (_selectedStation?.points != null &&
        index >= 0 && index < _selectedStation!.points!.length) {
      final updatedPoints = List<LatLng>.from(_selectedStation!.points!);
      updatedPoints.removeAt(index);

      _stationService?.updateStation(
        _selectedStation!,
        points: updatedPoints,
      );
    }
  }

  // Gestion des marqueurs d'édition
  void _updateEditMarkers() {
    _clearEditMarkers();

    if (_editMode || _showEditVertices) {
      // Créer des marqueurs pour tous les points
      for (int i = 0; i < _points.length; i++) {
        final point = _points[i];
        final isSelected = _selectedPointIndex == i;

        _editMarkers.add(
          Marker(
            point: point,
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => selectPoint(point, i),
              onPanUpdate: (details) {
                // Logique de déplacement sera gérée par le MapScreen
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.drag_indicator,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  void _clearEditMarkers() {
    _editMarkers.clear();
  }

  // Méthodes pour les marqueurs
  @override
  List<Marker> getPointMarkers() {
    List<Marker> markers = [];

    // Marqueurs de points normaux
    for (int i = 0; i < _points.length; i++) {
      final point = _points[i];
      final isSelected = _selectedPointIndex == i;

      if (!_editMode) {
        markers.add(
          Marker(
            point: point,
            width: 16,
            height: 16,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  @override
  List<Marker> getEditVertexMarkers() {
    return _editMarkers;
  }

  // Méthodes pour les polylignes
  @override
  List<Polyline> getPolylines() {
    List<Polyline> polylines = [];

    // Polylignes normales
    for (int i = 0; i < _lines.length; i++) {
      polylines.add(
        Polyline(
          points: _lines[i],
          strokeWidth: 3.0,
          color: Colors.red,
          pattern: StrokePattern.dashed(segments: [5, 5]),
        ),
      );
    }

    // Ligne en cours de dessin
    if (_currentTool == DrawTool.line && _currentPoints.length > 1) {
      polylines.add(
        Polyline(
          points: _currentPoints,
          strokeWidth: 3.0,
          color: Colors.red.withValues(alpha: 0.7),
          pattern: StrokePattern.dashed(segments: [3, 3]),
        ),
      );
    }

    return polylines;
  }

  // Méthodes pour les polygones
  @override
  List<Polygon> getPolygons() {
    List<Polygon> polygons = [];

    // Polygones normaux
    for (int i = 0; i < _polygons.length; i++) {
      polygons.add(
        Polygon(
          points: _polygons[i],
          color: Colors.green.withValues(alpha: 0.3),
          borderStrokeWidth: 2.0,
          borderColor: Colors.green,
        ),
      );
    }

    // Polygone en cours de dessin
    if (_currentTool == DrawTool.polygon && _currentPoints.length > 2) {
      polygons.add(
        Polygon(
          points: _currentPoints,
          color: Colors.green.withValues(alpha: 0.2),
          borderStrokeWidth: 2.0,
          borderColor: Colors.green.withValues(alpha: 0.7),
        ),
      );
    }

    return polygons;
  }

  @override
  List<LatLng> getCurrentPoints() {
    return _currentPoints;
  }

  // Méthodes d'interaction tactile
  @override
  void handleMapTap(LatLng point) {
    switch (_currentTool) {
      case DrawTool.point:
        addPoint(point);
        break;
      case DrawTool.line:
        addLinePoint(point);
        break;
      case DrawTool.polygon:
        addPolygonPoint(point);
        break;
      case DrawTool.none:
        if (_editMode) {
          handlePointTap(point);
        }
        break;
      case DrawTool.edit:
        handlePointTap(point);
        break;
      case DrawTool.delete:
        _deleteGeometryAt(point);
        break;
    }
  }

  @override
  void handleMapLongPress(LatLng point) {
    // Long press pour ouvrir le menu contextuel ou basculer en mode édition
    if (!_editMode && _points.isNotEmpty) {
      enableEditMode();
    } else if (_currentTool == DrawTool.line && _currentPoints.length >= 2) {
      completeCurrentDrawing();
    } else if (_currentTool == DrawTool.polygon && _currentPoints.length >= 3) {
      completeCurrentDrawing();
    }
  }

  @override
  void setTempMarker(LatLng point) {
    _tempMarker = Marker(
      point: point,
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
    notifyListeners();
  }

  @override
  void deleteGeometry(LatLng point, double threshold) {
    _deleteGeometryAt(point, threshold: threshold);
  }

  void _deleteGeometryAt(LatLng point, {double threshold = 0.0001}) {
    // Supprimer le point le plus proche
    for (int i = 0; i < _points.length; i++) {
      if (isNearPoint(point, _points[i], threshold: threshold)) {
        deletePoint(i);
        return;
      }
    }

    // Supprimer ligne si trouvée
    for (int i = 0; i < _lines.length; i++) {
      for (final linePoint in _lines[i]) {
        if (isNearPoint(point, linePoint, threshold: threshold)) {
          _lines.removeAt(i);
          notifyListeners();
          return;
        }
      }
    }

    // Supprimer polygone si trouvé
    for (int i = 0; i < _polygons.length; i++) {
      for (final polygonPoint in _polygons[i]) {
        if (isNearPoint(point, polygonPoint, threshold: threshold)) {
          _polygons.removeAt(i);
          notifyListeners();
          return;
        }
      }
    }
  }

  // Méthodes de nettoyage
  @override
  void clearAll() {
    _points.clear();
    _lines.clear();
    _polygons.clear();
    _currentPoints.clear();
    _selectedPoint = null;
    _selectedPointIndex = null;
    _clearEditMarkers();
    notifyListeners();
  }

  @override
  void reset() {
    clearAll();
    _currentTool = DrawTool.none;
    _editMode = false;
    _tempMarker = null;
    notifyListeners();
  }

  @override
  void finishDrawing() {
    completeCurrentDrawing();
  }

  void clearPoints() {
    _points.clear();
    _selectedPoint = null;
    _selectedPointIndex = null;
    _updateEditMarkers();
    notifyListeners();
  }

  // Méthodes d'annulation (undo)
  @override
  void undo() {
    if (_currentPoints.isNotEmpty) {
      _currentPoints.removeLast();
      notifyListeners();
    } else if (_points.isNotEmpty) {
      _points.removeLast();
      if (_selectedPointIndex == _points.length) {
        _selectedPoint = null;
        _selectedPointIndex = null;
      }
      _updateEditMarkers();
      notifyListeners();
    } else if (_lines.isNotEmpty) {
      _lines.removeLast();
      notifyListeners();
    } else if (_polygons.isNotEmpty) {
      _polygons.removeLast();
      notifyListeners();
    }
  }

  // Détection de proximité pour la sélection
  bool isNearPoint(LatLng tapPoint, LatLng targetPoint, {double threshold = 0.0001}) {
    final distance = math.sqrt(
        math.pow(tapPoint.latitude - targetPoint.latitude, 2) +
            math.pow(tapPoint.longitude - targetPoint.longitude, 2)
    );
    return distance < threshold;
  }

  // Gestion des tap sur les points
  bool handlePointTap(LatLng tapPoint) {
    for (int i = 0; i < _points.length; i++) {
      if (isNearPoint(tapPoint, _points[i])) {
        if (_editMode) {
          selectPoint(_points[i], i);
        }
        return true;
      }
    }
    return false;
  }

  // Méthodes pour les interactions tactiles
  void handleTap(LatLng point) {
    handleMapTap(point);
  }

  void handleDoubleTap(LatLng point) {
    if (_currentTool == DrawTool.line && _currentPoints.length > 1) {
      completeCurrentDrawing();
    } else if (_currentTool == DrawTool.polygon && _currentPoints.length > 2) {
      completeCurrentDrawing();
    }
  }

  void handleLongPress(LatLng point) {
    handleMapLongPress(point);
  }

  @override
  void dispose() {
    _clearEditMarkers();
    super.dispose();
  }
}