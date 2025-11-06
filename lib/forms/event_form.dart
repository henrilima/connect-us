import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
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
  DateTime _selectedDate = DateTime.now();
  String _message = '';

  Map<String, dynamic>? _eventData;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    if (widget.method == 'edit') {
      _loadAndSetData();
    }
  }

  _loadAndSetData() async {
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

  _showMessage({String? message, clear = false}) {
    setState(() {
      _message = clear ? '' : message!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.method == 'add' ? "Adicionar Evento" : "Editar Evento";
    final actionText = widget.method == 'add' ? 'adicionado' : 'editado';

    return Card(
      color: AppColors.backgroundColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColorHover,
              ),
            ),
            if (_message.isNotEmpty)
              Text(
                _message.split(':')[1],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _message.split(':')[0] == 'error'
                      ? AppColors.errorColor
                      : AppColors.successColor,
                ),
              ),
            SizedBox(height: 32),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Título do evento',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Descrição do evento',
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: _dateController,
              onTap: () => _selectDate(context),
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
                    return _showMessage(
                      message:
                          "error:Por favor, preencha corretamente todos os campos obrigatórios.",
                    );
                  }

                  await DatabaseService().addEventFromTimeline(
                    relationshipId: widget.userData['relationshipId'],
                    title: _titleController.text,
                    description: _descriptionController.text,
                    date: DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                    ),
                    update: widget.method == 'edit',
                    eventkey: widget.method == 'edit' ? widget.eventKey : null,
                  );

                  if (_message.isNotEmpty) {
                    _showMessage(clear: true);
                  }

                  if (widget.method == 'add') {
                    _showMessage(
                      message: "success:O evento foi $actionText com sucesso.",
                    );
                    _titleController.text = "";
                    _descriptionController.text = "";
                  }
                  if (widget.method == 'edit') {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }
                },
                child: Text(title),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
