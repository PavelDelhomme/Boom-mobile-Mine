import 'dart:convert' as convert;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/offline_cache_service.dart';

/// Provider d'images pour tuiles avec cache hors ligne
class OfflineTileImageProvider extends ImageProvider<OfflineTileImageProvider> {
  final String url;
  final OfflineCacheService cacheService;
  final TileCoordinates coordinates;

  const OfflineTileImageProvider({
    required this.url,
    required this.cacheService,
    required this.coordinates,
  });

  @override
  Future<OfflineTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture(this);
  }

  // Remplace la méthode dépréciée loadBuffer par loadImage
  @override
  ImageStreamCompleter loadImage(
      OfflineTileImageProvider key,
      ImageDecoderCallback decode,
      ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: url,
      informationCollector: () => [
        DiagnosticsProperty('URL', url),
        DiagnosticsProperty('Coordinates', '${coordinates.x},${coordinates.y},${coordinates.z}'),
        DiagnosticsProperty('Cache service', cacheService.runtimeType.toString()),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
      OfflineTileImageProvider key,
      ImageDecoderCallback decode,
      ) async {
    try {
      // Récupérer la tuile depuis le cache (mémoire/disque) ou télécharger
      final tileData = await cacheService.getTile(url);

      if (tileData != null) {
        final buffer = await ui.ImmutableBuffer.fromUint8List(tileData);
        return await decode(buffer);
      } else {
        // Pas de données disponibles, créer une tuile d'erreur
        final errorTileData = await _createErrorTileData();
        final buffer = await ui.ImmutableBuffer.fromUint8List(errorTileData);
        return await decode(buffer);
      }
    } catch (e) {
      // En cas d'erreur, créer une tuile d'erreur simple
      final errorTileData = await _createErrorTileData();
      final buffer = await ui.ImmutableBuffer.fromUint8List(errorTileData);
      return await decode(buffer);
    }
  }

  Future<Uint8List> _createErrorTileData() async {
    // Créer une tuile d'erreur simple - retourner des données PNG minimales
    // Pour une vraie implémentation, vous devriez générer une vraie image PNG
    const List<int> simplePngHeader = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    ];

    // Pour l'instant, retourner une liste vide qui sera traitée comme erreur
    return Uint8List.fromList(simplePngHeader);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is OfflineTileImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}

/// Couche de tuiles optimisée avec cache hors ligne
class OfflineTileLayer extends StatelessWidget {
  final String urlTemplate;
  final String userAgentPackageName;
  final int maxZoom;
  final int maxNativeZoom;
  final int keepBuffer;
  final int panBuffer;
  final Map<String, String> additionalOptions;
  final bool enableOfflineCache;
  final Widget? errorTileWidget;

  const OfflineTileLayer({
    super.key,
    required this.urlTemplate,
    required this.userAgentPackageName,
    this.maxZoom = 19,
    this.maxNativeZoom = 18,
    this.keepBuffer = 2,
    this.panBuffer = 1,
    this.additionalOptions = const {'retinaMode': 'true'},
    this.enableOfflineCache = true,
    this.errorTileWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableOfflineCache) {
      // Mode classique sans cache
      return TileLayer(
        urlTemplate: urlTemplate,
        userAgentPackageName: userAgentPackageName,
        maxZoom: maxZoom.toDouble(),
        maxNativeZoom: maxNativeZoom,
        keepBuffer: keepBuffer,
        panBuffer: panBuffer,
        additionalOptions: additionalOptions,
      );
    }

    // Mode avec cache offline
    return Consumer<OfflineCacheService>(
      builder: (context, cacheService, child) {
        return TileLayer(
          urlTemplate: urlTemplate,
          userAgentPackageName: userAgentPackageName,
          maxZoom: maxZoom.toDouble(),
          maxNativeZoom: maxNativeZoom,
          keepBuffer: keepBuffer,
          panBuffer: panBuffer,
          additionalOptions: additionalOptions,
          // Provider de tuiles personnalisé avec cache
          tileProvider: OfflineTileProvider(
            cacheService: cacheService,
            urlTemplate: urlTemplate,
          ),
          // CORRECTION: errorTileCallback ne retourne rien (void)
          errorTileCallback: (tile, error, stackTrace) {
            debugPrint('❌ Erreur tuile ${tile.coordinates}: $error');
            // Ne pas retourner de widget ici - c'est void
          },
        );
      },
    );
  }

  Widget _buildErrorTile() {
    return Container(
      width: 256,
      height: 256,
      color: Colors.grey.shade200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              color: Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Hors ligne',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider de tuiles personnalisé avec gestion du cache
class OfflineTileProvider extends TileProvider {
  final OfflineCacheService cacheService;
  final String urlTemplate;

  OfflineTileProvider({
    required this.cacheService,
    required this.urlTemplate,
  });

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = urlTemplate
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString());

    return OfflineTileImageProvider(
      url: url,
      cacheService: cacheService,
      coordinates: coordinates,
    );
  }
}

/// Widget utilitaire pour le pré-téléchargement de zones
class OfflineMapPreloader extends StatefulWidget {
  final LatLng center;
  final double radiusKm;
  final int minZoom;
  final int maxZoom;
  final String tileUrlTemplate;
  final Widget? child;

  const OfflineMapPreloader({
    super.key,
    required this.center,
    required this.radiusKm,
    required this.minZoom,
    required this.maxZoom,
    required this.tileUrlTemplate,
    this.child,
  });

  @override
  State<OfflineMapPreloader> createState() => _OfflineMapPreloaderState();
}

class _OfflineMapPreloaderState extends State<OfflineMapPreloader> {
  bool _isPreloading = false;
  double _progress = 0.0;
  int _totalTiles = 0;
  int _loadedTiles = 0;

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}