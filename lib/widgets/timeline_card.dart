import 'package:connect/forms/event_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimelineCard extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final String eventKey;
  final Map<String, dynamic> userData;

  const TimelineCard({
    required this.title,
    required this.description,
    required this.date,
    required this.eventKey,
    required this.userData,
    super.key,
  });

  @override
  State<TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard> {
  String _monthName(int month) {
    const months = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    if (month >= 1 && month <= 12) return months[month];
    return '';
  }

  _editEvent() {
    return Dialoguer.openModalBottomSheet(
      context: context,
      form: EventForm(
        userData: widget.userData,
        eventKey: widget.eventKey,
        method: 'edit',
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text(
            'Tem certeza de que deseja deletar este evento da Linha do Tempo? Esta ação não pode ser desfeita.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.errorColor,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      DatabaseService().deleteEventFromTimeline(
        relationshipId: widget.userData['relationshipId'],
        eventkey: widget.eventKey,
      );
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(widget.date);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 0,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 28,
                      bottom: 20,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dateTime.day} de ${_monthName(dateTime.month)} de ${dateTime.year}',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 20,
                                height: 1.5,
                                color: AppColors.secondaryColorHover,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 12,
                    child: PopupMenuButton(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: AppColors.backgroundColor,
                      padding: EdgeInsets.all(6),
                      constraints: BoxConstraints(),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'Editar',
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.pencil,
                                size: 16,
                                color: AppColors.infoColorHover,
                              ),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Excluir',
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.trash,
                                size: 16,
                                color: AppColors.errorColor,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Excluir',
                                style: TextStyle(color: AppColors.errorColor),
                              ),
                            ],
                          ),
                        ),
                      ],

                      onSelected: (String value) async {
                        if (value == 'Editar') {
                          _editEvent();
                        } else if (value == 'Excluir') {
                          await _confirmDelete();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 24, width: 2, color: AppColors.secondaryColorHover),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
