import 'dart:async';
import 'dart:io';

import '../models/report_model.dart';
import 'demo_data.dart';
import 'points_service.dart';
import 'user_repository.dart';

class ReportDraft {
  const ReportDraft({
    required this.userId,
    required this.category,
    required this.description,
    required this.imageFile,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final String userId;
  final ReportCategory category;
  final String description;
  final File? imageFile;
  final double latitude;
  final double longitude;
  final String address;
}

class ReportRepository {
  ReportRepository(this._pointsService, this._userRepository);

  final PointsService _pointsService;
  final UserRepository _userRepository;
  final _controller = StreamController<List<ReportModel>>.broadcast();

  Stream<List<ReportModel>> watchReports() async* {
    yield _sortedReports();
    yield* _controller.stream.map((_) => _sortedReports());
  }

  Stream<List<ReportModel>> watchRecentReports({int limit = 10}) {
    return watchReports().map((reports) => reports.take(limit).toList());
  }

  Stream<List<ReportModel>> watchUserReports(String userId) {
    return watchReports().map(
      (reports) => reports.where((item) => item.userId == userId).toList(),
    );
  }

  Future<void> createReport(ReportDraft draft) async {
    final report = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: draft.userId,
      category: draft.category,
      description: draft.description,
      imageUrl: draft.imageFile?.path ?? '',
      latitude: draft.latitude,
      longitude: draft.longitude,
      address: draft.address,
      status: ReportStatus.newReport,
      createdAt: DateTime.now(),
      resolvedAt: null,
      isFake: false,
    );

    DemoData.reports.insert(0, report);
    await _pointsService.addPoints(draft.userId, 10, reason: 'report_create');
    await _userRepository.incrementReportStats(draft.userId);

    final userReports = DemoData.reports.where(
      (item) => item.userId == draft.userId,
    );
    if (userReports.length == 1) {
      await _pointsService.addPoints(draft.userId, 25, reason: 'first_report');
    }

    _notify();
  }

  Future<void> updateStatus(String reportId, ReportStatus status) async {
    final index = DemoData.reports.indexWhere((item) => item.id == reportId);
    if (index == -1) {
      return;
    }

    final current = DemoData.reports[index];
    final updated = current.copyWith(
      status: status,
      resolvedAt: status == ReportStatus.resolved ? DateTime.now() : null,
    );
    DemoData.reports[index] = updated;

    if (current.status != ReportStatus.resolved &&
        status == ReportStatus.resolved) {
      await _userRepository.markResolved(current.userId);
    }

    _notify();
  }

  Future<void> markFake(String reportId) async {
    final index = DemoData.reports.indexWhere((item) => item.id == reportId);
    if (index == -1) {
      return;
    }
    final current = DemoData.reports[index];
    DemoData.reports[index] = current.copyWith(isFake: true);
    await _pointsService.deductPoints(current.userId, 20);
    _notify();
  }

  List<ReportModel> _sortedReports() {
    final reports = [...DemoData.reports];
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }

  void _notify() => _controller.add(_sortedReports());
}
