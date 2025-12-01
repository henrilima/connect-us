import 'package:connect/model/user.dart';
import 'package:connect/screens/chat_screen.dart';
import 'package:connect/screens/location_screen.dart';
import 'package:connect/screens/love_language_screen.dart';
import 'package:connect/screens/rps_screen.dart';
import 'package:connect/screens/achievements_screen.dart';
import 'package:connect/screens/settings_screen.dart';
import 'package:connect/screens/spotify_screen.dart';
import 'package:connect/screens/surprises_screen.dart';
import 'package:connect/screens/timeline_screen.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/provider/auth_provider.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:connect/screens/counters_screen.dart';
import 'package:connect/screens/feeling_screen.dart';

import 'package:connect/screens/moments_screen.dart';
import 'package:connect/screens/daily_photos_screen.dart';
import 'package:connect/services/location_service.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class ScreensManager extends StatefulWidget {
  const ScreensManager({super.key});

  @override
  State<ScreensManager> createState() => _ScreensManagerState();
}

class _ScreensManagerState extends State<ScreensManager> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic> get userData => _userData ?? {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    if (!mounted) return;
    final String? userId = context.read<AuthProvider>().userId;

    if (userId != null) {
      try {
        final Map<String, dynamic> data = await UserModel().getUserData(userId);

        if (!mounted) return;

        if (data.isEmpty) {
          context.read<AuthProvider>().logoutUser();
          return;
        }

        _updateUserLocation(data['userId']);

        setState(() {
          _userData = data;
        });

        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        context.read<AuthProvider>().logoutUser();
        return;
      }
    } else {
      if (!mounted) return;
      context.read<AuthProvider>().logoutUser();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserLocation(String id) async {
    if (await LocationService().hasPermission() &&
        await Geolocator.isLocationServiceEnabled()) {
      final Position position = await LocationService().getCurrentLocation();
      await DatabaseService().updateLocation(id, position);
    }
  }

  Map<String, Widget> get pages => {
    "chat": ChatScreen(setPage, userData: userData),
    "counters": CountersScreen(setPage, userData: userData),
    "location": LocationScreen(setPage, userData: userData),
    "timeline": TimelineScreen(setPage, userData: userData),
    "lovelanguage": LoveLanguageScreen(setPage, userData: userData),
    "rps": RPSScreen(setPage, userData: userData),
    "achievements": AchievementsScreen(setPage, userData: userData),
    "surprises": SurprisesScreen(setPage, userData: userData),
    "spotify": SpotifyScreen(setPage, userData: userData),
    "feeling": FeelingScreen(setPage, userData: userData),
    "moments": MomentsScreen(setPage, userData: userData),
    "daily_photos": DailyPhotosScreen(setPage, userData: userData),
    "settings": SettingsScreen(setPage, userData: userData),
  };

  void setPage(String newPage) {
    if (pages.containsKey(newPage)) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => pages[newPage]!));

      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Loading();
    }

    return HomeScreen(setPage, userData: userData);
  }
}
