import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/auth/presentation/home_screen.dart';
import '../../../shared/providers/auth_providers.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return HomeScreen();
        } else {
          return  LoginScreen();
        }
      },
      loading: () => const SplashScreen(),
      error: (error, stack) =>
          Scaffold(
            body: Center(child: Text('Error: $error')),
          ),
    );
  }
}