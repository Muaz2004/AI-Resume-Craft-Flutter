import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/auth/presentation/auth_gate.dart';
import 'package:resume_ai/shared/providers/auth_providers.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../auth/logic/logout_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: authState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text('No User Found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                /// AVATAR
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF9333EA),
                          Color(0xFF2563EB),
                          Color(0xFF22D3EE)
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      backgroundImage: user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              user.displayName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// USER NAME
                Text(
                  user.displayName ?? 'Account Holder',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                /// EMAIL
                Text(
                  user.email ?? 'No email associated',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),

                const SizedBox(height: 32),

                /// PERSONAL INFORMATION
                _buildSectionHeader("Personal Information"),

                _buildCard([
                  _buildProfileTile(
                      Icons.email_outlined, "Email Address", user.email ?? 'N/A'),

                  const Divider(indent: 50),

                  _buildProfileTile(
                    Icons.verified_user_outlined,
                    "Account Status",
                    user.emailVerified ? "Verified" : "Unverified",
                  ),

                  const Divider(indent: 50),

                  _buildProfileTile(
                    Icons.fingerprint_outlined,
                    "User ID",
                    "${user.uid.substring(0, 10)}...",
                  ),

                  const Divider(indent: 50),

                  _buildProfileTile(
                    Icons.calendar_today_outlined,
                    "Account Created",
                    user.metadata.creationTime != null
                        ? "${user.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}"
                        : "Unknown",
                  ),

                  const Divider(indent: 50),

                  _buildProfileTile(
                    Icons.login_outlined,
                    "Last Sign In",
                    user.metadata.lastSignInTime != null
                        ? "${user.metadata.lastSignInTime!.day}/${user.metadata.lastSignInTime!.month}/${user.metadata.lastSignInTime!.year}"
                        : "Unknown",
                  ),
                ], theme),

                const SizedBox(height: 24),

                /// SETTINGS
                _buildSectionHeader("Application Settings"),

                _buildCard([
                  ListTile(
                    leading: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: colorScheme.primary,
                    ),
                    title: const Text(
                      "Dark Theme",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Switch.adaptive(
                      value: isDark,
                      onChanged: (val) =>
                          ref.read(themeProvider.notifier).toggleTheme(val),
                    ),
                  ),
                ], theme),

                const SizedBox(height: 40),

                /// LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await LogoutService().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const AuthGate()),
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}