import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/report_provider.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/report_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).value;
    final reports = ref.watch(recentReportsProvider).value ?? [];
    final stats = ref.watch(reportStatsProvider);

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.report),
        backgroundColor: AppColors.accent,
        label: const Text(
          '📸 МӘСЕЛЕ ТІРКЕУ',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Қош келдің,',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${auth?.displayName ?? 'Алматы'} 👋',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentGlow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${auth?.points ?? 0} ⭐',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (auth != null) LevelBadge(level: auth.level),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _StatsRow(stats: stats),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go(AppRoutes.map),
            child: const _MiniMapPreview(),
          ),
          const SizedBox(height: 18),
          const Text(
            'Соңғы тіркелген',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          for (final report in reports) ...[
            ReportCard(report: report),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final Map<dynamic, int> stats;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Жаңа', '${stats.values.elementAt(0)}', AppColors.danger),
      ('Жұмыста', '${stats.values.elementAt(1)}', AppColors.warn),
      ('Шешілді', '${stats.values.elementAt(2)}', AppColors.success),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: item.$3.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Text(
                  item.$2,
                  style: TextStyle(
                    color: item.$3,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MiniMapPreview extends StatelessWidget {
  const _MiniMapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MiniMapPainter())),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Картаны ашу →',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    final line = Paint()
      ..color = AppColors.border
      ..strokeWidth = 2;

    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      line,
    );

    final hotZone = Paint()
      ..color = AppColors.danger.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.38, size.height * 0.42),
      16,
      hotZone,
    );

    final points = [
      (0.38, 0.42, AppColors.danger),
      (0.62, 0.55, AppColors.warn),
      (0.28, 0.65, AppColors.success),
      (0.55, 0.28, AppColors.danger),
      (0.44, 0.70, AppColors.warn),
    ];

    for (final point in points) {
      canvas.drawCircle(
        Offset(size.width * point.$1, size.height * point.$2),
        4,
        Paint()..color = point.$3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
