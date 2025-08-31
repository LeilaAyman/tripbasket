import 'package:cloud_firestore/cloud_firestore.dart';

class ChatCleanupUtils {
  static Future<void> deleteOldChats() async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayTimestamp = Timestamp.fromDate(yesterday);
      
      // Get all chat rooms that haven't been active since yesterday
      final oldChatRooms = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('lastMessageTime', isLessThan: yesterdayTimestamp)
          .get();
      
      print('Found ${oldChatRooms.docs.length} old chat rooms to delete');
      
      // Delete each old chat room and its messages
      for (final chatRoomDoc in oldChatRooms.docs) {
        await deleteChatRoomWithMessages(chatRoomDoc.id);
      }
      
      print('Successfully deleted ${oldChatRooms.docs.length} old chat rooms');
    } catch (e) {
      print('Error deleting old chats: $e');
    }
  }
  
  static Future<void> deleteAllChatsAtEndOfDay() async {
    try {
      // Get the start of today (midnight)
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfTodayTimestamp = Timestamp.fromDate(startOfToday);
      
      // Get all chat rooms created before today
      final todaysChats = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('createdAt', isLessThan: startOfTodayTimestamp)
          .get();
      
      print('Found ${todaysChats.docs.length} chat rooms from before today to delete');
      
      // Delete each chat room and its messages
      for (final chatRoomDoc in todaysChats.docs) {
        await deleteChatRoomWithMessages(chatRoomDoc.id);
      }
      
      print('Successfully deleted all chats from before today');
    } catch (e) {
      print('Error deleting end-of-day chats: $e');
    }
  }
  
  static Future<void> deleteChatRoomWithMessages(String chatRoomId) async {
    try {
      // Delete all messages in the chat room
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .get();
      
      // Use batch delete for better performance
      final batch = FirebaseFirestore.instance.batch();
      
      for (final messageDoc in messagesQuery.docs) {
        batch.delete(messageDoc.reference);
      }
      
      // Delete the chat room document
      batch.delete(FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId));
      
      // Commit the batch
      await batch.commit();
      
      print('Deleted chat room $chatRoomId with ${messagesQuery.docs.length} messages');
    } catch (e) {
      print('Error deleting chat room $chatRoomId: $e');
    }
  }
  
  // Schedule daily cleanup (call this from a timer or cloud function)
  static Future<void> scheduleDailyCleanup() async {
    try {
      final now = DateTime.now();
      
      // Check if it's past 11:59 PM (end of day)
      if (now.hour == 23 && now.minute >= 59) {
        print('Running end-of-day chat cleanup...');
        await deleteAllChatsAtEndOfDay();
        print('End-of-day chat cleanup completed');
      }
    } catch (e) {
      print('Error in scheduled cleanup: $e');
    }
  }
  
  // Manual cleanup method for admin dashboard
  static Future<void> manualCleanupOldChats({int daysOld = 1}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);
      
      // Get all chat rooms older than the cutoff
      final oldChatRooms = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .where('createdAt', isLessThan: cutoffTimestamp)
          .get();
      
      print('Found ${oldChatRooms.docs.length} chat rooms older than $daysOld days');
      
      // Delete each old chat room and its messages
      for (final chatRoomDoc in oldChatRooms.docs) {
        await deleteChatRoomWithMessages(chatRoomDoc.id);
      }
      
      return Future.value();
    } catch (e) {
      print('Error in manual cleanup: $e');
      rethrow;
    }
  }
}