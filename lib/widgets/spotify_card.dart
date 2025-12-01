import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/fade_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spotify/spotify.dart' as spotify;
import 'package:url_launcher/url_launcher.dart';

class SpotifyCard extends StatelessWidget {
  final Map<String, dynamic> trackData;
  final String? note;
  final bool minimal;

  const SpotifyCard({
    super.key,
    required this.trackData,
    this.note,
    this.minimal = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        trackData['album']?['images'] != null &&
            (trackData['album']['images'] as List).isNotEmpty
        ? trackData['album']['images'][minimal ? 1 : 0]
        : 'https://via.placeholder.com/${minimal ? 150 : 300}';

    final artistName =
        trackData['artists'] != null &&
            (trackData['artists'] as List).isNotEmpty
        ? (trackData['artists'] as List).map((a) => a['name']).join(', ')
        : 'Artista desconhecido';

    final Map<String, dynamic> externalUrls =
        (trackData['external_urls'] as spotify.ExternalUrls).toJson();

    if (minimal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FadeNetworkImage(
                  imageUrl: imageUrl,
                  height: 160,
                  width: 160,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    height: 160,
                    width: 160,
                    color: AppColors.cardBackgroundColor,
                    child: const Icon(
                      Icons.music_note,
                      size: 64,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${trackData['name']}${trackData['explicit'] ? ' 🅴' : ''}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Por: $artistName",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textColorSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: FadeNetworkImage(
                  imageUrl: imageUrl,
                  width: 280,
                  height: 280,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    width: 280,
                    height: 280,
                    color: AppColors.cardBackgroundColor,
                    child: const Icon(
                      Icons.music_note,
                      size: 80,
                      color: AppColors.textColorSecondary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              trackData['name'] ?? 'Música desconhecida',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artistName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textColorSecondary,
              ),
            ),
            if (externalUrls['spotify'] != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  final uri = Uri.parse(externalUrls['spotify']);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.spotify, size: 20),
                label: const Text(
                  'Abrir no Spotify',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (note != null && note!.trim().isNotEmpty) ...[
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.drawerBackgroundColor.withAlpha(125),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(005),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.quoteLeft,
                      color: AppColors.primaryColorHover,
                      size: 20,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      note!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
