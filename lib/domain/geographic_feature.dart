import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

enum FeatureType {
  point,
  line,
  polygon
}

// Extension pour obtenir une chaîne à partir du type
extension FeatureTypeExtension on FeatureType {
  String get name {
    switch (this) {
      case FeatureType.point: return 'point';
      case FeatureType.line: return 'ligne';
      case FeatureType.polygon: return 'polygone';
    }
  }

  IconData get icon {
    switch (this) {
      case FeatureType.point: return Icons.location_on;
      case FeatureType.line: return Icons.timeline;
      case FeatureType.polygon: return Icons.pentagon;
    }
  }
}

// Classe représentant une forme géographique
class GeographicFeature {
  final String id;
  final FeatureType type;
  final List<LatLng> points;
  final Map<String, dynamic>? properties;
  final Color color;

  // Constructeur principal
  GeographicFeature({
    required this.id,
    required this.type,
    required this.points,
    this.properties,
    Color? color,
  }) : color = color ?? _getDefaultColor(type);

  // Constructeur pour créer un point
  factory GeographicFeature.point(
      LatLng point, {
        String? id,
        Map<String, dynamic>? properties,
        Color? color,
      }) {
    return GeographicFeature(
      id: id ?? 'point_${DateTime.now().millisecondsSinceEpoch}_${(properties?['name'] ?? '')}',
      type: FeatureType.point,
      points: [point],
      properties: properties,
      color: color,
    );
  }

  // Constructeur pour créer une ligne
  factory GeographicFeature.line(
      List<LatLng> points, {
        String? id,
        Map<String, dynamic>? properties,
        Color? color,
      }) {
    if (points.length < 2) {
      throw ArgumentError('Une ligne doit avoir au moins 2 points');
    }

    return GeographicFeature(
      id: id ?? 'line_${DateTime.now().millisecondsSinceEpoch}',
      type: FeatureType.line,
      points: points,
      properties: properties,
      color: color,
    );
  }

  // Constructeur pour créer un polygone
  factory GeographicFeature.polygon(
      List<LatLng> points, {
        String? id,
        Map<String, dynamic>? properties,
        Color? color,
      }) {
    if (points.length < 3) {
      throw ArgumentError('Un polygone doit avoir au moins 3 points');
    }

    // Vérifier si le polygone est fermé, sinon fermer automatiquement
    if (points.first.latitude != points.last.latitude ||
        points.first.longitude != points.last.longitude) {
      points.add(points.first);
    }

    return GeographicFeature(
      id: id ?? 'polygon_${DateTime.now().millisecondsSinceEpoch}',
      type: FeatureType.polygon,
      points: points,
      properties: properties,
      color: color,
    );
  }

  // Méthode pour copier avec des modifications
  GeographicFeature copyWith({
    String? id,
    FeatureType? type,
    List<LatLng>? points,
    Map<String, dynamic>? properties,
    Color? color,
  }) {
    return GeographicFeature(
      id: id ?? this.id,
      type: type ?? this.type,
      points: points ?? this.points,
      properties: properties ?? this.properties,
      color: color ?? this.color,
    );
  }

  // Méthode pour convertir en GeoJSON
  Map<String, dynamic> toGeoJson() {
    String typeStr;
    List<dynamic> coordinates;

    switch (type) {
      case FeatureType.point:
        typeStr = 'Point';
        final point = points.first;
        coordinates = [point.longitude, point.latitude];
        break;

      case FeatureType.line:
        typeStr = 'LineString';
        coordinates = points.map((p) => [p.longitude, p.latitude]).toList();
        break;

      case FeatureType.polygon:
        typeStr = 'Polygon';
        coordinates = [
          points.map((p) => [p.longitude, p.latitude]).toList()
        ];
        break;
    }

    return {
      'type': 'Feature',
      'id': id,
      'geometry': {
        'type': typeStr,
        'coordinates': coordinates,
      },
      'properties': properties ?? {},
    };
  }

  // Créer à partir de GeoJSON
  factory GeographicFeature.fromGeoJson(Map<String, dynamic> json) {
    final String featureId = json['id'] ?? 'feature_${DateTime.now().millisecondsSinceEpoch}';
    final Map<String, dynamic> geometry = json['geometry'];
    final String geometryType = geometry['type'];
    final properties = json['properties'] as Map<String, dynamic>?;

    FeatureType featureType;
    List<LatLng> points = [];

    switch (geometryType) {
      case 'Point':
        featureType = FeatureType.point;
        final List<dynamic> coords = geometry['coordinates'];
        points.add(LatLng(coords[1], coords[0]));
        break;

      case 'LineString':
        featureType = FeatureType.line;
        final List<dynamic> coords = geometry['coordinates'];
        for (final coord in coords) {
          points.add(LatLng(coord[1], coord[0]));
        }
        break;

      case 'Polygon':
        featureType = FeatureType.polygon;
        final List<dynamic> coordsRings = geometry['coordinates'];
        // Utiliser seulement le premier anneau (extérieur)
        final List<dynamic> coords = coordsRings[0];
        for (final coord in coords) {
          points.add(LatLng(coord[1], coord[0]));
        }
        break;

      default:
        throw ArgumentError('Type de géométrie non supporté: $geometryType');
    }

    // Extraire la couleur depuis les propriétés si disponible
    Color? color;
    if (properties != null && properties['color'] != null) {
      final String colorStr = properties['color'];
      if (colorStr.startsWith('#')) {
        color = Color(int.parse('0xFF${colorStr.substring(1)}'));
      }
    }

    return GeographicFeature(
      id: featureId,
      type: featureType,
      points: points,
      properties: properties,
      color: color,
    );
  }

  // Vérifier si un point est proche de cette forme
  bool isNearPoint(LatLng point, double tolerance) {
    switch (type) {
      case FeatureType.point:
        final distance = Distance().as(
          LengthUnit.Meter,
          point,
          points.first,
        );
        return distance <= tolerance;

      case FeatureType.line:
        for (int i = 0; i < points.length - 1; i++) {
          final distance = _distancePointToSegment(
            point,
            points[i],
            points[i + 1],
          );
          if (distance <= tolerance) {
            return true;
          }
        }
        return false;

      case FeatureType.polygon:
      // Vérifier la proximité au périmètre
        for (int i = 0; i < points.length - 1; i++) {
          final distance = _distancePointToSegment(
            point,
            points[i],
            points[i + 1],
          );
          if (distance <= tolerance) {
            return true;
          }
        }

        // Vérifier si le point est à l'intérieur
        return _isPointInPolygon(point, points);
    }
  }

  // Obtenir l'index du point le plus proche d'un point donné
  int getNearestPointIndex(LatLng point) {
    int nearestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final distance = Distance().as(
        LengthUnit.Meter,
        point,
        points[i],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    return nearestIndex;
  }

  // Couleur par défaut selon le type
  static Color _getDefaultColor(FeatureType type) {
    switch (type) {
      case FeatureType.point: return Colors.red;
      case FeatureType.line: return Colors.blue;
      case FeatureType.polygon: return Colors.green;
    }
  }

  // Calculer la distance d'un point à un segment
  static double _distancePointToSegment(LatLng point, LatLng segmentStart, LatLng segmentEnd) {
    // Convertir en coordonnées cartésiennes pour simplifier les calculs
    final x = point.longitude;
    final y = point.latitude;
    final x1 = segmentStart.longitude;
    final y1 = segmentStart.latitude;
    final x2 = segmentEnd.longitude;
    final y2 = segmentEnd.latitude;

    // Longueur du segment au carré
    final l2 = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);

    // Si le segment est un point, retourner la distance au point
    if (l2 == 0) return Distance().as(LengthUnit.Meter, point, segmentStart);

    // Projection du point sur la ligne
    double t = ((x - x1) * (x2 - x1) + (y - y1) * (y2 - y1)) / l2;

    // Limiter t à [0,1] pour rester sur le segment
    t = (t < 0) ? 0 : (t > 1) ? 1 : t;

    // Point projeté sur le segment
    final projX = x1 + t * (x2 - x1);
    final projY = y1 + t * (y2 - y1);

    // Retourner la distance au point projeté
    return Distance().as(
      LengthUnit.Meter,
      point,
      LatLng(projY, projX),
    );
  }

  // Vérifier si un point est à l'intérieur d'un polygone (ray casting algorithm)
  static bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool isInside = false;
    final x = point.longitude;
    final y = point.latitude;

    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

      if (intersect) isInside = !isInside;
    }

    return isInside;
  }
}