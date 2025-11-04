import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/forms/event_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/loading_screen.dart';
import 'package:connect/widgets/timeline_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimelineScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function setPage;
  const TimelineScreen(this.setPage, {required this.userData, super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  late Function setPage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setPage = widget.setPage;
  }

  String get relationshipId {
    return widget.userData['relationshipId'] ?? '';
  }

  void _openTimelineFormModal() {
    return Dialoguer.openModalBottomSheet(
      context: context,
      form: EventForm(userData: widget.userData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: DatabaseService().getTimelineStream(relationshipId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        if (snapshot.hasError) {
          return ErrorScreenComponent("${snapshot.error}");
        }

        if (snapshot.connectionState == ConnectionState.active) {
          isLoading = false;
        }

        final Map<String, dynamic>? relationshipTimeline = snapshot.data;

        return Scaffold(
          appBar: AppBarComponent(
            "Linha do Tempo",
            actions: [
              IconButton(
                icon: FaIcon(FontAwesomeIcons.plus),
                tooltip: 'Adicionar evento',
                onPressed: () => _openTimelineFormModal(),
              ),
            ],
          ),
          drawer: DrawerComponent(setPage),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        if (relationshipTimeline == null ||
                            relationshipTimeline.isEmpty)
                          const Center(
                            child: Text(
                              'Não há eventos na linha do tempo ainda.',
                            ),
                          )
                        else if (relationshipTimeline.isNotEmpty)
                          ...relationshipTimeline.entries.map((entry) {
                            final el = entry.value;
                            final title = (el is Map && el['title'] != null)
                                ? el['title'].toString()
                                : el.toString();
                            final description =
                                (el is Map && el['description'] != null)
                                ? el['description'].toString()
                                : el.toString();
                            final date = (el is Map && el['date'] != null)
                                ? el['date'].toString()
                                : '';
                            return TimelineCard(
                              title: title,
                              description: description,
                              date: date,
                              eventKey: entry.key,
                              userData: widget.userData,
                            );
                          }),
                        if (relationshipTimeline != null &&
                            relationshipTimeline.isNotEmpty)
                          SizedBox(
                            width: double.infinity,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    "Não há mais eventos para exibir.",
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
