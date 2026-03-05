import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resume_ai/features/auth/presentation/auth_gate.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../auth/logic/logout_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: Text('No user info'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Full Name: ${user.displayName ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Email: ${user.email ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),

                  // Dark Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                      Switch(
                        value: isDark,
                        onChanged: (val) {
                          ref.read(themeProvider.notifier).toggleTheme(val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Logout Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        await LogoutService().signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const AuthGate()),
                          (route) => false,
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}