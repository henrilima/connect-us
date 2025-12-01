import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryColorHover,
              onPrimary: Colors.white,
              surface: AppColors.cardBackgroundColor,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
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

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          if (_message.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _message.split(':')[0] == 'error'
                    ? AppColors.errorColor.withAlpha(26)
                    : AppColors.successColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _message.split(':')[0] == 'error'
                      ? AppColors.errorColor.withAlpha(128)
                      : AppColors.successColor.withAlpha(128),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _message.split(':')[0] == 'error'
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: _message.split(':')[0] == 'error'
                        ? AppColors.errorColor
                        : AppColors.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _message.split(':')[1],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _message.split(':')[0] == 'error'
                            ? AppColors.errorColor
                            : AppColors.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          TextField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              hintText: 'Título do evento',
              filled: true,
              fillColor: AppColors.drawerBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: AppColors.textColor),
            decoration: InputDecoration(
              hintText: 'Descrição do evento',
              filled: true,
              fillColor: AppColors.drawerBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.drawerBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.calendar,
                    color: AppColors.primaryColorHover,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _dateController.text.isEmpty
                        ? 'Data do evento'
                        : _dateController.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColorHover,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
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
                  partnerId: widget.userData['partnerId'],
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
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
