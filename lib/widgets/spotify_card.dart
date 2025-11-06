import 'package:connect/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyCard extends StatefulWidget {
  final Map<String, dynamic> trackData;
  final bool minimal;
  const SpotifyCard(this.trackData, {this.minimal = false, super.key});

  @override
  State<SpotifyCard> createState() => _SpotifyCardState();
}

class _SpotifyCardState extends State<SpotifyCard> {
  Future<void> _openMusicLink(String? id) async {
    if (id == null || id.isEmpty) return;

    final Uri appUri = Uri.parse('spotify:track:$id');
    final Uri webUri = Uri.parse('https://open.spotify.com/track/$id');

    try {
      if (!await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.trackData;

    final imageUrl =
        track['album']?['images'] != null &&
            (track['album']['images'] as List).isNotEmpty
        ? track['album']['images'][1]
        : 'https://via.placeholder.com/80';

    final List<int> releasedDate = [];

    for (int x = 0; x < 3; x++) {
      final String date = track['album']['release_date']
          .toString()
          .replaceAll('-', ' ')
          .split(' ')
          .toList()[x];
      releasedDate.add(int.parse(date));
    }

    if (widget.minimal) {
      return SizedBox(
        width: double.infinity,
        height: 116,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: AppColors.drawerBackgroundColor,
          ),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.fitWidth,
                    alignment: AlignmentGeometry.center,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${track['name']}${track['explicit'] ? ' 🅴' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              track['artists'] != null &&
                                      (track['artists'] as List).isNotEmpty
                                  ? (track['artists'] as List)
                                        .map((a) => a['name'])
                                        .join(', ')
                                  : 'Artista desconhecido',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              color: AppColors.textColor,
                              size: 26,
                            ),
                            onPressed: () => _openMusicLink(track['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 400,
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: AppColors.drawerBackgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.fitWidth,
                  alignment: AlignmentGeometry.center,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${track['name']}${track['explicit'] ? ' 🅴' : ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                color: AppColors.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track['artists'] != null &&
                                      (track['artists'] as List).isNotEmpty
                                  ? (track['artists'] as List)
                                        .map((a) => a['name'])
                                        .join(', ')
                                  : 'Artista desconhecido',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Lançada em ${DateFormat('dd MMM y').format(DateTime(releasedDate[0], releasedDate[1], releasedDate[2]))}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textColor.withAlpha(100),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.open_in_new_rounded,
                      color: AppColors.textColor,
                      size: 26,
                    ),
                    onPressed: () => _openMusicLink(track['id']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
