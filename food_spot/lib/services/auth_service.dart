import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future register(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future logout() async {
    await _auth.signOut();
  }
}
