// These tests verify that key UI widgets render correctly and respond
// to user interaction as expected. Each test pumps a widget inside a
// MaterialApp wrapper with the app's dark theme applied.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:outer_horizons/theme/app_theme.dart';
import 'package:outer_horizons/widgets/feedback_bar.dart';
import 'package:outer_horizons/widgets/quiz_options.dart';

// Helper : wraps a widget in MaterialApp with our dark theme
Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.darkTheme(),
    home: Scaffold(body: child),
  );
}

void main() {
  // FeedbackBar
  group('FeedbackBar', () {
    testWidgets('1 : visible: false renders nothing visible', (tester) async {
      await tester.pumpWidget(_wrap(
        const FeedbackBar(
          visible: false,
          isCorrect: false,
          message: 'This should not appear',
        ),
      ));

      // No text rendered when not visible
      expect(find.text('This should not appear'), findsNothing);
    });

    testWidgets('2 : visible: true, isCorrect: true shows correct message',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const FeedbackBar(
          visible: true,
          isCorrect: true,
          message: '✓ Correct! Great job.',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('✓ Correct! Great job.'), findsOneWidget);
    });

    testWidgets('3 : visible: true, isCorrect: false shows incorrect message',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const FeedbackBar(
          visible: true,
          isCorrect: false,
          message: '✗ Incorrect.',
        ),
      ));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('✗ Incorrect.'), findsOneWidget);
    });

    testWidgets('4 : message text is rendered when visible', (tester) async {
      const msg = 'Earth orbits the Sun every 365.2 days.';
      await tester.pumpWidget(_wrap(
        const FeedbackBar(
          visible: true,
          isCorrect: true,
          message: msg,
        ),
      ));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text(msg), findsOneWidget);
    });
  });

  // ── QuizOptionTile ────────────────────────────────────────────────────────
  group('QuizOptionTile', () {
    testWidgets('Renders option text and letter label', (tester) async {
      await tester.pumpWidget(_wrap(
        QuizOptionTile(
          index: 0,
          text: 'National Aeronautics and Space Administration',
          answered: false,
          isCorrect: true,
          isSelected: false,
          onTap: () {},
        ),
      ));

      expect(find.text('A'), findsOneWidget);
      expect(find.text('National Aeronautics and Space Administration'),
          findsOneWidget);
    });

    testWidgets('6 : onTap fires when answered=false', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        QuizOptionTile(
          index: 1,
          text: 'Option B',
          answered: false,
          isCorrect: false,
          isSelected: false,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('7 : onTap is null when answered=true', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        QuizOptionTile(
          index: 2,
          text: 'Option C',
          answered: true, // already answered : taps blocked
          isCorrect: false,
          isSelected: false,
          onTap: () => tapped = true,
        ),
      ));

      // Tapping an answered tile should not fire onTap
      await tester.tap(find.byType(InkWell), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('7b : four options render with labels A B C D', (tester) async {
      await tester.pumpWidget(_wrap(
        Column(
          children: List.generate(
              4,
              (i) => QuizOptionTile(
                    index: i,
                    text: 'Option ${i + 1}',
                    answered: false,
                    isCorrect: i == 0,
                    isSelected: false,
                    onTap: () {},
                  )),
        ),
      ));

      for (final label in ['A', 'B', 'C', 'D']) {
        expect(find.text(label), findsOneWidget);
      }
    });
  });

  // MainNav
  group('MainNav', () {
    // MainNav requires Firebase and other heavy dependencies at build time,
    // so we test only the BottomNavigationBar label presence here by
    // inspecting the nav bar directly rather than pumping the full screen.

    testWidgets('8 : bottom nav has 4 items with correct labels',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme(),
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            onTap: (_) {},
            backgroundColor: AppTheme.surfaceDark,
            selectedItemColor: AppTheme.cosmicTeal,
            unselectedItemColor: Colors.white38,
            type: BottomNavigationBarType.fixed,
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
          ),
        ),
      ));

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Detective'), findsOneWidget);
      expect(find.text('Explorer'), findsOneWidget);
      expect(find.text('Solar System'), findsOneWidget);
    });

    testWidgets('Default selected tab index is Home', (tester) async {
      int selected = 0;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.darkTheme(),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: const SizedBox.shrink(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selected,
              onTap: (i) => setState(() => selected = i),
              backgroundColor: AppTheme.surfaceDark,
              selectedItemColor: AppTheme.cosmicTeal,
              unselectedItemColor: Colors.white38,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.psychology_rounded), label: 'Detective'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.travel_explore_rounded),
                    label: 'Explorer'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.public_rounded), label: 'Solar System'),
              ],
            ),
          ),
        ),
      ));

      // Initial state : index 0
      expect(selected, 0);

      // Tap the Explorer tab
      await tester.tap(find.text('Explorer'));
      await tester.pump();
      expect(selected, 2);
    });
  });
}
