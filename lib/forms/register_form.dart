import 'package:connect/theme/app_color.dart';
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

  _showMessage({String? message, clear = false}) {
    setState(() {
      _message = clear ? '' : message!;
    });
  }

  _selectDate(BuildContext context) async {
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  SizedBox(height: 12),
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
            SizedBox(height: 32),
            TextField(
              controller: _emailController,
              onChanged: (value) {
                if (!isValidEmail(value)) {
                  _showMessage(message: "warning:Este não é um e-mail válido.");
                } else {
                  _showMessage(clear: true);
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Insira seu melhor email",
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _authorIdController,
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
                labelText: "Escolha um ID para você",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _partnerIdController,
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
                labelText: "Escolha um ID para seu parceiro",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: _relationshipDateController,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Data de quando se conheceram',
                suffixIcon: IconButton(
                  onPressed: () => _selectDate(context),
                  icon: FaIcon(FontAwesomeIcons.calendar),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    AppColors.primaryColor,
                  ),
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
                child: Text(
                  "Criar Perfil",
                  style: TextStyle(color: AppColors.textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
