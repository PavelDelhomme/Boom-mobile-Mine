import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';


class BoomPhotoViewer extends StatefulWidget {
  final List<String> photoPaths;
  final Function(List<String>) onPhotosUpdated;

  const BoomPhotoViewer({
    super.key,
    required this.photoPaths,
    required this.onPhotosUpdated,
  });

  @override
  State<BoomPhotoViewer> createState() => _BoomPhotoViewerState();
}

class _BoomPhotoViewerState extends State<BoomPhotoViewer> {
  final Map<String, File> _cachedFiles = {};
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initCache();
  }

  Future<void> _initCache() async {
    for (final path in widget.photoPaths) {
      if (path.startsWith('assets/')) {
        final file = await _cacheAsset(path);
        _cachedFiles[path] = file;
      }
    }
  }


  Future<File> _cacheAsset(String assetPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${assetPath.split('/').last}');

    if (!await file.exists()) {
      final data = await rootBundle.load(assetPath);
      await file.writeAsBytes(data.buffer.asUint8List());
    }

    return file;
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImageProvider(
        path,
        cacheKey: path, // Utilisez un identifiant unique pour le cache
        cacheManager: DefaultCacheManager(),
      );
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }


  Future<void> _handlePhotoAction() async {
    final source = await _showSourceSelector();
    if (source == null) return;

    final permission = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (permission.isGranted) {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        final newPhotos = [...widget.photoPaths, image.path];
        widget.onPhotosUpdated(newPhotos);
      }
    }
  }

  Future<ImageSource?> _showSourceSelector() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir dans la galerie'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.photoPaths.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index < widget.photoPaths.length) {
            return _buildPhotoCard(widget.photoPaths[index], index);
          } else {
            return _buildAddPhotoPlaceholder();
          }
        },
      ),
    );
  }

  void _removePhoto(int index) {
    final newPhotos = List<String>.from(widget.photoPaths)..removeAt(index);
    widget.onPhotosUpdated(newPhotos);
  }

  Widget _buildPhotoCard(String path, int index) {
    return Stack(
      children: [
        Container(
          width: 180,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: _getImageProvider(path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(Icons.edit, () => _editPhoto(index)),
              const SizedBox(width: 12),
              _buildActionButton(Icons.delete, () => _removePhoto(index)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildAddPhotoPlaceholder() {
    return GestureDetector(
      onTap: _handlePhotoAction,
      child: Container(
        width: 160,
        height: 210,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 48),
            SizedBox(height: 16),
            Text("Ajouter une photo", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _editPhoto(int index) async {
    final source = await _showSourceSelector();
    if (source == null) return;

    final permission = source == ImageSource.camera
        ? await Permission.camera.request()
        : await Permission.photos.request();

    if (permission.isGranted) {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        final newPhotos = List<String>.from(widget.photoPaths);
        newPhotos[index] = image.path;
        widget.onPhotosUpdated(newPhotos);
      }
    }
  }
}
