import 'dart:async';

import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/dates.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const HomeScreen(this.setPage, {super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? relationshipData;
  late Timer _timer;

  late DateTime userDate;
  Map<String, int>? relationshipDate;

  @override
  void initState() {
    super.initState();
    getRelationshipData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  getRelationshipData() async {
    final data = await DatabaseService().getRelationshipData(
      widget.userData['relationshipId'],
    );

    setState(() {
      relationshipData = data;
      userDate = DateTime.parse(data['relationshipDate']);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        relationshipDate = getDifferenceDate(
          DateTime(userDate.year, userDate.month, userDate.day),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (relationshipData == null || relationshipDate == null) {
      return HomeScreenScaffold(
        widget.setPage,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return HomeScreenScaffold(
      widget.setPage,
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: relationshipData!["authorId"],
                      style: TextStyle(color: AppColors.primaryColorHover),
                    ),
                    TextSpan(text: ' e '),
                    TextSpan(
                      text: relationshipData!["partnerId"],
                      style: TextStyle(color: AppColors.primaryColorHover),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text("se conhecem há", style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 12,
                children: [
                  Column(
                    children: [
                      Text(
                        '${relationshipDate!['days']}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Dias', style: TextStyle(height: 0.1)),
                    ],
                  ),
                  Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Text(
                        '${relationshipDate!['hours']}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Horas', style: TextStyle(height: 0.1)),
                    ],
                  ),
                  Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Text(
                        '${relationshipDate!['minutes']}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Minutos', style: TextStyle(height: 0.1)),
                    ],
                  ),
                  Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: [
                      Text(
                        '${relationshipDate!['seconds']}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Segundos', style: TextStyle(height: 0.1)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreenScaffold extends StatelessWidget {
  final Function setPage;
  final Widget child;
  const HomeScreenScaffold(this.setPage, {required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent("Nos Conecte"),
      drawer: DrawerComponent(setPage),
      body: Padding(padding: EdgeInsets.all(16), child: child),
    );
  }
}
