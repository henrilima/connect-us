import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
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
    if (_linkController.text.isEmpty) {
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
    return Card(
      color: AppColors.backgroundColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Melodia do Amor",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColorHover,
              ),
            ),
            Text(
              "Dedique uma música para o seu par. Insira o link de uma música do Spotify e defina uma nota (opcional).",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            if (_message.isNotEmpty)
              Text(
                _message.split(':')[1],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _message.split(':')[0] == 'error'
                      ? AppColors.errorColor
                      : AppColors.successColor,
                ),
              ),
            SizedBox(height: 32),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Link da música (Spotify)",
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: "Escreva uma nota",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_data != null)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        AppColors.errorColor,
                      ),
                    ),
                    onPressed: () => _submitForm(delete: true),
                    child: Text(
                      "Remover dedicação",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      AppColors.primaryColor,
                    ),
                  ),
                  onPressed: () => _submitForm(),
                  child: Text("Dedicar", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
