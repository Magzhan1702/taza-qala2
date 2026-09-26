import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/location_helper.dart';
import '../../../data/models/report_model.dart';
import '../../../providers/map_provider.dart';
import '../../../providers/report_provider.dart';
import '../../widgets/map_pin_widget.dart';
import '../../widgets/report_card.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await LocationHelper.getPreciseCurrentPosition();
      if (!mounted) {
        return;
      }
      setState(() => _userPosition = position);
    } catch (_) {
      // Keep the map usable even if live location is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(reportsProvider).value ?? [];
    final hotZones = ref.watch(hotZonesProvider);
    final initialTarget = _userPosition == null
        ? const LatLng(43.238949, 76.889709)
        : LatLng(_userPosition!.latitude, _userPosition!.longitude);
    final markers = reports.map((report) {
      return Marker(
        markerId: MarkerId(report.id),
        position: LatLng(report.latitude, report.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(report.status)),
        onTap: () => _showReportSheet(context, report),
      );
    }).toSet();

    final circles = hotZones.map((zone) {
      return Circle(
        circleId: CircleId('${zone.latitude}-${zone.longitude}'),
        center: LatLng(zone.latitude, zone.longitude),
        radius: 500,
        fillColor: AppColors.success.withValues(alpha: 0.12),
        strokeColor: AppColors.success.withValues(alpha: 0.4),
        strokeWidth: 2,
      );
    }).toSet();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Мәселе картасы',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const MapLegend(),
          const SizedBox(height: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GoogleMap(
                key: ValueKey(
                  _userPosition == null
                      ? 'default-map'
                      : 'user-${_userPosition!.latitude},${_userPosition!.longitude}',
                ),
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: _userPosition == null ? 12.8 : 16.2,
                ),
                markers: markers,
                circles: circles,
                myLocationEnabled: _userPosition != null,
                myLocationButtonEnabled: _userPosition != null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Жалпы ${reports.length} мәселе тіркелген',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  static double _markerHue(ReportStatus status) {
    return switch (status) {
      ReportStatus.newReport => BitmapDescriptor.hueRed,
      ReportStatus.inProgress => BitmapDescriptor.hueYellow,
      ReportStatus.resolved => BitmapDescriptor.hueGreen,
    };
  }

  static Future<void> _showReportSheet(
    BuildContext context,
    ReportModel report,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.42,
          minChildSize: 0.32,
          maxChildSize: 0.8,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                ReportCard(report: report, showImage: true),
                const SizedBox(height: 12),
                _SheetImage(imageUrl: report.imageUrl),
                const SizedBox(height: 12),
                Text(
                  report.address,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  report.description,
                  style: const TextStyle(color: AppColors.textSoft),
                ),
                const SizedBox(height: 12),
                Text(
                  'Уақыты: ${report.createdAt}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SheetImage extends StatelessWidget {
  const _SheetImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined, size: 40),
      );
    }

    if (imageUrl.startsWith('/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(
          File(imageUrl),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
