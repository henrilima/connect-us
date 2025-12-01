import 'package:connect/components/connect_component.dart';
import 'package:connect/components/floating_bar.dart';
import 'package:connect/components/header.dart';
import 'package:connect/components/pages_component.dart';
import 'package:connect/components/timeout_component.dart';
import 'package:connect/services/database_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const HomeScreen(this.setPage, {super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _setStatus(true);
    } else {
      _setStatus(false);
    }
  }

  void _setStatus(bool isOnline) {
    if (widget.userData['userId'] != null) {
      _databaseService.updateUserStatus(widget.userData['userId'], isOnline);
    }
  }

  Widget component(selectedIndex) {
    if (selectedIndex == 1) {
      return PagesComponent(widget.setPage, widget.userData);
    } else if (selectedIndex == 2) {
      return ConnectComponent(userData: widget.userData);
    } else {
      return TimeoutComponent(
        infos: {
          "partnerId": widget.userData['partnerId'],
          "date": widget.userData['relationshipData']['relationshipDate'],
          "author": widget.userData['username'],
          "partner": widget.userData['partnerData']['username'],
          "partnerPhotoUrl": widget.userData['partnerData']['photoUrl'],
          "relationshipId":
              widget.userData['relationshipData']['relationshipId'],
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenScaffold(
      true,
      widget.setPage,
      selectedIndex: _selectedIndex,
      photoUrl: widget.userData['photoUrl'],
      onTabChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: component(_selectedIndex),
    );
  }
}

class HomeScreenScaffold extends StatelessWidget {
  final bool loaded;
  final Function setPage;
  final Widget child;
  final int selectedIndex;
  final String? photoUrl;
  final Function(int) onTabChanged;

  const HomeScreenScaffold(
    this.loaded,
    this.setPage, {
    required this.child,
    required this.selectedIndex,
    required this.onTabChanged,
    this.photoUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: AlignmentGeometry.topCenter,
        children: [
          if (loaded) CustomHeader(setPage, false, photoUrl: photoUrl),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          ),

          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: BottomFloatingBar(
                setPage,
                selectedIndex: selectedIndex,
                onTabChanged: onTabChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
