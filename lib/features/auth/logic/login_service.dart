import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        throw Exception('The user account has been disabled by an administrator.');
      } else if (e.code == 'operation-not-allowed') {
        throw Exception('Email/password accounts are not enabled.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('Too many requests. Please try again later.');
      } else if (e.code == 'network-request-failed') {
        throw Exception('Network error. Please check your connection and try again.');
      } else if (e.code == 'unknown') {
        throw Exception('An unknown error occurred. Please try again.');
      } else {
        throw Exception('Failed to sign in: ${e.message}');
      }
    }
  }
}