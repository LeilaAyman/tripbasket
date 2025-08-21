import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';

/// Debug widget to understand login flow issues
class DebugLoginFlow extends StatefulWidget {
  @override
  _DebugLoginFlowState createState() => _DebugLoginFlowState();
}

class _DebugLoginFlowState extends State<DebugLoginFlow> {
  String debugInfo = 'Starting debug...';
  
  @override
  void initState() {
    super.initState();
    _runDebugChecks();
  }
  
  Future<void> _runDebugChecks() async {
    setState(() {
      debugInfo = 'Running debug checks...\n';
    });
    
    // Check 1: Firebase Auth Status
    final currentUser = authManager.currentUser;
    _log('=== FIREBASE AUTH STATUS ===');
    _log('Current User: ${currentUser?.uid}');
    _log('Email: ${currentUser?.email}');
    _log('Email Verified: ${currentUser?.emailVerified}');
    _log('Logged In: ${authManager.loggedIn}');
    
    // Check 2: User Document Status
    _log('\n=== USER DOCUMENT STATUS ===');
    final userDoc = currentUserDocument;
    _log('User Document: ${userDoc != null ? 'EXISTS' : 'NULL'}');
    if (userDoc != null) {
      _log('Document Email: ${userDoc.email}');
      _log('Document Roles: ${userDoc.role}');
      _log('Agency Reference: ${userDoc.agencyReference}');
    }
    
    // Check 3: Try to manually load user document
    _log('\n=== MANUAL USER DOCUMENT LOAD ===');
    if (currentUser != null) {
      try {
        final userRef = UsersRecord.collection.doc(currentUser.uid);
        final userSnapshot = await userRef.get();
        _log('Document exists in Firestore: ${userSnapshot.exists}');
        if (userSnapshot.exists) {
          final data = userSnapshot.data();
          _log('Document data: $data');
        }
      } catch (e) {
        _log('Error loading user document: $e');
      }
    }
    
    // Check 4: App State
    _log('\n=== APP STATE ===');
    _log('App State Logged In: ${AppStateNotifier.instance.loggedIn}');
    _log('App State Loading: ${AppStateNotifier.instance.loading}');
    _log('Show Splash: ${AppStateNotifier.instance.showSplashImage}');
  }
  
  void _log(String message) {
    setState(() {
      debugInfo += '$message\n';
    });
    print('DEBUG: $message');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Debug')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Flow Debug Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                debugInfo,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _runDebugChecks,
              child: Text('Refresh Debug Info'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authManager.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                } catch (e) {
                  _log('Sign out error: $e');
                }
              },
              child: Text('Sign Out'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
