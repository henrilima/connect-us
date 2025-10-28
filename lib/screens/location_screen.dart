import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const LocationScreen(this.setPage, {super.key, required this.userData});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? distance;
  late Function setPage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setPage = widget.setPage;
    updateLocation();
  }

  Future<void> updateLocation() async {
    DatabaseService().updateLocation(widget.userData['userId']);
    final currentDistance = await DatabaseService().getUsersDistance(
      widget.userData['userId'],
      widget.userData['partnerId'],
    );

    setState(() {
      distance = currentDistance;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            appBar: AppBarComponent("Distância"),
            drawer: DrawerComponent(setPage),
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
            appBar: AppBarComponent("Distância"),
            drawer: DrawerComponent(setPage),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.userData['userId']}',
                            style: TextStyle(
                              color: AppColors.primaryColorHover,
                            ),
                          ),
                          TextSpan(text: ', você e '),
                          TextSpan(
                            text: '${widget.userData['partnerId']}',
                            style: TextStyle(
                              color: AppColors.primaryColorHover,
                            ),
                          ),
                          TextSpan(text: ' estão a'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${distance}km',
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'de distância, aproximadamente.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }
}
