import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/speech_service.dart';

// --- Events ---
abstract class ReadingEvent extends Equatable {
  const ReadingEvent();

  @override
  List<Object> get props => [];
}

class LoadReadingSession extends ReadingEvent {}

class StartListening extends ReadingEvent {}

class StopReading extends ReadingEvent {}

class NextText extends ReadingEvent {}

class DecayFluency extends ReadingEvent {}

class ReadingCompleted extends ReadingEvent {
  final PronunciationAnalysis analysis;
  const ReadingCompleted(this.analysis);
}

// --- States ---
enum ReadingStatus {
  initial,
  listening,
  processing,
  success,
  failure,
  sessionCompleted,
}

class ReadingState extends Equatable {
  final ReadingStatus status;
  final String currentText;
  final int currentIndex;
  final int totalTexts;
  final String recognizedText;
  final double fluencyScore;
  final List<WordAnalysis> detailedAnalysis;
  final List<double> sessionScores;
  final String? errorMessage;

  const ReadingState({
    this.status = ReadingStatus.initial,
    this.currentText = '',
    this.currentIndex = 0,
    this.totalTexts = 0,
    this.recognizedText = '',
    this.fluencyScore = 0.0,
    this.detailedAnalysis = const [],
    this.sessionScores = const [],
    this.errorMessage,
  });

  ReadingState copyWith({
    ReadingStatus? status,
    String? currentText,
    int? currentIndex,
    int? totalTexts,
    String? recognizedText,
    double? fluencyScore,
    List<WordAnalysis>? detailedAnalysis,
    List<double>? sessionScores,
    String? errorMessage,
  }) {
    return ReadingState(
      status: status ?? this.status,
      currentText: currentText ?? this.currentText,
      currentIndex: currentIndex ?? this.currentIndex,
      totalTexts: totalTexts ?? this.totalTexts,
      recognizedText: recognizedText ?? this.recognizedText,
      fluencyScore: fluencyScore ?? this.fluencyScore,
      detailedAnalysis: detailedAnalysis ?? this.detailedAnalysis,
      sessionScores: sessionScores ?? this.sessionScores,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentText,
    currentIndex,
    totalTexts,
    recognizedText,
    fluencyScore,
    detailedAnalysis,
    sessionScores,
    errorMessage,
  ];
}

// --- Bloc ---
class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final SpeechService speechService;
  Timer? _decayTimer;
  StreamSubscription? _speechSubscription;

  final List<String> _practiceTexts = [
    "In a rapidly changing world, the ability to learn continuously is the only sustainable competitive advantage.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "The best way to predict the future is to create it.",
    "Do not wait for the perfect moment, take the moment and make it perfect.",
    "Believe you can and you're halfway there.",
  ];

  ReadingBloc({required this.speechService}) : super(const ReadingState()) {
    on<LoadReadingSession>(_onLoadSession);
    on<StartListening>(_onStartListening);
    on<StopReading>(_onStopReading);
    on<NextText>(_onNextText);
    on<DecayFluency>(_onDecayFluency);
    on<ReadingCompleted>(_onCompleted);
  }

  void _onLoadSession(LoadReadingSession event, Emitter<ReadingState> emit) {
    emit(
      state.copyWith(
        status: ReadingStatus.initial,
        currentText: _practiceTexts[0],
        currentIndex: 0,
        totalTexts: _practiceTexts.length,
        sessionScores: [],
        recognizedText: '',
        fluencyScore: 0.0,
      ),
    );
  }

  Future<void> _onStartListening(
    StartListening event,
    Emitter<ReadingState> emit,
  ) async {
    _decayTimer?.cancel();
    _speechSubscription?.cancel();

    emit(
      state.copyWith(
        status: ReadingStatus.listening,
        recognizedText: '',
        fluencyScore: 0.1,
      ),
    );

    // Start decay timer - reduces fluency every 500ms
    _decayTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      add(DecayFluency());
    });

    await emit.forEach<SpeechResult>(
      speechService.startListening(),
      onData: (result) {
        if (result.isFinal) {
          add(StopReading());
          _triggerAnalysisHook(result.recognizedWords);
          return state.copyWith(recognizedText: result.recognizedWords);
        }
        // Increase fluency when words are recognized
        return state.copyWith(
          recognizedText: result.recognizedWords,
          fluencyScore: (state.fluencyScore + 0.08).clamp(0.0, 1.0),
        );
      },
      onError: (error, stackTrace) {
        _decayTimer?.cancel();
        return state.copyWith(
          status: ReadingStatus.failure,
          errorMessage: error.toString(),
        );
      },
    );
  }

  void _onDecayFluency(DecayFluency event, Emitter<ReadingState> emit) {
    if (state.status == ReadingStatus.listening) {
      // Slow decay of fluency when silent
      emit(
        state.copyWith(
          fluencyScore: (state.fluencyScore - 0.015).clamp(0.0, 1.0),
        ),
      );
    } else {
      _decayTimer?.cancel();
    }
  }

  Future<void> _onStopReading(
    StopReading event,
    Emitter<ReadingState> emit,
  ) async {
    _decayTimer?.cancel();
    await speechService.stopListening();
    if (state.status == ReadingStatus.listening) {
      emit(state.copyWith(status: ReadingStatus.processing));
    }
  }

  void _onNextText(NextText event, Emitter<ReadingState> emit) {
    final nextIndex = state.currentIndex + 1;
    final updatedScores = List<double>.from(state.sessionScores)
      ..add(state.fluencyScore);

    if (nextIndex < _practiceTexts.length) {
      emit(
        state.copyWith(
          status: ReadingStatus.initial,
          currentIndex: nextIndex,
          currentText: _practiceTexts[nextIndex],
          sessionScores: updatedScores,
          recognizedText: '',
          fluencyScore: 0.0,
          detailedAnalysis: [],
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: ReadingStatus.sessionCompleted,
          sessionScores: updatedScores,
        ),
      );
    }
  }

  Future<void> _onCompleted(
    ReadingCompleted event,
    Emitter<ReadingState> emit,
  ) async {
    _decayTimer?.cancel();
    emit(
      state.copyWith(
        status: ReadingStatus.success,
        fluencyScore: event.analysis.overallScore,
        detailedAnalysis: event.analysis.words,
      ),
    );
  }

  void _triggerAnalysisHook(String recognizedText) async {
    try {
      final analysis = await speechService.analyzePronunciation(
        recognizedText,
        state.currentText,
      );
      add(ReadingCompleted(analysis));
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> close() {
    _decayTimer?.cancel();
    _speechSubscription?.cancel();
    return super.close();
  }
}
