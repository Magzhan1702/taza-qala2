import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/location_helper.dart';
import 'report_provider.dart';

final hotZonesProvider = Provider<List<HotZone>>((ref) {
  final reports = ref.watch(reportsProvider).value ?? [];
  return LocationHelper.detectHotZones(reports);
});
