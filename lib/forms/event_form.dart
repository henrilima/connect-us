import 'package:connect/components/appbar.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/utils/messenger.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EventForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String? eventKey;
  final String method;

  const EventForm({
    required this.userData,
    this.eventKey,
    this.method = 'add',
    super.key,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  DateTime? _selectedDate;
  Map<String, dynamic>? _eventData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.method == 'edit') {
      _loadAndSetData();
    }
  }

  Future<void> _loadAndSetData() async {
    final Map<String, dynamic> eventDataTest = await DatabaseService()
        .getEventFromTimeline(
          widget.userData['relationshipId'],
          widget.eventKey,
        );

    if (mounted) {
      setState(() {
        _eventData = eventDataTest;
        _titleController.text = _eventData!['title'];
        _descriptionController.text = _eventData!['description'];

        final selectedDate = DateTime.parse(_eventData!['date']);
        _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
        _selectedDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBarComponent(
        widget.method == 'add' ? "Adicionar Evento" : "Editar Evento",
        type: 'back',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Título',
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Descrição',
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  controller: _dateController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Data do evento',
                    suffixIcon: IconButton(
                      onPressed: () => _selectDate(context),
                      icon: FaIcon(FontAwesomeIcons.calendar),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_titleController.text.isEmpty ||
                          _descriptionController.text.isEmpty) {
                        AppMessenger(
                          context,
                          "Por favor, preencha corretamente todos os campos obrigatórios.",
                          'warning',
                        ).show();

                        return;
                      }

                      if (_selectedDate == null) {
                        AppMessenger(
                          context,
                          "Por favor, preencha a data corretamente. Clique no ícone de calendário para definir.",
                          'warning',
                        ).show();

                        return;
                      }

                      await DatabaseService().addEventFromTimeline(
                        relationshipId: widget.userData['relationshipId'],
                        title: _titleController.text,
                        description: _descriptionController.text,
                        date: DateTime(
                          _selectedDate!.year,
                          _selectedDate!.month,
                          _selectedDate!.day,
                        ),
                        update: widget.method == 'edit',
                        eventkey: widget.method == 'edit'
                            ? widget.eventKey
                            : null,
                      );

                      if (!context.mounted) return;
                      AppMessenger(
                        context,
                        "O evento foi ${widget.method == 'add' ? 'adicionado' : 'editado'} com sucesso.",
                        'success',
                      ).show();

                      if (widget.method == 'add') {
                        _titleController.text = "";
                        _descriptionController.text = "";
                        _dateController.text = "";
                        _selectedDate = null;
                      }
                    },
                    child: Text(
                      widget.method == 'add'
                          ? 'Adicionar evento'
                          : 'Editar evento',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
