// Événements
import 'dart:math' as math;
import 'package:boom_mobile/data/interfaces/commands.dart';
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:boom_mobile/data/interfaces/draw_service_interface.dart';
import 'package:latlong2/latlong.dart';


abstract class DrawEvent {}

class AddPointEvent extends DrawEvent {
  final LatLng point;
  final Station? station;

  AddPointEvent(this.point, {this.station});
}

class AddLinePointEvent extends DrawEvent {
  final LatLng point;
  AddLinePointEvent(this.point);
}

class AddPolygonPointEvent extends DrawEvent {
  final LatLng point;
  AddPolygonPointEvent(this.point);
}

class CompleteDrawingEvent extends DrawEvent {}

class UndoEvent extends DrawEvent {}

class RedoEvent extends DrawEvent {}

class SetToolEvent extends DrawEvent {
  final DrawTool tool;
  SetToolEvent(this.tool);
}

class ClearEvent extends DrawEvent {}

// États
class DrawState {
  final List<LatLng> points;
  final List<List<LatLng>> lines;
  final List<List<LatLng>> polygons;
  final List<LatLng> currentPoints;
  final DrawTool currentTool;

  DrawState({
    required this.points,
    required this.lines,
    required this.polygons,
    required this.currentPoints,
    required this.currentTool,
  });

  DrawState copyWith({
    List<LatLng>? points,
    List<List<LatLng>>? lines,
    List<List<LatLng>>? polygons,
    List<LatLng>? currentPoints,
    DrawTool? currentTool,
  }) {
    return DrawState(
      points: points ?? this.points,
      lines: lines ?? this.lines,
      polygons: polygons ?? this.polygons,
      currentPoints: currentPoints ?? this.currentPoints,
      currentTool: currentTool ?? this.currentTool,
    );
  }
}

// Bloc
class DrawBloc extends Bloc<DrawEvent, DrawState> implements DrawServiceInterface {
  final CommandManager _commandManager = CommandManager();
  final StationService _stationService;

  DrawBloc(this._stationService) : super(DrawState(
    points: [],
    lines: [],
    polygons: [],
    currentPoints: [],
    currentTool: DrawTool.none,
  )) {
    on<AddPointEvent>(_onAddPoint);
    on<AddLinePointEvent>(_onAddLinePoint);
    on<AddPolygonPointEvent>(_onAddPolygonPoint);
    on<CompleteDrawingEvent>(_onCompleteDrawing);
    on<UndoEvent>(_onUndo);
    on<RedoEvent>(_onRedo);
    on<SetToolEvent>(_onSetTool);
    on<ClearEvent>(_onClear);
  }

  @override
  StationService? get stationService => _stationService;

  @override
  List<LatLng> get points => state.points;

  @override
  List<List<LatLng>> get polylines => state.lines;

  @override
  List<List<LatLng>> get polygons => state.polygons;

  @override
  List<LatLng> get currentPoints => state.currentPoints;

  @override
  DrawTool get currentTool => state.currentTool;

  @override
  Station? get currentStation => null; // À implémenter si nécessaire

  Marker? _tempMarker;

  @override
  Marker? get tempMarker => _tempMarker;


  void _onAddPoint(AddPointEvent event, Emitter<DrawState> emit) {
    if (state.currentTool != DrawTool.point) return;

    // Créer une copie de la liste des points
    final updatedPoints = List<LatLng>.from(state.points)..add(event.point);

    // Si une station est spécifiée, ajouter le point à cette station
    if (event.station != null) {
      _stationService.addPointToStation(event.station!, event.point);
    }

    emit(state.copyWith(points: updatedPoints));
  }

  void _onAddLinePoint(AddLinePointEvent event, Emitter<DrawState> emit) {
    if (state.currentTool != DrawTool.line) return;

    final updatedCurrentPoints = List<LatLng>.from(state.currentPoints)..add(event.point);
    emit(state.copyWith(currentPoints: updatedCurrentPoints));
  }

  void _onAddPolygonPoint(AddPolygonPointEvent event, Emitter<DrawState> emit) {
    if (state.currentTool != DrawTool.polygon) return;

    final updatedCurrentPoints = List<LatLng>.from(state.currentPoints)..add(event.point);
    emit(state.copyWith(currentPoints: updatedCurrentPoints));
  }



  void _onCompleteDrawing(CompleteDrawingEvent event, Emitter<DrawState> emit) {
    if (state.currentPoints.length < 2) return;

    if (state.currentTool == DrawTool.line) {
      final updatedLines = List<List<LatLng>>.from(state.lines)
        ..add(List<LatLng>.from(state.currentPoints));

      emit(state.copyWith(
        lines: updatedLines,
        currentPoints: [],
      ));
    } else if (state.currentTool == DrawTool.polygon && state.currentPoints.length >= 3) {
      final polygonPoints = List<LatLng>.from(state.currentPoints);

      // Fermer le polygone si nécessaire
      if (polygonPoints.first != polygonPoints.last) {
        polygonPoints.add(polygonPoints.first);
      }

      final updatedPolygons = List<List<LatLng>>.from(state.polygons)
        ..add(polygonPoints);

      emit(state.copyWith(
        polygons: updatedPolygons,
        currentPoints: [],
      ));
    }
  }

  void _onUndo(UndoEvent event, Emitter<DrawState> emit) {
    if (state.currentPoints.isNotEmpty) {
      // S'il y a des points en cours, enlever le dernier
      final updatedCurrentPoints = List<LatLng>.from(state.currentPoints)..removeLast();
      emit(state.copyWith(currentPoints: updatedCurrentPoints));
    } else if (state.points.isNotEmpty) {
      // Ou le dernier point
      final updatedPoints = List<LatLng>.from(state.points)..removeLast();
      emit(state.copyWith(points: updatedPoints));
    } else if (state.lines.isNotEmpty) {
      // Sinon, enlever la dernière ligne
      final updatedLines = List<List<LatLng>>.from(state.lines)..removeLast();
      emit(state.copyWith(lines: updatedLines));
    } else if (state.polygons.isNotEmpty) {
      // Ou le dernier polygone
      final updatedPolygons = List<List<LatLng>>.from(state.polygons)..removeLast();
      emit(state.copyWith(polygons: updatedPolygons));
    }
  }

  void _onRedo(RedoEvent event, Emitter<DrawState> emit) {
    // À implémenter avec CommandManager
  }

  void _onSetTool(SetToolEvent event, Emitter<DrawState> emit) {
    // Si on change d'outil, terminer le dessin en cours
    if (state.currentTool != event.tool && state.currentPoints.isNotEmpty) {
      add(CompleteDrawingEvent());
    }

    emit(state.copyWith(currentTool: event.tool));
  }

  void _onClear(ClearEvent event, Emitter<DrawState> emit) {
    emit(state.copyWith(
      points: [],
      lines: [],
      polygons: [],
      currentPoints: [],
    ));
  }

  // Implémentation de DrawServiceInterface pour compatibilité
  @override
  void addPoint(LatLng point) {
    add(AddPointEvent(point));
  }

  @override
  void addLinePoint(LatLng point) {
    add(AddLinePointEvent(point));
  }

  @override
  void addPolygonPoint(LatLng point) {
    add(AddPolygonPointEvent(point));
  }

  @override
  void completeCurrentDrawing() {
    add(CompleteDrawingEvent());
  }

  @override
  void loadStationGeometries(Station station) {
    // Implémentation complète
    if (_stationService == null) return;

    final geometries = _stationService.getStationGeometries(station);

    final stationPoints = geometries['points'] as List<LatLng>? ?? [];
    final stationLines = geometries['lignes'] as List<List<LatLng>>? ?? [];
    final stationPolygons = geometries['polygones'] as List<List<LatLng>>? ?? [];

    emit(state.copyWith(
      points: stationPoints,
      lines: stationLines,
      polygons: stationPolygons,
      currentPoints: [],
    ));
  }

  @override
  void selectStation(Station station) {
    loadStationGeometries(station);
  }

  @override
  Map<String, dynamic> getGeometriesForStation() {
    return {
      'points': state.points,
      'lignes': state.lines,
      'polygones': state.polygons,
    };
  }

  @override
  void deleteGeometry(LatLng point, double threshold) {
    // Implémentation complète pour supprimer les géométries proches du point

    // Vérifier les points
    int? pointIndexToRemove;
    for (int i = 0; i < state.points.length; i++) {
      if (_calculateDistance(state.points[i], point) < threshold) {
        pointIndexToRemove = i;
        break;
      }
    }

    if (pointIndexToRemove != null) {
      final newPoints = List<LatLng>.from(state.points);
      newPoints.removeAt(pointIndexToRemove);
      emit(state.copyWith(points: newPoints));
      return;
    }

    // Vérifier les lignes
    int? lineIndexToRemove;
    for (int i = 0; i < state.lines.length; i++) {
      if (_isPointNearLine(state.lines[i], point, threshold)) {
        lineIndexToRemove = i;
        break;
      }
    }

    if (lineIndexToRemove != null) {
      final newLines = List<List<LatLng>>.from(state.lines);
      newLines.removeAt(lineIndexToRemove);
      emit(state.copyWith(lines: newLines));
      return;
    }

    // Vérifier les polygones
    int? polygonIndexToRemove;
    for (int i = 0; i < state.polygons.length; i++) {
      if (_isPointInPolygon(state.polygons[i], point) ||
          _isPointNearPolygonBorder(state.polygons[i], point, threshold)) {
        polygonIndexToRemove = i;
        break;
      }
    }

    if (polygonIndexToRemove != null) {
      final newPolygons = List<List<LatLng>>.from(state.polygons);
      newPolygons.removeAt(polygonIndexToRemove);
      emit(state.copyWith(polygons: newPolygons));
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return math.sqrt(math.pow(p1.latitude - p2.latitude, 2) +
        math.pow(p1.longitude - p2.longitude, 2));
  }

  bool _isPointNearLine(List<LatLng> line, LatLng point, double threshold) {
    for (int i = 0; i < line.length - 1; i++) {
      final p1 = line[i];
      final p2 = line[i + 1];

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
    final lenSq = C * C + D * D;
    double param = -1;

    if (lenSq != 0) {
      param = dot / lenSq;
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

    return math.sqrt(dx * dx + dy * dy);
  }

  bool _isPointInPolygon(List<LatLng> polygon, LatLng point) {
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].latitude > point.latitude) !=
          (polygon[j].latitude > point.latitude) &&
          point.longitude < (polygon[j].longitude - polygon[i].longitude) *
              (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude) {
        inside = !inside;
      }
    }
    return inside;
  }

  bool _isPointNearPolygonBorder(List<LatLng> polygon, LatLng point, double threshold) {
    return _isPointNearLine(polygon, point, threshold);
  }

  @override
  List<Marker> getPointMarkers() {
    return state.points.map((p) => Marker(
      point: p,
      width: 30,
      height: 30,
      child: const Icon(Icons.location_on, color: Colors.red, size: 30),
    )).toList();
  }

  @override
  List<Marker> getEditVertexMarkers() {
    final List<Marker> markers = [];

    // Ajouter des marqueurs pour les points
    for (int i = 0; i < state.points.length; i++) {
      final point = state.points[i];
      markers.add(Marker(
        point: point,
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ));
    }

    // Ajouter des marqueurs pour les vertices des lignes
    for (final line in state.lines) {
      for (final point in line) {
        markers.add(Marker(
          point: point,
          width: 16,
          height: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ));
      }
    }

    // Ajouter des marqueurs pour les vertices des polygones
    for (final polygon in state.polygons) {
      for (final point in polygon) {
        markers.add(Marker(
          point: point,
          width: 16,
          height: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.purple,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ));
      }
    }

    return markers;
  }

  @override
  List<Polyline> getPolylines() {
    final List<Polyline> polylines = [];

    // Lignes existantes
    for (final line in state.lines) {
      polylines.add(
        Polyline(
          points: line,
          strokeWidth: 4.0,
          color: Colors.blue,
          pattern: const StrokePattern.solid(),
        ),
      );
    }

    // Ligne en cours de création
    if (state.currentTool == DrawTool.line && state.currentPoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: state.currentPoints,
          strokeWidth: 4.0,
          color: Colors.orange,
          pattern: StrokePattern.dashed(segments: [2, 2]),
        ),
      );
    }

    return polylines;
  }

  @override
  List<Polygon> getPolygons() {
    final List<Polygon> polygons = [];

    // Polygones existants
    for (final polygon in state.polygons) {
      polygons.add(
        Polygon(
          points: polygon,
          borderStrokeWidth: 4.0,
          color: Colors.blue.withValues(alpha: 77, red: 0, green: 0, blue: 255),
          borderColor: Colors.blue,
        ),
      );
    }

    // Polygone en cours de création
    if (state.currentTool == DrawTool.polygon && state.currentPoints.length >= 3) {
      polygons.add(
        Polygon(
          points: [...state.currentPoints, state.currentPoints.first],
          borderStrokeWidth: 4.0,
          color: Colors.orange.withValues(alpha: 77, red: 255, green: 165, blue: 0),
          borderColor: Colors.orange,
          pattern: StrokePattern.dashed(segments: [5, 5]),
        ),
      );
    }

    return polygons;
  }

  @override
  void setTempMarker(LatLng point) {
    if (state.currentTool == DrawTool.line || state.currentTool == DrawTool.polygon) {
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
    } else {
      _tempMarker = null;
    }
  }

  @override
  void cancelDrawing() {
    emit(state.copyWith(currentPoints: []));
    _tempMarker = null;
  }
  @override
  List<LatLng> getCurrentPoints() {
    return state.currentPoints;
  }

  @override
  void handleMapTap(LatLng point) {
    // Selon l'outil actif
    switch (state.currentTool) {
      case DrawTool.point:
        add(AddPointEvent(point));
        break;
      case DrawTool.line:
        add(AddLinePointEvent(point));
        break;
      case DrawTool.polygon:
        add(AddPolygonPointEvent(point));
        break;
      default:
        break;
    }
  }

  @override
  void handleMapLongPress(LatLng point) {
    if (state.currentTool == DrawTool.line || state.currentTool == DrawTool.polygon) {
      add(CompleteDrawingEvent());
    }
  }

  @override
  void undo() {
    add(UndoEvent());
  }

  @override
  void clearAll() {
    add(ClearEvent());
  }

  @override
  void reset() {
    add(ClearEvent());
    add(SetToolEvent(DrawTool.none));
  }

  @override
  void finishDrawing() {
    add(CompleteDrawingEvent());
  }

  @override
  void setTool(DrawTool tool) {
    add(SetToolEvent(tool));
  }
}