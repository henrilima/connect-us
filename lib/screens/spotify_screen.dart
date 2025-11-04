import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/forms/spotify_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/spotify_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/widgets/error_screen.dart';
import 'package:connect/widgets/spotify_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SpotifyScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;
  const SpotifyScreen(this.setPage, {required this.userData, super.key});

  @override
  State<SpotifyScreen> createState() => _SpotifyScreenState();
}

class _SpotifyScreenState extends State<SpotifyScreen> {
  Map<String, dynamic>? _trackData;
  String? _lastUrl;
  bool _loading = false;

  Future<void> _loadDemoTrack(String url) async {
    setState(() => _loading = true);
    final data = await SpotifyService().getTrackDataFromUrl(url);
    if (!mounted) return;
    setState(() {
      _trackData = data;
      _loading = false;
    });
  }

  _openSpotifyFormModal(BuildContext context) {
    final partnerId = widget.userData['partnerId'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SpotifyForm(_setMusic, partnerId),
            ),
          ),
        );
      },
    );
  }

  _setMusic(String link, String note) async {
    await DatabaseService().updatePartnerMusic(
      widget.userData['partnerId'],
      link,
      note,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().streamPartnerMusic(widget.userData['userId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBarComponent(
              'Música Dedicada',
              actions: [
                IconButton(
                  onPressed: () => _openSpotifyFormModal(context),
                  icon: const FaIcon(FontAwesomeIcons.link, size: 20),
                ),
              ],
            ),
            drawer: DrawerComponent(widget.setPage),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return ErrorScreenComponent("Nenhuma música encontrada");
        }

        final url = data['url'];
        final note = data['note'];

        if (url != null && url.isNotEmpty && url != _lastUrl) {
          _lastUrl = url;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadDemoTrack(url);
          });
        }

        return Scaffold(
          appBar: AppBarComponent(
            'Música Dedicada',
            actions: [
              IconButton(
                onPressed: () => _openSpotifyFormModal(context),
                icon: const FaIcon(FontAwesomeIcons.link, size: 20),
              ),
            ],
          ),
          drawer: DrawerComponent(widget.setPage),
          body: Center(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _trackData != null
                ? HasMusic(_trackData, note: note)
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Parece que seu par ainda não dedicou uma música para você (ou inseriu um link inválido). Dedique um som clicando no ícone de link.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class HasMusic extends StatelessWidget {
  final Map<String, dynamic>? _trackData;
  final String? note;
  const HasMusic(this._trackData, {this.note, super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpotifyCard(_trackData),
            const SizedBox(height: 24),

            if (note != null && note!.isNotEmpty)
              Column(
                children: [
                  const Text(
                    "O seu par deixou uma mensagem junto com a música:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColorSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '"${note!}"',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
