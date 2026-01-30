/// Interfaz para el servicio de reconocimiento y análisis de voz.
/// Esta abstracción permite cambiar entre implementaciones (Google, Azure, Mock)
/// sin afectar la lógica de negocio.
abstract class SpeechService {
  /// Inicia la escucha activa.
  /// Retorna un stream de resultados parciales y finales.
  Stream<SpeechResult> startListening();

  /// Detiene la escucha.
  Future<void> stopListening();

  /// Analiza la similitud fonética entre el audio grabado y el texto objetivo.
  /// Usado para el feedback detallado.
  Future<PronunciationAnalysis> analyzePronunciation(
    String recordedAudioPath,
    String targetText,
  );
}

class SpeechResult {
  final String recognizedWords;
  final bool isFinal;
  final double confidence;

  SpeechResult({
    required this.recognizedWords,
    this.isFinal = false,
    this.confidence = 0.0,
  });
}

class PronunciationAnalysis {
  final double overallScore; // 0.0 - 1.0 (Energía Verbal)
  final List<WordAnalysis> words;

  PronunciationAnalysis({required this.overallScore, required this.words});
}

class WordAnalysis {
  final String word;
  final bool isCorrect;
  final double confidence;

  WordAnalysis({
    required this.word,
    required this.isCorrect,
    required this.confidence,
  });
}
