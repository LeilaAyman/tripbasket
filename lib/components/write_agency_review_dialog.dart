import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class WriteAgencyReviewDialog extends StatefulWidget {
  final AgenciesRecord agencyRecord;
  final AgencyReviewsRecord? existingReview;

  const WriteAgencyReviewDialog({
    super.key,
    required this.agencyRecord,
    this.existingReview,
  });

  @override
  State<WriteAgencyReviewDialog> createState() => _WriteAgencyReviewDialogState();
}

class _WriteAgencyReviewDialogState extends State<WriteAgencyReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  double _serviceQuality = 5.0;
  double _communication = 5.0;
  double _valueForMoney = 5.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _commentController.text = widget.existingReview!.comment;
      _rating = widget.existingReview!.rating;
      _serviceQuality = widget.existingReview!.hasServiceQuality() 
          ? widget.existingReview!.serviceQuality 
          : 5.0;
      _communication = widget.existingReview!.hasCommunication() 
          ? widget.existingReview!.communication 
          : 5.0;
      _valueForMoney = widget.existingReview!.hasValueForMoney() 
          ? widget.existingReview!.valueForMoney 
          : 5.0;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.existingReview != null ? 'Edit Review' : 'Write Review',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(
                        Icons.close,
                        color: FlutterFlowTheme.of(context).secondaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Agency Name
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFD76B30).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.business,
                        color: Color(0xFFD76B30),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.agencyRecord.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: FlutterFlowTheme.of(context).primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Overall Rating
                Text(
                  'Overall Rating',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 32,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Color(0xFFF2D83B),
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _rating = rating;
                        });
                      },
                    ),
                    SizedBox(width: 12),
                    Text(
                      _rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Service Quality Rating
                Text(
                  'Service Quality',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: _serviceQuality,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 24,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Color(0xFFF2D83B),
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _serviceQuality = rating;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    Text(
                      _serviceQuality.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Communication Rating
                Text(
                  'Communication',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: _communication,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 24,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Color(0xFFF2D83B),
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _communication = rating;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    Text(
                      _communication.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Value for Money Rating
                Text(
                  'Value for Money',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: _valueForMoney,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 24,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Color(0xFFF2D83B),
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _valueForMoney = rating;
                        });
                      },
                    ),
                    SizedBox(width: 8),
                    Text(
                      _valueForMoney.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Comment Field
                Text(
                  'Your Experience',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this agency...',
                    hintStyle: GoogleFonts.poppins(
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD76B30),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: FlutterFlowTheme.of(context).primaryBackground,
                  ),
                  style: GoogleFonts.poppins(
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: () => Navigator.of(context).pop(false),
                        text: 'Cancel',
                        options: FFButtonOptions(
                          height: 50,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle: GoogleFonts.poppins(
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: FFButtonWidget(
                        onPressed: _isSubmitting ? null : _submitReview,
                        text: _isSubmitting 
                            ? 'Submitting...' 
                            : (widget.existingReview != null ? 'Update' : 'Submit'),
                        options: FFButtonOptions(
                          height: 50,
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: Color(0xFFD76B30),
                          textStyle: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          disabledColor: FlutterFlowTheme.of(context).secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (!loggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to submit a review')),
      );
      return;
    }

    if (currentUserReference == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User reference is null. Please try signing out and back in.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.existingReview != null) {
        // Update existing review
        await widget.existingReview!.reference.update({
          'rating': _rating,
          'service_quality': _serviceQuality,
          'communication': _communication,
          'value_for_money': _valueForMoney,
          'comment': _commentController.text.trim(),
          'updated_at': getCurrentTimestamp,
        });
      } else {
        // Create new review
        final reviewData = {
          'agency_reference': widget.agencyRecord.reference,
          'agency_name': widget.agencyRecord.name,
          'user_reference': currentUserReference,
          'rating': _rating,
          'service_quality': _serviceQuality,
          'communication': _communication,
          'value_for_money': _valueForMoney,
          'comment': _commentController.text.trim(),
          'created_at': getCurrentTimestamp,
          'updated_at': getCurrentTimestamp,
        };
        
        print('Attempting to create review with data: $reviewData');
        await AgencyReviewsRecord.collection.add(reviewData);
        print('Review created successfully');
      }

      // Update agency's average rating
      await _updateAgencyAverageRating();

      Navigator.of(context).pop(true);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.existingReview != null 
              ? 'Review updated successfully!' 
              : 'Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateAgencyAverageRating() async {
    try {
      final reviews = await queryAgencyReviewsRecordOnce(
        queryBuilder: (q) => q.where('agency_reference', isEqualTo: widget.agencyRecord.reference),
      );

      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<double>(0, (sum, review) => sum + review.rating);
        final averageRating = totalRating / reviews.length;

        await widget.agencyRecord.reference.update({
          'average_rating': averageRating,
          'total_reviews': reviews.length,
        });
      }
    } catch (e) {
      print('Error updating agency average rating: $e');
    }
  }
}
