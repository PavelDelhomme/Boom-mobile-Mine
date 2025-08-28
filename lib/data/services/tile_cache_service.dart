// Service de mise en cache

import 'dart:math';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/adapters.dart';

class TileCacheService {
  late Box<Uint8List> _tileCache;

  //TileCacheService(this._tileCache);

  Future<void> initialize() async {
    _tileCache = await Hive.openBox<Uint8List>('tile_cache');
  }

  // Récupérer une tuile depuis le cache
  Future<Uint8List?> getTile(String url) async {
    return _tileCache.get(url);
  }

  // Mettre en cache une tuile
  Future<void> cacheTile(String url, Uint8List tileData) async {
    await _tileCache.put(url, tileData);
  }

  // Pré-charger les tuiles pour une zone
  Future<void> preloadTiles(LatLngBounds bounds, int minZoom, int maxZoom) async {
    // Calculer les tuiles à précharger
    for (int z = minZoom; z <= maxZoom; z++) {
      final tiles = _getTilesForBounds(bounds, z);
      for (final tile in tiles) {
        final url = _getTileUrl(tile.x, tile.y, z);
        if (!_tileCache.containsKey(url)) {
          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              await cacheTile(url, response.bodyBytes);
            }
          } catch (e) {
            debugPrint('Erreur lors du préchargement de la tuile: $e');
          }
        }
      }
    }
  }

  // Calculer les tuiles pour une zone
  List<TileCoordinates> _getTilesForBounds(LatLngBounds bounds, int zoom) {
    // Logique simplifiée pour l'exemple
    final List<TileCoordinates> tiles = [];

    // Calcul basique des coordonnées de tuiles pour la zone
    final minX = _longitudeToTileX(bounds.southWest.longitude, zoom).floor();
    final maxX = _longitudeToTileX(bounds.northEast.longitude, zoom).ceil();
    final minY = _latitudeToTileY(bounds.northEast.latitude, zoom).floor();
    final maxY = _latitudeToTileY(bounds.southWest.latitude, zoom).ceil();

    for (int x = minX; x <= maxX; x++) {
      for (int y = minY; y <= maxY; y++) {
        tiles.add(TileCoordinates(x, y, zoom));
      }
    }

    return tiles;
  }

  // Construire l'URL d'une tuile
  String _getTileUrl(int x, int y, int z) {
    return 'https://tile.openstreetmap.org/$z/$x/$y.png';
  }

  // Conversions coordonnées géographiques -> tuiles
  double _longitudeToTileX(double lon, int zoom) {
    return ((lon + 180) / 360) * pow(2, zoom);
  }

  double _latitudeToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    return (1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * pow(2, zoom);
  }

  double pow(double x, int power) {
    return math.pow(x, power).toDouble();
  }
}