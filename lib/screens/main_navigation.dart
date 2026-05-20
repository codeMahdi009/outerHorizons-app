import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'cosmic_detective.dart';
import 'cosmic_explorer.dart';
import 'solar_system.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    CosmicDetectiveScreen(),
    CosmicExplorerScreen(),
    ExoplanetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.psychology_rounded), label: 'Detective'),
          BottomNavigationBarItem(
              icon: Icon(Icons.travel_explore_rounded), label: 'Explorer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.public_rounded), label: 'Solar System'),
        ],
        backgroundColor: AppTheme.surfaceDark,
        selectedItemColor: AppTheme.cosmicTeal,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
    );
  }
}
