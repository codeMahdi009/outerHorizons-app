import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_questions.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/feedback_bar.dart';
import '../widgets/quiz_options.dart';

enum _DetectiveState { loading, error, instructions, quiz, result }

class CosmicDetectiveScreen extends StatefulWidget {
  const CosmicDetectiveScreen({super.key});

  @override
  State<CosmicDetectiveScreen> createState() => _CosmicDetectiveScreenState();
}

class _CosmicDetectiveScreenState extends State<CosmicDetectiveScreen> {
  final _firebaseService = FirebaseService();

  _DetectiveState _state = _DetectiveState.loading;
  String? _loadError;
  List<QuizQuestion> _allQuestions = [];
  late List<QuizQuestion> _questions;

  int _currentIndex = 0;
  int _score = 0;
  int _timeLeft = 15;
  int? _selectedOption;
  bool _answered = false;
  String _feedbackMessage = '';
  bool _feedbackIsCorrect = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _state = _DetectiveState.loading;
      _loadError = null;
    });
    try {
      final questions = await _firebaseService.fetchQuestions();
      if (mounted) {
        setState(() {
          _allQuestions = questions;
          _state = _DetectiveState.instructions;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = _friendlyError(e);
          _state = _DetectiveState.error;
        });
      }
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('No questions found')) {
      return 'No questions found in Firebase.\n\n'
          'Add documents to the "questions" collection in Firestore. '
          'Each document needs: question, options (array), '
          'correctIndex (number), explanation, and category.';
    }
    if (msg.contains('PERMISSION_DENIED')) {
      return 'Firebase permission denied.\n'
          'Check your Firestore security rules and try again.';
    }
    if (msg.contains('network') || msg.contains('unavailable')) {
      return 'Could not reach Firebase.\n'
          'Check your internet connection and try again.';
    }
    return 'Could not load questions.\n'
        'Check your Firebase setup and internet connection, then try again.';
  }

  void _startQuiz() {
    final shuffled = [..._allQuestions]..shuffle();
    _questions = shuffled.take(10).toList();
    _currentIndex = 0;
    _score = 0;
    _answered = false;
    _selectedOption = null;
    _feedbackMessage = '';
    setState(() => _state = _DetectiveState.quiz);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) {
        t.cancel();
        if (!_answered) _handleAnswer(-1);
      }
    });
  }

  void _handleAnswer(int selectedIndex) {
    if (_answered) return;
    _timer?.cancel();
    final q = _questions[_currentIndex];
    final correct = selectedIndex == q.correctIndex;
    if (correct) _score++;
    setState(() {
      _answered = true;
      _selectedOption = selectedIndex;
      _feedbackIsCorrect = correct;
      _feedbackMessage = correct
          ? '✓ Correct! ${q.explanation}'
          : selectedIndex == -1
              ? 'Time\'s up! ${q.explanation}'
              : 'Incorrect. ${q.explanation}';
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      setState(() => _state = _DetectiveState.result);
      return;
    }
    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedOption = null;
      _feedbackMessage = '';
    });
    _startTimer();
  }

  void _confirmQuit() {
    _timer?.cancel();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        title: Text('Quit quiz?',
            style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A1A))),
        content: Text(
          'You\'ve answered $_currentIndex of ${_questions.length} '
          'questions and scored $_score point${_score == 1 ? '' : 's'}. '
          'Your progress will be lost.',
          style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.greyText, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('KEEP PLAYING',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('QUIT',
                style: TextStyle(color: AppTheme.incorrectRed)),
          ),
        ],
      ),
    ).then((quit) {
      if (quit == true && mounted) {
        setState(() {
          _answered = false;
          _selectedOption = null;
          _feedbackMessage = '';
          _state = _DetectiveState.instructions;
        });
      } else {
        if (!_answered) _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('COSMIC DETECTIVE', overflow: TextOverflow.ellipsis),
        leading: _state == _DetectiveState.quiz
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Quit quiz',
                onPressed: _confirmQuit,
              )
            : null,
        actions: _state == _DetectiveState.quiz
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    const Icon(Icons.star, color: AppTheme.starGold, size: 18),
                    const SizedBox(width: 4),
                    Text('$_score',
                        style: const TextStyle(
                            color: AppTheme.starGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(width: 16),
                    Icon(Icons.timer,
                        color: _timeLeft <= 5 ? AppTheme.incorrectRed : primary,
                        size: 18),
                    const SizedBox(width: 4),
                    Text('$_timeLeft s',
                        style: TextStyle(
                            color: _timeLeft <= 5
                                ? AppTheme.incorrectRed
                                : primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ]),
                )
              ]
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: switch (_state) {
          _DetectiveState.loading => _buildLoading(primary),
          _DetectiveState.error => _buildError(primary),
          _DetectiveState.instructions => _buildInstructions(primary),
          _DetectiveState.quiz => _buildQuiz(primary),
          _DetectiveState.result => _buildResult(primary),
        },
      ),
    );
  }

  // Resolve theme-dependent colours once per build subtree
  _ThemeColours _tc(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _ThemeColours(
      textMain: isDark ? Colors.white : const Color(0xFF1A1A1A),
      textSub: isDark ? Colors.white70 : AppTheme.greyText,
      textMeta: isDark ? Colors.white60 : const Color(0xFF7A7A8A),
      cardBg: isDark ? AppTheme.cardDark : AppTheme.lightCard,
      border: isDark ? Colors.white12 : const Color(0xFFDDDDE8),
      iconMuted: isDark ? Colors.white38 : const Color(0xFFAAAAAA),
    );
  }

  Widget _buildLoading(Color primary) {
    return Center(
      key: const ValueKey('loading'),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: primary),
        const SizedBox(height: 16),
        const Text('Loading questions from Firebase...',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey)),
      ]),
    );
  }

  Widget _buildError(Color primary) {
    final tc = _tc(context);
    return SingleChildScrollView(
      key: const ValueKey('error'),
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 16),
        Icon(Icons.cloud_off_rounded, color: tc.iconMuted, size: 64),
        const SizedBox(height: 20),
        Text('Could not load questions',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: tc.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(_loadError ?? 'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tc.textSub, fontSize: 14, height: 1.6)),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: _loadQuestions,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildInstructions(Color primary) {
    final tc = _tc(context);
    return SingleChildScrollView(
      key: const ValueKey('instructions'),
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withAlpha(30),
              border: Border.all(color: primary.withAlpha(80)),
            ),
            child: Icon(Icons.psychology_rounded, color: primary, size: 60),
          ),
        ),
        const SizedBox(height: 24),
        Text('Cosmic Detective Mode',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: tc.textMain)),
        const SizedBox(height: 8),
        Text('Test your knowledge of space and astronomy!',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(color: tc.textSub)),
        const SizedBox(height: 28),
        _instructionItem(Icons.quiz_rounded, primary, tc.textSub,
            'Answer ${_allQuestions.length.clamp(1, 10)} randomly selected questions.'),
        _instructionItem(Icons.timer_rounded, primary, tc.textSub,
            'You have 15 seconds per question.'),
        _instructionItem(Icons.star_rounded, primary, tc.textSub,
            '1 point for each correct answer.'),
        _instructionItem(Icons.feedback_rounded, primary, tc.textSub,
            'Instant feedback and explanation after each answer.'),
        _instructionItem(Icons.close_rounded, primary, tc.textSub,
            'Tap × in the top-left at any time to quit.'),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primary.withAlpha(60)),
          ),
          child: Row(children: [
            Icon(Icons.check_circle_outline, color: primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_allQuestions.length} question${_allQuestions.length == 1 ? '' : 's'} '
                'loaded: 10 will be randomly selected each game',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: primary, fontSize: 13),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('BEGIN MISSION',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }

  Widget _instructionItem(
      IconData icon, Color primary, Color textColor, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(color: textColor, fontSize: 15))),
      ]),
    );
  }

  // Scrollable quiz content to avoid overflow in landscape.
  Widget _buildQuiz(Color primary) {
    final tc = _tc(context);
    final q = _questions[_currentIndex];
    return Column(
      key: const ValueKey('quiz'),
      children: [
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _questions.length,
          backgroundColor: tc.cardBg,
          valueColor: AlwaysStoppedAnimation<Color>(primary),
          minHeight: 4,
        ),
        FeedbackBar(
            visible: _answered,
            isCorrect: _feedbackIsCorrect,
            message: _feedbackMessage),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Q${_currentIndex + 1} of ${_questions.length}  •  ${q.category}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(color: primary, fontSize: 13)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: tc.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: tc.border),
                  ),
                  child: Text(q.question,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 6,
                      style: TextStyle(
                          color: tc.textMain,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.5)),
                ),
                const SizedBox(height: 20),
                ...List.generate(
                    q.options.length,
                    (i) => QuizOptionTile(
                          index: i,
                          text: q.options[i],
                          answered: _answered,
                          isCorrect: i == q.correctIndex,
                          isSelected: i == _selectedOption,
                          onTap: () => _handleAnswer(i),
                        )),
              ],
            ),
          ),
        ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentIndex >= _questions.length - 1
                      ? 'VIEW RESULTS'
                      : 'NEXT QUESTION →',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResult(Color primary) {
    final tc = _tc(context);
    final pct = (_score / _questions.length * 100).toInt();
    String rank;
    Color rankColor;
    if (pct >= 90) {
      rank = 'Notorious Nebula Navigator';
      rankColor = AppTheme.starGold;
    } else if (pct >= 70) {
      rank = 'Star Trekker';
      rankColor = primary;
    } else if (pct >= 50) {
      rank = 'Cosmic Captain';
      rankColor = AppTheme.nebulaPurple;
    } else {
      rank = 'Rocket Rookie';
      rankColor = tc.textMeta;
    }

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 20),
        Text(rank,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: rankColor)),
        const SizedBox(height: 20),
        Stack(alignment: Alignment.center, children: [
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: _score / _questions.length,
              strokeWidth: 10,
              backgroundColor: tc.cardBg,
              valueColor: AlwaysStoppedAnimation<Color>(rankColor),
            ),
          ),
          Column(children: [
            Text('$_score',
                style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    color: rankColor)),
            Text('/ ${_questions.length}',
                style: TextStyle(color: tc.textSub, fontSize: 16)),
          ]),
        ]),
        const SizedBox(height: 16),
        Text('$pct% accuracy',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tc.textSub, fontSize: 15)),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('PLAY AGAIN',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                setState(() => _state = _DetectiveState.instructions),
            icon: const Icon(Icons.home_rounded),
            label: const Text('BACK TO INSTRUCTIONS',
                overflow: TextOverflow.ellipsis),
            style: OutlinedButton.styleFrom(
                foregroundColor: tc.textSub,
                side: BorderSide(color: tc.border)),
          ),
        ),
      ]),
    );
  }
}

// Simple value object for resolved theme colours : avoids passing
// many individual colour parameters through every build method.
class _ThemeColours {
  final Color textMain;
  final Color textSub;
  final Color textMeta;
  final Color cardBg;
  final Color border;
  final Color iconMuted;

  const _ThemeColours({
    required this.textMain,
    required this.textSub,
    required this.textMeta,
    required this.cardBg,
    required this.border,
    required this.iconMuted,
  });
}
