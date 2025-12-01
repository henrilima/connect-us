import 'dart:async';
import 'package:connect/components/header.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/location_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const LocationScreen(this.setPage, {super.key, required this.userData});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Map<String, String>? _usernames;
  String? distance;
  String? distanceText;
  bool _hasPermission = false;
  bool _isLoading = true;

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<Map<String, dynamic>>? _partnerStreamSubscription;
  Position? _currentPosition;
  Map<String, dynamic>? _partnerData;

  @override
  void initState() {
    super.initState();
    _initLocationService();
    _loadUsernames();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _partnerStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUsernames() async {
    final authorUsername = await DatabaseService().getUsername(
      widget.userData['userId'],
    );
    final partnerUsername = await DatabaseService().getUsername(
      widget.userData['partnerId'],
    );

    if (mounted) {
      setState(() {
        _usernames = {'author': authorUsername, 'partner': partnerUsername};
      });
    }
  }

  Future<void> _initLocationService() async {
    final hasPermission = await LocationService().hasPermission();
    setState(() {
      _hasPermission = hasPermission;
    });

    if (hasPermission) {
      _startTracking();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTracking() {
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          _currentPosition = position;
          DatabaseService().updateLocation(widget.userData['userId'], position);
          _calculateDistance();
        });

    _partnerStreamSubscription = DatabaseService()
        .getPartnerStream(widget.userData['partnerId'])
        .listen((data) {
          if (mounted) {
            setState(() {
              _partnerData = data;
            });
            _calculateDistance();
          }
        });

    setState(() {
      _isLoading = false;
    });
  }

  void _calculateDistance() {
    if (_currentPosition != null &&
        _partnerData != null &&
        _partnerData!['location'] != null) {
      final partnerLoc = _partnerData!['location'];
      final double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        (partnerLoc['latitude'] as num).toDouble(),
        (partnerLoc['longitude'] as num).toDouble(),
      );

      final double distanceInKm = distanceInMeters / 1000;

      String text;
      if (distanceInMeters < 20) {
        text = "Vocês estão juntinhos";
      } else if (distanceInMeters < 100) {
        text = "Vocês estão muito perto";
      } else {
        text = "de distância, aproximadamente.";
      }

      if (mounted) {
        setState(() {
          distance = distanceInKm.toStringAsFixed(2);
          distanceText = text;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    await LocationService().requestPermission(context);
    _initLocationService();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _usernames == null) {
      return const Loading();
    }

    return Scaffold(
      body: !_hasPermission
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomHeader(widget.setPage, true),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Para exibir a distância, ambos os usuários precisam dar permissão de acesso a localização.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: Text("Permitir"),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomHeader(widget.setPage, true, title: "Distância"),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 24,
                              color: AppColors.textColor,
                            ),
                            children: [
                              TextSpan(
                                text: '${_usernames!['author']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' e ',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              TextSpan(
                                text: '${_usernames!['partner']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        if (distance != null) ...[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$distance',
                                style: const TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryColorHover,
                                  height: 1.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'quilômetros',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColorSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.drawerBackgroundColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              distanceText ?? 'Calculando proximidade...',
                              style: const TextStyle(
                                color: AppColors.textColorSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            "Calculando distância...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColorSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
