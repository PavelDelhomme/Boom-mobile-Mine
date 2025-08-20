import 'dart:math' as math;

import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/services/station_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum DrawTool {
  none,
  point,
  line,
  polygon,
  edit,
  delete,
}

class DrawService with ChangeNotifier {
  final StationService? stationService;

  // Station actuelle
  Station? _currentStation;
  Station? _selectedStation;

  DrawService({this.stationService});

  DrawTool _currentTool = DrawTool.none;

  // Points en cours d'édition
  List<LatLng> _currentPoints = [];

  // Collections pour stocker les géométries dessinées
  List<LatLng> _points = [];
  List<List<LatLng>> _lines = [];
  List<List<LatLng>> _polygons = [];

  // État d'édition
  bool _isEditing = false;
  int? _editingIndex;
  DrawTool? _editingType;

  // Pour le mode édition
  List<Marker> _editMarkers = [];

  // Marker temporaire pour prévisualisation
  Marker? _tempMarker;

  // Getters
  DrawTool get currentTool => _currentTool;
  bool get isEditing => _isEditing;
  Station? get currentStation => _currentStation;
  Station? get selectedStation => _selectedStation;
  Marker? get tempMarker => _tempMarker;

  // Getters pour MapView et d'autres composants
  List<LatLng> get points => List.unmodifiable(_points);
  List<List<LatLng>> get polylines => List.unmodifiable(_lines);
  List<List<LatLng>> get polygons => List.unmodifiable(_polygons);

  // Setter pour l'outil actif
  void setTool(DrawTool tool) {
    if (_currentTool == tool && tool != DrawTool.none) {
      _currentTool = DrawTool.none;
    } else {
      _currentTool = tool;
    }

    // Réinitialiser les points en cours si on change d'outil
    if (tool != DrawTool.line && tool != DrawTool.polygon) {
      _currentPoints = [];
    }

    // Préparer les markers d'édition si on entre en mode édition
    if (tool == DrawTool.edit) {
      _prepareEditMarkers();
    } else {
      _editMarkers = [];
    }

    notifyListeners();
  }

  // Charger les géométries d'une station
  void loadStationGeometries(Station station) {
    _currentStation = station;
    _selectedStation = station;

    // Réinitialiser les géométries actuelles
    _points = [];
    _lines = [];
    _polygons = [];

    // Charger les points
    if (station.points != null) {
      _points = List.from(station.points!);
    }

    // Charger les lignes
    if (station.lignes != null) {
      _lines = List.from(station.lignes!);
    }

    // Charger les polygones
    if (station.polygones != null) {
      _polygons = List.from(station.polygones!);
    }

    // Mettre à jour les markers d'édition si en mode édition
    if (_currentTool == DrawTool.edit || _currentTool == DrawTool.delete) {
      _prepareEditMarkers();
    }

    notifyListeners();
  }

  // Préparer les markers d'édition
  void _prepareEditMarkers() {
    _editMarkers = [];

    // Ajouter des markers pour chaque point
    for (int i = 0; i < _points.length; i++) {
      final index = i;
      _editMarkers.add(
        Marker(
          point: _points[i],
          width: 24,
          height: 24,
          child: GestureDetector(
            onTap: () {
              if (_currentTool == DrawTool.delete) {
                _points.removeAt(index);

                // Si une station est sélectionnée, supprimer le point
                if (_selectedStation != null && stationService != null) {
                  stationService!.removeGeographicFeature(_selectedStation!, 'point', index);
                }

                _prepareEditMarkers();
                notifyListeners();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.circle, color: Colors.white, size: 16),
            ),
          ),
        ),
      );
    }

    // Ajouter des markers pour chaque vertex de ligne
    for (int lineIdx = 0; lineIdx < _lines.length; lineIdx++) {
      final line = _lines[lineIdx];
      for (int i = 0; i < line.length; i++) {
        final lIdx = lineIdx;
        final vIdx = i;
        _editMarkers.add(
          Marker(
            point: line[i],
            width: 20,
            height: 20,
            child: GestureDetector(
              onTap: () {
                if (_currentTool == DrawTool.delete) {
                  if (line.length <= 2) {
                    // Supprimer toute la ligne si elle n'a plus assez de points
                    _lines.removeAt(lIdx);

                    // Si une station est sélectionnée, supprimer la ligne
                    if (_selectedStation != null && stationService != null) {
                      stationService!.removeGeographicFeature(_selectedStation!, 'line', lIdx);
                    }
                  } else {
                    // Supprimer juste ce vertex
                    _lines[lIdx].removeAt(vIdx);
                  }
                  _prepareEditMarkers();
                  notifyListeners();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Ajouter des markers pour chaque vertex de polygone
    for (int polyIdx = 0; polyIdx < _polygons.length; polyIdx++) {
      final polygon = _polygons[polyIdx];
      for (int i = 0; i < polygon.length; i++) {
        final pIdx = polyIdx;
        final vIdx = i;
        _editMarkers.add(
          Marker(
            point: polygon[i],
            width: 20,
            height: 20,
            child: GestureDetector(
              onTap: () {
                if (_currentTool == DrawTool.delete) {
                  if (polygon.length <= 4) {  // Moins de 3 points réels (+1 point de fermeture)
                    // Supprimer tout le polygone s'il n'a plus assez de points
                    _polygons.removeAt(pIdx);

                    // Si une station est sélectionnée, supprimer le polygone
                    if (_selectedStation != null && stationService != null) {
                      stationService!.removeGeographicFeature(_selectedStation!, 'polygon', pIdx);
                    }
                  } else {
                    // Supprimer juste ce vertex
                    _polygons[pIdx].removeAt(vIdx);
                    // Si c'était le dernier point (qui fermait le polygone), mettre à jour
                    if (vIdx == polygon.length - 1) {
                      _polygons[pIdx].add(_polygons[pIdx][0]);  // Refermer le polygone
                    }
                  }
                  _prepareEditMarkers();
                  notifyListeners();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  // Gestion des clics sur la carte
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
      case DrawTool.edit:
        _handleEditTap(point);
        break;
      case DrawTool.delete:
        _handleDeleteTap(point);
        break;
      case DrawTool.none:
        break;
    }
  }

  // Gestion des appuis longs
  void handleMapLongPress(LatLng point) {
    if (_currentTool == DrawTool.line || _currentTool == DrawTool.polygon) {
      completeCurrentDrawing();
    }
  }

  // Méthode pour gérer la suppression
  void _handleDeleteTap(LatLng point) {
    deleteGeometry(point, 0.0005); // ~50m de tolérance
  }

  // Méthode pour ajouter un point
  void addPoint(LatLng point) {
    if (_currentTool == DrawTool.point) {
      _points.add(point);

      // Si une station est sélectionnée, ajouter le point à cette station
      if (_selectedStation != null && stationService != null) {
        stationService!.addPointToStation(_selectedStation!, point);
      }

      notifyListeners();
    } else if (_currentTool == DrawTool.line || _currentTool == DrawTool.polygon) {
      _currentPoints.add(point);
      notifyListeners();
    }
  }

  // Méthode pour ajouter un point à une ligne
  void addLinePoint(LatLng point) {
    _currentPoints.add(point);
    notifyListeners();
  }

  // Méthode pour ajouter un point à un polygone
  void addPolygonPoint(LatLng point) {
    _currentPoints.add(point);
    notifyListeners();
  }

  // Méthode pour finaliser une ligne ou un polygone
  void completeCurrentDrawing() {
    if (_currentPoints.length < 2) return;

    if (_currentTool == DrawTool.line) {
      _lines.add(List.from(_currentPoints));

      // Si une station est sélectionnée, ajouter la ligne à cette station
      if (_selectedStation != null && stationService != null) {
        stationService!.addLineToStation(_selectedStation!, List.from(_currentPoints));
      }
    } else if (_currentTool == DrawTool.polygon && _currentPoints.length >= 3) {
      // Fermer le polygone si nécessaire
      if (_currentPoints.first != _currentPoints.last) {
        _currentPoints.add(_currentPoints.first);
      }

      _polygons.add(List.from(_currentPoints));

      // Si une station est sélectionnée, ajouter le polygone à cette station
      if (_selectedStation != null && stationService != null) {
        stationService!.addPolygonToStation(_selectedStation!, List.from(_currentPoints));
      }
    }

    // Réinitialiser
    _currentPoints = [];
    notifyListeners();
  }

  // Prévisualisation pour ligne/polygone
  void setTempMarker(LatLng point) {
    if (_currentTool == DrawTool.line || _currentTool == DrawTool.polygon) {
      _tempMarker = Marker(
        point: point,
        width: 20,
        height: 20,
        child: const Icon(
          Icons.add_location,
          color: Colors.orange,
          size: 20,
        ),
      );
      notifyListeners();
    } else {
      _tempMarker = null;
      notifyListeners();
    }
  }

  // Méthode pour terminer le dessin en cours
  void finishDrawing() {
    completeCurrentDrawing();
  }

  // Méthode pour annuler le dessin en cours
  void cancelDrawing() {
    _currentPoints.clear();
    notifyListeners();
  }

  // Méthodes d'édition
  void _handleEditTap(LatLng point) {
    // Trouver l'élément le plus proche à éditer
    _findNearestElement(point);
  }

  void _findNearestElement(LatLng tapPoint, {bool forDelete = false}) {
    double minDistance = double.infinity;
    int? nearestIndex;
    DrawTool? nearestType;

    // Vérifier les points
    for (int i = 0; i < _points.length; i++) {
      double distance = _calculateDistance(tapPoint, _points[i]);
      if (distance < minDistance && distance < 0.001) { // Seuil de proximité
        minDistance = distance;
        nearestIndex = i;
        nearestType = DrawTool.point;
      }
    }

    // Vérifier les lignes
    for (int i = 0; i < _lines.length; i++) {
      for (int j = 0; j < _lines[i].length; j++) {
        double distance = _calculateDistance(tapPoint, _lines[i][j]);
        if (distance < minDistance && distance < 0.001) {
          minDistance = distance;
          nearestIndex = i;
          nearestType = DrawTool.line;
        }
      }
    }

    // Vérifier les polygones
    for (int i = 0; i < _polygons.length; i++) {
      for (int j = 0; j < _polygons[i].length; j++) {
        double distance = _calculateDistance(tapPoint, _polygons[i][j]);
        if (distance < minDistance && distance < 0.001) {
          minDistance = distance;
          nearestIndex = i;
          nearestType = DrawTool.polygon;
        }
      }
    }

    if (nearestIndex != null && nearestType != null) {
      if (forDelete) {
        _deleteElement(nearestIndex, nearestType);
      } else {
        _startEditing(nearestIndex, nearestType);
      }
    }
  }

  // Supprimer un élément
  void _deleteElement(int index, DrawTool type) {
    switch (type) {
      case DrawTool.point:
        if (index < _points.length) {
          _points.removeAt(index);

          // Si une station est sélectionnée, supprimer le point de cette station
          if (_selectedStation != null && stationService != null) {
            stationService!.removeGeographicFeature(_selectedStation!, 'point', index);
          }
        }
        break;
      case DrawTool.line:
        if (index < _lines.length) {
          _lines.removeAt(index);

          // Si une station est sélectionnée, supprimer la ligne de cette station
          if (_selectedStation != null && stationService != null) {
            stationService!.removeGeographicFeature(_selectedStation!, 'line', index);
          }
        }
        break;
      case DrawTool.polygon:
        if (index < _polygons.length) {
          _polygons.removeAt(index);

          // Si une station est sélectionnée, supprimer le polygone de cette station
          if (_selectedStation != null && stationService != null) {
            stationService!.removeGeographicFeature(_selectedStation!, 'polygon', index);
          }
        }
        break;
      default:
        break;
    }

    notifyListeners();
  }

  // Commencer l'édition d'un élément
  void _startEditing(int index, DrawTool type) {
    _isEditing = true;
    _editingIndex = index;
    _editingType = type;
    notifyListeners();
  }

  // Méthodes pour récupérer les géométries
  List<Marker> getPointMarkers() {
    return _points.map((p) => Marker(
      point: p,
      width: 30,
      height: 30,
      child: const Icon(Icons.location_on, color: Colors.red, size: 30),
    )).toList();
  }

  List<Marker> getEditVertexMarkers() {
    return _editMarkers;
  }

  List<LatLng> getCurrentPoints() {
    return List.from(_currentPoints);
  }

  // Méthodes pour récupérer les géométries pour l'affichage
  List<Polyline> getPolylines() {
    final polylines = <Polyline>[];

    // Lignes sauvegardées
    for (final line in _lines) {
      polylines.add(
        Polyline(
          points: line,
          strokeWidth: 4.0,
          color: Colors.blue,
          // Utiliser pattern au lieu de isDotted pour compatibilité
          pattern: const StrokePattern.solid(),
        ),
      );
    }

    // Ligne en cours de dessin
    if (_currentTool == DrawTool.line && _currentPoints.isNotEmpty) {
      final allPoints = List<LatLng>.from(_currentPoints);

      // Ajouter le point temporaire s'il existe
      if (_tempMarker != null) {
        allPoints.add(_tempMarker!.point);
      }

      polylines.add(
        Polyline(
          points: allPoints,
          strokeWidth: 4.0,
          color: Colors.orange,
          // Utiliser pattern avec StrokePattern.dot() au lieu de isDotted
          pattern: const StrokePattern.dash(),
        ),
      );
    }

    return polylines;
  }

  List<Polygon> getPolygons() {
    final polygons = <Polygon>[];

    // Polygones sauvegardés
    for (final polygon in _polygons) {
      polygons.add(
        Polygon(
          points: polygon,
          borderStrokeWidth: 4.0,
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
          // Pas besoin de isFilled, color non-null le fait automatiquement
        ),
      );
    }

    // Polygone en cours de dessin
    if (_currentTool == DrawTool.polygon && _currentPoints.length >= 2) {
      final allPoints = List<LatLng>.from(_currentPoints);

      // Ajouter le point temporaire s'il existe et qu'il y a au moins 2 points
      if (_tempMarker != null) {
        allPoints.add(_tempMarker!.point);
      }

      // Fermer le polygone pour la visualisation
      if (allPoints.length >= 3) {
        polygons.add(
          Polygon(
            points: [...allPoints, allPoints.first],
            borderStrokeWidth: 4.0,
            color: Colors.orange.withOpacity(0.3),
            borderColor: Colors.orange,
            // Utiliser pattern au lieu de isDotted
            pattern: const StrokePattern.dash(),
          ),
        );
      }
    }

    return polygons;
  }

  // Méthode pour supprimer une géométrie
  void deleteGeometry(LatLng point, double threshold) {
    // Rechercher un point à supprimer
    int pointIndex = -1;
    for (int i = 0; i < _points.length; i++) {
      final distance = _calculateDistance(_points[i], point);
      if (distance < threshold) {
        pointIndex = i;
        break;
      }
    }

    if (pointIndex >= 0) {
      _points.removeAt(pointIndex);

      // Si une station est sélectionnée, supprimer le point
      if (_selectedStation != null && stationService != null) {
        stationService!.removeGeographicFeature(_selectedStation!, 'point', pointIndex);
      }

      notifyListeners();
      return;
    }

    // Rechercher une ligne à supprimer
    int lineIndex = -1;
    for (int i = 0; i < _lines.length; i++) {
      if (_isPointNearLine(_lines[i], point, threshold)) {
        lineIndex = i;
        break;
      }
    }

    if (lineIndex >= 0) {
      _lines.removeAt(lineIndex);

      // Si une station est sélectionnée, supprimer la ligne
      if (_selectedStation != null && stationService != null) {
        stationService!.removeGeographicFeature(_selectedStation!, 'line', lineIndex);
      }

      notifyListeners();
      return;
    }

    // Rechercher un polygone à supprimer
    int polygonIndex = -1;
    for (int i = 0; i < _polygons.length; i++) {
      if (_isPointInPolygon(_polygons[i], point) ||
          _isPointNearPolygonBorder(_polygons[i], point, threshold)) {
        polygonIndex = i;
        break;
      }
    }

    if (polygonIndex >= 0) {
      _polygons.removeAt(polygonIndex);

      // Si une station est sélectionnée, supprimer le polygone
      if (_selectedStation != null && stationService != null) {
        stationService!.removeGeographicFeature(_selectedStation!, 'polygon', polygonIndex);
      }

      notifyListeners();
      return;
    }
  }

  // Méthodes auxiliaires
  double _calculateDistance(LatLng p1, LatLng p2) {
    return math.sqrt(math.pow(p1.latitude - p2.latitude, 2) +
        math.pow(p1.longitude - p2.longitude, 2));
  }

  bool _isPointNearLine(List<LatLng> line, LatLng point, double threshold) {
    for (int i = 0; i < line.length - 1; i++) {
      final p1 = line[i];
      final p2 = line[i + 1];

      // Distance du point au segment
      final distance = _distanceToSegment(point, p1, p2);
      if (distance < threshold) {
        return true;
      }
    }
    return false;
  }

  double _distanceToSegment(LatLng p, LatLng s1, LatLng s2) {
    final x = p.longitude;
    final y = p.latitude;
    final x1 = s1.longitude;
    final y1 = s1.latitude;
    final x2 = s2.longitude;
    final y2 = s2.latitude;

    final A = x - x1;
    final B = y - y1;
    final C = x2 - x1;
    final D = y2 - y1;

    final dot = A * C + B * D;
    final len_sq = C * C + D * D;
    double param = -1;

    if (len_sq != 0) {
      param = dot / len_sq;
    }

    double xx, yy;

    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    final dx = x - xx;
    final dy = y - yy;

    return dx * dx + dy * dy;
  }

  bool _isPointInPolygon(List<LatLng> polygon, LatLng point) {
    // Algorithme du "point in polygon"
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude) &&
          point.longitude < (polygon[j].longitude - polygon[i].longitude) *
              (point.latitude - polygon[i].latitude) / (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool _isPointNearPolygonBorder(List<LatLng> polygon, LatLng point, double threshold) {
    return _isPointNearLine(polygon, point, threshold);
  }

  // Obtenir toutes les géométries actives sous forme de dictionnaire pour sauvegarder dans la station
  Map<String, dynamic> getGeometriesForStation() {
    return {
      'points': _points,
      'lignes': _lines,
      'polygones': _polygons,
    };
  }

  // Méthode pour sélectionner une station
  void selectStation(Station station) {
    _selectedStation = station;
    _currentStation = station;

    // Charger les géométries de la station
    if (stationService != null) {
      final geometries = stationService!.getStationGeometries(station);

      // Charger les points
      _points.clear();
      if (geometries['points'] != null) {
        _points.addAll(List<LatLng>.from(geometries['points']));
      }

      // Charger les lignes
      _lines.clear();
      if (geometries['lignes'] != null) {
        for (final ligne in geometries['lignes']) {
          if (ligne is List<LatLng> && ligne.isNotEmpty) {
            _lines.add(List<LatLng>.from(ligne));
          }
        }
      }

      // Charger les polygones
      _polygons.clear();
      if (geometries['polygones'] != null) {
        for (final poly in geometries['polygones']) {
          if (poly is List<LatLng> && poly.isNotEmpty) {
            _polygons.add(List<LatLng>.from(poly));
          }
        }
      }
    }

    notifyListeners();
  }

  // Méthode pour annuler la dernière action
  void undo() {
    if (_currentPoints.isNotEmpty) {
      // S'il y a un chemin en cours, enlever le dernier point
      _currentPoints.removeLast();
    } else if (_points.isNotEmpty) {
      // Ou le dernier point
      _points.removeLast();
    } else if (_lines.isNotEmpty) {
      // Sinon, enlever la dernière polyligne
      _lines.removeLast();
    } else if (_polygons.isNotEmpty) {
      // Ou le dernier polygone
      _polygons.removeLast();
    }
    notifyListeners();
  }

  // Méthode pour tout effacer
  void clearAll() {
    _currentPoints.clear();
    _points.clear();
    _lines.clear();
    _polygons.clear();
    _editMarkers.clear();
    _tempMarker = null;
    notifyListeners();
  }

  // Méthode pour réinitialiser tout
  void reset() {
    _currentTool = DrawTool.none;
    _currentPoints.clear();
    _points.clear();
    _lines.clear();
    _polygons.clear();
    _editMarkers.clear();
    _tempMarker = null;
    _currentStation = null;
    _selectedStation = null;
    _isEditing = false;
    _editingIndex = null;
    _editingType = null;
    notifyListeners();
  }
}