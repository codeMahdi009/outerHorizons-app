import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

// Global ValueNotifier so any widget in the tree can toggle the theme
// without needing a state management package.
// SettingsScreen reads and writes this directly.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load the saved theme preference before the app renders so there
  // is no flash of the wrong theme on startup.
  final prefs = await SharedPreferences.getInstance();
  final darkMode = prefs.getBool('darkMode') ?? true;
  themeModeNotifier.value = darkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const OuterHorizonsApp());
}

class OuterHorizonsApp extends StatelessWidget {
  const OuterHorizonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder rebuilds MaterialApp whenever the theme notifier changes: this is what actually switches the theme.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Outer Horizons',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
