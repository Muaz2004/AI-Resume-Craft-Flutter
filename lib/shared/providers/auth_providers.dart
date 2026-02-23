import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/logic/auth_service.dart';
import '../../features/auth/logic/login_service.dart';
import '../../features/auth/logic/logout_service.dart';
import '../../features/auth/logic/signup_service.dart';


final authStateProvider = StreamProvider<User?>((ref) {

final authStateService = AuthStateService();
  return authStateService.authStateChanges();
});

final signUpServiceProvider = Provider<SignUpService>((ref) {
  return SignUpService();
});

final loginServiceProvider = Provider<LoginService>((ref) {
  return LoginService();
});

final logoutServiceProvider = Provider<LogoutService>((ref) {
  return LogoutService();
});

