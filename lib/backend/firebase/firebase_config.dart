import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCX0GVpCxSNBRyUsmSqWlhg_x5lVazIBx4",
            authDomain: "tripbasket-sctkxj.firebaseapp.com",
            projectId: "tripbasket-sctkxj",
            storageBucket: "tripbasket-sctkxj.firebasestorage.app",
            messagingSenderId: "950681576261",
            appId: "1:950681576261:web:bcac7dfa1ec12b33f5942c",
            measurementId: "G-1458DL741S"));
  } else {
    await Firebase.initializeApp();
  }
}
