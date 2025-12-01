import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SurpriseForm extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Map<String, dynamic>? surprise;
  final VoidCallback onSuccess;

  const SurpriseForm({
    super.key,
    required this.userData,
    this.surprise,
    required this.onSuccess,
  });

  @override
  State<SurpriseForm> createState() => _SurpriseFormState();
}

class _SurpriseFormState extends State<SurpriseForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.surprise != null) {
      _titleController.text = widget.surprise!['title'] ?? '';
      _messageController.text = widget.surprise!['message'];
      final scheduled = DateTime.parse(widget.surprise!['scheduledFor']);
      _selectedDate = scheduled;
      _selectedTime = TimeOfDay.fromDateTime(scheduled);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryColorHover,
              onPrimary: Colors.white,
              surface: AppColors.cardBackgroundColor,
              onSurface: AppColors.textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.backgroundColor,
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
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryColorHover,
              onPrimary: Colors.white,
              surface: AppColors.cardBackgroundColor,
              onSurface: AppColors.textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.backgroundColor,
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

  Future<void> _scheduleSurprise() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, dê um título para a surpresa.'),
        ),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, escreva uma mensagem.')),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione data e hora.')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data deve ser no futuro.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.surprise != null) {
        final updates = {
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'scheduledFor': scheduledDateTime.toIso8601String(),
        };

        await DatabaseService().updateSurprise(
          widget.userData['relationshipId'],
          widget.surprise!['id'],
          updates,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Surpresa atualizada com sucesso!')),
          );
        }
      } else {
        final surpriseData = {
          'senderUid': widget.userData['userId'],
          'receiverUid': widget.userData['partnerId'],
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          'scheduledFor': scheduledDateTime.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
          'notificationSent': false,
        };

        await DatabaseService().createSurprise(
          widget.userData['relationshipId'],
          surpriseData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Surpresa agendada com sucesso!')),
          );
        }
      }

      widget.onSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar surpresa.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.surprise != null ? 'Editar Surpresa' : 'Nova Surpresa',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escreva uma mensagem que será revelada apenas na data e hora escolhidas.',
            style: TextStyle(fontSize: 14, color: AppColors.textColorSecondary),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Título (ex: Abra no Natal)',
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
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Escreva sua mensagem aqui...',
              filled: true,
              fillColor: AppColors.drawerBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildPickerButton(
                  icon: FontAwesomeIcons.calendar,
                  label: _selectedDate == null
                      ? 'Data'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPickerButton(
                  icon: FontAwesomeIcons.clock,
                  label: _selectedTime == null
                      ? 'Hora'
                      : _selectedTime!.format(context),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _scheduleSurprise,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColorHover,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.surprise != null
                          ? 'Salvar Alterações'
                          : 'Agendar Surpresa',
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

  Widget _buildPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.drawerBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withAlpha(51)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.primaryColorHover),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
