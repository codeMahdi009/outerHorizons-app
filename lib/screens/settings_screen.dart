import 'package:flutter/material.dart';
import '../main.dart' show themeModeNotifier;
import '../models/settings_model.dart';
import '../theme/app_theme.dart';
import '../widgets/video_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsModel = SettingsModel();

  bool _darkMode = true;
  bool _sound = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsModel.loadAll();
    setState(() {
      _darkMode = settings['darkMode'] ?? true;
      _sound = settings['sound'] ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    // In light mode tiles are solid white/light-grey so they're readable
    // over the video. In dark mode they stay semi-transparent.
    final tileBg =
        isDark ? Colors.white.withAlpha(18) : Colors.white.withAlpha(230);
    final tileBorder =
        isDark ? Colors.white.withAlpha(25) : const Color(0xFFDDDDE8);
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white54 : AppTheme.greyText;
    final iconBg = primary.withAlpha(isDark ? 40 : 25);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            const Text('SETTINGS & APP INFO', overflow: TextOverflow.ellipsis),
        backgroundColor: isDark
            ? AppTheme.darkSurface.withAlpha(180)
            : Colors.white.withAlpha(220),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: VideoBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              // ── Logo ────────────────────────────────────────────
              Center(
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.white.withAlpha(200),
                      border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(40)
                              : primary.withAlpha(80)),
                    ),
                    child: Icon(Icons.rocket_launch, color: primary, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text('Outer Horizons',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          shadows: isDark
                              ? null
                              : [
                                  const Shadow(
                                      color: Colors.white, blurRadius: 8),
                                ])),
                  Text('v1.0.0',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: subtitleColor, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 24),

              _sectionHeader('Display', primary),
              _settingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: 'Switch between dark and light theme',
                tileBg: tileBg,
                tileBorder: tileBorder,
                iconBg: iconBg,
                iconColor: primary,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (v) {
                    setState(() => _darkMode = v);
                    themeModeNotifier.value =
                        v ? ThemeMode.dark : ThemeMode.light;
                    _settingsModel.saveDarkMode(v);
                  },
                ),
              ),

              _sectionHeader('Sound', primary),
              _settingsTile(
                icon: Icons.volume_up_rounded,
                title: 'Sound Effects',
                subtitle: 'Play sounds during quiz mode',
                tileBg: tileBg,
                tileBorder: tileBorder,
                iconBg: iconBg,
                iconColor: primary,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                trailing: Switch(
                  value: _sound,
                  onChanged: (v) {
                    setState(() => _sound = v);
                    _settingsModel.saveSound(v);
                  },
                ),
              ),

              _sectionHeader('About', primary),
              _settingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About App',
                subtitle: 'Outer Horizons : A NASA edutainment app.\n'
                    'Built with Flutter & Firebase.',
                tileBg: tileBg,
                tileBorder: tileBorder,
                iconBg: iconBg,
                iconColor: primary,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                trailing: Icon(Icons.chevron_right, color: subtitleColor),
                onTap: () => _showAboutDialog(
                    isDark, primary, titleColor, subtitleColor),
              ),
              _settingsTile(
                icon: Icons.api_rounded,
                title: 'Data Sources',
                subtitle: 'NASA Image & Video Library\n'
                    'NASA Exoplanet Archive • Google Firebase',
                tileBg: tileBg,
                tileBorder: tileBorder,
                iconBg: iconBg,
                iconColor: primary,
                titleColor: titleColor,
                subtitleColor: subtitleColor,
                trailing: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, Color primary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title.toUpperCase(),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
            color: primary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            shadows: isDark
                ? null
                : [
                    const Shadow(color: Colors.white, blurRadius: 6),
                  ]),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color tileBg,
    required Color tileBorder,
    required Color iconBg,
    required Color iconColor,
    required Color titleColor,
    required Color subtitleColor,
    required Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tileBorder),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(color: subtitleColor, fontSize: 12)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(
      bool isDark, Color primary, Color titleColor, Color subtitleColor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        title: Text('About Outer Horizons',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: titleColor)),
        content: Text(
          'Outer Horizons is an edutainment app for curious space lovers.\n\n'
          '• Cosmic Detective: Quiz mode powered by Firebase Firestore.\n'
          '• Cosmic Explorer: Browse NASA\'s image and video library.\n'
          '• Settings saved locally using SharedPreferences.\n'
          '• Background videos bundled as local assets.',
          style: TextStyle(color: subtitleColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
  }
}
