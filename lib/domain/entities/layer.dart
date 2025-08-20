import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Layer {
  final String nom;
  final String type;
  final String date;
  final LatLng? center;
  final List<Marker> Function(BuildContext, {bool showBadges}) markerBuilder;

  // ✅ Ajout des builders pour polygones et polylignes
  final List<Polygon> Function(BuildContext)? polygonBuilder;
  final List<Polyline> Function(BuildContext)? polylineBuilder;

  Layer({
    required this.nom,
    required this.type,
    required this.date,
    required this.center,
    required this.markerBuilder,
    this.polygonBuilder,
    this.polylineBuilder,
  });

  factory Layer.fromMap(Map<String, String> map) {
    return Layer(
      nom: map['nom'] ?? '',
      type: map['type'] ?? '',
      date: map['date'] ?? '',
      center: null,
      markerBuilder: (_, {showBadges = true}) => [],
      polygonBuilder: null,
      polylineBuilder: null,
    );
  }

  // ✅ Méthode helper pour créer une layer avec polygones
  factory Layer.withPolygons({
    required String nom,
    required String type,
    required String date,
    required LatLng center,
    required List<Polygon> Function(BuildContext) polygonBuilder,
    List<Marker> Function(BuildContext, {bool showBadges})? markerBuilder,
  }) {
    return Layer(
      nom: nom,
      type: type,
      date: date,
      center: center,
      markerBuilder: markerBuilder ?? (_, {showBadges = true}) => [],
      polygonBuilder: polygonBuilder,
    );
  }

  // ✅ Méthode helper pour créer une layer avec polylignes
  factory Layer.withPolylines({
    required String nom,
    required String type,
    required String date,
    required LatLng center,
    required List<Polyline> Function(BuildContext) polylineBuilder,
    List<Marker> Function(BuildContext, {bool showBadges})? markerBuilder,
  }) {
    return Layer(
      nom: nom,
      type: type,
      date: date,
      center: center,
      markerBuilder: markerBuilder ?? (_, {showBadges = true}) => [],
      polylineBuilder: polylineBuilder,
    );
  }

  // ✅ Méthode helper pour créer une layer complète
  factory Layer.complete({
    required String nom,
    required String type,
    required String date,
    required LatLng center,
    required List<Marker> Function(BuildContext, {bool showBadges}) markerBuilder,
    List<Polygon> Function(BuildContext)? polygonBuilder,
    List<Polyline> Function(BuildContext)? polylineBuilder,
  }) {
    return Layer(
      nom: nom,
      type: type,
      date: date,
      center: center,
      markerBuilder: markerBuilder,
      polygonBuilder: polygonBuilder,
      polylineBuilder: polylineBuilder,
    );
  }
}