import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BoomTabHeader extends StatelessWidget {
  final int currentIndex;
  final List<String> labels;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onChanged;

  const BoomTabHeader({
    super.key,
    required this.currentIndex,
    required this.labels,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (i) {
          final selected = i == currentIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                    colors: [AppColors.ligthGreenSearchBar, AppColors.ligthGreenSearchBar],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(33),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? AppColors.primaryGreen : AppColors.textLightGrey,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
    );
  }
}