import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/location_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LocationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const LocationScreen(this.setPage, {super.key, required this.userData});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? distance;
  bool _hasPermission = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    updateLocation();
  }

  Future<void> updateLocation() async {
    final currentDistance = await DatabaseService().getUsersDistance(
      widget.userData['userId'],
      widget.userData['partnerId'],
    );

    final hasPermission = await LocationService().hasPermission();

    setState(() {
      distance = currentDistance;
      _hasPermission = hasPermission;

      if (_isLoading) {
        _isLoading = false;
      }
    });
  }

  Future<void> _updateAndFetchMyOwnLocation() async {
    setState(() => _isLoading = true);
    await DatabaseService().updateLocation(widget.userData['userId']);
    updateLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        "Distância",
        actions: [
          if (distance != null || _hasPermission)
            IconButton(
              onPressed: () => _updateAndFetchMyOwnLocation(),
              icon: FaIcon(FontAwesomeIcons.repeat),
            ),
        ],
      ),
      drawer: DrawerComponent(widget.setPage),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : distance == null || !_hasPermission
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Para exibir a distância, ambos os usuários precisam dar permissão de acesso a localização.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await LocationService().requestPermission(context);
                  },
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
