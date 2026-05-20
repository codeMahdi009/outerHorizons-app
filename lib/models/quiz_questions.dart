import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });

  // Each Firestore document in the 'questions' collection is one question.
  // Fields: question (string), options (array), correctIndex (number),
  //         explanation (string), category (string)
  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizQuestion(
      question: data['question'] as String,
      options: List<String>.from(data['options'] as List),
      correctIndex: (data['correctIndex'] as num).toInt(),
      explanation: data['explanation'] as String,
      category: data['category'] as String,
    );
  }
}
