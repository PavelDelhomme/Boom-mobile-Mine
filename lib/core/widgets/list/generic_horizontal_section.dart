import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_text_styles.dart';

class GenericHorizontalSection<T> extends StatelessWidget {
  final List<T> items;
  final String title;
  final Widget Function(T) itemBuilder;

  const GenericHorizontalSection({
    super.key,
    required this.items,
    required this.title,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding, vertical: kVerticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: kElementSpacing),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length.clamp(0, 6),
              separatorBuilder: (_, __) => const SizedBox(width: kCardSpacing),
              itemBuilder: (context, index) => itemBuilder(items[index]),
            ),
          ),
        ],
      ),
    );
  }
}
