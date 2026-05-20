import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/video_background.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('OUTER HORIZONS', overflow: TextOverflow.ellipsis),
        backgroundColor: isDark
            ? AppTheme.darkSurface.withAlpha(180)
            : Colors.white.withAlpha(220),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: VideoBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: isLandscape
                ? _buildLandscapeLayout(context)
                : _buildPortraitLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _WelcomeBanner(),
        const SizedBox(height: 20),
        _SectionLabel('CHOOSE YOUR MISSION'),
        const SizedBox(height: 12),
        // Top row : two equal-width cards
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                  child: _ModeCard(
                icon: Icons.psychology_rounded,
                title: 'Cosmic Detective',
                description:
                    'Answer 10 timed space questions. 15 seconds per question.',
              )),
              SizedBox(width: 12),
              Expanded(
                  child: _ModeCard(
                icon: Icons.travel_explore_rounded,
                title: 'Cosmic Explorer',
                description:
                    'Search NASA\'s image and video library by topic or mission.',
              )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Bottom : centred third card (triangle point)
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: const _ModeCard(
              icon: Icons.public_rounded,
              title: 'Solar System',
              description:
                  'Explore all 8 planets with stats, moons, distances and orbital data from NASA.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _WelcomeBanner(),
        const SizedBox(height: 20),
        _SectionLabel('CHOOSE YOUR MISSION'),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              Expanded(
                  child: _ModeCard(
                icon: Icons.psychology_rounded,
                title: 'Cosmic Detective',
                description:
                    'Answer 10 timed space questions. 15 seconds per question.',
              )),
              SizedBox(width: 12),
              Expanded(
                  child: _ModeCard(
                icon: Icons.travel_explore_rounded,
                title: 'Cosmic Explorer',
                description:
                    'Search NASA\'s image and video library by topic or mission.',
              )),
              SizedBox(width: 12),
              Expanded(
                  child: _ModeCard(
                icon: Icons.public_rounded,
                title: 'Solar System',
                description:
                    'Explore all 8 planets with stats, moons, distances and orbital data from NASA.',
              )),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    return Text(text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
            color: primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            shadows: isDark
                ? null
                : [const Shadow(color: Colors.white, blurRadius: 8)]));
  }
}

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor =
        isDark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(230);
    final border =
        isDark ? Colors.white.withAlpha(30) : const Color(0xFFDDDDE8);
    final titleCol = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final bodyCol = isDark ? Colors.white70 : AppTheme.greyText;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withAlpha(isDark ? 60 : 25),
          ),
          child: Icon(Icons.rocket_launch, color: primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Explorer!',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: titleCol,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 4),
            Text('Your journey through the cosmos begins here.',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: bodyCol, fontSize: 13)),
          ],
        )),
      ]),
    );
  }
}

// All three cards are identical in style : same primary colour, same layout.
// Heuristic #4 (Consistency) and #8 (Minimalist): one card design, no redundant hints.
class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Theme.of(context).colorScheme.primary;
    final bgColor = isDark ? color.withAlpha(40) : Colors.white.withAlpha(220);
    final border = isDark ? color.withAlpha(80) : color.withAlpha(100);
    final bodyCol = isDark ? Colors.white60 : AppTheme.greyText;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: isDark ? 1 : 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 60 : 25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(description,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: TextStyle(color: bodyCol, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}
