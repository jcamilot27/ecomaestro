import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/reading/presentation/screens/reading_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

// Constantes de rutas
class AppRoutes {
  static const String home = '/';
  static const String reading = '/reading';
  static const String profile = '/profile';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    // TODO: Add other routes as we implement features
    GoRoute(
      path: AppRoutes.reading,
      builder: (context, state) => const ReadingScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
