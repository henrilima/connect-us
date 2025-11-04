import 'package:connect/spotify_credentials.dart';
import 'package:spotify/spotify.dart';

class SpotifyService {
  final credentials = SpotifyApiCredentials(
    SpotifyCredentials.clientId,
    SpotifyCredentials.clientSecret,
  );
  late final SpotifyApi spotify;

  SpotifyService() {
    spotify = SpotifyApi(credentials);
  }

  SpotifyApi get instance => spotify;

  Future<Map<String, dynamic>?> getTrackDataFromUrl(String url) async {
    final spotify = instance;

    String? extractId(String u) {
      final uri = Uri.tryParse(u);
      if (uri != null) {
        final segments = uri.pathSegments;
        for (var i = 0; i < segments.length; i++) {
          if (segments[i] == 'track' && i + 1 < segments.length) {
            return segments[i + 1];
          }
        }
      }
      final idRegex = RegExp(r'([A-Za-z0-9]{22})');
      final match = idRegex.firstMatch(u);
      return match?.group(1);
    }

    String? trackId = extractId(url);
    if (trackId == null) return null;

    Track track;

    try {
      track = await spotify.tracks.get(trackId);
    } catch (_) {
      return null;
    }

    String formatDuration(int? ms) {
      if (ms == null) return 'N/A';
      final seconds = (ms / 1000).round();
      final m = (seconds ~/ 60).toString();
      final s = (seconds % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }

    final artists = (track.artists ?? [])
        .map((a) => {'id': a.id ?? '', 'name': a.name ?? ''})
        .toList();

    final album = track.album;
    final albumImages = (album?.images ?? [])
        .map((img) => img.url ?? '')
        .where((u) => u.isNotEmpty)
        .toList();

    final result = <String, dynamic>{
      'id': track.id ?? '',
      'name': track.name ?? '',
      'artists': artists,
      'album': {
        'id': album?.id ?? '',
        'name': album?.name ?? '',
        'release_date': album?.releaseDate ?? '',
        'images': albumImages,
      },
      'duration_ms': track.durationMs,
      'duration': formatDuration(track.durationMs),
      'popularity': track.popularity,
      'preview_url': track.previewUrl ?? '',
      'external_urls': track.externalUrls ?? {},
      'explicit': track.explicit ?? false,
    };

    return result;
  }
}
