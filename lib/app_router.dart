import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/screens/welcome_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/room/screens/create_room_screen.dart';
import 'features/room/screens/join_room_screen.dart';
import 'features/game/screens/game_screen.dart';
import 'features/card_creator/screens/card_creator_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/create-room',
      builder: (context, state) => const CreateRoomScreen(),
    ),
    GoRoute(
      path: '/room-lobby',
      builder: (context, state) => const RoomLobbyScreen(),
    ),
    GoRoute(
      path: '/join-room',
      builder: (context, state) => const JoinRoomScreen(),
    ),
    GoRoute(
      path: '/game',
      builder: (context, state) {
        final solo = state.uri.queryParameters['solo'] != 'false';
        return GameScreen(isSolo: solo);
      },
    ),
    GoRoute(
      path: '/card-creator',
      builder: (context, state) => const CardCreatorScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'Sayfa bulunamadı',
            style: const TextStyle(fontSize: 18),
          ),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Ana Sayfaya Dön'),
          ),
        ],
      ),
    ),
  ),
);
