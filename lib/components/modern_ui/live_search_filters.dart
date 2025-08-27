import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/theme/app_design_system.dart';
import '/components/modern_ui/premium_button.dart';

class SearchFilters {
  String query;
  List<String> categories;
  double? minPrice;
  double? maxPrice;
  double? minRating;
  String? location;
  DateTimeRange? dateRange;

  SearchFilters({
    this.query = '',
    this.categories = const [],
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.location,
    this.dateRange,
  });

  SearchFilters copyWith({
    String? query,
    List<String>? categories,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
    DateTimeRange? dateRange,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      categories: categories ?? this.categories,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      location: location ?? this.location,
      dateRange: dateRange ?? this.dateRange,
    );
  }

  bool get hasActiveFilters {
    return query.isNotEmpty ||
           categories.isNotEmpty ||
           minPrice != null ||
           maxPrice != null ||
           minRating != null ||
           location != null ||
           dateRange != null;
  }
}

class LiveSearchFilters extends StatefulWidget {
  final SearchFilters initialFilters;
  final Function(SearchFilters) onFiltersChanged;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const LiveSearchFilters({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
    this.isExpanded = false,
    this.onToggleExpanded,
  });

  @override
  State<LiveSearchFilters> createState() => _LiveSearchFiltersState();
}

class _LiveSearchFiltersState extends State<LiveSearchFilters>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _fadeController;
  late AnimationController _searchController;
  
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _searchAnimation;
  
  late TextEditingController _queryController;
  late SearchFilters _currentFilters;
  
  final List<String> _availableCategories = [
    'Adventure',
    'Beach',
    'Mountain',
    'City',
    'Cultural',
    'Wildlife',
    'Luxury',
    'Budget',
  ];

  @override
  void initState() {
    super.initState();
    
    _currentFilters = widget.initialFilters;
    _queryController = TextEditingController(text: _currentFilters.query);
    
    _expandController = AnimationController(
      duration: AppDesignSystem.animationMedium,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppDesignSystem.animationSlow,
      vsync: this,
    );
    
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: Curves.elasticOut,
    ));

    if (widget.isExpanded) {
      _expandController.forward();
    }
    
    _fadeController.forward();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fadeController.dispose();
    _searchController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LiveSearchFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  void _onQueryChanged() {
    _searchController.forward().then((_) {
      _searchController.reverse();
    });
    
    _updateFilters(_currentFilters.copyWith(query: _queryController.text));
  }

  void _updateFilters(SearchFilters newFilters) {
    setState(() => _currentFilters = newFilters);
    widget.onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.all(AppDesignSystem.space16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
          boxShadow: AppDesignSystem.elevatedCardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: AppDesignSystem.glassMorphism,
              child: Column(
                children: [
                  _buildSearchBar(),
                  _buildExpandedFilters(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(AppDesignSystem.space16),
      child: Row(
        children: [
          Expanded(
            child: _buildSearchField(),
          ),
          SizedBox(width: AppDesignSystem.space12),
          _buildFilterToggle(),
          if (_currentFilters.hasActiveFilters) ...[
            SizedBox(width: AppDesignSystem.space8),
            _buildClearFiltersButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
            boxShadow: _searchAnimation.value > 0 ? [
              BoxShadow(
                color: AppDesignSystem.accentTeal.withOpacity(
                  0.3 * _searchAnimation.value,
                ),
                blurRadius: 20 * _searchAnimation.value,
                offset: const Offset(0, 0),
              ),
            ] : null,
          ),
          child: TextFormField(
            controller: _queryController,
            style: AppDesignSystem.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search amazing destinations...',
              hintStyle: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.neutralGray500,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppDesignSystem.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: AppDesignSystem.accentTeal,
                  size: 20,
                ),
              ),
              suffixIcon: _queryController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppDesignSystem.neutralGray500,
                        size: 20,
                      ),
                      onPressed: () {
                        _queryController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppDesignSystem.neutralWhite.withOpacity(0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
                borderSide: BorderSide(
                  color: AppDesignSystem.accentTeal,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterToggle() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onToggleExpanded?.call();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.isExpanded
              ? AppDesignSystem.primaryBlue
              : AppDesignSystem.neutralWhite.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppDesignSystem.cardShadow,
        ),
        child: AnimatedRotation(
          turns: widget.isExpanded ? 0.5 : 0.0,
          duration: AppDesignSystem.animationMedium,
          child: Icon(
            Icons.tune_rounded,
            color: widget.isExpanded
                ? AppDesignSystem.neutralWhite
                : AppDesignSystem.primaryBlue,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    return PremiumButton(
      text: 'Clear',
      type: PremiumButtonType.ghost,
      size: PremiumButtonSize.small,
      customColor: AppDesignSystem.accentCoral,
      onPressed: _clearAllFilters,
    );
  }

  Widget _buildExpandedFilters() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: Container(
        padding: EdgeInsets.all(AppDesignSystem.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryFilters(),
            SizedBox(height: AppDesignSystem.space24),
            _buildPriceRangeFilter(),
            SizedBox(height: AppDesignSystem.space24),
            _buildRatingFilter(),
            SizedBox(height: AppDesignSystem.space24),
            _buildLocationFilter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: AppDesignSystem.heading5.copyWith(
            color: AppDesignSystem.neutralGray800,
          ),
        ),
        SizedBox(height: AppDesignSystem.space12),
        Wrap(
          spacing: AppDesignSystem.space8,
          runSpacing: AppDesignSystem.space8,
          children: _availableCategories.map((category) {
            final isSelected = _currentFilters.categories.contains(category);
            return GestureDetector(
              onTap: () => _toggleCategory(category),
              child: AnimatedContainer(
                duration: AppDesignSystem.animationFast,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppDesignSystem.primaryBlue
                      : AppDesignSystem.neutralWhite.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppDesignSystem.primaryBlue
                        : AppDesignSystem.neutralGray300,
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: isSelected
                        ? AppDesignSystem.neutralWhite
                        : AppDesignSystem.neutralGray700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: AppDesignSystem.heading5.copyWith(
            color: AppDesignSystem.neutralGray800,
          ),
        ),
        SizedBox(height: AppDesignSystem.space12),
        Row(
          children: [
            Expanded(
              child: _buildPriceField(
                label: 'Min',
                value: _currentFilters.minPrice,
                onChanged: (value) => _updateFilters(
                  _currentFilters.copyWith(minPrice: value),
                ),
              ),
            ),
            SizedBox(width: AppDesignSystem.space16),
            Expanded(
              child: _buildPriceField(
                label: 'Max',
                value: _currentFilters.maxPrice,
                onChanged: (value) => _updateFilters(
                  _currentFilters.copyWith(maxPrice: value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required String label,
    required double? value,
    required Function(double?) onChanged,
  }) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: TextInputType.number,
      style: AppDesignSystem.bodySmall,
      decoration: InputDecoration(
        labelText: label,
        prefixText: '\$',
        filled: true,
        fillColor: AppDesignSystem.neutralWhite.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (text) {
        final parsedValue = double.tryParse(text);
        onChanged(parsedValue);
      },
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum Rating',
          style: AppDesignSystem.heading5.copyWith(
            color: AppDesignSystem.neutralGray800,
          ),
        ),
        SizedBox(height: AppDesignSystem.space12),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1.0;
            final isSelected = (_currentFilters.minRating ?? 0) >= rating;
            
            return GestureDetector(
              onTap: () => _updateFilters(
                _currentFilters.copyWith(
                  minRating: rating == _currentFilters.minRating ? null : rating,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: AppDesignSystem.primaryGold,
                  size: 28,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppDesignSystem.heading5.copyWith(
            color: AppDesignSystem.neutralGray800,
          ),
        ),
        SizedBox(height: AppDesignSystem.space12),
        TextFormField(
          initialValue: _currentFilters.location ?? '',
          style: AppDesignSystem.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Enter location...',
            prefixIcon: Icon(
              Icons.location_on_rounded,
              color: AppDesignSystem.accentTeal,
              size: 20,
            ),
            filled: true,
            fillColor: AppDesignSystem.neutralWhite.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusMedium),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) => _updateFilters(
            _currentFilters.copyWith(location: value.isEmpty ? null : value),
          ),
        ),
      ],
    );
  }

  void _toggleCategory(String category) {
    HapticFeedback.selectionClick();
    final categories = List<String>.from(_currentFilters.categories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    _updateFilters(_currentFilters.copyWith(categories: categories));
  }

  void _clearAllFilters() {
    HapticFeedback.mediumImpact();
    _queryController.clear();
    _updateFilters(SearchFilters());
  }
}