import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// Extension pour permettre la modification des propriétés de Station
extension MutableStation on Station {
  // Propriétés pour les formes géographiques
  static List<List<LatLng>> polygones = [];
  static List<List<LatLng>> lignes = [];
  static List<LatLng> points = [];
}


class StationService with ChangeNotifier {
  // ✅ Stockage avec clés String pour cohérence
  final Map<String, Station> _modifiedStations = {};
  final Map<String, Station> _originalStations = {};

  bool get hasModifications => _modifiedStations.isNotEmpty;
  int get modificationsCount => _modifiedStations.length;

  // ✅ Helper pour convertir numeroStation en clé String
  String _getStationKey(Station station) {
    return station.numeroStation.toString();
  }

  Station getStation(Station original) {
    final key = _getStationKey(original);
    return _modifiedStations[key] ?? original;
  }

  bool isStationModified(Station station) {
    final key = _getStationKey(station);
    return _modifiedStations.containsKey(key);
  }
// Correction des erreurs de syntaxe dans updateStation
  void updateStation(Station station, {
    double? latitude,
    double? longitude,
    String? treeLandscape,
    int? humanFrequency,
    bool? espaceBoiseClasse,
    bool? interetPaysager,
    bool? codeEnvironnement,
    bool? alleeArbres,
    bool? perimetreMonument,
    bool? sitePatrimonial,
    bool? autresProtections,
    bool? meriteProtection,
    String? commentaireProtection,
    String? commentaireMeriteProtection,
    List<String>? photoUrls,

    // Identité
    String? identifiantExterne,
    String? archiveNumero,
    String? adresse,
    String? baseDonneesEssence,
    String? essenceLibre,
    String? variete,
    String? stadeDeveloppement,
    bool? sujetVeteran,
    String? anneePlantation,
    bool? appartenantGroupe,
    bool? arbreReplanter,

    // Forme et gabarit
    String? structureTronc,
    String? portForme,
    String? diametreTronc,
    double? circonferenceTronc,
    String? diametreHouppier,
    double? hauteurGenerale,

    // Géométrie - correction : supprimer le '>' supplémentaire
    List<List<LatLng>>? polygones,
    List<List<LatLng>>? lignes,
    List<LatLng>? points,

    String? lastModifiedBy,
    DateTime? lastModifiedDate,
  }) {
    final key = _getStationKey(station);

    // Sauvegarder la version originale si première modification
    if (!_originalStations.containsKey(key)) {
      _originalStations[key] = station;
    }

    // Créer ou récupérer la version modifiée
    final Station modified = _modifiedStations[key] ?? station;

    // Créer une nouvelle station avec les modifications
    // Vérifier que votre classe Station a un constructeur approprié
    // S'il n'y a pas de champ 'id', vous devrez l'adapter
    final updatedStation = Station(
      numeroStation: modified.numeroStation, // Utiliser numeroStation au lieu de id
      latitude: latitude ?? modified.latitude,
      longitude: longitude ?? modified.longitude,
      treeLandscape: treeLandscape ?? modified.treeLandscape,
      humanFrequency: humanFrequency ?? modified.humanFrequency,
      espaceBoiseClasse: espaceBoiseClasse ?? modified.espaceBoiseClasse,
      interetPaysager: interetPaysager ?? modified.interetPaysager,
      codeEnvironnement: codeEnvironnement ?? modified.codeEnvironnement,
      alleeArbres: alleeArbres ?? modified.alleeArbres,
      perimetreMonument: perimetreMonument ?? modified.perimetreMonument,
      sitePatrimonial: sitePatrimonial ?? modified.sitePatrimonial,
      autresProtections: autresProtections ?? modified.autresProtections,
      meriteProtection: meriteProtection ?? modified.meriteProtection,
      commentaireProtection: commentaireProtection ?? modified.commentaireProtection,
      commentaireMeriteProtection: commentaireMeriteProtection ?? modified.commentaireMeriteProtection,
      photoUrls: photoUrls ?? modified.photoUrls,

      // Identité
      identifiantExterne: identifiantExterne ?? modified.identifiantExterne,
      archiveNumero: archiveNumero ?? modified.archiveNumero,
      adresse: adresse ?? modified.adresse,
      baseDonneesEssence: baseDonneesEssence ?? modified.baseDonneesEssence,
      essenceLibre: essenceLibre ?? modified.essenceLibre,
      variete: variete ?? modified.variete,
      stadeDeveloppement: stadeDeveloppement ?? modified.stadeDeveloppement,
      sujetVeteran: sujetVeteran ?? modified.sujetVeteran,
      anneePlantation: anneePlantation ?? modified.anneePlantation,
      appartenantGroupe: appartenantGroupe ?? modified.appartenantGroupe,
      arbreReplanter: arbreReplanter ?? modified.arbreReplanter,

      // Forme et gabarit
      structureTronc: structureTronc ?? modified.structureTronc,
      portForme: portForme ?? modified.portForme,
      diametreTronc: diametreTronc ?? modified.diametreTronc,
      circonferenceTronc: circonferenceTronc ?? modified.circonferenceTronc,
      diametreHouppier: diametreHouppier ?? modified.diametreHouppier,
      hauteurGenerale: hauteurGenerale ?? modified.hauteurGenerale,

      // Géométrie
      polygones: polygones ?? modified.polygones,
      lignes: lignes ?? modified.lignes,
      points: points ?? modified.points,

      // Métadonnées - ces champs devraient être présents dans votre classe Station
      // S'ils ne le sont pas, vous devrez adapter cette partie
      treesToCut: modified.treesToCut,
      warning: modified.warning,
      highlight: modified.highlight,
    );

    _modifiedStations[key] = updatedStation;
    notifyListeners();
  }

// Ajouter les méthodes saveChanges et rollbackChanges
  void saveChanges() {
    debugPrint('Sauvegarde de ${_modifiedStations.length} stations modifiées...');

    // Dans une application réelle, vous enverriez ces modifications au serveur
    for (var entry in _modifiedStations.entries) {
      debugPrint('Station ${entry.key} sauvegardée avec succès.');
    }

    _modifiedStations.clear();
    _originalStations.clear();
    notifyListeners();
  }

  void rollbackChanges() {
    debugPrint('Annulation de ${_modifiedStations.length} modifications...');
    _modifiedStations.clear();
    _originalStations.clear();
    notifyListeners();
  }

  // Méthodes pour obtenir et gérer les géométries
  Map<String, dynamic> getStationGeometries(Station station) {
    final s = getStation(station);
    return {
      'points': s.points,
      'lignes': s.lignes,
      'polygones': s.polygones,
    };
  }

  // Ajouter un point à une station
  void addPointToStation(Station station, LatLng point) {
    final modified = getStation(station);
    final points = modified.points != null ?
      List<LatLng>.from(modified.points!) : <LatLng>[];
    points.add(point);

    updateStation(station, points: points);
  }

  // Ajouter une ligne à une station
  void addLineToStation(Station station, List<LatLng> line) {
    final modified = getStation(station);
    final lignes = modified.lignes != null ?
        List<List<LatLng>>.from(modified.lignes!) : <List<LatLng>>[];
    lignes.add(line);

    updateStation(station, lignes: lignes);
  }

  // Ajouter un polygone à une station
  void addPolygonToStation(Station station, List<LatLng> polygon) {
    final modified = getStation(station);
    final polygones = modified.polygones != null ?
    List<List<LatLng>>.from(modified.polygones!) : <List<LatLng>>[];
    polygones.add(polygon);

    updateStation(station, polygones: polygones);
  }

  // Supprimer une géométrie
  void removeGeographicFeature(Station station, String type, int index) {
    final modified = getStation(station);

    switch (type) {
      case 'point':
        if (modified.points != null && index < modified.points!.length) {
          final points = List<LatLng>.from(modified.points!);
          points.removeAt(index);
          updateStation(station, points: points);
        }
        break;

      case 'line':
        if (modified.lignes != null && index < modified.lignes!.length) {
          final lignes = List<List<LatLng>>.from(modified.lignes!);
          lignes.removeAt(index);
          updateStation(station, lignes: lignes);
        }
        break;

      case 'polygon':
        if (modified.polygones != null && index < modified.polygones!.length) {
          final polygones = List<List<LatLng>>.from(modified.polygones!);
          polygones.removeAt(index);
          updateStation(station, polygones: polygones);
        }
        break;
    }
  }

  // Mettre à jour entièrement les géométries d'une station
  void updateStationGeometries(
      Station station, {
        List<LatLng>? points,
        List<List<LatLng>>? lignes,
        List<List<LatLng>>? polygones,
      }) {
    updateStation(
      station,
      points: points,
      lignes: lignes,
      polygones: polygones,
    );
  }

  // Annuler toutes les modifications
  void rollbackAllModifications() {
    _modifiedStations.clear();
    _originalStations.clear();
    notifyListeners();
  }

  // Valider les modifications (à implémenter avec API)
  Future<bool> commitModifications({required String userName}) async {
    // Simulation d'un appel API réussi
    for (final station in _modifiedStations.values) {
      // Ajouter le nom de l'utilisateur et la date
      updateStation(
        station,
        lastModifiedBy: userName,
        lastModifiedDate: DateTime.now(),
      );
    }

    // Dans un cas réel, appelez votre API ici

    // Réinitialiser après validation réussie
    final success = true;
    if (success) {
      _modifiedStations.clear();
      _originalStations.clear();
      notifyListeners();
    }

    return success;
  }

  // Obtenir un résumé des modifications
  Map<String, dynamic> getModificationSummary() {
    final Map<String, Map<String, dynamic>> changes = {};

    for (final entry in _modifiedStations.entries) {
      final original = _originalStations[entry.key];
      final modified = entry.value;

      if (original != null) {
        changes[entry.key] = _compareStations(original, modified);
      }
    }

    return {
      'count': _modifiedStations.length,
      'changes': changes,
    };
  }

  // Comparer deux stations pour voir les différences
  Map<String, dynamic> _compareStations(Station original, Station modified) {
    final Map<String, dynamic> changes = {};

    // Vérifier les changements de base
    if (original.treeLandscape != modified.treeLandscape) {
      changes['treeLandscape'] = {
        'old': original.treeLandscape,
        'new': modified.treeLandscape
      };
    }

    if (original.humanFrequency != modified.humanFrequency) {
      changes['humanFrequency'] = {
        'old': original.humanFrequency,
        'new': modified.humanFrequency
      };
    }

    // Vérifier les changements de géométrie
    if ((original.points?.length ?? 0) != (modified.points?.length ?? 0)) {
      changes['points'] = {
        'old': original.points?.length ?? 0,
        'new': modified.points?.length ?? 0
      };
    }

    if ((original.lignes?.length ?? 0) != (modified.lignes?.length ?? 0)) {
      changes['lignes'] = {
        'old': original.lignes?.length ?? 0,
        'new': modified.lignes?.length ?? 0
      };
    }

    if ((original.polygones?.length ?? 0) != (modified.polygones?.length ?? 0)) {
      changes['polygones'] = {
        'old': original.polygones?.length ?? 0,
        'new': modified.polygones?.length ?? 0
      };
    }

    return changes;
  }

  // ✅ Rechercher des stations par critères - CORRECTION pour numeroStation
  List<Station> searchStations(List<Station> allStations, {
    String? textSearch,
    String? landscape,
    int? minFrequency,
    int? maxFrequency,
    bool? hasGeometries,
    bool? hasModifications,
  }) {
    return allStations.where((station) {
      final currentStation = getStation(station);

      // ✅ CORRECTION: Filtre par texte avec conversion String
      if (textSearch != null && textSearch.isNotEmpty) {
        final search = textSearch.toLowerCase();
        final stationNumberStr = currentStation.numeroStation.toString().toLowerCase();

        if (!stationNumberStr.contains(search) &&
            !(currentStation.treeLandscape?.toLowerCase().contains(search) ?? false) &&
            !(currentStation.commentaireProtection?.toLowerCase().contains(search) ?? false)) {
          return false;
        }
      }

      // Filtre par paysage
      if (landscape != null && currentStation.treeLandscape != landscape) {
        return false;
      }

      // Filtre par fréquentation
      if (minFrequency != null && (currentStation.humanFrequency ?? 0) < minFrequency) {
        return false;
      }
      if (maxFrequency != null && (currentStation.humanFrequency ?? 0) > maxFrequency) {
        return false;
      }

      // Filtre pour stations avec géométries
      if (hasGeometries == true) {
        final hasPoints = currentStation.points?.isNotEmpty ?? false;
        final hasLignes = currentStation.lignes?.isNotEmpty ?? false;
        final hasPolygones = currentStation.polygones?.isNotEmpty ?? false;

        if (!hasPoints && !hasLignes && !hasPolygones) {
          return false;
        }
      }

      // Filtre pour stations modifiées
      if (hasModifications == true && !isStationModified(station)) {
        return false;
      }

      return true;
    }).toList();
  }
}
