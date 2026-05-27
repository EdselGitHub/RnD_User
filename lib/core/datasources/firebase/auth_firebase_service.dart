import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rnd_proj/core/models/user_model.dart';
import 'package:rnd_proj/core/constants/app_constants.dart';

class AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthFirebaseService() {
    // Disable reCAPTCHA verification untuk Android development/testing
    _auth.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signInWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Login gagal: user null');

      // Get user data from Firestore
      try {
        final doc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          // Create user document if it doesn't exist
          final newUser = UserModel(
            id: user.uid,
            name: user.displayName ?? email.split('@').first,
            email: email,
            password: password,
          );
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set(newUser.toFirestore());
          return newUser;
        }

        return UserModel.fromFirestore(doc);
      } catch (e) {
        debugPrint('Error fetching user data: $e');
        throw Exception('Gagal mengambil data user: $e');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      } else {
        throw Exception('Firebase Auth Error: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error in signIn: $e');
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  Future<UserModel> signUpWithEmailPassword(
      String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('Registrasi gagal: user null');

      // Update display name
      try {
        await user.updateDisplayName(name);
      } catch (e) {
        debugPrint('Error updating display name: $e');
      }

      // Create user document in Firestore with password
      final newUser = UserModel(
        id: user.uid,
        name: name,
        email: email,
        password: password,
      );
      
      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(newUser.toFirestore());
      } catch (e) {
        debugPrint('Error saving to Firestore: $e');
        throw Exception('Gagal menyimpan data user ke database: $e');
      }

      return newUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah. Minimal 6 karakter.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email sudah terdaftar.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      } else {
        throw Exception('Firebase Auth Error: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error in signUp: $e');
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }
}
