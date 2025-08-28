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

      if (tileData != null && tileData.length > 100) { // Vérification de taille minimale
        try {
          final buffer = await ui.ImmutableBuffer.fromUint8List(tileData);
          return await decode(buffer);
        } catch (decodeError) {
          debugPrint('⚠️ Erreur décodage: $decodeError');
          // Fallback vers tuile d'erreur si le décodage échoue
          final errorTileData = await _createErrorTileData();
          final buffer = await ui.ImmutableBuffer.fromUint8List(errorTileData);
          return await decode(buffer);
        }
      } else {
        // Pas de données valides, créer une tuile d'erreur
        final errorTileData = await _createErrorTileData();
        final buffer = await ui.ImmutableBuffer.fromUint8List(errorTileData);
        return await decode(buffer);
      }
    } catch (e) {
      // En cas d'erreur, créer une tuile d'erreur
      final errorTileData = await _createErrorTileData();
      final buffer = await ui.ImmutableBuffer.fromUint8List(errorTileData);
      return await decode(buffer);
    }
  }

  Future<Uint8List> _createErrorTileData() async {
    // Création d'une vraie image d'erreur via ui.PictureRecorder pour dessin d'image basique d'erreur
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Dessiner un fond gris clair
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 256, 256),
      Paint()..color = Colors.grey[200]!,
    );

    // Dessinger une icone ou texte d'erreur
    final textPainter = TextPainter(
      text: TextSpan(
        text: '❌',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
          (256 - textPainter.width) / 2,
          (256 - textPainter.height) / 2,
      ),
    );

    // Créer l'image
    final picture = recorder.endRecording();
    final img = await picture.toImage(256, 256);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List() ?? Uint8List(0);
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

  Future<void> _startPreloading() async {
    setState(() {
      _isPreloading = true;
      _progress = 0.0;
      _totalTiles = 0;
      _loadedTiles = 0;
    });

    try {
      // Obtenez le service de cache
      final cacheService = Provider.of<OfflineCacheService>(context, listen: false);

      // Démarrer le pré-téléchargement
      await cacheService.preloadArea(
        center: widget.center,
        radiusKm: widget.radiusKm,
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        tileUrlTemplate: widget.tileUrlTemplate,
        onProgress: (current, total) {
          setState(() {
            _loadedTiles = current;
            _totalTiles = total;
            _progress = current / total;
          });
        },
      );
    } finally {
      setState(() {
        _isPreloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isPreloading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Préchargement: $_loadedTiles/$_totalTiles tuiles',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _progress),
              ],
            ),
          ),
        if (!_isPreloading)
          ElevatedButton(
            onPressed: _startPreloading,
            child: const Text('Précharger la zone'),
          ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}