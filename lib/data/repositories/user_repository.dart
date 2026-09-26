import 'dart:async';

import '../models/user_model.dart';
import 'demo_data.dart';
import 'points_service.dart';

class UserRepository {
  UserRepository(this._pointsService);

  final PointsService _pointsService;
  final _controller = StreamController<List<UserModel>>.broadcast();

  Stream<UserModel> watchUser(String uid) async* {
    yield _find(uid);
    yield* _controller.stream.map((_) => _find(uid));
  }

  Stream<List<UserModel>> watchLeaderboard() async* {
    yield _sortedUsers();
    yield* _controller.stream.map((_) => _sortedUsers());
  }

  Future<UserModel> incrementReportStats(String uid) async {
    final user = _find(uid);
    final updated = user.copyWith(totalReports: user.totalReports + 1);
    _replace(updated);
    return updated;
  }

  Future<UserModel> markResolved(String uid) async {
    final user = _find(uid);
    final updated = user.copyWith(resolvedReports: user.resolvedReports + 1);
    _replace(updated);
    await _pointsService.addPoints(uid, 50, reason: 'resolved');
    return _find(uid);
  }

  Future<UserModel> addDailyLogin(String uid) async {
    final updated = await _pointsService.addPoints(
      uid,
      5,
      reason: 'daily_login',
    );
    _notify();
    return updated;
  }

  Future<UserModel> refreshLevel(String uid) async {
    final updated = await _pointsService.updateLevel(uid);
    _notify();
    return updated;
  }

  UserModel _find(String uid) {
    return DemoData.leaderboard.firstWhere((item) => item.uid == uid);
  }

  void _replace(UserModel updated) {
    final index = DemoData.leaderboard.indexWhere(
      (item) => item.uid == updated.uid,
    );
    if (index != -1) {
      DemoData.leaderboard[index] = updated;
    }
    if (DemoData.currentUser.uid == updated.uid) {
      DemoData.currentUser = updated;
    }
    _notify();
  }

  List<UserModel> _sortedUsers() {
    final users = [...DemoData.leaderboard];
    users.sort((a, b) => b.points.compareTo(a.points));
    return users;
  }

  void _notify() => _controller.add(_sortedUsers());
}
