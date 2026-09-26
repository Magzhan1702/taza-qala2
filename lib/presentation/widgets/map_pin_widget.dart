import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/report_model.dart';

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendItem(color: AppColors.danger, label: 'Жаңа'),
        _LegendItem(color: AppColors.warn, label: 'Жұмыста'),
        _LegendItem(color: AppColors.success, label: 'Шешілді'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}

Color statusColor(ReportStatus status) {
  return switch (status) {
    ReportStatus.newReport => AppColors.danger,
    ReportStatus.inProgress => AppColors.warn,
    ReportStatus.resolved => AppColors.success,
  };
}
