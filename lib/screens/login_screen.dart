import 'package:connect/forms/register_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/provider/auth_provider.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/utils/messenger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _relationshipIdController =
      TextEditingController();

  _openRegisterFormModal() {
    Dialoguer.openModalBottomSheet(
      context: context,
      form: RegisterForm(_loginUser),
    );
  }

  _loginUser(String usernameRef, String idRef, BuildContext context) async {
  
    String username = usernameRef.toLowerCase().trim();
    String id = idRef.toLowerCase().trim();

    if (username.isEmpty || id.isEmpty) {
      AppMessenger(
        context,
        'Por favor, preencha todos os campos.',
        'error',
      ).show();
      return;
    }

    final hasRelationship = await DatabaseService().relationshipExists(id);

    if (hasRelationship) {
      var userExists = await DatabaseService().userExists(username);

      if (userExists) {
        if (!context.mounted) return;
        AppMessenger(
          context,
          'Usuário encontrado, login bem-sucedido!',
          'success',
        ).show();
        await context.read<AuthProvider>().loginUser(username);

        await Future.delayed(Duration(seconds: 5));

        if (!context.mounted) return;
        AppMessenger(
          context,
          'Olá, seja muito bem-vindo(a). No menu "Dados e Perfil" você pode alterar seu nome de usuário e atualizar o dia em que se conheceram.',
          'info',
          duration: 12,
        ).show();
      } else {
        if (!context.mounted) return;
        AppMessenger(
          context,
          'Usuário não encontrado, verifique a escrita.',
          'error',
        ).show();
      }
    } else {
      if (!context.mounted) return;
      AppMessenger(
        context,
        'ID não encontrado, verifique a escrita.',
        'error',
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Image.asset(
                      'assets/images/cupid.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: Column(
                      children: [
                        Text(
                          "Insira abaixo o seu nome de usuário e o ID do relacionamento:",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _userIdController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nome de Usuário',
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: _relationshipIdController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID',
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _loginUser(
                              _userIdController.text,
                              _relationshipIdController.text,
                              context,
                            ),
                            child: Text('Conectar'),
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => _openRegisterFormModal(),
                            child: Text("Não tem uma perfil? Clique aqui"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
