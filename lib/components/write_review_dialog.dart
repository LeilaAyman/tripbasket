import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';

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
  double _overallRating = 0.0;
  double _serviceRating = 0.0;
  double _communicationRating = 0.0;
  double _valueRating = 0.0;
  bool _isSubmitting = false;

  static const int maxLength = 400;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _overallRating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get canSubmit => _overallRating > 0;

  Future<void> _submitReview() async {
    if (!canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Theme.of(context).colorScheme.error,
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
          'rating': _overallRating,
          'comment': _commentController.text.trim(),
        });
      } else {
        // Create new review
        final reviewData = createReviewsRecordData(
          tripReference: widget.tripRecord.reference,
          userReference: currentUserReference,
          userName: userData.displayName.isNotEmpty ? userData.displayName : userData.name,
          userPhoto: userData.photoUrl,
          rating: _overallRating,
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
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
        'rating_avg': averageRating,
        'rating_count': reviews.length,
      });
    } catch (e) {
      print('Error updating trip average rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textLength = _commentController.text.length;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.existingReview != null ? 'Edit Review' : 'Write Review',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.existingReview != null 
                                ? 'Update your experience'
                                : 'Share your experience',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                
                AppTheme.gap24,
                
                // Trip title
                Text(
                  widget.tripRecord.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                AppTheme.gap24,
                
                // Overall Rating (required)
                Text(
                  'Overall Rating *',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                AppTheme.gap8,
                
                RatingBar.builder(
                  initialRating: _overallRating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: AppTheme.seed,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _overallRating = rating;
                    });
                  },
                  itemSize: 28.0,
                  glow: true,
                  glowColor: AppTheme.seed.withOpacity(0.3),
                ),
                
                AppTheme.gap24,
                
                // Optional category ratings
                Text(
                  'Category Ratings (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                AppTheme.gap16,
                
                // Service Quality
                _buildCategoryRating('Service Quality', _serviceRating, (rating) {
                  setState(() => _serviceRating = rating);
                }),
                
                AppTheme.gap8,
                
                // Communication
                _buildCategoryRating('Communication', _communicationRating, (rating) {
                  setState(() => _communicationRating = rating);
                }),
                
                AppTheme.gap8,
                
                // Value
                _buildCategoryRating('Value', _valueRating, (rating) {
                  setState(() => _valueRating = rating);
                }),
                
                AppTheme.gap24,
                
                // Experience text
                Text(
                  'Your Experience (Optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                AppTheme.gap8,
                
                TextField(
                  controller: _commentController,
                  maxLength: maxLength,
                  minLines: 3,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Share your experience with this trip… (optional)',
                    helperText: 'A rating is all you need, but reviews help others!',
                    counterText: '$textLength/$maxLength',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                
                AppTheme.gap24,
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    
                    AppTheme.gap16,
                    
                    Expanded(
                      child: FilledButton(
                        onPressed: canSubmit && !_isSubmitting ? _submitReview : null,
                        child: _isSubmitting 
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(widget.existingReview != null ? 'Update' : 'Submit'),
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

  Widget _buildCategoryRating(String label, double rating, Function(double) onRatingUpdate) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          flex: 3,
          child: RatingBar.builder(
            initialRating: rating,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: AppTheme.seed,
            ),
            onRatingUpdate: onRatingUpdate,
            itemSize: 20.0,
          ),
        ),
      ],
    );
  }
}