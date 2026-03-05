import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resume_ai/features/auth/logic/logout_service.dart';
import 'package:resume_ai/shared/providers/theme_provider.dart';


class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('User ID: ${user.uid}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),

            // Dark Mode Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dark Mode', style: TextStyle(fontSize: 18)),
                Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (val) {
                    ref.read(themeProvider.notifier).state =
                        val ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Logout Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await LogoutService().signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                    // Navigate back or to login page
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}