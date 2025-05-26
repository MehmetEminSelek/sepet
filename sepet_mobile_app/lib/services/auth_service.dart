import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Current user model
  Future<UserModel?> get currentUserModel async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!);
      }
    } catch (e) {
      print('Error getting user model: $e');
    }
    return null;
  }

  // Email/Password ile kayıt ol
  Future<UserCredential?> registerWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);
      await credential.user?.reload();

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, displayName);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.message}');
      throw _getAuthException(e);
    } catch (e) {
      print('Unexpected registration error: $e');
      throw 'Kayıt olma sırasında bir hata oluştu';
    }
  }

  // Email/Password ile giriş yap
  Future<UserCredential?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      if (credential.user != null) {
        await _updateLastLogin(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      throw _getAuthException(e);
    } catch (e) {
      print('Unexpected sign in error: $e');
      throw 'Giriş yapma sırasında bir hata oluştu';
    }
  }

  // Google ile giriş yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Create or update user document in Firestore
      if (userCredential.user != null) {
        final userExists = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userExists.exists) {
          await _createUserDocument(
            userCredential.user!,
            userCredential.user!.displayName ?? 'Google User',
          );
        } else {
          await _updateLastLogin(userCredential.user!);
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Google sign in error: ${e.message}');
      throw _getAuthException(e);
    } catch (e) {
      print('Unexpected Google sign in error: $e');
      throw 'Google ile giriş yapma sırasında bir hata oluştu';
    }
  }

  // Şifre sıfırlama
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      throw _getAuthException(e);
    } catch (e) {
      print('Unexpected password reset error: $e');
      throw 'Şifre sıfırlama e-postası gönderilirken hata oluştu';
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw 'Çıkış yapma sırasında bir hata oluştu';
    }
  }

  // User document oluştur
  Future<void> _createUserDocument(User user, String displayName) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toFirestore());
  }

  // Son giriş zamanını güncelle
  Future<void> _updateLastLogin(User user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .update({'lastLoginAt': DateTime.now().toIso8601String()});
  }

  // Auth exception messages
  String _getAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Şifre çok zayıf';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'user-not-found':
        return 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Yanlış şifre';
      case 'too-many-requests':
        return 'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işleme izin verilmiyor';
      case 'network-request-failed':
        return 'Ağ bağlantısında sorun var';
      default:
        return e.message ?? 'Bir hata oluştu';
    }
  }

  // Email verification gönder
  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Email verification durumu
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Account deletion
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Auth account
        await user.delete();
      }
    } catch (e) {
      print('Delete account error: $e');
      throw 'Hesap silme sırasında bir hata oluştu';
    }
  }
}
