import 'package:shared_preferences/shared_preferences.dart';

//  SettingsScreen's state with:
//   final _settingsModel = SettingsModel();
class SettingsModel {
  static const _keyDarkMode = 'darkMode';
  static const _keySound = 'sound';

  Future<Map<String, bool>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _keyDarkMode: prefs.getBool(_keyDarkMode) ?? true,
      _keySound: prefs.getBool(_keySound) ?? true,
    };
  }

  Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<void> saveSound(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySound, value);
  }
}
