import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:flutter/material.dart';

class SpotifyForm extends StatefulWidget {
  final void Function(String, String, {bool delete}) onSubmit;
  final String partnerId;
  const SpotifyForm(this.onSubmit, this.partnerId, {super.key});

  @override
  State<SpotifyForm> createState() => _SpotifyFormState();
}

class _SpotifyFormState extends State<SpotifyForm> {
  Map<String, dynamic>? _data;
  String _message = '';

  final _linkController = TextEditingController();
  final _noteController = TextEditingController();

  _showMessage({String? message, clear = false}) {
    setState(() {
      _message = clear ? '' : message!;
    });
  }

  void _submitForm({bool delete = false}) async {
    if (!delete && _linkController.text.isEmpty) {
      _showMessage(
        message: "error:Você precisa inserir um link de uma música do spotify.",
      );
      return;
    }

    if (delete) {
      final confirm = await Dialoguer.showConfirmAlert(
        context: context,
        titleWidget: Text("Espere!"),
        contentWidget: Text(
          "Você tem certeza de que deseja remover a música dedicada?",
        ),
        actionsWidget: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      );

      if (confirm == true) {
        widget.onSubmit(
          _linkController.text,
          _noteController.text,
          delete: true,
        );
      } else {
        return;
      }
    } else {
      widget.onSubmit(
        _linkController.text,
        _noteController.text,
        delete: false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tryGetPartnerData();
  }

  _tryGetPartnerData() async {
    final data = await DatabaseService().getPartnerMusic(widget.partnerId);

    if (data.isNotEmpty) {
      setState(() {
        _data = data;
      });

      _linkController.text = data['url'] as String;
      _noteController.text = data['note'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Melodia do Amor",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Dedique uma música para o seu par. Insira o link de uma música do Spotify e defina uma nota (opcional).",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textColorSecondary,
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
                controller: _linkController,
                style: const TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  hintText: "Link da música (Spotify)",
                  filled: true,
                  fillColor: AppColors.drawerBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.link,
                    color: AppColors.textColorSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                style: const TextStyle(color: AppColors.textColor),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Escreva uma nota (opcional)",
                  filled: true,
                  fillColor: AppColors.drawerBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
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
                      onPressed: () => _submitForm(),
                      child: const Text(
                        "Dedicar Música",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_data != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.errorColorHover,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _submitForm(delete: true),
                        child: const Text(
                          "Remover dedicação",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
