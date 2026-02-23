import 'package:firebase_auth/firebase_auth.dart';

class AuthStateService {
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }
}