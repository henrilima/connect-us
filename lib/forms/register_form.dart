import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class RegisterForm extends StatefulWidget {
  final Function(String, String, BuildContext) loginUser;
  const RegisterForm(this.loginUser, {super.key});

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

  _registerRelationship(ctx) async {
    if (_emailController.text.isEmpty || !isValidEmail(_emailController.text)) {
      return _showMessage(message: "error:O e-mail inserido não é válido.");
    }

    if (_authorIdController.text.isEmpty ||
        !isValidUserId(_authorIdController.text)) {
      return _showMessage(
        message: "error:${validateUserId(_authorIdController.text, "seu ID")}",
      );
    }

    if (_partnerIdController.text.isEmpty ||
        !isValidUserId(_partnerIdController.text)) {
      return _showMessage(
        message:
            "error:${validateUserId(_partnerIdController.text, "ID do seu par")}",
      );
    }

    if (_authorIdController.text.toLowerCase() ==
        _partnerIdController.text.toLowerCase()) {
      return _showMessage(
        message: "error:O seu ID e o ID do seu par não podem ser iguais.",
      );
    }

    if (_selectedDate == null) {
      return _showMessage(
        message:
            "error:A data em que você e seu par se conheceram não pode ser vazia.",
      );
    }

    final String email = _emailController.text;
    final String authorId = _authorIdController.text;
    final String partnerId = _partnerIdController.text;
    final DateTime relationshipDate = _selectedDate!;

    _showMessage(clear: true);
    final relationshipResponse = await DatabaseService().createRelationship(
      authorId,
      partnerId,
      email,
      relationshipDate,
    );

    final partedResponse = relationshipResponse.split(':');

    if (partedResponse[0] == 'error') {
      return _showMessage(message: "error:${partedResponse[1]}");
    } else if (partedResponse[0] == 'id') {
      Navigator.of(ctx).pop();
      widget.loginUser(authorId, partedResponse[1], ctx);
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
                onPressed: () => _registerRelationship(context),
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
