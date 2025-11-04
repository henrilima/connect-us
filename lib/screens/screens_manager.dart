import 'package:connect/screens/chat_screen.dart';
import 'package:connect/screens/location_screen.dart';
import 'package:connect/screens/love_language_screen.dart';
import 'package:connect/screens/spotify_screen.dart';
import 'package:connect/screens/timeline_screen.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/provider/auth_provider.dart';
import 'package:connect/screens/home_screen.dart';
import 'package:connect/screens/counters_screen.dart';
import 'package:connect/services/location_service.dart';
import 'package:flutter/material.dart';
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
        final Map<String, dynamic>? data = await DatabaseService().getUserData(
          userId,
        );

        if (!mounted) return;

        if (data == null || data.isEmpty) {
          context.read<AuthProvider>().logoutUser();
          return;
        }

        _updateUserLocation(data['userId']);

        setState(() {
          _userData = data;
          _isLoading = false;
        });
      } catch (e) {
        if (!mounted) return;
        context.read<AuthProvider>().logoutUser();
        return;
      }
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserLocation(String id) async {
    if (await LocationService().hasPermission()) {
      await DatabaseService().updateLocation(id);
    }
  }

  String _currentPage = "home";

  Map<String, Widget> get pages => {
    "home": HomeScreen(setPage, userData: userData),
    "chat": ChatScreen(setPage, userData: userData),
    "counters": CountersScreen(setPage, userData: userData),
    "location": LocationScreen(setPage, userData: userData),
    "timeline": TimelineScreen(setPage, userData: userData),
    "lovelanguage": LoveLanguageScreen(setPage, userData: userData),
    "spotify": SpotifyScreen(setPage, userData: userData),
    "settings": const Scaffold(body: Center(child: Text("Settings Screen"))),
  };

  void setPage(String newPage) {
    if (pages.containsKey(newPage)) {
      setState(() {
        _currentPage = newPage;
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return pages[_currentPage] ??
        Scaffold(body: Center(child: Text('Página não encontrada')));
  }
}
