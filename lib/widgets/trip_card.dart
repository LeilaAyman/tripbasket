import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/widgets/price_text.dart';
import '/services/favorites_service.dart';
import '/components/interactive_trip_rating.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class TripCard extends StatefulWidget {
  final TripsRecord trip;
  final bool isWeb;
  
  const TripCard({
    required this.trip,
    this.isWeb = false,
    super.key,
  });

  @override
  State<TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<TripCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  Timer? _slideTimer;
  int _currentImageIndex = 0;
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;

  List<String> get _images {
    final images = <String>[];
    if (widget.trip.image.isNotEmpty) {
      images.add(widget.trip.image);
    }
    if (images.isEmpty) {
      images.add('https://images.unsplash.com/photo-1528114039593-4366cc08227d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8aXRhbHl8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60');
    }
    return images;
  }

  @override
  void initState() {
    super.initState();
    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _elevationController.dispose();
    super.dispose();
  }

  void _startImageSlideshow() {
    if (!widget.isWeb || _images.length <= 1) return;
    
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted && _isHovered) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _images.length;
        });
      }
    });
  }

  void _stopImageSlideshow() {
    _slideTimer?.cancel();
  }

  Future<bool> _isFavorite() async {
    if (currentUserReference == null) return false;
    final doc = FavoritesService.docFor(currentUserReference!, widget.trip.reference);
    final snapshot = await doc.get();
    return snapshot.exists;
  }

  Future<void> _toggleFavorite() async {
    if (currentUserReference == null) return;
    final doc = FavoritesService.docFor(currentUserReference!, widget.trip.reference);
    final snapshot = await doc.get();
    
    if (snapshot.exists) {
      await FavoritesService.remove(currentUserReference!, widget.trip.reference);
    } else {
      await FavoritesService.add(currentUserReference!, widget.trip.reference);
    }
  }

  void _showWriteReviewDialog() {
    if (currentUserReference == null) return;
    
    final TextEditingController reviewController = TextEditingController();
    double rating = 5.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip: ${widget.trip.title}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text('Rating:'),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = (index + 1).toDouble();
                      });
                    },
                    child: Icon(
                      Icons.star,
                      color: index < rating ? Color(0xFFF2D83B) : Colors.grey[300],
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (reviewController.text.isNotEmpty) {
                  await _submitReview(rating, reviewController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Review submitted successfully!')),
                  );
                }
              },
              child: Text('Submit Review'),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFD76B30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview(double rating, String reviewText) async {
    if (currentUserReference == null) return;
    
    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'trip_reference': widget.trip.reference,
        'user_reference': currentUserReference,
        'rating': rating,
        'review_text': reviewText,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  void _onHover(bool isHovered) {
    if (!widget.isWeb) return;
    
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _elevationController.forward();
      _startImageSlideshow();
    } else {
      _elevationController.reverse();
      _stopImageSlideshow();
      setState(() {
        _currentImageIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isWeb) {
      return _buildWebCard();
    } else {
      return _buildMobileCard();
    }
  }

  Widget _buildWebCard() {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Material(
            elevation: _elevationAnimation.value,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.pushNamed(
                'bookings',
                queryParameters: {
                  'tripref': serializeParam(
                    widget.trip.reference,
                    ParamType.DocumentReference,
                  ),
                }.withoutNulls,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWebImage(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWebTitle(),
                          const SizedBox(height: 8),
                          _buildWebLocation(),
                          const SizedBox(height: 12),
                          _buildWebRating(),
                          const SizedBox(height: 12),
                          _buildWebPrice(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWebImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: CachedNetworkImage(
              key: ValueKey(_currentImageIndex),
              imageUrl: _images[_currentImageIndex],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 200,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD76B30).withOpacity(0.3),
                      const Color(0xFFF2D83B).withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 48),
                ),
              ),
            ),
          ),
          // Price pill top-right
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: PriceText(
                widget.trip.price,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Favorite heart - only on hover
          AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Positioned(
              top: 12,
              left: 12,
              child: FutureBuilder<bool>(
                future: _isFavorite(),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  return GestureDetector(
                    onTap: () async {
                      await _toggleFavorite();
                      setState(() {}); // Refresh the widget
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTitle() {
    return Text(
      widget.trip.title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildWebLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.trip.location,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWebRating() {
    return Row(
      children: [
        RatingBarIndicator(
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Color(0xFFF2D83B),
          ),
          direction: Axis.horizontal,
          rating: 4.7,
          unratedColor: Colors.grey[300],
          itemCount: 5,
          itemSize: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '4.7',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => context.pushNamed('reviews', queryParameters: {
            'tripId': widget.trip.reference.id,
          }),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Reviews',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => _showWriteReviewDialog(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Write',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildWebPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PriceText(
          widget.trip.price,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          'per person',
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCard() {
    // Keep existing mobile design - reuse from home_widget.dart
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
      child: InkWell(
        onTap: () => context.pushNamed(
          'bookings',
          queryParameters: {
            'tripref': serializeParam(
              widget.trip.reference,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        ),
        child: Container(
          width: 270.0,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Color(0x230F1113),
                offset: Offset(0.0, 4.0),
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: FlutterFlowTheme.of(context).primaryBackground,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Hero(
                tag: 'tripImage_\${widget.trip.reference.id}',
                transitionOnUserGestures: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.trip.image.isNotEmpty 
                            ? widget.trip.image
                            : 'https://images.unsplash.com/photo-1528114039593-4366cc08227d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8aXRhbHl8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                        width: double.infinity,
                        height: 200.0,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          return Container(
                            width: double.infinity,
                            height: 200.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFD76B30).withOpacity(0.3),
                                  Color(0xFFF2D83B).withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 16.0,
                        right: 16.0,
                        child: FutureBuilder<bool>(
                          future: _isFavorite(),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;
                            return GestureDetector(
                              onTap: () async {
                                await _toggleFavorite();
                                setState(() {}); // Refresh the widget
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: Container(
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: Color(0xFFD76B30), // Orange button
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                            child: PriceText(
                              widget.trip.price,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                      child: Text(
                        widget.trip.location,
                        style: GoogleFonts.poppins(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          RatingBarIndicator(
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Color(0xFFF2D83B), // Bright yellow stars
                            ),
                            direction: Axis.horizontal,
                            rating: 4.0,
                            unratedColor: FlutterFlowTheme.of(context).secondaryText,
                            itemCount: 5,
                            itemSize: 16.0,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                            child: Text(
                              '4.7',
                              style: GoogleFonts.poppins(
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: InteractiveTripRating(
                        tripRecord: widget.trip,
                        onRatingChanged: (rating) {
                          print('Rating changed to: \$rating');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}