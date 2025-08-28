
import 'package:latlong2/latlong.dart';

class StationSnapshot {
  final String id;
  final DateTime timestamp;
  final Map<String, dynamic> geometries;

  StationSnapshot({
    required this.id,
    required this.timestamp,
    required this.geometries,
  });

  // Convertir en JSON pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'geometries': {
        'points': geometries['points']?.map<List<double>>((p) => [p.latitude, p.longitude]).toList(),
        'lignes': geometries['lignes']?.map<List<List<double>>>((ligne) =>
            ligne.map<List<double>>((p) => [p.latitude, p.longitude]).toList()).toList(),
        'polygones': geometries['polygones']?.map<List<List<double>>>((poly) =>
            poly.map<List<double>>((p) => [p.latitude, p.longitude]).toList()).toList(),
      }
    };
  }

  // Créer à partir de JSON
  factory StationSnapshot.fromJson(Map<String, dynamic> json) {
    return StationSnapshot(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      geometries: {
        'points': (json['geometries']['points'] as List?)?.map<LatLng>((p) =>
            LatLng(p[0], p[1])).toList() ?? [],
        'lignes': (json['geometries']['lignes'] as List?)?.map<List<LatLng>>((ligne) =>
            (ligne as List).map<LatLng>((p) => LatLng(p[0], p[1])).toList()).toList() ?? [],
        'polygones': (json['geometries']['polygones'] as List?)?.map<List<LatLng>>((poly) =>
            (poly as List).map<LatLng>((p) => LatLng(p[0], p[1])).toList()).toList() ?? [],
      },
    );
  }
}