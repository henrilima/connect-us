import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class RegisterForm extends StatefulWidget {
  final void Function(
    BuildContext ctx, {
    required TextEditingController emailController,
    required TextEditingController authorIdController,
    required TextEditingController partnerIdController,
    required DateTime selectedDate,
    required Function({String? message, bool? clear}) showMessage,
  })
  registerRelationship;
  const RegisterForm(this.registerRelationship, {super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  DateTime? _selectedDate;
  String _message = '';

  final _emailController = TextEditingController();
  final _authorIdController = TextEditingController();
  final _partnerIdController = TextEditingController();
  final _relationshipDateController = TextEditingController();

  void _showMessage({String? message, bool? clear}) {
    setState(() {
      _message = (clear ?? false) ? '' : (message ?? '');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _relationshipDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Card(
        color: AppColors.backgroundColor,
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Seja bem-vindo(a)!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColorHover,
                ),
              ),
              Text(
                "Vamos criar um perfil de relacionamento para você e seu parceiro(a) e desfrutar de funções incríveis?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              if (_message.isNotEmpty)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      _message.split(':')[1],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _message.split(':')[0] == 'error'
                            ? AppColors.errorColor
                            : _message.split(':')[0] == 'warning'
                            ? AppColors.warningColor
                            : _message.split(':')[0] == 'success'
                            ? AppColors.successColor
                            : AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.textColor),
                onChanged: (value) {
                  if (!isValidEmail(value)) {
                    _showMessage(
                      message: "warning:Este não é um e-mail válido.",
                    );
                  } else {
                    _showMessage(clear: true);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Insira seu melhor email",
                  filled: true,
                  fillColor: AppColors.drawerBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.email,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _authorIdController,
                style: const TextStyle(color: AppColors.textColor),
                onChanged: (value) {
                  if (!isValidUserId(value)) {
                    _showMessage(
                      message: "warning:${validateUserId(value, "seu ID")}",
                    );
                  } else {
                    _showMessage(clear: true);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Escolha um ID para você",
                  filled: true,
                  fillColor: AppColors.drawerBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.person,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _partnerIdController,
                style: const TextStyle(color: AppColors.textColor),
                onChanged: (value) {
                  if (!isValidUserId(value)) {
                    _showMessage(
                      message:
                          "warning:${validateUserId(value, "ID do seu par")}",
                    );
                  } else {
                    _showMessage(clear: true);
                  }
                },
                decoration: InputDecoration(
                  hintText: "Escolha um ID para seu parceiro",
                  filled: true,
                  fillColor: AppColors.drawerBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.favorite,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                controller: _relationshipDateController,
                style: const TextStyle(color: AppColors.textColor),
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  hintText: 'Data de quando se conheceram',
                  filled: true,
                  fillColor: AppColors.drawerBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    FontAwesomeIcons.calendar,
                    color: AppColors.textColorSecondary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_selectedDate == null) {
                      _showMessage(
                        message:
                            "error:Selecione a data de quando se conheceram.",
                      );
                      return;
                    } else {
                      _showMessage(clear: true);
                    }

                    widget.registerRelationship(
                      context,
                      emailController: _emailController,
                      authorIdController: _authorIdController,
                      partnerIdController: _partnerIdController,
                      selectedDate: _selectedDate!,
                      showMessage: _showMessage,
                    );
                  },
                  child: const Text(
                    "Criar Perfil",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
