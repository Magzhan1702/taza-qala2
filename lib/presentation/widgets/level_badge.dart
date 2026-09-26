import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';

class LevelBadge extends StatelessWidget {
  const LevelBadge({super.key, required this.level});

  final UserLevel level;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (level) {
      UserLevel.beginner => ('🌱', 'Бастапқы деңгей'),
      UserLevel.ecoHero => ('🌿', 'Эко Батыр'),
      UserLevel.citySavior => ('🔥', 'Қала Құтқарушы'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accentGlow),
      ),
      child: Text(
        '$icon $label',
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
