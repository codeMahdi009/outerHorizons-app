import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_questions.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches every document from the 'questions' collection.
  // Each document is one question. The screen is responsible for
  // shuffling and selecting a unique subset per quiz attempt.
  //

  Future<List<QuizQuestion>> fetchQuestions() async {
    final snapshot = await _firestore.collection('questions').get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No questions found in Firebase.\n\n'
          'Add documents to the "questions" collection : '
          'each document should have: question, options (array), '
          'correctIndex (number), explanation, and category.');
    }

    return snapshot.docs.map((doc) => QuizQuestion.fromFirestore(doc)).toList();
  }
}
