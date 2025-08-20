import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class BoomSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const BoomSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryGreen,
            inactiveTrackColor: AppColors.primaryGreen.withAlpha(77),
            thumbColor: AppColors.primaryGreen,
            overlayColor: AppColors.primaryGreen.withAlpha(80),
          ),
          child: Slider(
            min: min,
            max: max,
            value: value,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
            label: value.round().toString(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate((max - min).toInt() + 1, (i) {
            return Expanded(
              child: Center(
                child: Text(
                  '${min.toInt() + i}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          }),
        )
      ],
    );
  }
}
