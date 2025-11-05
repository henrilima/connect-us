import 'package:connect/components/appbar.dart';
import 'package:connect/components/drawer.dart';
import 'package:connect/forms/spotify_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/spotify_service.dart';
import 'package:connect/theme/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
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
  String? _currentFetchedUrl;

  Future<void> _fetchTrackData(String url) async {
    final data = await SpotifyService().getTrackDataFromUrl(url);

    setState(() {
      _trackData = data;
    });
  }

  _openSpotifyFormModal(BuildContext context) {
    final partnerId = widget.userData['partnerId'];
    Dialoguer.openModalBottomSheet(
      context: context,
      form: SpotifyForm(savePartnerMusic, partnerId),
    );
  }

  savePartnerMusic(String link, String note, {bool delete = false}) async {
    await DatabaseService().updatePartnerMusic(
      widget.userData['partnerId'],
      link,
      note,
      delete: delete,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void didUpdateWidget(covariant SpotifyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldUrl = oldWidget.userData['url'];
    final newUrl = widget.userData['url'];

    if (oldUrl != newUrl && newUrl != null && newUrl.isNotEmpty) {
      _fetchTrackData(newUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DatabaseService().streamPartnerMusic(widget.userData['userId']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpotifyContentScreen(
            openSpotifyFormModal: _openSpotifyFormModal,
            setPage: widget.setPage,
            bodyWidget: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;

        if (data == null || data.isEmpty) {
          final bodyWidget = Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  "Parece que seu par ainda não dedicou uma música para você (ou inseriu um link inválido). Dedique um som clicando no ícone de link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );

          return SpotifyContentScreen(
            openSpotifyFormModal: _openSpotifyFormModal,
            setPage: widget.setPage,
            bodyWidget: bodyWidget,
          );
        }

        final url = data['url'];
        if (url != null && url.isNotEmpty && _currentFetchedUrl != url) {
          _currentFetchedUrl = url;
          _trackData = null;
          _fetchTrackData(url);
        }

        if (_trackData == null) {
          return SpotifyContentScreen(
            openSpotifyFormModal: _openSpotifyFormModal,
            setPage: widget.setPage,
            bodyWidget: Center(child: CircularProgressIndicator()),
          );
        }

        return SpotifyContentScreen(
          note: data['note'],
          setPage: widget.setPage,
          trackData: _trackData,
          openSpotifyFormModal: _openSpotifyFormModal,
        );
      },
    );
  }
}

class SpotifyContentScreen extends StatelessWidget {
  final Function(BuildContext) openSpotifyFormModal;
  final Function setPage;
  final Widget? bodyWidget;

  final Map<String, dynamic>? trackData;
  final String? note;

  const SpotifyContentScreen({
    required this.openSpotifyFormModal,
    required this.setPage,
    this.trackData,
    this.note,
    this.bodyWidget,
    super.key,
  });

  Widget get body {
    if (bodyWidget != null) {
      return bodyWidget!;
    } else {
      return Center(child: HasMusic(trackData!, note: note));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        'Música Dedicada',
        actions: [
          IconButton(
            onPressed: () => openSpotifyFormModal(context),
            icon: const FaIcon(FontAwesomeIcons.link, size: 20),
          ),
        ],
      ),
      drawer: DrawerComponent(setPage),
      body: body,
    );
  }
}

class HasMusic extends StatelessWidget {
  final Map<String, dynamic> _trackData;
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
                      fontWeight: FontWeight.w400,
                      color: AppColors.textColorSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '"${note!}"',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
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
