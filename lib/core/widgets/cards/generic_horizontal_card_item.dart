import 'package:flutter/material.dart';

class GenericHorizontalCardItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String? imageUrl;
  final VoidCallback onTap;
  final Widget? badge;
  final BorderRadiusGeometry borderRadius;
  final double imageBorderRadius;
  final bool isAvatar;

  const GenericHorizontalCardItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.onTap,
    this.imageUrl,
    this.badge,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.imageBorderRadius = 12,
    this.isAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 199,
        margin: const EdgeInsets.only(left: 4, right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec coins arrondis
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(imageBorderRadius),
                  child: Container(
                    height: 96,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageUrl ?? 'assets/images/photo1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    bottom: -9,
                    right: 9,
                    child: badge!,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
