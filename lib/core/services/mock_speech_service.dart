import 'package:eco_maestro/core/services/speech_service.dart';

class MockSpeechService implements SpeechService {
  @override
  Stream<SpeechResult> startListening() async* {
    yield SpeechResult(recognizedWords: "In a", isFinal: false);
    await Future.delayed(const Duration(milliseconds: 500));
    yield SpeechResult(recognizedWords: "In a rapidly", isFinal: false);
    await Future.delayed(const Duration(milliseconds: 500));
    yield SpeechResult(
      recognizedWords: "In a rapidly changing world",
      isFinal: true,
      confidence: 0.95,
    );
  }

  @override
  Future<void> stopListening() async {
    // Simulate cleanup
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<PronunciationAnalysis> analyzePronunciation(
    String recordedAudioPath,
    String targetText,
  ) async {
    // Simulate analysis delay
    await Future.delayed(const Duration(seconds: 1));

    // Return a nearly perfect score for demo purposes
    return PronunciationAnalysis(
      overallScore: 0.85,
      words: [
        WordAnalysis(word: "In", isCorrect: true, confidence: 0.99),
        WordAnalysis(word: "a", isCorrect: true, confidence: 0.98),
        WordAnalysis(word: "rapidly", isCorrect: true, confidence: 0.95),
        WordAnalysis(word: "changing", isCorrect: true, confidence: 0.90),
        WordAnalysis(
          word: "world",
          isCorrect: false,
          confidence: 0.40,
        ), // Simulated error
      ],
    );
  }
}
