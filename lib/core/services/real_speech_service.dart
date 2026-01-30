import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter/foundation.dart';
import 'speech_service.dart';

class RealSpeechService implements SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  @override
  Stream<SpeechResult> startListening() async* {
    bool available = await _speechToText.initialize(
      onError: (SpeechRecognitionError error) {
        // Handle init errors usually through status listener, but we will catch them in generic usage
        debugPrint('Speech setup error: ${error.errorMsg}');
      },
      onStatus: (String status) {
        debugPrint('Speech status: $status');
      },
    );

    if (!available) {
      throw Exception("Speech recognition not available or permission denied");
    }

    // Create a controller to bridge the callback-based API to Stream
    final controller = StreamController<SpeechResult>();

    void resultListener(SpeechRecognitionResult result) {
      if (!controller.isClosed) {
        controller.add(
          SpeechResult(
            recognizedWords: result.recognizedWords,
            isFinal: result.finalResult,
            confidence: result.confidence,
          ),
        );
      }
    }

    _speechToText.listen(
      onResult: resultListener,
      localeId: 'en_US', // Force English for better recognition accuracy
      listenFor: const Duration(seconds: 60), // Allow longer sessions
      pauseFor: const Duration(
        seconds: 10,
      ), // Allow longer pauses between words
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation, // Optimized for continuous speech
        sampleRate:
            44100, // Explicitly request higher quality audio if supported
      ),
    );

    // Yield results from the controller
    yield* controller.stream;

    // We don't automatically close the stream here because `listen` is async/callback based.
    // The BLoC will cancel the subscription which should trigger cleanup if we hook into onCancel?
    // Actually, converting typical callback API to Stream logic often requires careful resource management.
    // For simplicity, we just bridge events.
  }

  @override
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  @override
  Future<PronunciationAnalysis> analyzePronunciation(
    String recordedAudioPath,
    String targetText,
  ) async {
    // Syllable-based validation

    // 1. Clean and Split Words
    final targetWords = targetText
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ');
    final recordedWords = recordedAudioPath
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ');

    final List<WordAnalysis> analysis = [];
    double totalSyllables = 0;
    double matchedSyllables = 0;

    int lastFoundIndex = -1;

    for (int i = 0; i < targetWords.length; i++) {
      String target = targetWords[i];
      int targetSyllableCount = _countSyllables(target);
      totalSyllables += targetSyllableCount;

      double wordConfidence = 0.0;
      int bestMatchIndex = -1;

      // search window
      int searchStart = lastFoundIndex + 1;
      int searchEnd = (searchStart + 5).clamp(0, recordedWords.length);

      for (int j = searchStart; j < searchEnd; j++) {
        String rec = recordedWords[j];

        // 1. Exact Match
        if (rec == target) {
          wordConfidence = 1.0;
          bestMatchIndex = j;
          break; // Found perfect match
        }

        // 2. Levenshtein on Text (approximate syllable match proxy)
        // If words are similar (Levenshtein distance low relative to length),
        // we assume high syllable overlap.
        int dist = _levenshtein(target, rec);
        double similarity = 1.0 - (dist / target.length);

        // If similarity is > 0.5 (e.g. "comput" vs "computer"), maybe 2/3 syllables
        // We can estimate syllable match score based on text similarity.
        if (similarity > wordConfidence && similarity > 0.4) {
          wordConfidence = similarity;
          bestMatchIndex = j;
        }
      }

      if (bestMatchIndex != -1) {
        lastFoundIndex = bestMatchIndex;
        matchedSyllables += (targetSyllableCount * wordConfidence);
      }

      // Determine final "correctness" for visual feedback based on confidence threshold
      // > 0.8 = Green (Correct)
      // > 0.4 = Yellow (Regular)
      // <= 0.4 = Red

      analysis.add(
        WordAnalysis(
          word: targetWords[i],
          isCorrect:
              wordConfidence >
              0.4, // Loose definition for "isCorrect" boolean, but confidence carries nuance
          confidence: wordConfidence,
        ),
      );
    }

    // Prevent division by zero
    double overallScore = totalSyllables > 0
        ? (matchedSyllables / totalSyllables)
        : 0.0;

    return PronunciationAnalysis(
      overallScore: overallScore.clamp(0.0, 1.0),
      words: analysis,
    );
  }

  int _countSyllables(String word) {
    if (word.isEmpty) return 0;
    if (word.length <= 3) return 1;

    word = word.toLowerCase();
    // Remove silent 'e' at end
    if (word.endsWith('e')) {
      word = word.substring(0, word.length - 1);
    }

    // Count vowel groups
    final vowelGroups = RegExp(r'[aeiouy]+');
    final matches = vowelGroups.allMatches(word);

    int count = matches.length;
    // Special cases correction could go here

    return count > 0 ? count : 1;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) v0[i] = i;

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s.codeUnitAt(i) == t.codeUnitAt(j)) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j < t.length + 1; j++) v0[j] = v1[j];
    }

    return v1[t.length];
  }
}

void debugPrint(String msg) {
  if (kDebugMode) {
    print('EcoMaestroVoice: $msg');
  }
}
