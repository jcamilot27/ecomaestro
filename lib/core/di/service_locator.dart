import 'package:get_it/get_it.dart';
import '../../features/reading/presentation/bloc/reading_bloc.dart';
import '../services/speech_service.dart';
import '../services/real_speech_service.dart';

final sl = GetIt.instance; // SL = Service Locator

Future<void> init() async {
  // Features - Reading
  sl.registerFactory(() => ReadingBloc(speechService: sl()));

  // Core - Services
  // For now we use the Mock service. In production, we would switch based on environment or flags.
  sl.registerLazySingleton<SpeechService>(() => RealSpeechService());
}
