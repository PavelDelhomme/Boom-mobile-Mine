import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class DossierHorizontalCardItem extends StatelessWidget {
  final String title;
  final String status;
  final String date;
  final String? imageUrl;
  final VoidCallback onTap;
  final String imagePath;

  const DossierHorizontalCardItem({
    super.key,
    required this.title,
    required this.status,
    required this.date,
    this.imageUrl,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
        future: _getCachedImage(imagePath),
        builder: (context, snapshot) {
          final imageProvider = snapshot.hasData
              ? FileImage(snapshot.data!)
              : AssetImage(kDossierImage) as ImageProvider;

          return GestureDetector(
            onTap: onTap,
            child: _buildMainContainer(imageProvider),
          );
        });
  }

  Widget _buildMainContainer(ImageProvider imageProvider) {
    return Container(
      width: 199,
      margin: const EdgeInsets.only(left: 4, right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(99),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de fond avec badge
          Stack(
            clipBehavior: Clip.none, // Permission de déborder
            children: [
              // Image avec coins arrondis
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 96,
                  child: _buildOptimizedImage(),
                ),
              ),
              Positioned(
                bottom: -9,
                right: 9,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              top: 12.0,
              right: 16.0,
              bottom: 4.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texte avec ellipsis si trop long
                Text(
                  title,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),

                // Status avec badge
                Row(
                  children: [
                    Text(
                      status,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    // Badge orange
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA5624),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Text(
                        "34",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Future<File> _getCachedImage(String path) async {
    if (!path.startsWith('assets/')) return File(path);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${path.split('/').last}');

    if (!await file.exists()) {
      final data = await rootBundle.load(path);
      await file.writeAsBytes(data.buffer.asUint8List());
    }

    return file;
  }

  Widget _buildOptimizedImage() {
    final url = imageUrl ?? kDossierImage;

    // Pour les images réseau
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    }
    // Pour les assets locaux
    else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        cacheHeight: 192, // 2x pour les écrans HD
      );
    }
  }
}