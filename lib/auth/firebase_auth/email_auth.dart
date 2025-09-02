import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/two_factor_service.dart';

Future<UserCredential?> emailSignInFunc(
  String email,
  String password, {
  BuildContext? context,
}) async {
  try {
    // First authenticate with email/password
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.trim(), password: password);
    
    // If context is provided, show 2FA dialog
    if (context != null && context.mounted) {
      final verified = await TwoFactorService.show2FADialog(context, email.trim());
      if (!verified) {
        // Sign out if 2FA failed
        await FirebaseAuth.instance.signOut();
        return null;
      }
    }
    
    return credential;
  } catch (e) {
    rethrow;
  }
}

Future<UserCredential?> emailCreateAccountFunc(
  String email,
  String password, {
  BuildContext? context,
}) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    // If context is provided, show 2FA dialog for new account
    if (context != null && context.mounted) {
      final verified = await TwoFactorService.show2FADialog(context, email.trim());
      if (!verified) {
        // Delete account and sign out if 2FA failed
        await credential.user?.delete();
        await FirebaseAuth.instance.signOut();
        return null;
      }
    }
    
    return credential;
  } catch (e) {
    rethrow;
  }
}
