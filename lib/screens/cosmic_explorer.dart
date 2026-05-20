import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/nasa_api.dart';
import '../theme/app_theme.dart';
import '../widgets/nasa_results.dart';
import 'media_details.dart';

class CosmicExplorerScreen extends StatefulWidget {
  const CosmicExplorerScreen({super.key});

  @override
  State<CosmicExplorerScreen> createState() => _CosmicExplorerScreenState();
}

class _CosmicExplorerScreenState extends State<CosmicExplorerScreen> {
  final _nasaService = NasaApiService();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  String _lastQuery = '';

  final List<String> _suggestions = [
    'Mars',
    'Galaxy',
    'Nebula',
    'Saturn',
    'Apollo',
    'Hubble',
    'Jupiter',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _results = [];
        _searched = false;
        _error = null;
        _lastQuery = '';
      });
      return;
    }
    if (query == _lastQuery) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
      _error = null;
      _lastQuery = query;
    });
    try {
      final results = await _nasaService.searchLibrary(query);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Could not reach NASA\'s library. '
              'Check your internet connection and try again.';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  // Resolved theme colours
  _TC _tc(BuildContext ctx) {
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    return _TC(
      isDark: isDark,
      primary: Theme.of(ctx).colorScheme.primary,
      textMain: isDark ? Colors.white : const Color(0xFF1A1A1A),
      textSub: isDark ? Colors.white70 : AppTheme.greyText,
      textMuted: isDark ? Colors.white54 : const Color(0xFF9A9AAA),
      cardBg: isDark ? AppTheme.cardDark : AppTheme.lightCard,
      chipBg: isDark ? AppTheme.cardDark : AppTheme.lightCard,
      border: isDark ? Colors.white12 : const Color(0xFFDDDDE8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = _tc(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('COSMIC EXPLORER', overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        // <-- Wrap everything to avoid overflow
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search NASA\'s media library...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: tc.textMuted),
                          onPressed: _searchCtrl.clear,
                        )
                      : _loading
                          ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: tc.primary),
                              ),
                            )
                          : null,
                ),
                style: TextStyle(color: tc.textMain),
              ),
            ),

            // Result count
            if (_searched && !_loading && _error == null && _results.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Row(children: [
                  Icon(Icons.check_circle_outline, color: tc.primary, size: 14),
                  const SizedBox(width: 6),
                  Text('${_results.length} results for "$_lastQuery"',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: tc.primary, fontSize: 12)),
                ]),
              ),

            // Suggestion chips (only when not searched)
            if (!_searched)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _suggestions
                      .map((s) => ActionChip(
                            label: Text(s,
                                style:
                                    TextStyle(color: tc.textSub, fontSize: 13)),
                            backgroundColor: tc.chipBg,
                            side: BorderSide(
                                color: tc.primary.withAlpha(120), width: 0.5),
                            onPressed: () => _searchCtrl.text = s,
                          ))
                      .toList(),
                ),
              ),

            // Main content (no longer wrapped in Expanded)
            _buildBody(tc),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(_TC tc) {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: tc.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wifi_off, color: tc.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: tc.textSub, fontSize: 15, height: 1.5)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _search(_lastQuery),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ]),
        ),
      );
    }
    if (!_searched) return _buildWelcome(tc);
    if (_results.isEmpty) return _buildEmpty(tc);
    return _buildResults(tc);
  }

  Widget _buildWelcome(_TC tc) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.travel_explore_rounded,
            color: tc.primary.withAlpha(120), size: 72),
        const SizedBox(height: 16),
        Text('Search NASA\'s Media Library',
            style: TextStyle(color: tc.textMuted, fontSize: 16)),
        const SizedBox(height: 6),
        Text('Start typing to search automatically',
            style: TextStyle(color: tc.textMuted, fontSize: 13)),
      ]),
    );
  }

  Widget _buildEmpty(_TC tc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: tc.textMuted, size: 60),
            const SizedBox(height: 12),
            Text('No results found',
                style: TextStyle(color: tc.textSub, fontSize: 16)),
            const SizedBox(height: 6),
            Text('Try a different keyword',
                style: TextStyle(color: tc.textMuted, fontSize: 13)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _suggestions
                  .take(4)
                  .map((s) => ActionChip(
                        label: Text(s, style: TextStyle(color: tc.textSub)),
                        backgroundColor: tc.chipBg,
                        onPressed: () => _searchCtrl.text = s,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(_TC tc) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final imageResults = _results
        .where((item) =>
            (_extractMeta(item)['media_type'] as String? ?? 'image') == 'image')
        .toList();
    final videoResults = _results
        .where((item) =>
            (_extractMeta(item)['media_type'] as String? ?? 'image') == 'video')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageResults.isNotEmpty) ...[
          if (videoResults.isNotEmpty)
            _sectionLabel('IMAGES (${imageResults.length})', tc.primary),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 3 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: imageResults.length,
            itemBuilder: (_, i) => _buildImageGridItem(imageResults[i], tc),
          ),
        ],
        if (videoResults.isNotEmpty) ...[
          if (imageResults.isNotEmpty)
            _sectionLabel('VIDEOS (${videoResults.length})', tc.primary),
          ...videoResults.map((item) => _buildVideoListItem(item)),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(text,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2)),
    );
  }

  Map<String, dynamic> _extractMeta(Map<String, dynamic> item) {
    final data = item['data'] as List<dynamic>? ?? [];
    return data.isNotEmpty
        ? data.first as Map<String, dynamic>
        : <String, dynamic>{};
  }

  String _extractThumb(Map<String, dynamic> item) {
    final links = item['links'] as List<dynamic>? ?? [];
    return links.isNotEmpty
        ? (links.first as Map)['href'] as String? ?? ''
        : '';
  }

  Widget _buildImageGridItem(Map<String, dynamic> item, _TC tc) {
    final meta = _extractMeta(item);
    final thumb = _extractThumb(item);
    final title = meta['title'] as String? ?? 'Untitled';

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MediaDetailScreen(meta: meta, thumb: thumb, mediaType: 'image'),
          )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(fit: StackFit.expand, children: [
          thumb.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: thumb,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      color: tc.cardBg,
                      child: Icon(Icons.image_rounded, color: tc.border)),
                  errorWidget: (_, __, ___) => Container(
                      color: tc.cardBg,
                      child: Icon(Icons.broken_image, color: tc.textMuted)),
                )
              : Container(color: tc.cardBg),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(200)],
                ),
              ),
              child: Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildVideoListItem(Map<String, dynamic> item) {
    final meta = _extractMeta(item);
    final thumb = _extractThumb(item);
    return NasaResultTile(
      title: meta['title'] as String? ?? 'Untitled',
      description: meta['description'] as String? ?? '',
      thumbUrl: thumb,
      mediaType: 'video',
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MediaDetailScreen(meta: meta, thumb: thumb, mediaType: 'video'),
          )),
    );
  }
}

class _TC {
  final bool isDark;
  final Color primary;
  final Color textMain;
  final Color textSub;
  final Color textMuted;
  final Color cardBg;
  final Color chipBg;
  final Color border;
  const _TC(
      {required this.isDark,
      required this.primary,
      required this.textMain,
      required this.textSub,
      required this.textMuted,
      required this.cardBg,
      required this.chipBg,
      required this.border});
}
