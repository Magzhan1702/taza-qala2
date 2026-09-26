import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/report_model.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.trailing,
    this.showImage = false,
  });

  final ReportModel report;
  final Widget? trailing;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showImage) ...[
            _ReportImage(imageUrl: report.imageUrl),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_categoryIcon(report.category)} ${_categoryLabel(report.category)}',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.address,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing ?? StatusChip(status: report.status),
        ],
      ),
    );
  }

  static String _categoryIcon(ReportCategory category) {
    return switch (category) {
      ReportCategory.trash => '🗑️',
      ReportCategory.road => '🚧',
      ReportCategory.water => '💧',
      ReportCategory.other => '⚠️',
    };
  }

  static String _categoryLabel(ReportCategory category) {
    return switch (category) {
      ReportCategory.trash => 'Қоқыс',
      ReportCategory.road => 'Жол бұзылған',
      ReportCategory.water => 'Су ағып жатыр',
      ReportCategory.other => 'Басқа',
    };
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ReportStatus.newReport => (AppColors.danger, 'Жаңа'),
      ReportStatus.inProgress => (AppColors.warn, 'Жұмыста'),
      ReportStatus.resolved => (AppColors.success, 'Шешілді'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ReportImage extends StatelessWidget {
  const _ReportImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    );

    if (imageUrl.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: decoration,
        alignment: Alignment.center,
        child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
      );
    }

    if (imageUrl.startsWith('/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imageUrl),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => Container(
          decoration: decoration,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
