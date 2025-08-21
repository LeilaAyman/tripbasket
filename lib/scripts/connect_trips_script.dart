import 'package:firebase_core/firebase_core.dart';
import '../utils/connect_trips_to_agencies.dart';
import '../firebase_options.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('🔄 Starting trip-agency connection process...');
  
  // Connect trips to agencies
  await connectTripsToAgencies();
  
  print('✅ Trip-agency connection completed!');
}
