import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/providers/vendor_provider.dart';
import '../../data/models/vendor_models.dart';

class GasMapScreen extends ConsumerStatefulWidget {
  const GasMapScreen({super.key});

  @override
  ConsumerState<GasMapScreen> createState() => _GasMapScreenState();
}

class _GasMapScreenState extends ConsumerState<GasMapScreen> {
  final MapController _mapController = MapController();
  ll.LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  // JAWG ACCESS TOKEN from Vue
  static const String _jawgToken = 'QWSZT4r4RnGLINur1NGRr2YTcTCLVbIPPbijitdYg4K5imZqo0dqSzPajpWqMPWB';

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = kIsWeb || await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorSnackBar('Location permission denied.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showErrorSnackBar('Location permissions are permanently denied. Please enable them in settings.');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = ll.LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentPosition!, 12);
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = ll.LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorsProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer
          _buildMap(vendorsAsync),
        ],
      ),
    );
  }

  Widget _buildMap(AsyncValue<List<Vendor>> vendorsAsync) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition ?? const ll.LatLng(4.0511, 9.7085), // Fallback to Douala temporarily
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.jawg.io/jawg-dark/{z}/{x}/{y}{r}.png?access-token=$_jawgToken',
          userAgentPackageName: 'com.GaSX.app',
        ),
        MarkerLayer(
          markers: vendorsAsync.when(
            data: (vendors) => vendors.where((v) => v.latitude != null && v.longitude != null).map((v) {
              return Marker(
                point: ll.LatLng(v.latitude!, v.longitude!),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    // Could navigate or show toast
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentTeal.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.gas_meter, color: Colors.black, size: 20),
                  ),
                ),
              );
            }).toList()
              ..addAll(_currentPosition != null ? [
                Marker(
                  point: _currentPosition!,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 24),
                  ),
                ),
              ] : []),
            loading: () => [],
            error: (_, __) => [],
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
