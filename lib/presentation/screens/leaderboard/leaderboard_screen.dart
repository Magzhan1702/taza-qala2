import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/report_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userRepositoryProvider).watchLeaderboard();

    return StreamBuilder(
      stream: users,
      builder: (context, snapshot) {
        final leaderboard = snapshot.data ?? [];
        final topThree = leaderboard.take(3).toList();
        final rest = leaderboard.skip(3).toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏆 Рейтинг',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: AppColors.bg,
                  unselectedLabelColor: AppColors.textMuted,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Апталық'),
                    Tab(text: 'Жалпы'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (topThree.length > 1)
                      _PodiumCard(
                        rank: 2,
                        name: topThree[1].displayName,
                        points: topThree[1].points,
                        height: 100,
                      ),
                    if (topThree.isNotEmpty)
                      _PodiumCard(
                        rank: 1,
                        name: topThree[0].displayName,
                        points: topThree[0].points,
                        height: 126,
                      ),
                    if (topThree.length > 2)
                      _PodiumCard(
                        rank: 3,
                        name: topThree[2].displayName,
                        points: topThree[2].points,
                        height: 88,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: rest.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final user = rest[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 34,
                            child: Text(
                              '#${index + 4}',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const CircleAvatar(
                            backgroundColor: AppColors.accentDim,
                            child: Icon(Icons.person, color: AppColors.accent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${user.totalReports} репорт',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${user.points} ⭐',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.rank,
    required this.name,
    required this.points,
    required this.height,
  });

  final int rank;
  final String name;
  final int points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      _ => AppColors.bronze,
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.18),
          child: Text(
            rank == 1 ? '🔥' : '🌿',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 78,
          child: Text(
            name,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          '$points',
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.34),
                color.withValues(alpha: 0.18),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '#$rank',
            style: TextStyle(color: color, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
