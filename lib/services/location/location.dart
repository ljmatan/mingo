import 'dart:math';
import 'dart:async';

import 'package:geolocator/geolocator.dart';

abstract class LocationServices {
  static bool? _serviceEnabled;
  static bool get serviceEnabled => _serviceEnabled ?? false;

  static LocationPermission? _permissionStatus;
  static LocationPermission? get permissionStatus => _permissionStatus;

  static Position? _locationData;
  static Position? get locationData => _locationData?.latitude == null || _locationData?.longitude == null ? null : _locationData!;

  static void clearData() => _locationData = null;

  static Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw 'Nešto je pošlo po zlu',
    );
    if (!serviceEnabled) {
      throw 'GPS mora biti upaljen kako biste koristili lokacijske usluge';
    }
    _permissionStatus = await Geolocator.checkPermission();
    if (_permissionStatus == LocationPermission.deniedForever) {
      throw 'Lokacijske usluge trajno odbijene';
    } else if (_permissionStatus != LocationPermission.always || _permissionStatus != LocationPermission.whileInUse) {
      _permissionStatus = await Geolocator.requestPermission();
      if (_permissionStatus == LocationPermission.deniedForever) {
        throw 'Lokacijske usluge trajno odbijene';
      } else if (_permissionStatus == LocationPermission.denied) {
        throw 'GPS privola je potrebna kako biste koristili usluge lokacije';
      }
    } else if (_permissionStatus == LocationPermission.unableToDetermine) {
      throw 'Nešto je pošlo po zlu';
    }
    _locationData = await Geolocator.getCurrentPosition().timeout(
      const Duration(seconds: 7),
      onTimeout: () => throw 'Nešto je pošlo po zlu',
    );
    return locationData!;
  }

  /// Distance in kilometers.
  static num getDistance(double lat1, double lon1, double lat2, double lon2) {
    num deg2rad(deg) => deg * (pi / 180);
    final rLat = deg2rad(lat2 - lat1);
    final rLon = deg2rad(lon2 - lon1);
    final a = sin(rLat / 2) * sin(rLat / 2) + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(rLon / 2) * sin(rLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return 6371 * c;
  }
}
