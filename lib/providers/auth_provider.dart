import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? user;
  bool isLoading = false;
  bool isGoogleLoading = false;
  String? errorMessage;

  AppAuthProvider() {
    user = _authService.currentUser;
  }

  Future<bool> signUpHR({
    required String name,
    required String email,
    required String password,
    required String companyName,
  }) async {
    _setLoading(true);

    try {
      final createdUser = await _authService.signUp(
        email: email,
        password: password,
      );

      await _firestoreService.saveHRUser(
        uid: createdUser.uid,
        name: name,
        email: email,
        companyName: companyName,
      );

      await _authService.logout();
      user = null;
      _setLoading(false);
      return true;
    } catch (e) {
      errorMessage = _getErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginHR({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      user = await _authService.login(email: email, password: password);

      _setLoading(false);
      return true;
    } catch (e) {
      errorMessage = _getErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setGoogleLoading(true);

    try {
      final googleUser = await _authService.signInWithGoogle();

      if (googleUser == null) {
        errorMessage = "Google sign in was cancelled.";
        _setGoogleLoading(false);
        return false;
      }

      await _firestoreService.ensureHRUser(
        uid: googleUser.uid,
        name: googleUser.displayName ?? "HR User",
        email: googleUser.email ?? "",
        companyName: "Google Account",
        profileImage: googleUser.photoURL ?? "",
      );

      user = googleUser;
      _setGoogleLoading(false);
      return true;
    } catch (e) {
      errorMessage = _getErrorMessage(e);
      _setGoogleLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    user = null;
    _setLoading(false);
  }

  void clearError() {
    errorMessage = null;
  }

  void _setLoading(bool value) {
    isLoading = value;
    if (value) {
      errorMessage = null;
    }
    notifyListeners();
  }

  void _setGoogleLoading(bool value) {
    isGoogleLoading = value;
    if (value) {
      errorMessage = null;
    }
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case "email-already-in-use":
          return "This email is already registered.";
        case "invalid-email":
          return "Please enter a valid email address.";
        case "weak-password":
          return "Password should be at least 6 characters.";
        case "user-not-found":
        case "wrong-password":
        case "invalid-credential":
          return "Invalid email or password.";
        case "network-request-failed":
          return "Network error. Please check your connection.";
        default:
          return error.message ?? "Authentication failed. Please try again.";
      }
    }

    return "Something went wrong. Please try again.";
  }
}
