import 'package:firebase_auth/firebase_auth.dart';

class SignUpService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signUp({required String email, required String password}) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password accounts are not enabled.');
      }
      else if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your connection and try again.');
      } else if (e.code == 'unknown') {
        throw Exception('An unknown error occurred. Please try again.');
      }

      else if (e.code == 'too-many-requests') {
        throw Exception('Too many requests. Please try again later.');}
      else if (e.code == 'user-disabled') {
        throw Exception('The user account has been disabled by an administrator.');}
      else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password accounts are not enabled.');}
       else {
        throw Exception('Failed to sign up: ${e.message}');
      }
    }
  }
}