import 'package:connect/components/header.dart';
import 'package:connect/forms/spotify_form.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/services/spotify_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/utils/dialoguer.dart';
import 'package:connect/services/messenger_service.dart';
import 'package:connect/widgets/fade_in.dart';
import 'package:connect/widgets/loading_widget.dart';
import 'package:connect/widgets/spotify_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:connect/services/api_service.dart';

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

    if (mounted) {
      setState(() {
        _trackData = data;
      });
    }
  }

  _openSpotifyFormModal(BuildContext context) {
    final partnerId = widget.userData['partnerId'];
    Dialoguer.openModalBottomSheet(
      context: context,
      form: SpotifyForm(savePartnerMusic, partnerId),
    );
  }

  _openMusicAlert(BuildContext context) async {
    final Map<String, String> partnerMusic = await DatabaseService()
        .getPartnerMusic(widget.userData['partnerId']);

    if (context.mounted) {
      if (partnerMusic.isNotEmpty) {
        final Map<String, dynamic>? spotifyPartnerData = await SpotifyService()
            .getTrackDataFromUrl(partnerMusic['url']!);

        if (!context.mounted) return;

        if (!context.mounted) return;
        Dialoguer.openModalBottomSheet(
          context: context,
          customLayout: true,
          form: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'A música que você dedicou',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryColorHover,
                  ),
                ),
                const SizedBox(height: 16),
                SpotifyCard(
                  trackData: spotifyPartnerData!,
                  note: partnerMusic['note'],
                ),
              ],
            ),
          ),
        );
      } else {
        AppMessenger(
          context,
          "Você não dedicou nenhuma música para seu par, dedique no botão ao lado.",
          "warning",
        ).show();
      }
    }
  }

  savePartnerMusic(String link, String note, {bool delete = false}) async {
    await DatabaseService().updatePartnerMusic(
      widget.userData['partnerId'],
      link,
      note,
      delete: delete,
    );

    if (!delete) {
      final partnerId = widget.userData['partnerId'];
      final token = await DatabaseService().getMessagerToken(partnerId);

      if (token != null) {
        final myName = widget.userData['username'] ?? 'Seu amor';
        await ApiService().sendNotification(
          token,
          "Nova música dedicada! 🎵",
          "$myName dedicou uma música para você. Toque para ouvir!",
        );
      }
    }

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
          return const Loading();
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
                  "Parece que seu par ainda não dedicou uma música para você, ou o link precisa ser ajustado. Que tal dar o primeiro passo e dedicar um som especial? Clique no ícone de link!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );

          return SpotifyContentScreen(
            openMusicModal: _openMusicAlert,
            openSpotifyFormModal: _openSpotifyFormModal,
            setPage: widget.setPage,
            photoUrl: widget.userData['photoUrl'],
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
          return const Loading();
        }

        return SpotifyContentScreen(
          note: data['note'],
          setPage: widget.setPage,
          trackData: _trackData,
          photoUrl: widget.userData['photoUrl'],
          openSpotifyFormModal: _openSpotifyFormModal,
          openMusicModal: _openMusicAlert,
        );
      },
    );
  }
}

class SpotifyContentScreen extends StatelessWidget {
  final Function(BuildContext) openSpotifyFormModal;
  final Function(BuildContext) openMusicModal;
  final Function setPage;
  final Widget? bodyWidget;
  final String? photoUrl;

  final Map<String, dynamic>? trackData;
  final String? note;

  const SpotifyContentScreen({
    required this.openSpotifyFormModal,
    required this.openMusicModal,
    required this.setPage,
    this.trackData,
    this.note,
    this.bodyWidget,
    this.photoUrl,
    super.key,
  });

  Widget get body {
    if (bodyWidget != null) {
      return bodyWidget!;
    } else {
      return Center(
        child: FadeIn(
          child: SpotifyCard(trackData: trackData!, note: note),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              setPage,
              true,
              title: 'Música Dedicada',
              photoUrl: photoUrl,
              actions: [
                IconButton(
                  onPressed: () => openMusicModal(context),
                  icon: const FaIcon(FontAwesomeIcons.spotify, size: 20),
                ),
                IconButton(
                  onPressed: () => openSpotifyFormModal(context),
                  icon: const FaIcon(FontAwesomeIcons.link, size: 20),
                ),
              ],
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
