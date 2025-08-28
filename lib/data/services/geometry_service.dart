import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../repositories/geometry_repository.dart';

// ✅ CORRECTION : GeometryService doit hériter de ChangeNotifier
class GeometryService with ChangeNotifier {
  final GeometryRepository _repository;

  GeometryService(this._repository);

  // Méthodes pour manipuler les géométries
  void addPoint(String stationId, LatLng point) {
    final geometries = _repository.getStationGeometries(stationId);
    final points = List<LatLng>.from(geometries['points'] ?? []);
    points.add(point);
    _repository.saveStationGeometries(stationId, points: points);
    notifyListeners(); // ✅ AJOUT
  }

  void removePoint(String stationId, int index) {
    final geometries = _repository.getStationGeometries(stationId);
    final points = List<LatLng>.from(geometries['points'] ?? []);
    if (index >= 0 && index < points.length) {
      points.removeAt(index);
      _repository.saveStationGeometries(stationId, points: points);
      notifyListeners(); // ✅ AJOUT
    }
  }

  // Lignes
  void addLine(String stationId, List<LatLng> line) {
    final geometries = _repository.getStationGeometries(stationId);
    final lines = List<List<LatLng>>.from(geometries['lines'] ?? []);
    lines.add(line);
    _repository.saveStationGeometries(stationId, lines: lines);
    notifyListeners(); // ✅ AJOUT
  }

  void removeLine(String stationId, int index) {
    final geometries = _repository.getStationGeometries(stationId);
    final lines = List<List<LatLng>>.from(geometries['lines'] ?? []);
    if (index >= 0 && index < lines.length) {
      lines.removeAt(index);
      _repository.saveStationGeometries(stationId, lines: lines);
      notifyListeners(); // ✅ AJOUT
    }
  }

  void updateLine(String stationId, int index, List<LatLng> newLine) {
    final geometries = _repository.getStationGeometries(stationId);
    final lines = List<List<LatLng>>.from(geometries['lines'] ?? []);
    if (index >= 0 && index < lines.length) {
      lines[index] = newLine;
      _repository.saveStationGeometries(stationId, lines: lines);
      notifyListeners(); // ✅ AJOUT
    }
  }

  // Polygones
  void addPolygon(String stationId, List<LatLng> polygon) {
    final geometries = _repository.getStationGeometries(stationId);
    final polygons = List<List<LatLng>>.from(geometries['polygons'] ?? []);
    polygons.add(polygon);
    _repository.saveStationGeometries(stationId, polygons: polygons);
    notifyListeners(); // ✅ AJOUT
  }

  void removePolygon(String stationId, int index) {
    final geometries = _repository.getStationGeometries(stationId);
    final polygons = List<List<LatLng>>.from(geometries['polygons'] ?? []);
    if (index >= 0 && index < polygons.length) {
      polygons.removeAt(index);
      _repository.saveStationGeometries(stationId, polygons: polygons);
      notifyListeners(); // ✅ AJOUT
    }
  }

  void updatePolygon(String stationId, int index, List<LatLng> newPolygon) {
    final geometries = _repository.getStationGeometries(stationId);
    final polygons = List<List<LatLng>>.from(geometries['polygons'] ?? []);
    if (index >= 0 && index < polygons.length) {
      polygons[index] = newPolygon;
      _repository.saveStationGeometries(stationId, polygons: polygons);
      notifyListeners(); // ✅ AJOUT
    }
  }

  // Opérations globales
  void clearAllGeometries(String stationId) {
    _repository.saveStationGeometries(
        stationId,
        points: [],
        lines: [],
        polygons: []
    );
    notifyListeners(); // ✅ AJOUT
  }

  bool hasGeometries(String stationId) {
    final geometries = _repository.getStationGeometries(stationId);
    return (geometries['points'] as List?)?.isNotEmpty == true ||
        (geometries['lines'] as List?)?.isNotEmpty == true ||
        (geometries['polygons'] as List?)?.isNotEmpty == true;
  }

  // ✅ AJOUT : Méthode pour obtenir les géométries
  Map<String, dynamic> getStationGeometries(String stationId) {
    return _repository.getStationGeometries(stationId);
  }
}