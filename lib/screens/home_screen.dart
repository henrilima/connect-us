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
  Map<String, String>? _usernames;
  Timer? _timer;

  late DateTime userDate;
  Map<String, int>? relationshipDate;

  @override
  void initState() {
    super.initState();
    _loadRelationshipData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRelationshipData() async {
    try {
      final data = await DatabaseService().getRelationshipData(
        widget.userData['relationshipId'],
      );

      setState(() {
        relationshipData = data;
        userDate = DateTime.parse(data['relationshipDate']);
      });

      final testDate = getDifferenceDate(
        DateTime(userDate.year, userDate.month, userDate.day),
      );

      Duration duration = testDate['years'] as int > 0
          ? Duration(minutes: 1)
          : Duration(seconds: 1);

      _updateRelationshipDate();

      _timer = Timer.periodic(duration, (_) => _updateRelationshipDate());

      await _loadUsernames(data);
    } catch (e) {
      debugPrint("Erro ao carregar dados do relacionamento: $e");
    }
  }

  void _updateRelationshipDate() {
    if (!mounted) return;
    setState(() {
      relationshipDate = getDifferenceDate(
        DateTime(userDate.year, userDate.month, userDate.day),
      );
    });
  }

  Future<void> _loadUsernames(Map<String, dynamic> data) async {
    try {
      final authorUsername = await DatabaseService().getUsername(
        data['authorId'],
      );
      final partnerUsername = await DatabaseService().getUsername(
        data['partnerId'],
      );

      if (!mounted) return;
      setState(() {
        _usernames = {'author': authorUsername, 'partner': partnerUsername};
      });
    } catch (e) {
      debugPrint("Erro ao carregar usernames: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (relationshipData == null ||
        relationshipDate == null ||
        _usernames == null) {
      return HomeScreenScaffold(
        widget.setPage,
        child: const Center(child: CircularProgressIndicator()),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: _usernames!['author'],
                      style: TextStyle(color: AppColors.primaryColorHover),
                    ),
                    const TextSpan(text: ' e '),
                    TextSpan(
                      text: _usernames!['partner'],
                      style: TextStyle(color: AppColors.primaryColorHover),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                "se conhecem há",
                style: TextStyle(fontSize: 16, height: 0.8),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (relationshipDate!['years'] as int > 0)
                    _timeColumn('Anos', relationshipDate!['years']),
                  if (relationshipDate!['years'] as int > 0)
                    const Text(
                      ":",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  _timeColumn('Mês(es)', relationshipDate!['months']),
                  const Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  _timeColumn('Dia(s)', relationshipDate!['days']),
                  const Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  _timeColumn('Hora(s)', relationshipDate!['hours']),
                  const Text(
                    ":",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  _timeColumn('Minuto(s)', relationshipDate!['minutes']),
                  if (relationshipDate!['years'] as int <= 0)
                    const Text(
                      ":",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (relationshipDate!['years'] as int <= 0)
                    _timeColumn('Segundos', relationshipDate!['seconds']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeColumn(String label, int? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            value?.toString() ?? '--',
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(height: 0.1, fontSize: 10)),
        ],
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
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
