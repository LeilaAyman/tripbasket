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
    // First check if user exists but is not verified
    try {
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email.trim());
      if (methods.isNotEmpty) {
        // User exists, check if they're verified
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), 
          password: password
        );
        
        if (userCredential.user != null && !userCredential.user!.emailVerified) {
          // User exists but not verified - resend verification
          await userCredential.user!.sendEmailVerification();
          await FirebaseAuth.instance.signOut();
          throw FirebaseAuthException(
            code: 'unverified-email', 
            message: 'Account exists but email not verified. Please check your email for verification link.'
          );
        }
        
        await FirebaseAuth.instance.signOut();
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account with this email already exists.'
        );
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'wrong-password') {
        // Email exists with different password
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'An account with this email already exists.'
        );
      }
      // If it's our custom unverified-email exception, rethrow it
      if (e is FirebaseAuthException && e.code == 'unverified-email') {
        rethrow;
      }
      // Otherwise continue with account creation
    }

    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    // Send Firebase email verification
    if (credential.user != null) {
      await credential.user!.sendEmailVerification();
      
      if (context != null && context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! Please check your email and click the verification link before signing in.'),
            duration: Duration(seconds: 8),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
    
    return credential;
  } catch (e) {
    rethrow;
  }
}
