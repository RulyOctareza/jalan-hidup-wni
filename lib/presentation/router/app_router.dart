import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalan_hidup_wni/presentation/screens/character_creation_screen.dart';
import 'package:jalan_hidup_wni/presentation/screens/death_screen.dart';
import 'package:jalan_hidup_wni/presentation/screens/home_screen.dart';
import 'package:jalan_hidup_wni/presentation/screens/life_screen.dart';
import 'package:jalan_hidup_wni/presentation/screens/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const CharacterCreationScreen(),
      ),
      GoRoute(
        path: '/life',
        builder: (context, state) => const LifeScreen(),
      ),
      GoRoute(
        path: '/death',
        builder: (context, state) => const DeathScreen(),
      ),
    ],
  );
});
