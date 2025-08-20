import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Dossier {
  final String nom;
  final String type;
  final String date;
  final LatLng? center;
  final List<Station> stations;
  final List<Marker> Function(BuildContext, {bool showBadges}) markerBuilder;


  Dossier({
    required this.nom,
    required this.type,
    required this.date,
    required this.center,
    required this.stations,
    required this.markerBuilder,
  });

  factory Dossier.fromMap(Map<String, String> map) {
    return Dossier(
      nom: map['nom'] ?? '',
      type: map['type'] ?? '',
      date: map['date'] ?? '',
      center: null,
      stations: [],
      markerBuilder: (BuildContext context, {bool showBadges = true}) => [],
    );
  }

}
