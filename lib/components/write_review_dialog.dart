import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class WriteReviewDialog extends StatefulWidget {
  const WriteReviewDialog({
    super.key,
    required this.tripRecord,
    this.existingReview,
  });

  final TripsRecord tripRecord;
  final ReviewsRecord? existingReview;

  @override
  State<WriteReviewDialog> createState() => _WriteReviewDialogState();
}

class _WriteReviewDialogState extends State<WriteReviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user data
      final userData = await UsersRecord.getDocumentOnce(currentUserReference!);

      if (widget.existingReview != null) {
        // Update existing review
        await widget.existingReview!.reference.update({
          'rating': _rating,
          'comment': _commentController.text.trim(),
        });
      } else {
        // Create new review
        final reviewData = createReviewsRecordData(
          tripReference: widget.tripRecord.reference,
          userReference: currentUserReference,
          userName: userData.displayName.isNotEmpty ? userData.displayName : userData.name,
          userPhoto: userData.photoUrl,
          rating: _rating,
          comment: _commentController.text.trim(),
          createdAt: DateTime.now(),
          helpfulCount: 0,
          tripTitle: widget.tripRecord.title,
        );

        await ReviewsRecord.collection.add(reviewData);
      }

      // Update trip's average rating
      await _updateTripAverageRating();

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingReview != null 
                ? 'Review updated successfully!' 
                : 'Review submitted successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).primary,
          ),
        );
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review. Please try again.'),
            backgroundColor: FlutterFlowTheme.of(context).error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _updateTripAverageRating() async {
    try {
      final reviews = await queryReviewsRecordOnce(
        queryBuilder: (q) => q.where('trip_reference', isEqualTo: widget.tripRecord.reference),
      );

      double averageRating = 0.0;
      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(0.0, (sum, review) => sum + review.rating);
        averageRating = totalRating / reviews.length;
      }

      await widget.tripRecord.reference.update({
        'rating': averageRating,
      });
    } catch (e) {
      print('Error updating trip average rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existingReview != null 
                        ? 'Edit Your Review' 
                        : 'Write a Review',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Trip title
            Text(
              widget.tripRecord.title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
                letterSpacing: 0.0,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Rating section
            Text(
              'Your Rating',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
            ),
            
            SizedBox(height: 12),
            
            Center(
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Color(0xFFF2D83B),
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
                itemSize: 40.0,
                glow: true,
                glowColor: Color(0xFFF2D83B).withOpacity(0.3),
              ),
            ),
            
            if (_rating > 0) ...[
              SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(_rating),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).primary,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 24),
            
            // Comment section
            Text(
              'Your Review (Optional)',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.0,
              ),
            ),
            
            SizedBox(height: 12),
            
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your experience with this trip...',
                hintStyle: GoogleFonts.poppins(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).alternate,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: FlutterFlowTheme.of(context).primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                letterSpacing: 0.0,
              ),
            ),
            
            SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FFButtonWidget(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancel',
                    options: FFButtonOptions(
                      height: 44,
                      padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: Colors.transparent,
                      textStyle: GoogleFonts.poppins(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.0,
                      ),
                      elevation: 0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                Expanded(
                  child: FFButtonWidget(
                    onPressed: _isSubmitting ? null : _submitReview,
                    text: _isSubmitting 
                        ? 'Submitting...' 
                        : (widget.existingReview != null ? 'Update' : 'Submit'),
                    options: FFButtonOptions(
                      height: 44,
                      padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent!';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.0) return 'Good';
    if (rating >= 2.0) return 'Fair';
    return 'Poor';
  }
}
