import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/report_model.dart';

class HotZone {
  const HotZone({
    required this.latitude,
    required this.longitude,
    required this.count,
  });

  final double latitude;
  final double longitude;
  final int count;
}

class LocationHelper {
  static Future<LocationPermission> ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException('Location permission not granted.');
    }

    return permission;
  }

  static Future<Position> getPreciseCurrentPosition() async {
    await ensureLocationPermission();
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  }

  static Future<String> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final place = placemarks.first;
      return [
        place.street,
        place.locality,
        place.administrativeArea,
      ].where((value) => value != null && value.isNotEmpty).join(', ');
    } catch (_) {
      return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
    }
  }

  static List<HotZone> detectHotZones(List<ReportModel> reports) {
    final zones = <HotZone>[];

    for (final report in reports) {
      final nearbyCount = reports.where((other) {
        final distance = Geolocator.distanceBetween(
          report.latitude,
          report.longitude,
          other.latitude,
          other.longitude,
        );
        return distance <= 500;
      }).length;

      if (nearbyCount >= 3) {
        final alreadyExists = zones.any((zone) {
          final distance = Geolocator.distanceBetween(
            zone.latitude,
            zone.longitude,
            report.latitude,
            report.longitude,
          );
          return distance <= 300;
        });

        if (!alreadyExists) {
          zones.add(
            HotZone(
              latitude: report.latitude,
              longitude: report.longitude,
              count: nearbyCount,
            ),
          );
        }
      }
    }

    return zones;
  }
}
