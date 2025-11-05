import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/forms/counter_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/utils/icon.dart';
import 'package:connect/widgets/counter_card.dart';
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

  @override
  void initState() {
    super.initState();
    setPage = widget.setPage;
  }

  _openCounterFormModal() {
    Dialoguer.openModalBottomSheet(
      context: context,
      form: CounterForm(widget.userData['relationshipId']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: DatabaseService().getCountsStream(
        widget.userData['relationshipId'],
      ),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        final Map<String, dynamic> counters = snapshot.data ?? {};
        Map<String, dynamic>? customs;
        if (counters['custom'] != null) {
          customs = Map<String, dynamic>.from(counters['custom'] as Map);
        }

        return Scaffold(
          appBar: AppBarComponent(
            "Contadores",
            actions: [
              IconButton(
                onPressed: () => _openCounterFormModal(),
                icon: FaIcon(FontAwesomeIcons.plus),
              ),
            ],
          ),
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
                      CounterCard(
                        text: "Abraços",
                        value: "${counters['hugCount']}",
                        description:
                            "Total de abraços trocados desde que se conheceram.",
                        icon: FontAwesomeIcons.handshake,
                        type: 1,
                        lastUpdate: counters['hugCountTime'] ?? '',
                        execPlus: () => DatabaseService().manageCount(
                          widget.userData['relationshipId'],
                          countName: 'hugCount',
                          increment: true,
                        ),
                        execMinus: () => DatabaseService().manageCount(
                          widget.userData['relationshipId'],
                          countName: 'hugCount',
                          increment: false,
                        ),
                      ),
                      CounterCard(
                        text: "Beijos",
                        value: "${counters['kissCount']}",
                        description:
                            "Número de beijos compartilhados até agora.",
                        icon: FontAwesomeIcons.faceKiss,
                        type: 2,
                        lastUpdate: counters['kissCountTime'] ?? '',
                        execPlus: () => DatabaseService().manageCount(
                          widget.userData['relationshipId'],
                          countName: 'kissCount',
                          increment: true,
                        ),
                        execMinus: () => DatabaseService().manageCount(
                          widget.userData['relationshipId'],
                          countName: 'kissCount',
                          increment: false,
                        ),
                      ),

                      if (customs != null && customs.isNotEmpty)
                        ...customs.entries.map((entry) {
                          final counter = entry.value;
                          return CounterCard(
                            text: counter['title'],
                            value: counter['value'].toString(),
                            description: counter['description'],
                            icon: IconHelper.getIcon(counter['icon']),
                            lastUpdate: counter['time'] ?? '',
                            execPlus: () => DatabaseService().manageCount(
                              widget.userData['relationshipId'],
                              countName: entry.key,
                              increment: true,
                              custom: true,
                            ),
                            execMinus: () => DatabaseService().manageCount(
                              widget.userData['relationshipId'],
                              countName: entry.key,
                              increment: false,
                              custom: true,
                            ),
                            isCustom: true,
                            counterKey: entry.key,
                            relationshipId: widget.userData['relationshipId'],
                          );
                        }),
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
