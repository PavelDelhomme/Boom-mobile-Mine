import 'package:boom_mobile/domain/models/station_snapshot.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/station.dart';
import 'station_service.dart';

class StationVersionManager {
  late Box _snapshotBox;

  Future<void> initialize() async {
    _snapshotBox = await Hive.openBox('station_snapshots');
  }

  // Créer un snapshot
  Future<void> createSnapshot(Station station, Map<String, dynamic> geometries) async {
    final snapshot = StationSnapshot(
      id: '${station.numeroStation}_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      geometries: geometries,
    );
    await _snapshotBox.put(snapshot.id, snapshot.toJson());
  }

  // Récupérer tous les snapshots d'une station
  List<StationSnapshot> getStationSnapshots(Station station) {
    final stationPrefix = '${station.numeroStation}_';

    return _snapshotBox.keys
        .where((key) => (key as String).startsWith(stationPrefix))
        .map((key) {
      final data = _snapshotBox.get(key);
      if (data is Map) {
        return StationSnapshot.fromJson(Map<String, dynamic>.from(data));
      } else {
        // Handle case where data is not Map
        return null;
      }
    })
        .where((snapshot) => snapshot != null)
        .cast<StationSnapshot>()
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Restaurer un snapshot
  Future<void> restoreSnapshot(String snapshotId, StationService stationService) async {
    final snapshotData = _snapshotBox.get(snapshotId);
    if (snapshotData != null) {
      try {
        // ✅ CORRECTION: Conversion sécurisée Map -> Map<String, dynamic>
        final Map<String, dynamic> data = Map<String, dynamic>.from(snapshotData as Map);
        final snapshot = StationSnapshot.fromJson(data);
        final stationId = snapshot.id.split('_')[0];

        // Utiliser getStationById et vérifier le résultat
        final station = await stationService.getStationById(stationId);
        if (station != null) {
          // ✅ CORRECTION: Conversion sécurisée des géométries avec types corrects
          final geometries = snapshot.geometries;

          // Convertir les points
          List<LatLng>? points;
          if (geometries['points'] != null) {
            final pointsData = geometries['points'] as List?;
            points = pointsData?.map((point) {
              if (point is Map) {
                return LatLng(
                  (point['latitude'] as num).toDouble(),
                  (point['longitude'] as num).toDouble(),
                );
              }
              return null;
            }).where((p) => p != null).cast<LatLng>().toList();
          }

          // Convertir les lignes
          List<List<LatLng>>? lignes;
          if (geometries['lignes'] != null) {
            final lignesData = geometries['lignes'] as List?;
            lignes = lignesData?.map((ligne) {
              if (ligne is List) {
                return ligne.map((point) {
                  if (point is Map) {
                    return LatLng(
                      (point['latitude'] as num).toDouble(),
                      (point['longitude'] as num).toDouble(),
                    );
                  }
                  return null;
                }).where((p) => p != null).cast<LatLng>().toList();
              }
              return <LatLng>[];
            }).toList();
          }

          // Convertir les polygones
          List<List<LatLng>>? polygones;
          if (geometries['polygones'] != null) {
            final polygonesData = geometries['polygones'] as List?;
            polygones = polygonesData?.map((polygone) {
              if (polygone is List) {
                return polygone.map((point) {
                  if (point is Map) {
                    return LatLng(
                      (point['latitude'] as num).toDouble(),
                      (point['longitude'] as num).toDouble(),
                    );
                  }
                  return null;
                }).where((p) => p != null).cast<LatLng>().toList();
              }
              return <LatLng>[];
            }).toList();
          }

          // Mettre à jour les géométries
          stationService.updateStation(
            station,
            points: points,
            lignes: lignes,
            polygones: polygones,
          );
        }
      } catch (e) {
        // Log l'erreur mais ne pas faire échouer l'opération
        print('Erreur lors de la restauration du snapshot $snapshotId: $e');
      }
    }
  }

  // ✅ AJOUT: Méthode pour supprimer un snapshot
  Future<void> deleteSnapshot(String snapshotId) async {
    await _snapshotBox.delete(snapshotId);
  }

  // ✅ AJOUT: Méthode pour supprimer tous les snapshots d'une station
  Future<void> deleteAllStationSnapshots(Station station) async {
    final stationPrefix = '${station.numeroStation}_';
    final keysToDelete = _snapshotBox.keys
        .where((key) => (key as String).startsWith(stationPrefix))
        .toList();

    for (final key in keysToDelete) {
      await _snapshotBox.delete(key);
    }
  }

  // ✅ AJOUT: Méthode pour obtenir le nombre de snapshots
  int getSnapshotCount(Station station) {
    final stationPrefix = '${station.numeroStation}_';
    return _snapshotBox.keys
        .where((key) => (key as String).startsWith(stationPrefix))
        .length;
  }

  // ✅ AJOUT: Méthode pour nettoyer les anciens snapshots (garder seulement les N plus récents)
  Future<void> cleanupOldSnapshots(Station station, {int keepCount = 10}) async {
    final snapshots = getStationSnapshots(station);
    if (snapshots.length > keepCount) {
      final snapshotsToDelete = snapshots.skip(keepCount);
      for (final snapshot in snapshotsToDelete) {
        await deleteSnapshot(snapshot.id);
      }
    }
  }
}