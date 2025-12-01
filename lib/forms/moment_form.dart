import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MomentForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? moment;

  const MomentForm({super.key, required this.userData, this.moment});

  @override
  State<MomentForm> createState() => _MomentFormState();
}

class _MomentFormState extends State<MomentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _notify = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.moment != null) {
      _titleController.text = widget.moment!['title'];
      _descriptionController.text = widget.moment!['description'] ?? '';
      if (widget.moment!['scheduledDate'] != null) {
        _selectedDate = DateTime.parse(widget.moment!['scheduledDate']);
        _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
        _notify = widget.moment!['notify'] ?? false;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.drawerBackgroundColor,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      if (!context.mounted) return;
      _selectTime(context);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: AppColors.drawerBackgroundColor,
              onSurface: AppColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMoment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      DateTime? scheduledDateTime;
      if (_selectedDate != null && _selectedTime != null) {
        scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final momentData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'scheduledDate': scheduledDateTime?.toIso8601String(),
        'notify': _notify,
        'authorId': widget.userData['userId'],
        'partnerId': widget.userData['partnerId'],
      };

      try {
        if (widget.moment != null) {
          await DatabaseService().updateMoment(
            widget.userData['relationshipId'],
            widget.moment!['id'],
            momentData,
          );
        } else {
          await DatabaseService().createMoment(
            widget.userData['relationshipId'],
            momentData,
          );
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.moment != null ? 'Editar Momento' : 'Novo Momento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Crie momentos especiais com seu parceiro(a). Defina um título, descrição e data para não esquecerem.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textColor),
                  decoration: InputDecoration(
                    hintText: 'O que vamos fazer? (Ex: Assistir filme)',
                    filled: true,
                    fillColor: AppColors.drawerBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(
                      FontAwesomeIcons.pen,
                      color: AppColors.textColorSecondary,
                      size: 18,
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor, insira um título'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.textColor),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Detalhes (opcional)',
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
                  borderRadius: BorderRadius.circular(12),
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
                          color: AppColors.textColorSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDate == null
                              ? 'Agendar data e hora (opcional)'
                              : '${DateFormat('dd/MM/yyyy').format(_selectedDate!)} às ${_selectedTime?.format(context) ?? ''}',
                          style: TextStyle(
                            color: _selectedDate == null
                                ? AppColors.textColorSecondary
                                : AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(
                      'Notificar 30 min antes',
                      style: TextStyle(color: AppColors.textColor),
                    ),
                    value: _notify,
                    onChanged: (value) => setState(() => _notify = value),
                    activeThumbColor: AppColors.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMoment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColorHover,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
