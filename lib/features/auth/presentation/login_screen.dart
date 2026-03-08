import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/auth/presentation/signup_screen.dart';
import '../../../shared/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
      
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
            
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF9333EA), Color(0xFF2563EB), Color(0xFF22D3EE)],
                    ).createShader(bounds),
                    child: const Icon(Icons.token_rounded, size: 54, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Resume AI",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                ),
                Text(
                  "Craft your future with intelligence",
                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                ),

                const SizedBox(height: 50),

           
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        hint: "Email Address",
                        icon: Icons.alternate_email_rounded,
                        isTop: true,
                      ),
                      Divider(height: 1, indent: 50, color: theme.dividerColor.withOpacity(0.1)),
                      _buildTextField(
                        controller: _passwordController,
                        hint: "Password",
                        icon: Icons.lock_outline_rounded,
                        isBottom: true,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(_errorMessage!, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ),

                const SizedBox(height: 32),

              
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // --- FOOTER ---
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen())),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Create One",
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isTop = false,
    bool isBottom = false,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
    );
  }

  Future<void> _login() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await ref.read(loginServiceProvider).signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      setState(() { _errorMessage = "Login failed. Check your email or password."; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }
}