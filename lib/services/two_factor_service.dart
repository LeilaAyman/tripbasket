import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class TwoFactorService {
  static const int _codeLength = 6;
  static const Duration _codeExpiration = Duration(minutes: 10);

  /// Generate a random 6-digit verification code
  static String _generateCode() {
    final random = Random();
    return List.generate(_codeLength, (_) => random.nextInt(10)).join();
  }

  /// Send verification code to user's email
  static Future<bool> sendVerificationCode(String email) async {
    try {
      final code = _generateCode();
      final expiresAt = DateTime.now().add(_codeExpiration);

      // Store code in Firestore
      await FirebaseFirestore.instance
          .collection('verification_codes')
          .doc(email)
          .set({
        'code': code,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
      });

      // In a real app, you would send this via email service
      // For now, we'll show it in a debug dialog
      print('Verification code for $email: $code');

      return true;
    } catch (e) {
      print('Error sending verification code: $e');
      return false;
    }
  }

  /// Verify the code entered by user
  static Future<bool> verifyCode(String email, String enteredCode) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('verification_codes')
          .doc(email)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data()!;
      final storedCode = data['code'] as String;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final used = data['used'] as bool;

      // Check if code is expired
      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      // Check if code was already used
      if (used) {
        return false;
      }

      // Check if code matches
      if (storedCode != enteredCode) {
        return false;
      }

      // Mark code as used
      await doc.reference.update({'used': true});

      return true;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  /// Show 2FA verification dialog
  static Future<bool> show2FADialog(BuildContext context, String email) async {
    // Send verification code
    final codeSent = await sendVerificationCode(email);
    if (!codeSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification code'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return false;
    }

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _TwoFactorDialog(email: email);
      },
    ) ?? false;
  }
}

class _TwoFactorDialog extends StatefulWidget {
  final String email;

  const _TwoFactorDialog({required this.email});

  @override
  State<_TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<_TwoFactorDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final isValid = await TwoFactorService.verifyCode(
      widget.email,
      _codeController.text,
    );

    setState(() {
      _isVerifying = false;
    });

    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = 'Invalid or expired verification code';
      });
    }
  }

  Future<void> _resendCode() async {
    final success = await TwoFactorService.sendVerificationCode(widget.email);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New verification code sent'),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend code'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.security, color: FlutterFlowTheme.of(context).primary),
          SizedBox(width: 8),
          Text(
            'Two-Factor Authentication',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We\'ve sent a 6-digit verification code to:',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            widget.email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Verification Code',
              hintText: 'Enter 6-digit code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2,
                ),
              ),
              errorText: _errorMessage,
              prefixIcon: Icon(Icons.pin),
            ),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Didn\'t receive the code? ',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              TextButton(
                onPressed: _resendCode,
                child: Text(
                  'Resend',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ),
        FFButtonWidget(
          onPressed: _isVerifying ? null : _verifyCode,
          text: _isVerifying ? 'Verifying...' : 'Verify',
          options: FFButtonOptions(
            width: 100,
            height: 40,
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            color: FlutterFlowTheme.of(context).primary,
            textStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            borderSide: BorderSide(
              color: Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }
}