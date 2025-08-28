import 'package:latlong2/latlong.dart';

class GeometryRepository {
  // Stockage des géométries
  final Map<String, List<LatLng>> _points = {};
  final Map<String, List<List<LatLng>>> _lines = {};
  final Map<String, List<List<LatLng>>> _polygons = {};

  // Méthodes pour récupérer/sauvegarder les géométries
  void saveStationGeometries(String stationId, {
    List<LatLng>? points,
    List<List<LatLng>>? lines,
    List<List<LatLng>>? polygons,
  }) {
    if (points != null) _points[stationId] = points;
    if (lines != null) _lines[stationId] = lines;
    if (polygons != null) _polygons[stationId] = polygons;
  }

  // Méthodes pour récupérer les géométries
  Map<String, dynamic> getStationGeometries(String stationId) {
    return {
      'points': _points[stationId] ?? [],
      'lines': _lines[stationId] ?? [],
      'polygons': _polygons[stationId] ?? [],
    };
  }
}