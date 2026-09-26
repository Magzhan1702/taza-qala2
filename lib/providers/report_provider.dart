import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/report_model.dart';
import '../data/repositories/points_service.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/user_repository.dart';

final pointsServiceProvider = Provider<PointsService>((ref) => PointsService());

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(pointsServiceProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    ref.watch(pointsServiceProvider),
    ref.watch(userRepositoryProvider),
  );
});

final reportsProvider = StreamProvider<List<ReportModel>>((ref) {
  return ref.watch(reportRepositoryProvider).watchReports();
});

final recentReportsProvider = StreamProvider<List<ReportModel>>((ref) {
  return ref.watch(reportRepositoryProvider).watchRecentReports();
});

final reportStatsProvider = Provider<Map<ReportStatus, int>>((ref) {
  final reports = ref.watch(reportsProvider).value ?? [];
  return {
    ReportStatus.newReport: reports
        .where((item) => item.status == ReportStatus.newReport)
        .length,
    ReportStatus.inProgress: reports
        .where((item) => item.status == ReportStatus.inProgress)
        .length,
    ReportStatus.resolved: reports
        .where((item) => item.status == ReportStatus.resolved)
        .length,
  };
});
