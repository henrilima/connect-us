import 'package:connect/components/header.dart';
import 'package:connect/forms/counter_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/utils/icon.dart';
import 'package:connect/widgets/counter_card.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:connect/widgets/fade_in.dart';
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
          body: SafeArea(
            child: Column(
              children: [
                CustomHeader(
                  setPage,
                  true,
                  title: "Contador",
                  actions: [
                    IconButton(
                      onPressed: () => _openCounterFormModal(),
                      icon: FaIcon(FontAwesomeIcons.plus),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 16,
                        left: 8,
                        right: 8,
                        bottom: 16,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FadeIn(
                                delay: const Duration(milliseconds: 0),
                                child: CounterCard(
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
                                    partnerId: widget.userData['partnerId'],
                                  ),
                                  execMinus: () =>
                                      DatabaseService().manageCount(
                                        widget.userData['relationshipId'],
                                        countName: 'hugCount',
                                        increment: false,
                                        partnerId: widget.userData['partnerId'],
                                      ),
                                ),
                              ),
                              FadeIn(
                                delay: const Duration(milliseconds: 100),
                                child: CounterCard(
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
                                    partnerId: widget.userData['partnerId'],
                                  ),
                                  execMinus: () =>
                                      DatabaseService().manageCount(
                                        widget.userData['relationshipId'],
                                        countName: 'kissCount',
                                        increment: false,
                                        partnerId: widget.userData['partnerId'],
                                      ),
                                ),
                              ),

                              if (customs != null && customs.isNotEmpty)
                                ...customs.entries.toList().asMap().entries.map(
                                  (entry) {
                                    final index = entry.key;
                                    final mapEntry = entry.value;
                                    final counter = mapEntry.value;
                                    return FadeIn(
                                      delay: Duration(
                                        milliseconds: (index + 2) * 100,
                                      ),
                                      child: CounterCard(
                                        text: counter['title'],
                                        value: counter['value'].toString(),
                                        description: counter['description'],
                                        icon: IconHelper.getIcon(
                                          counter['icon'],
                                        ),
                                        lastUpdate: counter['time'] ?? '',
                                        execPlus: () =>
                                            DatabaseService().manageCount(
                                              widget.userData['relationshipId'],
                                              countName: mapEntry.key,
                                              increment: true,
                                              custom: true,
                                            ),
                                        execMinus: () =>
                                            DatabaseService().manageCount(
                                              widget.userData['relationshipId'],
                                              countName: mapEntry.key,
                                              increment: false,
                                              custom: true,
                                            ),
                                        isCustom: true,
                                        counterKey: mapEntry.key,
                                        relationshipId:
                                            widget.userData['relationshipId'],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
