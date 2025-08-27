import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/fix_existing_ratings.dart';

class DebugRatingsPage extends StatefulWidget {
  const DebugRatingsPage({super.key});

  @override
  State<DebugRatingsPage> createState() => _DebugRatingsPageState();
}

class _DebugRatingsPageState extends State<DebugRatingsPage> {
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Debug: Fix Trip Ratings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating Fix Utility',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This utility will:\n'
                      '• Find all trips in the database\n'
                      '• Calculate average ratings from existing reviews\n'
                      '• Update rating_avg and rating_count fields\n'
                      '• Fix display issues where reviews exist but ratings don\'t show',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FFButtonWidget(
                      onPressed: _isRunning ? null : _runFix,
                      text: _isRunning ? 'Running...' : 'Fix All Trip Ratings',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: _isRunning 
                            ? Colors.grey 
                            : FlutterFlowTheme.of(context).primary,
                        textStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    if (_isRunning) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Processing all trips... Please wait.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to use',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Click "Fix All Trip Ratings" button above\n'
                      '2. Wait for the process to complete\n'
                      '3. Go back to the main app and check if ratings now display correctly\n'
                      '4. You should see actual ratings instead of "Be the first to share your review" for trips that have reviews',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runFix() async {
    setState(() {
      _isRunning = true;
    });

    try {
      await FixExistingRatings.runFix();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All trip ratings have been fixed successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error fixing ratings: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }
}