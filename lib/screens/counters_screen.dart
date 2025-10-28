import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/widgets/data_card.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CountersScreen extends StatefulWidget {
  final Map userData;
  final Function setPage;
  const CountersScreen(this.setPage, {required this.userData, super.key});

  @override
  State<CountersScreen> createState() => _CountersScreenState();
}

class _CountersScreenState extends State<CountersScreen> {
  late Function setPage;

  String get relationshipId {
    return widget.userData['relationshipId'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    setPage = widget.setPage;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: DatabaseService().getCountsStream(relationshipId),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        final Map<String, dynamic> counters = snapshot.data ?? {};

        return Scaffold(
          appBar: AppBarComponent("Contadores"),
          drawer: DrawerComponent(setPage),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 16),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    spacing: 16,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DataCard(
                        text: "Abraços",
                        value: "${counters['hugCount']}",
                        description:
                            "Total de abraços trocados desde que se conheceram.",
                        icon: FontAwesomeIcons.handshake,
                        type: 1,
                        execPlus: () => DatabaseService().manageHugsCount(
                          relationshipId,
                          increment: true,
                        ),
                        execMinus: () => DatabaseService().manageHugsCount(
                          relationshipId,
                          increment: false,
                        ),
                      ),
                      DataCard(
                        text: "Beijos",
                        value: "${counters['kissCount']}",
                        description:
                            "Número de beijos compartilhados até agora.",
                        icon: FontAwesomeIcons.faceKiss,
                        type: 2,
                        execPlus: () => DatabaseService().manageKissesCount(
                          relationshipId,
                          increment: true,
                        ),
                        execMinus: () => DatabaseService().manageKissesCount(
                          relationshipId,
                          increment: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
