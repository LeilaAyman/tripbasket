import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/backend/backend.dart';
import '/theme/app_design_system.dart';
import '/components/modern_ui/premium_button.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PremiumTripCard extends StatefulWidget {
  final TripsRecord trip;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onBookPressed;
  final bool isFavorite;
  final bool showBookButton;

  const PremiumTripCard({
    super.key,
    required this.trip,
    this.onFavoritePressed,
    this.onBookPressed,
    this.isFavorite = false,
    this.showBookButton = true,
  });

  @override
  State<PremiumTripCard> createState() => _PremiumTripCardState();
}

class _PremiumTripCardState extends State<PremiumTripCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _favoriteController;
  late AnimationController _shimmerController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _favoriteAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: AppDesignSystem.animationMedium,
      vsync: this,
    );
    
    _favoriteController = AnimationController(
      duration: AppDesignSystem.animationMedium,
      vsync: this,
    );
    
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutBack,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    if (widget.isFavorite) {
      _favoriteController.forward();
    }
    
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _favoriteController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PremiumTripCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite) {
        _favoriteController.forward();
      } else {
        _favoriteController.reverse();
      }
    }
  }

  double get _displayRating {
    if (widget.trip.hasRatingAvg() && widget.trip.ratingAvg > 0) {
      return widget.trip.ratingAvg;
    } else if (widget.trip.hasRating() && widget.trip.rating > 0) {
      return widget.trip.rating;
    }
    return 0.0;
  }

  bool get _hasRating => _displayRating > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) {
              setState(() => _isHovered = true);
              _hoverController.forward();
            },
            onExit: (_) {
              setState(() => _isHovered = false);
              _hoverController.reverse();
            },
            child: GestureDetector(
              onTap: () => _navigateToTripDetails(),
              child: Container(
                margin: EdgeInsets.all(AppDesignSystem.space8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
                  boxShadow: _isHovered 
                      ? AppDesignSystem.elevatedCardShadow 
                      : AppDesignSystem.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
                  child: Stack(
                    children: [
                      _buildBackground(),
                      _buildGradientOverlay(),
                      _buildContent(),
                      _buildShimmerEffect(),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Hero(
        tag: 'trip-image-${widget.trip.reference.id}',
        child: CachedNetworkImage(
          imageUrl: widget.trip.imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppDesignSystem.neutralGray200,
            child: Center(
              child: CircularProgressIndicator(
                color: AppDesignSystem.accentTeal,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppDesignSystem.neutralGray300,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppDesignSystem.neutralGray500,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(AppDesignSystem.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(),
            const Spacer(),
            _buildBottomContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        if (_hasRating) _buildRatingChip(),
        const Spacer(),
        _buildPriceChip(),
      ],
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppDesignSystem.neutralWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppDesignSystem.primaryGold,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            _displayRating.toStringAsFixed(1),
            style: AppDesignSystem.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppDesignSystem.neutralGray800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppDesignSystem.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppDesignSystem.primaryGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '\$${widget.trip.price.toStringAsFixed(0)}',
        style: AppDesignSystem.bodySmall.copyWith(
          fontWeight: FontWeight.w700,
          color: AppDesignSystem.neutralWhite,
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.trip.title,
          style: AppDesignSystem.heading4.copyWith(
            color: AppDesignSystem.neutralWhite,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: AppDesignSystem.accentTeal,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.trip.location,
                style: AppDesignSystem.bodyMedium.copyWith(
                  color: AppDesignSystem.neutralGray200,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (widget.showBookButton) ...[
          const SizedBox(height: 16),
          _buildBookButton(),
        ],
      ],
    );
  }

  Widget _buildBookButton() {
    return PremiumButton(
      text: 'Book Now',
      type: PremiumButtonType.glow,
      size: PremiumButtonSize.medium,
      isFullWidth: true,
      icon: Icons.flight_takeoff_rounded,
      onPressed: widget.onBookPressed ?? () => _navigateToBooking(),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  (_shimmerAnimation.value - 1).clamp(0.0, 1.0),
                  _shimmerAnimation.value.clamp(0.0, 1.0),
                  (_shimmerAnimation.value + 1).clamp(0.0, 1.0),
                ],
                colors: [
                  Colors.transparent,
                  AppDesignSystem.neutralWhite.withOpacity(_isHovered ? 0.1 : 0.0),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: AppDesignSystem.space16,
      right: AppDesignSystem.space16,
      child: Column(
        children: [
          _buildFavoriteButton(),
          const SizedBox(height: 8),
          _buildShareButton(),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return AnimatedBuilder(
      animation: _favoriteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _favoriteAnimation.value,
          child: GestureDetector(
            onTap: widget.onFavoritePressed,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppDesignSystem.neutralWhite.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.isFavorite 
                    ? Icons.favorite_rounded 
                    : Icons.favorite_border_rounded,
                color: widget.isFavorite 
                    ? AppDesignSystem.accentCoral
                    : AppDesignSystem.neutralGray600,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () => _shareTrip(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppDesignSystem.neutralWhite.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.share_rounded,
          color: AppDesignSystem.neutralGray600,
          size: 20,
        ),
      ),
    );
  }

  void _navigateToTripDetails() {
    context.pushNamed(
      'book_trip',
      queryParameters: {
        'tripId': widget.trip.reference.id,
      },
    );
  }

  void _navigateToBooking() {
    context.pushNamed(
      'book_trip',
      queryParameters: {
        'tripId': widget.trip.reference.id,
      },
    );
  }

  void _shareTrip() {
    // Implement share functionality
  }
}