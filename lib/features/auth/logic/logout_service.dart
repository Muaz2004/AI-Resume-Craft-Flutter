import 'package:firebase_auth/firebase_auth.dart';

class LogoutService {
    Future<void> signOut() async {
    try {     await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }



}
}



