// Dans draw_service_interface.dart
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Définir l'enum ici uniquement
enum DrawTool {
  none,
  point,
  line,
  polygon,
  edit,
  delete,
}

abstract class DrawServiceInterface {
  // Propriétés
  StationService? get stationService;
  List<LatLng> get points;
  List<List<LatLng>> get polylines;
  List<List<LatLng>> get polygons;
  List<LatLng> get currentPoints;
  DrawTool get currentTool;
  Station? get currentStation;
  Marker? get tempMarker;

  // Méthodes pour les points
  void addPoint(LatLng point);
  void addLinePoint(LatLng point);
  void addPolygonPoint(LatLng point);
  void completeCurrentDrawing();

  // Méthodes pour les outils
  void setTool(DrawTool tool);
  void setTempMarker(LatLng point);

  // Méthodes pour les stations
  void loadStationGeometries(Station station);
  void selectStation(Station station);
  Map<String, dynamic> getGeometriesForStation();

  // Méthodes pour la gestion des géométries
  void deleteGeometry(LatLng point, double threshold);
  List<Marker> getPointMarkers();
  List<Marker> getEditVertexMarkers();
  List<Polyline> getPolylines();
  List<Polygon> getPolygons();
  List<LatLng> getCurrentPoints();

  // Méthodes pour l'édition
  void handleMapTap(LatLng point);
  void handleMapLongPress(LatLng point);
  void undo();
  void clearAll();
  void reset();
  void finishDrawing();
  void cancelDrawing();
}