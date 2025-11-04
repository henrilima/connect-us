import 'package:connect/services/database_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';

class SpotifyForm extends StatefulWidget {
  final void Function(String, String) onSubmit;
  final String partnerId;
  const SpotifyForm(this.onSubmit, this.partnerId, {super.key});

  @override
  State<SpotifyForm> createState() => _SpotifyFormState();
}

class _SpotifyFormState extends State<SpotifyForm> {
  final _linkController = TextEditingController();
  final _noteController = TextEditingController();

  void _submitForm() {
    if (_linkController.text.isEmpty) return;
    widget.onSubmit(_linkController.text, _noteController.text);
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
        _linkController.text = data['url'] as String;
        _noteController.text = data['note'] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.backgroundColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
            SizedBox(height: 32),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Link da música (SPOTIFY)",
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      AppColors.primaryColor,
                    ),
                  ),
                  onPressed: () => _submitForm(),
                  child: Text(
                    "Salvar mudanças",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
