import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> getCurrentDevicePosition() async {
  if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) {
    throw Exception('Turn on location services to use your current location.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw Exception('Location permission was denied.');
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception(
      'Enable location permission for GaSX in your device settings.',
    );
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    ),
  );
}
