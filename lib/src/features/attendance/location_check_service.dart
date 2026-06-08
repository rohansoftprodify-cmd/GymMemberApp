import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationCheckResult {
  const LocationCheckResult.success({
    required this.distanceMeters,
    required this.latitude,
    required this.longitude,
  })  : isSuccess = true,
        errorMessage = null;

  const LocationCheckResult.failure(this.errorMessage)
      : isSuccess = false,
        distanceMeters = null,
        latitude = null,
        longitude = null;

  final bool isSuccess;
  final String? errorMessage;
  final double? distanceMeters;
  final double? latitude;
  final double? longitude;
}

Future<LocationCheckResult> verifyNearGym({
  required double? gymLatitude,
  required double? gymLongitude,
  required int radiusMeters,
}) async {
  if (gymLatitude == null || gymLongitude == null) {
    return const LocationCheckResult.failure(
      'Gym location is not configured yet. Ask staff to set coordinates in gym profile.',
    );
  }

  try {
    return await _verifyNearGym(
      gymLatitude: gymLatitude,
      gymLongitude: gymLongitude,
      radiusMeters: radiusMeters,
    );
  } on MissingPluginException {
    return const LocationCheckResult.failure(
      'Location plugin not loaded. Fully stop and reopen the app, then try again.',
    );
  }
}

Future<LocationCheckResult> _verifyNearGym({
  required double gymLatitude,
  required double gymLongitude,
  required int radiusMeters,
}) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return const LocationCheckResult.failure('Turn on location services to check in at the gym.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    return const LocationCheckResult.failure('Location permission is required for gym check-in.');
  }

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );

  final distance = _distanceMeters(
    position.latitude,
    position.longitude,
    gymLatitude,
    gymLongitude,
  );

  if (distance > radiusMeters) {
    return LocationCheckResult.failure(
      'You are ${distance.round()} m away. Move within ${radiusMeters}m of the gym.',
    );
  }

  return LocationCheckResult.success(
    distanceMeters: distance,
    latitude: position.latitude,
    longitude: position.longitude,
  );
}


double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

double _toRadians(double deg) => deg * math.pi / 180;
