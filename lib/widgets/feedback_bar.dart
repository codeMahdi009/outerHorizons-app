import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Animated feedback bar shown after each quiz answer.
// Green for correct, red for incorrect/timeout.
class FeedbackBar extends StatelessWidget {
  final bool visible;
  final bool isCorrect;
  final String message;

  const FeedbackBar({
    super.key,
    required this.visible,
    required this.isCorrect,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      color: visible
          ? (isCorrect ? AppTheme.correctGreen : AppTheme.incorrectRed)
          : Colors.transparent,
      padding: visible
          ? const EdgeInsets.symmetric(vertical: 10, horizontal: 16)
          : EdgeInsets.zero,
      child: visible
          ? Text(
              message,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          : const SizedBox.shrink(),
    );
  }
}
