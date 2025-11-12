import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final Dio dio;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.dio,
  });

  Future<UserCredential> signInWithGoogle() async {
    GoogleSignIn.instance.initialize(
        serverClientId: '648191628661-ocjf8p4316td6pjg3lbuoudjtje5a018.apps.googleusercontent.com'
    );
    final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();

    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    if (!await SignInWithApple.isAvailable()) {
      throw Exception('Sign in with Apple is not available on this device');
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await firebaseAuth.signInWithCredential(oauthCredential);

    // КРИТИЧЕСКИ ВАЖНО: Apple предоставляет имя ТОЛЬКО при первом входе
    // Нужно сразу сохранить его в Firebase displayName
    if (appleCredential.givenName != null || appleCredential.familyName != null) {
      final displayName = [
        appleCredential.givenName ?? '',
        appleCredential.familyName ?? '',
      ].where((part) => part.isNotEmpty).join(' ');

      if (displayName.isNotEmpty) {
        print('Apple Sign In: Saving displayName: $displayName');

        // Обновляем displayName
        await userCredential.user?.updateDisplayName(displayName);

        // ВАЖНО: Перезагружаем данные пользователя
        await userCredential.user?.reload();

        // Получаем обновленного пользователя из Firebase
        final updatedUser = firebaseAuth.currentUser;

        print('Apple Sign In: Updated displayName: ${updatedUser?.displayName}');

      }
    }

    return userCredential;
  }

  Future<UserCredential> signInWithDemo() async {
    try {
      final response = await dio.post('/auth/demo-login');
      final customToken = response.data['customToken'] as String;
      final userCredential = await firebaseAuth.signInWithCustomToken(customToken);
      return userCredential;
    } catch (e) {
      throw Exception('Demo login failed: $e');
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
    ]);
  }

  Future<User?> getCurrentFirebaseUser() {
    return Future.value(firebaseAuth.currentUser);
  }

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();
}