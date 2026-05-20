import 'dart:convert';
import 'package:http/http.dart' as http;

const String _nasaApiKey = 'G39WT0OioSgdcAVxD2Uu6uRvevmddaEvf2ThyI5e';

class NasaApiService {
  static const String _libraryUrl = 'https://images-api.nasa.gov';

  // ── GET /search?q={q} ────────────────────────────────────────────────
  // Deduplicates by nasa_id and forces https on all thumbnail URLs.
  Future<List<Map<String, dynamic>>> searchLibrary(String query) async {
    final uri = Uri.parse(
        '$_libraryUrl/search?q=${Uri.encodeComponent(query)}&media_type=image,video');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['collection']['items'] as List<dynamic>;
      final seen = <String>{};
      final results = <Map<String, dynamic>>[];
      for (final item in items) {
        final map = item as Map<String, dynamic>;
        final meta =
            (map['data'] as List<dynamic>?)?.first as Map<String, dynamic>? ??
                {};
        final id = meta['nasa_id'] as String? ?? '';
        if (id.isNotEmpty && seen.contains(id)) continue;
        if (id.isNotEmpty) seen.add(id);
        final links = map['links'] as List<dynamic>?;
        if (links != null) {
          for (final link in links) {
            final l = link as Map<String, dynamic>;
            if (l['href'] is String) {
              l['href'] =
                  (l['href'] as String).replaceFirst('http://', 'https://');
            }
          }
        }
        results.add(map);
        if (results.length >= 20) break;
      }
      return results;
    }
    throw Exception('Search failed (${response.statusCode})');
  }

  // ── GET /asset/{nasa_id} ─────────────────────────────────────────────
  Future<List<String>> fetchAsset(String nasaId) async {
    final uri = Uri.parse('$_libraryUrl/asset/${Uri.encodeComponent(nasaId)}');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['collection']['items'] as List<dynamic>;
      return items
          .map((item) => ((item as Map)['href'] as String)
              .replaceFirst('http://', 'https://'))
          .toList();
    }
    throw Exception('Asset fetch failed (${response.statusCode})');
  }

  // ── GET /captions/{nasa_id} ──────────────────────────────────────────
  Future<String?> fetchCaptions(String nasaId) async {
    final uri =
        Uri.parse('$_libraryUrl/captions/${Uri.encodeComponent(nasaId)}');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['location'] as String?)?.replaceFirst('http://', 'https://');
    }
    if (response.statusCode == 404) return null;
    throw Exception('Captions fetch failed (${response.statusCode})');
  }

  // ── Fetch raw VTT captions text ──────────────────────────────────────
  Future<String> fetchVttText(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return response.body;
    return '';
  }
}
