import 'package:connect/forms/register_form.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/provider/auth_provider.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/services/messenger_service.dart';
import 'package:connect/utils/validator.dart';
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
      form: RegisterForm(_registerRelationship),
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

        if (!context.mounted) return;
        AppMessenger(
          context,
          'Olá, seja muito bem-vindo(a). Você pode alterar seu nome de usuário e outras coisas no perfil.',
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

  void _registerRelationship(
    BuildContext ctx, {
    required TextEditingController emailController,
    required TextEditingController authorIdController,
    required TextEditingController partnerIdController,
    required DateTime selectedDate,
    required Function({String? message, bool? clear}) showMessage,
  }) async {
    if (emailController.text.isEmpty || !isValidEmail(emailController.text)) {
      showMessage(message: "error:O e-mail inserido não é válido.");
      return;
    }

    if (authorIdController.text.isEmpty ||
        !isValidUserId(authorIdController.text)) {
      showMessage(
        message: "error:${validateUserId(authorIdController.text, "seu ID")}",
      );
      return;
    }

    if (partnerIdController.text.isEmpty ||
        !isValidUserId(partnerIdController.text)) {
      showMessage(
        message:
            "error:${validateUserId(partnerIdController.text, "ID do seu par")}",
      );
      return;
    }

    if (authorIdController.text.toLowerCase() ==
        partnerIdController.text.toLowerCase()) {
      showMessage(
        message: "error:O seu ID e o ID do seu par não podem ser iguais.",
      );
      return;
    }

    final String email = emailController.text;
    final String authorId = authorIdController.text;
    final String partnerId = partnerIdController.text;
    final DateTime relationshipDate = selectedDate;

    showMessage(clear: true);
    final relationshipResponse = await DatabaseService().createRelationship(
      authorId,
      partnerId,
      email,
      relationshipDate,
    );

    final partedResponse = relationshipResponse.split(':');

    if (partedResponse[0] == 'error') {
      showMessage(message: "error:${partedResponse[1]}");
      return;
    } else if (partedResponse[0] == 'id') {
      if (ctx.mounted) {
        Navigator.of(ctx).pop();

        if (mounted) {
          await _loginUser(authorId, partedResponse[1], context);
        }
      }
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
                      'assets/images/logo.png',
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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _userIdController,
                          style: const TextStyle(color: AppColors.textColor),
                          decoration: InputDecoration(
                            hintText: 'Nome de Usuário',
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
                        SizedBox(height: 12),
                        TextField(
                          controller: _relationshipIdController,
                          style: const TextStyle(color: AppColors.textColor),
                          decoration: InputDecoration(
                            hintText: 'ID do Relacionamento',
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
                        SizedBox(height: 20),
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
                            onPressed: () => _loginUser(
                              _userIdController.text,
                              _relationshipIdController.text,
                              context,
                            ),
                            child: const Text(
                              'Conectar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
