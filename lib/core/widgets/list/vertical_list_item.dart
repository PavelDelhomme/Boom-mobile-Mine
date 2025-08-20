import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class VerticalListItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final String subtitle2;
  final VoidCallback onTap;
  final Widget trailing;
  final List<BoxShadow>? boxShadow;

  const VerticalListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.subtitle2,
    required this.onTap,
    required this.trailing,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        subtitle2,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
