import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes. 
  /// Yields a [User] if logged in, null otherwise.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Gets the currently authenticated user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw 'Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  /// Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(), 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw 'Error [${e.code}]: ${e.message}';
    } catch (e) {
      throw 'An error occurred: $e';
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
