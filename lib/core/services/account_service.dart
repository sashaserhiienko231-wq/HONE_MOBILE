import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hone_mobile/core/models/user_account.dart';
import 'package:hone_mobile/core/services/cloud_backup_service.dart';

class AccountService {
  static bool _isInitialized = false;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static GoogleSignIn? _googleSignIn;
  
  static final StreamController<UserAccount?> _userController = StreamController.broadcast();
  static final StreamController<AuthEvent> _authEventController = StreamController.broadcast();
  
  static UserAccount? _currentUser;
  static bool _isGuestMode = false;
  static DateTime? _lastSyncTime;
  static int _syncIntervalHours = 24;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Firebase services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _googleSignIn = GoogleSignIn(
        clientId: 'your-client-id.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      
      // Listen to auth state changes
      _auth!.authStateChanges().listen(_onAuthStateChanged);
      
      // Load cached user data
      await _loadCachedUser();
      
      _isInitialized = true;
      debugPrint('Account Service initialized');
    } catch (e) {
      debugPrint('Error initializing Account Service: $e');
      _isInitialized = true;
    }
  }

  static Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User signed out
      if (_currentUser != null) {
        _authEventController.add(AuthEvent(
          type: AuthEventType.signedOut,
          userId: _currentUser!.id,
          timestamp: DateTime.now(),
        ));
        _currentUser = null;
        _userController.add(null);
      }
    } else {
      // User signed in or state changed
      final userAccount = await _getUserFromFirebase(firebaseUser);
      _currentUser = userAccount;
      _userController.add(userAccount);
      
      _authEventController.add(AuthEvent(
        type: AuthEventType.signedIn,
        userId: userAccount.id,
        timestamp: DateTime.now(),
      ));
      
      // Cache user data
      await _cacheUser(userAccount);
      
      // Sync data if needed
      if (_shouldSync()) {
        await CloudBackupService.syncUserData();
      }
    }
  }

  static Future<UserAccount> _getUserFromFirebase(User firebaseUser) async {
    try {
      final userDoc = await _firestore!.collection('users').doc(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        // Existing user
        final userData = userDoc.data()!;
        return UserAccount.fromFirebase(userData, firebaseUser);
      } else {
        // New user
        final userAccount = UserAccount.create(firebaseUser);
        await _saveUserToFirestore(userAccount);
        return userAccount;
      }
    } catch (e) {
      debugPrint('Error getting user from Firebase: $e');
      return UserAccount.create(firebaseUser);
    }
  }

  static Future<void> _saveUserToFirestore(UserAccount user) async {
    try {
      await _firestore!.collection('users').doc(user.id).set(user.toFirebaseMap());
    } catch (e) {
      debugPrint('Error saving user to Firestore: $e');
    }
  }

  static Future<void> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('cached_user');
      
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = UserAccount.fromJson(userData);
        _userController.add(_currentUser);
      }
    } catch (e) {
      debugPrint('Error loading cached user: $e');
    }
  }

  static Future<void> _cacheUser(UserAccount user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error caching user: $e');
    }
  }

  static bool _shouldSync() {
    if (_lastSyncTime == null) return true;
    
    final hoursSinceLastSync = DateTime.now().difference(_lastSyncTime!).inHours;
    return hoursSinceLastSync >= _syncIntervalHours;
  }

  // Public API
  static Stream<UserAccount?> get userStream => _userController.stream;
  static Stream<AuthEvent> get authEvents => _authEventController.stream;
  static UserAccount? get currentUser => _currentUser;
  static bool get isGuestMode => _isGuestMode;
  static bool get isInitialized => _isInitialized;
  static bool get isLoggedIn => _currentUser != null && !_isGuestMode;

  // Authentication methods
  static Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      debugPrint('Signing in with email: $email');
      
      final credential = EmailAuthProvider.credential(email: email, password: email);
      final result = await _auth!.signInWithCredential(credential);
      
      if (result.user != null) {
        return AuthResult.success(
          message: 'Sign in successful',
          user: _currentUser,
        );
      } else {
        return AuthResult.failure(
          message: 'Sign in failed: Invalid credentials',
          error: 'Invalid email or password',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error: $e');
      return AuthResult.failure(
        message: 'Sign in failed',
        error: e.message,
      );
    } catch (e) {
      debugPrint('Unexpected error during sign in: $e');
      return AuthResult.failure(
        message: 'Unexpected error',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> signUpWithEmail(String email, String password, String displayName) async {
    try {
      debugPrint('Signing up with email: $email');
      
      final result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update user profile
        await result.user!.updateDisplayName(displayName);
        
        return AuthResult.success(
          message: 'Sign up successful',
          user: _currentUser,
        );
      } else {
        return AuthResult.failure(
          message: 'Sign up failed',
          error: 'Unable to create account',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error during sign up: $e');
      String errorMessage = 'Sign up failed';
      
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already in use';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address';
      }
      
      return AuthResult.failure(
        message: errorMessage,
        error: e.message,
      );
    } catch (e) {
      debugPrint('Unexpected error during sign up: $e');
      return AuthResult.failure(
        message: 'Unexpected error',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> signInWithGoogle() async {
    try {
      debugPrint('Signing in with Google');
      
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return AuthResult.failure(
          message: 'Google sign in cancelled',
          error: 'User cancelled sign in',
        );
      }
      
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final result = await _auth!.signInWithCredential(credential);
      
      if (result.user != null) {
        return AuthResult.success(
          message: 'Google sign in successful',
          user: _currentUser,
        );
      } else {
        return AuthResult.failure(
          message: 'Google sign in failed',
          error: 'Unable to sign in with Google',
        );
      }
    } catch (e) {
      debugPrint('Error during Google sign in: $e');
      return AuthResult.failure(
        message: 'Google sign in failed',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> signInAsGuest() async {
    try {
      debugPrint('Signing in as guest');
      
      _isGuestMode = true;
      final guestUser = UserAccount.guest();
      _currentUser = guestUser;
      _userController.add(guestUser);
      
      _authEventController.add(AuthEvent(
        type: AuthEventType.guestMode,
        userId: guestUser.id,
        timestamp: DateTime.now(),
      ));
      
      return AuthResult.success(
        message: 'Guest mode activated',
        user: guestUser,
      );
    } catch (e) {
      debugPrint('Error during guest sign in: $e');
      return AuthResult.failure(
        message: 'Failed to activate guest mode',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> signOut() async {
    try {
      debugPrint('Signing out');
      
      if (_isGuestMode) {
        _isGuestMode = false;
      } else {
        await _auth!.signOut();
        await _googleSignIn!.signOut();
      }
      
      _currentUser = null;
      _userController.add(null);
      
      // Clear cached data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user');
      
      _authEventController.add(AuthEvent(
        type: AuthEventType.signedOut,
        userId: 'unknown',
        timestamp: DateTime.now(),
      ));
      
      return AuthResult.success(
        message: 'Sign out successful',
      );
    } catch (e) {
      debugPrint('Error during sign out: $e');
      return AuthResult.failure(
        message: 'Failed to sign out',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> resetPassword(String email) async {
    try {
      debugPrint('Sending password reset email to: $email');
      
      await _auth!.sendPasswordResetEmail(email: email);
      
      return AuthResult.success(
        message: 'Password reset email sent',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error during password reset: $e');
      return AuthResult.failure(
        message: 'Failed to send password reset email',
        error: e.message,
      );
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      return AuthResult.failure(
        message: 'Failed to send password reset email',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      if (_currentUser == null || _currentUser!.isGuest) {
        return AuthResult.failure(
          message: 'No user logged in',
          error: 'User must be logged in to update profile',
        );
      }
      
      final updatedUser = _currentUser!.copyWith(
        displayName: displayName,
        photoURL: photoURL,
        bio: bio,
        preferences: preferences,
        updatedAt: DateTime.now(),
      );
      
      await _saveUserToFirestore(updatedUser);
      
      _currentUser = updatedUser;
      _userController.add(updatedUser);
      
      return AuthResult.success(
        message: 'Profile updated successfully',
        user: updatedUser,
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return AuthResult.failure(
        message: 'Failed to update profile',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> updatePreferences(Map<String, dynamic> preferences) async {
    return await updateProfile(preferences: preferences);
  }

  static Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
    try {
      if (_currentUser == null || _currentUser!.isGuest) {
        return AuthResult.failure(
          message: 'No user logged in',
          error: 'User must be logged in to change password',
        );
      }
      
      final user = _auth!.currentUser!;
      if (user.email == null) {
        return AuthResult.failure(
          message: 'No email associated with account',
          error: 'Cannot change password without email',
        );
      }
      
      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      
      return AuthResult.success(
        message: 'Password changed successfully',
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth error during password change: $e');
      String errorMessage = 'Failed to change password';
      
      if (e.code == 'wrong-password') {
        errorMessage = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        errorMessage = 'New password is too weak';
      }
      
      return AuthResult.failure(
        message: errorMessage,
        error: e.message,
      );
    } catch (e) {
      debugPrint('Unexpected error during password change: $e');
      return AuthResult.failure(
        message: 'Failed to change password',
        error: e.toString(),
      );
    }
  }

  static Future<AuthResult> deleteAccount() async {
    try {
      if (_currentUser == null || _currentUser!.isGuest) {
        return AuthResult.failure(
          message: 'No user logged in',
          error: 'User must be logged in to delete account',
        );
      }
      
      // Delete user data from Firestore
      await _firestore!.collection('users').doc(_currentUser!.id).delete();
      
      // Delete user from Firebase Auth
      final userId = _currentUser!.id;
      await FirebaseAuth.instance.currentUser?.delete();
      
      // Clear local data
      _currentUser = null;
      _userController.add(null);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user');
      
      _authEventController.add(AuthEvent(
        type: AuthEventType.accountDeleted,
        userId: userId,
        timestamp: DateTime.now(),
      ));
      
      return AuthResult.success(
        message: 'Account deleted successfully',
      );
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return AuthResult.failure(
        message: 'Failed to delete account',
        error: e.toString(),
      );
    }
  }

  // Cloud sync methods
  static Future<bool> syncUserData() async {
    if (_currentUser == null || _currentUser!.isGuest) return false;
    
    try {
      debugPrint('Syncing user data to cloud');
      
      await CloudBackupService.syncUserData();
      
      _lastSyncTime = DateTime.now();
      
      // Cache sync time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time', _lastSyncTime!.toIso8601String());
      
      return true;
    } catch (e) {
      debugPrint('Error syncing user data: $e');
      return false;
    }
  }

  static Future<bool> restoreUserData() async {
    if (_currentUser == null || _currentUser!.isGuest) return false;
    
    try {
      debugPrint('Restoring user data from cloud');
      
      final success = await CloudBackupService.restoreUserData();
      
      if (success) {
        // Reload user data
        await _loadCachedUser();
      }
      
      return success;
    } catch (e) {
      debugPrint('Error restoring user data: $e');
      return false;
    }
  }

  // Utility methods
  static Future<void> setSyncInterval(int hours) async {
    _syncIntervalHours = hours;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sync_interval_hours', hours);
  }

  static Future<void> loadSyncInterval() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _syncIntervalHours = prefs.getInt('sync_interval_hours') ?? 24;
    } catch (e) {
      _syncIntervalHours = 24;
    }
  }

  static Future<void> loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncTimeString = prefs.getString('last_sync_time');
      
      if (syncTimeString != null) {
        _lastSyncTime = DateTime.parse(syncTimeString);
      }
    } catch (e) {
      _lastSyncTime = null;
    }
  }

  static void dispose() {
    _userController.close();
    _authEventController.close();
  }
}

class AuthResult {
  final bool success;
  final String message;
  final String? error;
  final UserAccount? user;

  AuthResult({
    required this.success,
    required this.message,
    this.error,
    this.user,
  });

  factory AuthResult.success({required String message, UserAccount? user}) {
    return AuthResult(
      success: true,
      message: message,
      user: user,
    );
  }

  factory AuthResult.failure({required String message, String? error}) {
    return AuthResult(
      success: false,
      message: message,
      error: error,
    );
  }
}

class AuthEvent {
  final AuthEventType type;
  final String userId;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  AuthEvent({
    required this.type,
    required this.userId,
    required this.timestamp,
    this.data,
  });
}

enum AuthEventType {
  signedIn,
  signedOut,
  guestMode,
  accountCreated,
  accountDeleted,
  profileUpdated,
  preferencesUpdated,
}
