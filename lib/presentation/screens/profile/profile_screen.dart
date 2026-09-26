import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/report_provider.dart';
import '../../widgets/level_badge.dart';
import '../../widgets/report_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user =
        authState.value ?? ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      if (authState.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return const Center(
        child: Text(
          'Профиль деректері қолжетімсіз.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    final reportsStream = ref
        .watch(reportRepositoryProvider)
        .watchUserReports(user.uid);

    return StreamBuilder(
      stream: reportsStream,
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];
        final nextLevelTarget = _nextLevelTarget(user.level);
        final progress = nextLevelTarget == null
            ? 1.0
            : ((user.points - _currentLevelMin(user.level)) /
                      (nextLevelTarget - _currentLevelMin(user.level)))
                  .clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.accent,
                child: Icon(Icons.person, size: 32, color: AppColors.bg),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  user.email,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 10),
              Center(child: LevelBadge(level: user.level)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Жиналған балл'),
                        Text(
                          '${user.points} ⭐',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      ),
                    ),
                    if (nextLevelTarget != null) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${nextLevelTarget - user.points} балл қалды',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${user.totalReports}',
                      label: 'Репорт',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(
                      value: '${user.resolvedReports}',
                      label: 'Шешілді',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatCard(value: '${user.points}', label: 'Балл'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Тарих',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              for (final report in reports) ...[
                ReportCard(report: report),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
                child: const Text('Шығу'),
              ),
            ],
          ),
        );
      },
    );
  }

  static int _currentLevelMin(UserLevel level) {
    return switch (level) {
      UserLevel.beginner => 0,
      UserLevel.ecoHero => 500,
      UserLevel.citySavior => 1200,
    };
  }

  static int? _nextLevelTarget(UserLevel level) {
    return switch (level) {
      UserLevel.beginner => 500,
      UserLevel.ecoHero => 1200,
      UserLevel.citySavior => null,
    };
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
