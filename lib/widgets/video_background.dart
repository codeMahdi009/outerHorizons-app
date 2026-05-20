import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

// Add your .mp4 files to assets/videos/ and list them here.
// Free space footage: images.nasa.gov, pexels.com, pixabay.com
// Keep files under 10MB and ensure they loop cleanly.
const List<String> _backgroundVideos = [
  'assets/videos/blackhole.mp4',
  'assets/videos/galaxyscreen.mp4',
];

class VideoBackground extends StatefulWidget {
  final Widget child;
  const VideoBackground({super.key, required this.child});

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _noAssets = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (_backgroundVideos.isEmpty) {
      if (kDebugMode) {
        debugPrint('VideoBackground: no videos listed in _backgroundVideos.');
      }
      setState(() => _noAssets = true);
      return;
    }
    try {
      final videos = List<String>.from(_backgroundVideos)..shuffle();
      final controller = VideoPlayerController.asset(videos.first);
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      controller.setLooping(true);
      controller.setVolume(0);
      controller.play();
      setState(() {
        _controller = controller;
        _isReady = true;
      });
    } catch (e) {
      // Assets not found or failed to decode : show gradient backgreound.
      if (kDebugMode) {
        debugPrint('VideoBackground: failed to load video : $e\n'
            'Make sure .mp4 files exist in assets/videos/ '
            'and are listed in pubspec.yaml under flutter > assets.');
      }
      setState(() => _noAssets = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1 : video or gradient
        if (_isReady && _controller != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          const _GradientFallback(),

        // Layer 2 : dark overlay.
        // Lighter when showing the gradient fallback so it remains visible.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isReady
                  ? [
                      Colors.black.withAlpha(160),
                      Colors.black.withAlpha(120),
                      Colors.black.withAlpha(170),
                    ]
                  : [
                      Colors.black.withAlpha(80),
                      Colors.black.withAlpha(60),
                      Colors.black.withAlpha(80),
                    ],
            ),
          ),
        ),

        // Layer 3 : screen content
        widget.child,
      ],
    );
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A0800),
            Color(0xFF3D1500),
            AppTheme.orangeMuted,
            Color(0xFF1A0800),
            Color(0xFF0A0A0A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.15, 0.35, 0.55, 0.75, 1.0],
        ),
      ),
    );
  }
}
