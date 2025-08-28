import 'dart:convert';
import 'dart:math';
import 'package:boom_mobile/domain/entities/dossier.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:latlong2/latlong.dart';


class OfflineCacheService with ChangeNotifier {
  Database? _database;
  bool _isInitialized = false;
  bool _isOnline = true;
  final Map<String, Uint8List> _memoryTileCache = {}; // Cache mémoire pour performances

  // Limites de cache
  static const int maxMemoryCacheSize = 100; // 100 tuiles en mémoire
  static const int maxDiskCacheMb = 500; // 500 MB max sur disque
  static const Duration cacheValidityDuration = Duration(days: 30);

  bool get isInitialized => _isInitialized;
  bool get isOnline => _isOnline;

  // ✅ INITIALISATION
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeDatabase();
      await checkConnectivity();
      _isInitialized = true;
      debugPrint('🚀 OfflineCacheService initialisé');
    } catch (e) {
      debugPrint('❌ Erreur initialisation cache: $e');
    }
  }

  Future<void> _initializeDatabase() async {
    final documentsPath = await getApplicationDocumentsDirectory();
    final dbPath = '${documentsPath.path}/boom_offline_cache.db';

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Table pour les tuiles de carte
    await db.execute('''
      CREATE TABLE map_tiles (
        id TEXT PRIMARY KEY,
        url TEXT NOT NULL,
        data BLOB NOT NULL,
        cached_at INTEGER NOT NULL,
        access_count INTEGER DEFAULT 0,
        file_size INTEGER NOT NULL
      )
    ''');

    // Table pour les stations
    await db.execute('''
      CREATE TABLE cached_stations (
        id INTEGER PRIMARY KEY,
        numero_station INTEGER UNIQUE NOT NULL,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        dossier_id TEXT
      )
    ''');

    // Table pour les dossiers
    await db.execute('''
      CREATE TABLE cached_dossiers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL,
        is_synchronized INTEGER DEFAULT 0
      )
    ''');

    // Table pour les couches
    await db.execute('''
      CREATE TABLE cached_layers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Table pour les métadonnées de cache
    await db.execute('''
      CREATE TABLE cache_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Index pour optimiser les requêtes
    await db.execute('CREATE INDEX idx_tiles_url ON map_tiles(url)');
    await db.execute('CREATE INDEX idx_stations_dossier ON cached_stations(dossier_id)');
    await db.execute('CREATE INDEX idx_cached_at ON map_tiles(cached_at)');
  }

  // ✅ GESTION CONNECTIVITÉ
  Future<void> checkConnectivity() async {
    try {
      final result = await http.get(
        Uri.parse('https://www.google.com'),
        headers: {'Connection': 'close'},
      ).timeout(const Duration(seconds: 5));

      _isOnline = result.statusCode == 200;
    } catch (e) {
      _isOnline = false;
    }

    debugPrint('📶 Mode: ${_isOnline ? "EN LIGNE" : "HORS LIGNE"}');
    notifyListeners();
  }

  void setOfflineMode(bool offline) {
    _isOnline = !offline;
    debugPrint('📶 Basculement: ${_isOnline ? "EN LIGNE" : "HORS LIGNE"}');
    notifyListeners();
  }

  // ✅ CACHE TUILES DE CARTE
  Future<Uint8List?> getTile(String url) async {
    if (!_isInitialized) await initialize();

    final tileId = _generateTileId(url);

    // 1. Vérifier cache mémoire
    if (_memoryTileCache.containsKey(tileId)) {
      debugPrint('🎯 Tuile depuis mémoire: $tileId');
      return _memoryTileCache[tileId];
    }

    // 2. Vérifier cache disque
    final cachedTile = await _getTileFromDisk(tileId);
    if (cachedTile != null) {
      // Ajouter au cache mémoire
      _addToMemoryCache(tileId, cachedTile);
      return cachedTile;
    }

    // 3. Télécharger si en ligne
    if (_isOnline) {
      return await _downloadAndCacheTile(url, tileId);
    }

    return null;
  }

  Future<Uint8List?> _getTileFromDisk(String tileId) async {
    try {
      final result = await _database!.query(
        'map_tiles',
        where: 'id = ?',
        whereArgs: [tileId],
      );

      if (result.isNotEmpty) {
        final cachedAt = result.first['cached_at'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Vérifier validité du cache
        if (now - cachedAt < cacheValidityDuration.inMilliseconds) {
          // Mettre à jour compteur d'accès
          await _database!.update(
            'map_tiles',
            {'access_count': (result.first['access_count'] as int) + 1},
            where: 'id = ?',
            whereArgs: [tileId],
          );

          debugPrint('💾 Tuile depuis disque: $tileId');
          return result.first['data'] as Uint8List;
        } else {
          // Cache expiré, supprimer
          await _database!.delete('map_tiles', where: 'id = ?', whereArgs: [tileId]);
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lecture tuile: $e');
    }

    return null;
  }

  Future<Uint8List?> _downloadAndCacheTile(String url, String tileId) async {
    try {
      debugPrint('⬇️ Téléchargement tuile: $url');

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final tileData = response.bodyBytes;

        // Sauvegarder sur disque
        await _saveTileToDisk(tileId, url, tileData);

        // Ajouter au cache mémoire
        _addToMemoryCache(tileId, tileData);

        return tileData;
      }
    } catch (e) {
      debugPrint('❌ Erreur téléchargement tuile: $e');
    }

    return null;
  }

  Future<void> _saveTileToDisk(String tileId, String url, Uint8List data) async {
    try {
      await _database!.insert(
        'map_tiles',
        {
          'id': tileId,
          'url': url,
          'data': data,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
          'file_size': data.length,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Vérifier taille du cache et nettoyer si nécessaire
      await _cleanupCacheIfNeeded();
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde tuile: $e');
    }
  }

  void _addToMemoryCache(String tileId, Uint8List data) {
    if (_memoryTileCache.length >= maxMemoryCacheSize) {
      // Supprimer la plus ancienne entrée (FIFO)
      final oldestKey = _memoryTileCache.keys.first;
      _memoryTileCache.remove(oldestKey);
    }

    _memoryTileCache[tileId] = data;
  }

  String _generateTileId(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ✅ CACHE DONNÉES MÉTIER
  Future<void> cacheStations(List<Station> stations, String dossierId) async {
    if (!_isInitialized) await initialize();

    try {
      final batch = _database!.batch();

      for (final station in stations) {
        batch.insert(
          'cached_stations',
          {
            'numero_station': station.numeroStation,
            'data': jsonEncode(_stationToJson(station)),
            'cached_at': DateTime.now().millisecondsSinceEpoch,
            'dossier_id': dossierId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit();
      debugPrint('💾 ${stations.length} stations mises en cache pour $dossierId');
    } catch (e) {
      debugPrint('❌ Erreur cache stations: $e');
    }
  }

  Future<List<Station>> getCachedStations(String dossierId) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database!.query(
        'cached_stations',
        where: 'dossier_id = ?',
        whereArgs: [dossierId],
      );

      final stations = result.map((row) {
        final data = jsonDecode(row['data'] as String);
        return _stationFromJson(data);
      }).toList();

      debugPrint('💾 ${stations.length} stations récupérées du cache pour $dossierId');
      return stations;
    } catch (e) {
      debugPrint('❌ Erreur récupération stations: $e');
      return [];
    }
  }

  Future<void> cacheDossier(Dossier dossier) async {
    if (!_isInitialized) await initialize();

    try {
      await _database!.insert(
        'cached_dossiers',
        {
          'id': dossier.nom,
          'name': dossier.nom,
          'data': jsonEncode(_dossierToJson(dossier)),
          'cached_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Cacher aussi les stations du dossier
      await cacheStations(dossier.stations, dossier.nom);

      debugPrint('💾 Dossier ${dossier.nom} mis en cache');
    } catch (e) {
      debugPrint('❌ Erreur cache dossier: $e');
    }
  }

  Future<List<Dossier>> getCachedDossiers() async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database!.query('cached_dossiers');

      List<Dossier> dossiers = [];
      for (final row in result) {
        final data = jsonDecode(row['data'] as String);
        final dossier = _dossierFromJson(data);

        // Récupérer les stations du dossier
        final stations = await getCachedStations(dossier.nom);
        final dossierWithStations = Dossier(
          nom: dossier.nom,
          type: dossier.type,
          date: dossier.date,
          center: dossier.center,
          stations: stations,
          markerBuilder: dossier.markerBuilder,
        );

        dossiers.add(dossierWithStations);
      }

      debugPrint('💾 ${dossiers.length} dossiers récupérés du cache');
      return dossiers;
    } catch (e) {
      debugPrint('❌ Erreur récupération dossiers: $e');
      return [];
    }
  }

  // ✅ PRÉ-TÉLÉCHARGEMENT ZONE
  Future<void> preloadArea({
    required LatLng center,
    required double radiusKm,
    required int minZoom,
    required int maxZoom,
    String tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    Function(int current, int total)? onProgress,
  }) async {
    if (!_isOnline) {
      debugPrint('❌ Pré-téléchargement impossible hors ligne');
      return;
    }

    debugPrint('⬇️ Début pré-téléchargement zone: ${radiusKm}km autour de $center');

    int totalTiles = 0;
    int downloadedTiles = 0;

    // Calculer toutes les tuiles nécessaires
    List<Map<String, dynamic>> tilesToDownload = [];

    for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
      final tiles = _calculateTilesForArea(center, radiusKm, zoom);
      for (final tile in tiles) {
        final url = tileUrlTemplate
            .replaceAll('{z}', zoom.toString())
            .replaceAll('{x}', tile['x'].toString())
            .replaceAll('{y}', tile['y'].toString());

        tilesToDownload.add({
          'url': url,
          'zoom': zoom,
          'x': tile['x'],
          'y': tile['y'],
        });
      }
    }

    totalTiles = tilesToDownload.length;
    debugPrint('📊 $totalTiles tuiles à télécharger');

    // Télécharger par batch pour éviter la surcharge
    const batchSize = 10;
    for (int i = 0; i < tilesToDownload.length; i += batchSize) {
      final batch = tilesToDownload.skip(i).take(batchSize);

      await Future.wait(batch.map((tileInfo) async {
        final tileData = await getTile(tileInfo['url']);
        if (tileData != null) {
          downloadedTiles++;
        }
      }));

      onProgress?.call(downloadedTiles, totalTiles);

      // Petite pause pour éviter la surcharge serveur
      await Future.delayed(const Duration(milliseconds: 100));
    }

    debugPrint('✅ Pré-téléchargement terminé: $downloadedTiles/$totalTiles tuiles');
  }

  List<Map<String, int>> _calculateTilesForArea(LatLng center, double radiusKm, int zoom) {
    final List<Map<String, int>> tiles = [];

    // Convertir rayon en tuiles
    final tilesPerDegree = (1 << zoom) / 360.0;
    final radiusDegrees = radiusKm / 111.32; // 1 degré ≈ 111.32 km
    final radiusTiles = (radiusDegrees * tilesPerDegree).ceil();

    // Calculer tuile centrale
    final centerTileX = ((center.longitude + 180.0) / 360.0 * (1 << zoom)).floor();
    final centerTileY = ((1.0 - (log(tan(center.latitude * pi / 180.0) +
        1.0 / cos(center.latitude * pi / 180.0)) / pi)) / 2.0 * (1 << zoom)).floor();

    // Générer toutes les tuiles dans le rayon
    for (int x = centerTileX - radiusTiles; x <= centerTileX + radiusTiles; x++) {
      for (int y = centerTileY - radiusTiles; y <= centerTileY + radiusTiles; y++) {
        if (x >= 0 && y >= 0 && x < (1 << zoom) && y < (1 << zoom)) {
          tiles.add({'x': x, 'y': y});
        }
      }
    }

    return tiles;
  }

  // ✅ NETTOYAGE CACHE
  Future<void> _cleanupCacheIfNeeded() async {
    try {
      // Vérifier taille totale du cache
      final sizeResult = await _database!.rawQuery(
          'SELECT SUM(file_size) as total_size FROM map_tiles'
      );

      final totalSizeMB = (sizeResult.first['total_size'] as int? ?? 0) / (1024 * 1024);

      if (totalSizeMB > maxDiskCacheMb) {
        debugPrint('🧹 Nettoyage cache nécessaire: ${totalSizeMB.toStringAsFixed(1)} MB');

        // Supprimer les tuiles les moins utilisées et les plus anciennes
        await _database!.execute('''
          DELETE FROM map_tiles 
          WHERE id IN (
            SELECT id FROM map_tiles 
            ORDER BY access_count ASC, cached_at ASC 
            LIMIT (SELECT COUNT(*) / 4 FROM map_tiles)
          )
        ''');

        debugPrint('🧹 Nettoyage terminé');
      }
    } catch (e) {
      debugPrint('❌ Erreur nettoyage cache: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_isInitialized) await initialize();

    try {
      final tilesResult = await _database!.rawQuery('''
        SELECT 
          COUNT(*) as tile_count,
          SUM(file_size) as total_size,
          AVG(access_count) as avg_access
        FROM map_tiles
      ''');

      final stationsResult = await _database!.rawQuery(
          'SELECT COUNT(*) as station_count FROM cached_stations'
      );

      final dossiersResult = await _database!.rawQuery(
          'SELECT COUNT(*) as dossier_count FROM cached_dossiers'
      );

      return {
        'tiles': {
          'count': tilesResult.first['tile_count'] ?? 0,
          'size_mb': ((tilesResult.first['total_size'] as int? ?? 0) / (1024 * 1024)).toStringAsFixed(2),
          'avg_access': (tilesResult.first['avg_access'] as double? ?? 0).toStringAsFixed(1),
        },
        'stations': {
          'count': stationsResult.first['station_count'] ?? 0,
        },
        'dossiers': {
          'count': dossiersResult.first['dossier_count'] ?? 0,
        },
        'memory_cache': {
          'tiles': _memoryTileCache.length,
        },
        'is_online': _isOnline,
      };
    } catch (e) {
      debugPrint('❌ Erreur stats cache: $e');
      return {};
    }
  }

  Future<void> clearCache({bool includeTiles = true, bool includeData = true}) async {
    if (!_isInitialized) await initialize();

    try {
      if (includeTiles) {
        await _database!.delete('map_tiles');
        _memoryTileCache.clear();
        debugPrint('🧹 Cache tuiles effacé');
      }

      if (includeData) {
        await _database!.delete('cached_stations');
        await _database!.delete('cached_dossiers');
        await _database!.delete('cached_layers');
        debugPrint('🧹 Cache données effacé');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Erreur nettoyage cache: $e');
    }
  }

  // ✅ HELPERS SÉRIALISATION
  Map<String, dynamic> _stationToJson(Station station) {
    return {
      'numeroStation': station.numeroStation,
      'latitude': station.latitude,
      'longitude': station.longitude,
      'treesToCut': station.treesToCut,
      'warning': station.warning,
      'highlight': station.highlight,
      'lastModifiedBy': station.lastModifiedBy,
      'treeLandscape': station.treeLandscape,
      'humanFrequency': station.humanFrequency,
      'espaceBoiseClasse': station.espaceBoiseClasse,
      'interetPaysager': station.interetPaysager,
      'codeEnvironnement': station.codeEnvironnement,
      'commentaireProtection': station.commentaireProtection,
      'photoUrls': station.photoUrls,
      'points': station.points?.map((p) => [p.latitude, p.longitude]).toList(),
      'lignes': station.lignes?.map((ligne) =>
          ligne.map((p) => [p.latitude, p.longitude]).toList()).toList(),
      'polygones': station.polygones?.map((poly) =>
          poly.map((p) => [p.latitude, p.longitude]).toList()).toList(),
    };
  }

  Station _stationFromJson(Map<String, dynamic> json) {
    return Station(
      numeroStation: json['numeroStation'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      treesToCut: json['treesToCut'],
      warning: json['warning'],
      highlight: json['highlight'] ?? false,
      lastModifiedBy: json['lastModifiedBy'],
      treeLandscape: json['treeLandscape'],
      humanFrequency: json['humanFrequency'],
      espaceBoiseClasse: json['espaceBoiseClasse'],
      interetPaysager: json['interetPaysager'],
      codeEnvironnement: json['codeEnvironnement'],
      commentaireProtection: json['commentaireProtection'],
      photoUrls: json['photoUrls']?.cast<String>(),
      points: json['points']?.map<LatLng>((p) => LatLng(p[0], p[1])).toList(),
      lignes: json['lignes']?.map<List<LatLng>>((ligne) =>
          ligne.map<LatLng>((p) => LatLng(p[0], p[1])).toList()).toList(),
      polygones: json['polygones']?.map<List<LatLng>>((poly) =>
          poly.map<LatLng>((p) => LatLng(p[0], p[1])).toList()).toList(),
    );
  }

  Map<String, dynamic> _dossierToJson(Dossier dossier) {
    return {
      'nom': dossier.nom,
      'type': dossier.type,
      'date': dossier.date,
      'center': dossier.center != null ?
      [dossier.center!.latitude, dossier.center!.longitude] : null,
    };
  }

  Dossier _dossierFromJson(Map<String, dynamic> json) {
    return Dossier(
      nom: json['nom'],
      type: json['type'],
      date: json['date'],
      center: json['center'] != null ?
      LatLng(json['center'][0], json['center'][1]) : null,
      stations: [], // Seront chargées séparément
      markerBuilder: (context, {showBadges = true}) => [],
    );
  }
}