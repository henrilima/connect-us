import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/messenger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  final Function setPage;
  final String userId;
  const SettingsScreen(this.setPage, {required this.userId, super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _relationshipData;
  String _message = '';
  bool _isReady = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserAndRelationshipData();
  }

  _getUserAndRelationshipData() async {
    setState(() => _isReady = false);
    final userData = await DatabaseService().getUserData(widget.userId);
    final relationshipData = await DatabaseService().getRelationshipData(
      userData['relationshipId'],
    );

    setState(() {
      _userData = userData;
      _relationshipData = relationshipData;
      _selectedDate = DateTime.parse(relationshipData['relationshipDate']);

      _usernameController.text = userData['username'];
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _isReady = true;
    });
  }

  _selectDate(BuildContext context) async {
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

  _showMessage({String? message, clear = false}) {
    setState(() {
      _message = clear ? '' : message!;
    });
  }

  updateUserAndRelationshipData() async {
    if (_relationshipData != null) {
      final relationshipDate = DateTime.parse(
        _relationshipData!['relationshipDate'],
      );

      if (_usernameController.text == _userData!['username'] &&
          _selectedDate == relationshipDate) {
        return _showMessage(
          message:
              "warning:Nenhum dado foi alterado, logo, nenhuma modificação precisa ser realizada.",
        );
      }

      if (_usernameController.text.length > 16) {
        return _showMessage(
          message:
              "error:O nome de usuário não pode ter mais que 16 caracteres.",
        );
      }

      DatabaseService().updateUserAndRelationshipData(
        userId: _userData!['userId'],
        relationshipId: _relationshipData!['relationshipId'],
        newUsername: _usernameController.text == _userData!['username']
            ? null
            : _usernameController.text,
        newDate: _selectedDate == relationshipDate ? null : _selectedDate,
      );

      _showMessage(message: "success:Os dados foram atualizados.");
      _getUserAndRelationshipData();

      Future.delayed(const Duration(seconds: 6), () {
        _showMessage(clear: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarComponent('', type: 'back'),
      drawer: DrawerComponent(widget.setPage),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configurações de Perfil",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColorHover,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                "Utilize esta área para ajustar, corrigir ou modificar quaisquer informações que possam ser alteradas.",
                style: TextStyle(fontSize: 14),
              ),
              if (_message.isNotEmpty)
                Column(
                  children: [
                    SizedBox(height: 24),
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
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Nome de usuário',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                readOnly: true,
                controller: _dateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Dia que se conheceram',
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
                  onPressed: _isReady
                      ? () => updateUserAndRelationshipData()
                      : null,
                  child: Text("Salvar dados"),
                ),
              ),
              Spacer(),
              if (_userData != null && _relationshipData != null)
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    color: AppColors.drawerBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Dados de conexão",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.infoColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'ID do relacionamento (compartilhe com seu par):',
                          ),
                          SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: _relationshipData!['relationshipId'],
                                ),
                              );
                              AppMessenger(
                                context,
                                'Copiado para a área de transferência!',
                                'info',
                              ).show();
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryColorHover,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _relationshipData!['relationshipId'],
                                    ),
                                  ),
                                  Icon(
                                    Icons.copy,
                                    size: 18,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('Seu ID:'),
                          SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: _userData!['userId']),
                              );
                              AppMessenger(
                                context,
                                'Copiado para a área de transferência!',
                                'info',
                              ).show();
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryColorHover,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(_userData!['userId'])),
                                  Icon(
                                    Icons.copy,
                                    size: 18,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('ID do seu par:'),
                          SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: _userData!['partnerId']),
                              );
                              AppMessenger(
                                context,
                                'Copiado para a área de transferência',
                                'info',
                              ).show();
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primaryColorHover,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(_userData!['partnerId']),
                                  ),
                                  Icon(
                                    Icons.copy,
                                    size: 18,
                                    color: AppColors.textColorSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
