import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:resume_ai/shared/providers/theme_provider.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Define centralized light theme
final lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    primary: Color(0xFF2563EB), // Deep Blue
    secondary: Color(0xFF3B82F6), // Accent
    background: Color(0xFFF8FAFC), // Light Gray
    surface: Colors.white, // Cards
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Color(0xFF111827), // Text on background
    onSurface: Color(0xFF111827),
    brightness: Brightness.light,
    error: Colors.red,
    onError: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E40AF), // AppBar Deep Blue
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
);

// Define centralized dark theme
final darkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2563EB),
    secondary: Color(0xFF3B82F6),
    background: Color(0xFF111827),
    surface: Color(0xFF1E293B),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E40AF),
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF111827),
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resume AI',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}