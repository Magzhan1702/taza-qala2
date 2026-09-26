import '../models/user_model.dart';
import 'demo_data.dart';

class PointsService {
  Future<UserModel> addPoints(
    String userId,
    int points, {
    String? reason,
  }) async {
    final user = DemoData.leaderboard.firstWhere((item) => item.uid == userId);
    final updated = user.copyWith(
      points: user.points + points,
      level: calculateLevel(user.points + points),
    );
    _replaceUser(updated);
    return updated;
  }

  Future<UserModel> deductPoints(String userId, int points) async {
    final user = DemoData.leaderboard.firstWhere((item) => item.uid == userId);
    final nextPoints = (user.points - points).clamp(0, 999999);
    final updated = user.copyWith(
      points: nextPoints,
      level: calculateLevel(nextPoints),
    );
    _replaceUser(updated);
    return updated;
  }

  Future<UserModel> updateLevel(String userId) async {
    final user = DemoData.leaderboard.firstWhere((item) => item.uid == userId);
    final updated = user.copyWith(level: calculateLevel(user.points));
    _replaceUser(updated);
    return updated;
  }

  UserLevel calculateLevel(int points) {
    if (points >= 1200) {
      return UserLevel.citySavior;
    }
    if (points >= 500) {
      return UserLevel.ecoHero;
    }
    return UserLevel.beginner;
  }

  void _replaceUser(UserModel updated) {
    final index = DemoData.leaderboard.indexWhere(
      (item) => item.uid == updated.uid,
    );
    if (index != -1) {
      DemoData.leaderboard[index] = updated;
    }
    if (DemoData.currentUser.uid == updated.uid) {
      DemoData.currentUser = updated;
    }
  }
}
