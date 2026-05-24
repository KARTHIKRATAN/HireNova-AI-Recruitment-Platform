import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<User> signUp({required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: "user-not-created",
          message: "Account was not created. Please try again.",
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Signup error: ${e.code} ${e.message}");
      rethrow;
    }
  }

  Future<User> login({required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "No user found for these credentials.",
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Login error: ${e.code} ${e.message}");
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final googleUser = await GoogleSignIn().signIn();

        if (googleUser == null) {
          return null;
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Google sign in error: ${e.code} ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("Google sign in error: $e");
      throw FirebaseAuthException(
        code: "google-sign-in-failed",
        message: "Google sign in failed. Please check Firebase/iOS setup.",
      );
    }
  }

  Future<void> logout() async {
    final providerIds =
        _auth.currentUser?.providerData.map((info) => info.providerId) ?? [];

    if (providerIds.contains("google.com")) {
      await GoogleSignIn().signOut();
    }

    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
