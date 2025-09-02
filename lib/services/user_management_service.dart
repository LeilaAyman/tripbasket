import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class UserManagementService {
  static final _functions = FirebaseFunctions.instance;

  /// Completely delete a user from both Firebase Auth and Firestore
  /// This will also delete related data like bookings
  static Future<Map<String, dynamic>> deleteUserCompletely({
    String? email,
    String? uid,
  }) async {
    try {
      if (email == null && uid == null) {
        throw Exception('Either email or uid must be provided');
      }

      final callable = _functions.httpsCallable('deleteUserCompletely');
      final result = await callable.call({
        if (email != null) 'email': email,
        if (uid != null) 'uid': uid,
      });

      return {
        'success': true,
        'data': result.data,
      };
    } catch (e) {
      print('Error deleting user completely: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Show a dialog to delete a user with confirmation
  static Future<void> showDeleteUserDialog(
    BuildContext context, {
    String? email,
    String? uid,
    required VoidCallback onDeleted,
  }) async {
    final displayText = email ?? uid ?? 'Unknown User';
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Delete User'),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to permanently delete this user?'),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User: $displayText',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'This will delete:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text('• Firebase Auth account'),
                      Text('• Firestore user document'),
                      Text('• All user bookings'),
                      Text('• Related user data'),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'This action cannot be undone!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete Permanently'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _performDeletion(context, email: email, uid: uid, onDeleted: onDeleted);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _performDeletion(
    BuildContext context, {
    String? email,
    String? uid,
    required VoidCallback onDeleted,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Deleting user...'),
          ],
        ),
      ),
    );

    try {
      final result = await deleteUserCompletely(email: email, uid: uid);
      
      // Hide loading dialog
      Navigator.of(context).pop();

      if (result['success']) {
        final details = result['data']['details'];
        final message = StringBuffer('User deletion completed:\n\n');
        
        if (details['authDeleted']) {
          message.writeln('✅ Firebase Auth account deleted');
        } else {
          message.writeln('❌ Firebase Auth account not found/deleted');
        }
        
        if (details['firestoreDeleted']) {
          message.writeln('✅ Firestore document deleted');
        } else {
          message.writeln('❌ Firestore document not found/deleted');
        }
        
        if (details['bookingsDeleted'] > 0) {
          message.writeln('✅ ${details['bookingsDeleted']} bookings deleted');
        }

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Text('Success'),
              ],
            ),
            content: Text(message.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDeleted();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text('Failed to delete user: ${result['error']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text('An error occurred: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}