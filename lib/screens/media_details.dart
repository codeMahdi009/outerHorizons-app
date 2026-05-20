import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../services/nasa_api.dart';
import '../theme/app_theme.dart';

class MediaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> meta;
  final String thumb;
  final String mediaType;

  const MediaDetailScreen({
    super.key,
    required this.meta,
    required this.thumb,
    required this.mediaType,
  });

  @override
  State<MediaDetailScreen> createState() => _MediaDetailScreenState();
}

class _MediaDetailScreenState extends State<MediaDetailScreen> {
  final _nasaService = NasaApiService();

  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _videoLoading = false;
  String? _videoError;

  String? _captionsText;
  bool _captionsLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') _loadVideoAndCaptions();
  }

  Future<void> _loadVideoAndCaptions() async {
    final nasaId = widget.meta['nasa_id'] as String? ?? '';
    if (nasaId.isEmpty) return;
    setState(() => _videoLoading = true);

    // Fetch asset manifest and captions URL in parallel
    final results = await Future.wait([
      _nasaService.fetchAsset(nasaId).catchError((_) => <String>[]),
      _nasaService.fetchCaptions(nasaId).catchError((_) => null),
    ]);

    final assetUrls = results[0] as List<String>;
    final captionUrl = results[1] as String?;

    // Prefer mobile mp4 for faster loading, fall back to any mp4
    final videoUrl = assetUrls.firstWhere(
      (u) => u.contains('mobile.mp4'),
      orElse: () => assetUrls.firstWhere(
        (u) => u.endsWith('.mp4'),
        orElse: () => '',
      ),
    );

    if (videoUrl.isNotEmpty && mounted) {
      try {
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await controller.initialize();
        if (!mounted) {
          controller.dispose();
          return;
        }
        controller.setVolume(1.0);
        setState(() {
          _videoController = controller;
          _videoReady = true;
          _videoLoading = false;
        });
      } catch (_) {
        if (mounted) {
          setState(() {
            _videoError = 'Video could not be loaded.';
            _videoLoading = false;
          });
        }
      }
    } else {
      if (mounted) setState(() => _videoLoading = false);
    }

    // Fetch and parse the actual VTT file content
    if (captionUrl != null && mounted) {
      setState(() => _captionsLoading = true);
      try {
        final vttText = await _nasaService.fetchVttText(captionUrl);
        if (mounted) {
          setState(() {
            _captionsText = _parseVtt(vttText);
            _captionsLoading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _captionsLoading = false);
      }
    }
  }

  // Strips WebVTT timestamps, cue numbers and inline tags,
  // leaving only the spoken text as a readable paragraph.
  String _parseVtt(String vtt) {
    final textLines = <String>[];
    for (final line in vtt.split('\n')) {
      final t = line.trim();
      if (t.isEmpty || t == 'WEBVTT') continue;
      if (t.contains('-->')) continue;
      if (RegExp(r'^\d+$').hasMatch(t)) continue;
      final clean = t.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (clean.isNotEmpty) textLines.add(clean);
    }
    return textLines.join(' ');
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.lightCard;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSub = isDark ? Colors.white70 : AppTheme.greyText;
    final textMeta = isDark ? Colors.white38 : const Color(0xFF9A9AAA);

    final title = widget.meta['title'] as String? ?? 'Untitled';
    final desc =
        widget.meta['description'] as String? ?? 'No description available.';
    final date = widget.meta['date_created'] as String? ?? '';
    final center = widget.meta['center'] as String? ?? '';
    final keywords = (widget.meta['keywords'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.mediaType == 'video'
                ? _buildVideoSection(cardBg, primary)
                : _buildImageSection(cardBg, primary),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: TextStyle(
                          color: textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (date.isNotEmpty)
                    Text(
                        date.substring(0, date.length >= 10 ? 10 : date.length),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: primary, fontSize: 13)),
                  if (center.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text('📡 $center',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: textMeta, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  Divider(
                      color: isDark ? Colors.white12 : const Color(0xFFDDDDE8)),
                  const SizedBox(height: 12),
                  _sectionLabel('Description', primary),
                  const SizedBox(height: 8),
                  Text(desc,
                      style: TextStyle(
                          color: textSub, fontSize: 14, height: 1.65)),
                  if (widget.mediaType == 'video') ...[
                    const SizedBox(height: 20),
                    Divider(
                        color:
                            isDark ? Colors.white12 : const Color(0xFFDDDDE8)),
                    const SizedBox(height: 12),
                    _sectionLabel('Transcript', primary),
                    const SizedBox(height: 8),
                    _buildCaptionsSection(cardBg, textSub, textMeta, primary),
                  ],
                  if (keywords.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _sectionLabel('Keywords', primary),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: keywords
                          .take(10)
                          .map((k) => Chip(
                                label: Text(k,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: textSub, fontSize: 12)),
                                backgroundColor: cardBg,
                                side: BorderSide(
                                    color: isDark
                                        ? Colors.white12
                                        : const Color(0xFFDDDDE8)),
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text, Color primary) => Text(text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: primary, fontWeight: FontWeight.bold));

  Widget _buildImageSection(Color cardBg, Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 260,
      child: CachedNetworkImage(
        imageUrl: widget.thumb,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
            color: cardBg,
            child: Center(child: CircularProgressIndicator(color: primary))),
        errorWidget: (_, __, ___) => Container(
            color: cardBg,
            child: const Icon(Icons.broken_image,
                color: Colors.white38, size: 60)),
      ),
    );
  }

  Widget _buildVideoSection(Color cardBg, Color primary) {
    if (_videoLoading) {
      return Container(
        height: 260,
        color: cardBg,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: primary),
          const SizedBox(height: 12),
          const Text('Loading video...',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white54)),
        ])),
      );
    }

    if (_videoReady && _videoController != null) {
      return Column(children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        Container(
          color: cardBg,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            IconButton(
              icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: primary),
              onPressed: () => setState(() {
                _videoController!.value.isPlaying
                    ? _videoController!.pause()
                    : _videoController!.play();
              }),
            ),
            Expanded(
                child: VideoProgressIndicator(
              _videoController!,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: primary,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white12,
              ),
            )),
            IconButton(
              icon: Icon(
                  _videoController!.value.volume > 0
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: primary),
              onPressed: () => setState(() {
                _videoController!
                    .setVolume(_videoController!.value.volume > 0 ? 0 : 1.0);
              }),
            ),
          ]),
        ),
      ]);
    }

    return Container(
      height: 260,
      color: cardBg,
      child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_circle_outline, color: primary, size: 64),
        const SizedBox(height: 8),
        Text(_videoError ?? 'Video unavailable',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white60)),
      ])),
    );
  }

  Widget _buildCaptionsSection(
      Color cardBg, Color textSub, Color textMeta, Color primary) {
    if (_captionsLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: primary)),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Loading transcript...',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ),
        ]),
      );
    }
    if (_captionsText != null && _captionsText!.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(_captionsText!,
            style: TextStyle(color: textSub, fontSize: 13, height: 1.6)),
      );
    }
    return Text('No transcript available for this video.',
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(color: textMeta, fontSize: 13));
  }
}
