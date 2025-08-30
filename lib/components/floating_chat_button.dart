import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/components/live_chat_widget.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  void _openChat(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.bottomRight,
        insetPadding: const EdgeInsets.only(
          right: 20,
          bottom: 20,
          left: 50,
          top: 50,
        ),
        child: const LiveChatWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () => _openChat(context),
        backgroundColor: const Color(0xFFD76B30),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.chat),
        label: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}