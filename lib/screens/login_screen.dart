import 'package:connect/services/database_service.dart';
import 'package:connect/provider/auth_provider.dart';
import 'package:connect/utils/messenger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController idController = TextEditingController();

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
                          controller: userController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nome de Usuário',
                          ),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: idController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'ID',
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              String username = userController.text
                                  .toLowerCase()
                                  .trim();
                              String id = idController.text
                                  .toLowerCase()
                                  .trim();

                              if (username.isEmpty || id.isEmpty) {
                                AppMessenger(
                                  context,
                                  'Por favor, preencha todos os campos.',
                                  'error',
                                ).show();
                                return;
                              }

                              if (username.isNotEmpty && id.isNotEmpty) {
                                DatabaseService dbService = DatabaseService();

                                var relationship = await dbService
                                    .relationshipExists(id);
                                if (!context.mounted) return;

                                if (relationship) {
                                  AppMessenger(
                                    context,
                                    'Relacionamento encontrado, verificando usuário.',
                                    'success',
                                  ).show();

                                  var userExists = await dbService.userExists(
                                    username,
                                  );

                                  if (userExists) {
                                    if (!context.mounted) return;
                                    AppMessenger(
                                      context,
                                      'Login bem-sucedido!',
                                      'success',
                                    ).show();

                                    await context
                                        .read<AuthProvider>()
                                        .loginUser(username);
                                  } else {
                                    if (!context.mounted) return;
                                    AppMessenger(
                                      context,
                                      'Usuário não encontrado, verifique a escrita.',
                                      'error',
                                    ).show();
                                  }
                                } else {
                                  AppMessenger(
                                    context,
                                    'ID não encontrado, verifique a escrita.',
                                    'error',
                                  ).show();
                                }
                              }
                            },
                            child: Text('Conectar'),
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
