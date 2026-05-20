import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizOptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool answered;
  final bool isCorrect;
  final bool isSelected;
  final VoidCallback? onTap;

  const QuizOptionTile({
    super.key,
    required this.index,
    required this.text,
    required this.answered,
    required this.isCorrect,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.lightCard;

    Color bg = cardBg;
    Color border = isDark ? Colors.white12 : const Color(0xFFDDDDE8);

    if (answered) {
      if (isCorrect) {
        bg = AppTheme.correctGreen.withAlpha(60);
        border = AppTheme.correctGreen;
      } else if (isSelected) {
        bg = AppTheme.incorrectRed.withAlpha(60);
        border = AppTheme.incorrectRed;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: answered ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: border.withAlpha(60),
                ),
                child: Center(
                  child: Text(
                    ['A', 'B', 'C', 'D'][index],
                    style: TextStyle(
                      color: answered ? textMain : primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    Text(text, style: TextStyle(color: textMain, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
