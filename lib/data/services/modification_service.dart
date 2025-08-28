import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/station.dart';

// Enum pour les types de modifications
enum ModificationType {
  stationUpdate,
  stationCreate,
  stationDelete,
  geometryAdd,
  geometryUpdate,
  geometryDelete,
}

// Classe représentant une modification
class Modification {
  final String id;
  final ModificationType type;
  final DateTime timestamp;
  final String? dossierName;
  final Map<String, dynamic> data;
  final Map<String, dynamic>? previousData; // Pour le rollback

  Modification({
    required this.id,
    required this.type,
    required this.data,
    this.dossierName,
    this.previousData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Créer une copie avec modifications
  Modification copyWith({
    String? id,
    ModificationType? type,
    DateTime? timestamp,
    String? dossierName,
    Map<String, dynamic>? data,
    Map<String, dynamic>? previousData,
  }) {
    return Modification(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      dossierName: dossierName ?? this.dossierName,
      data: data ?? this.data,
      previousData: previousData ?? this.previousData,
    );
  }
}

// Service de gestion des modifications
class ModificationService with ChangeNotifier {
  final Map<String, List<Modification>> _pendingModifications = {};
  final Map<String, List<Modification>> _appliedModifications = {};

  // ✅ CORRECTION: Constructeur vide (pas de paramètres requis)
  ModificationService();

  // Getters
  Map<String, List<Modification>> get pendingModifications => _pendingModifications;
  Map<String, List<Modification>> get appliedModifications => _appliedModifications;

  bool hasPendingModifications(String dossierName) {
    return _pendingModifications[dossierName]?.isNotEmpty ?? false;
  }

  int getPendingCount(String dossierName) {
    return _pendingModifications[dossierName]?.length ?? 0;
  }

  List<Modification> getPendingModifications(String dossierName) {
    return _pendingModifications[dossierName] ?? [];
  }

  // Ajouter une modification de station
  void addStationModification({
    required String dossierName,
    required Station station,
    required Station? previousStation,
    required ModificationType type,
  }) {
    final modification = Modification(
      id: '${type.name}_${station.numeroStation}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      dossierName: dossierName,
      data: {
        'station': _stationToMap(station),
        'stationId': station.numeroStation,
      },
      previousData: previousStation != null ? {
        'station': _stationToMap(previousStation),
        'stationId': previousStation.numeroStation,
      } : null,
    );

    _addModification(dossierName, modification);
  }

  // Ajouter une modification géométrique
  void addGeometryModification({
    required String dossierName,
    required Station station,
    required String geometryType, // 'point', 'ligne', 'polygone'
    required List<LatLng> points,
    required ModificationType type,
    int? geometryIndex,
  }) {
    final modification = Modification(
      id: '${type.name}_geo_${station.numeroStation}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      dossierName: dossierName,
      data: {
        'stationId': station.numeroStation,
        'geometryType': geometryType,
        'points': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
        'geometryIndex': geometryIndex,
      },
    );

    _addModification(dossierName, modification);
  }

  // Ajouter une modification générique
  void _addModification(String dossierName, Modification modification) {
    if (_pendingModifications[dossierName] == null) {
      _pendingModifications[dossierName] = [];
    }

    _pendingModifications[dossierName]!.add(modification);
    notifyListeners();

    debugPrint('Modification ajoutée: ${modification.type.name} pour $dossierName');
  }

  // Appliquer toutes les modifications en attente d'un dossier
  Future<bool> applyPendingModifications(String dossierName) async {
    final modifications = _pendingModifications[dossierName];
    if (modifications == null || modifications.isEmpty) {
      return true;
    }

    try {
      // Simuler la sauvegarde (remplacer par votre logique de sauvegarde)
      await _simulateSave(modifications);

      // Déplacer vers les modifications appliquées
      if (_appliedModifications[dossierName] == null) {
        _appliedModifications[dossierName] = [];
      }
      _appliedModifications[dossierName]!.addAll(modifications);

      // Vider les modifications en attente
      _pendingModifications[dossierName]?.clear();

      notifyListeners();

      debugPrint('${modifications.length} modifications appliquées pour $dossierName');
      return true;
    } catch (e) {
      debugPrint('Erreur lors de l\'application des modifications: $e');
      return false;
    }
  }

  // Annuler toutes les modifications en attente d'un dossier
  void rollbackPendingModifications(String dossierName) {
    final modifications = _pendingModifications[dossierName];
    if (modifications == null || modifications.isEmpty) {
      return;
    }

    // Appliquer les rollbacks dans l'ordre inverse
    for (int i = modifications.length - 1; i >= 0; i--) {
      final modification = modifications[i];
      _rollbackSingleModification(modification);
    }

    // Vider les modifications en attente
    _pendingModifications[dossierName]?.clear();
    notifyListeners();

    debugPrint('Rollback de ${modifications.length} modifications pour $dossierName');
  }

  // Annuler une modification spécifique
  void _rollbackSingleModification(Modification modification) {
    switch (modification.type) {
      case ModificationType.stationUpdate:
      // Restaurer les données précédentes de la station
        if (modification.previousData != null) {
          debugPrint('Rollback station ${modification.data['stationId']}');
        }
        break;

      case ModificationType.geometryAdd:
      // Supprimer la géométrie ajoutée
        debugPrint('Rollback ajout géométrie ${modification.data['geometryType']}');
        break;

      case ModificationType.geometryDelete:
      // Restaurer la géométrie supprimée
        debugPrint('Rollback suppression géométrie ${modification.data['geometryType']}');
        break;

      default:
        debugPrint('Rollback ${modification.type.name}');
    }
  }

  // Supprimer une modification spécifique
  void removeModification(String dossierName, String modificationId) {
    _pendingModifications[dossierName]?.removeWhere((m) => m.id == modificationId);
    notifyListeners();
  }

  // Obtenir un résumé des modifications
  String getModificationSummary(String dossierName) {
    final modifications = _pendingModifications[dossierName] ?? [];
    if (modifications.isEmpty) return 'Aucune modification';

    final Map<ModificationType, int> counts = {};
    for (final modification in modifications) {
      counts[modification.type] = (counts[modification.type] ?? 0) + 1;
    }

    final List<String> summary = [];
    counts.forEach((type, count) {
      switch (type) {
        case ModificationType.stationUpdate:
          summary.add('$count station${count > 1 ? 's' : ''} modifiée${count > 1 ? 's' : ''}');
          break;
        case ModificationType.geometryAdd:
          summary.add('$count géométrie${count > 1 ? 's' : ''} ajoutée${count > 1 ? 's' : ''}');
          break;
        case ModificationType.geometryDelete:
          summary.add('$count géométrie${count > 1 ? 's' : ''} supprimée${count > 1 ? 's' : ''}');
          break;
        default:
          summary.add('$count ${type.name}');
      }
    });

    return summary.join(', ');
  }

  // Vider toutes les modifications (pour reset complet)
  void clearAllModifications() {
    _pendingModifications.clear();
    _appliedModifications.clear();
    notifyListeners();
    debugPrint('Toutes les modifications supprimées');
  }

  // Simuler la sauvegarde (remplacer par votre logique métier)
  Future<void> _simulateSave(List<Modification> modifications) async {
    // Simuler un délai de sauvegarde
    await Future.delayed(const Duration(milliseconds: 500));

    for (final modification in modifications) {
      debugPrint('Sauvegarde: ${modification.type.name} - ${modification.id}');
    }
  }

  // Convertir une Station en Map pour la sérialisation
  Map<String, dynamic> _stationToMap(Station station) {
    return {
      'numeroStation': station.numeroStation,
      'latitude': station.latitude,
      'longitude': station.longitude,
      'identifiantExterne': station.identifiantExterne,
      'archiveNumero': station.archiveNumero,
      'adresse': station.adresse,
      'baseDonneesEssence': station.baseDonneesEssence,
      'essenceLibre': station.essenceLibre,
      'variete': station.variete,
      'stadeDeveloppement': station.stadeDeveloppement,
      'sujetVeteran': station.sujetVeteran,
      'anneePlantation': station.anneePlantation,
      'appartenantGroupe': station.appartenantGroupe,
      'arbreReplanter': station.arbreReplanter,
      'structureTronc': station.structureTronc,
      'portForme': station.portForme,
      'diametreTronc': station.diametreTronc,
      'circonferenceTronc': station.circonferenceTronc,
      'diametreHouppier': station.diametreHouppier,
      'hauteurGenerale': station.hauteurGenerale,
      'treeLandscape': station.treeLandscape,
      'humanFrequency': station.humanFrequency,
      'espaceBoiseClasse': station.espaceBoiseClasse,
      'interetPaysager': station.interetPaysager,
      'codeEnvironnement': station.codeEnvironnement,
      'alleeArbres': station.alleeArbres,
      'perimetreMonument': station.perimetreMonument,
      'sitePatrimonial': station.sitePatrimonial,
      'autresProtections': station.autresProtections,
      'meriteProtection': station.meriteProtection,
      'commentaireProtection': station.commentaireProtection,
      'commentaireMeriteProtection': station.commentaireMeriteProtection,
      'photoUrls': station.photoUrls,
      'lastModifiedBy': station.lastModifiedBy,
      // Géométries
      'points': station.points?.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'lignes': station.lignes?.map((ligne) =>
          ligne.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()
      ).toList(),
      'polygones': station.polygones?.map((polygone) =>
          polygone.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList()
      ).toList(),
    };
  }
}