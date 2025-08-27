import 'package:flutter/material.dart';
import '/theme/app_design_system.dart';

enum PremiumButtonType { primary, secondary, ghost, glow }
enum PremiumButtonSize { small, medium, large }

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonType type;
  final PremiumButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? customColor;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = PremiumButtonType.primary,
    this.size = PremiumButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.customColor,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late AnimationController _glowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: AppDesignSystem.animationMedium,
      vsync: this,
    );
    _tapController = AnimationController(
      duration: AppDesignSystem.animationFast,
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.type == PremiumButtonType.glow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  double get _buttonHeight {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return 40;
      case PremiumButtonSize.medium:
        return 48;
      case PremiumButtonSize.large:
        return 56;
    }
  }

  EdgeInsets get _buttonPadding {
    switch (widget.size) {
      case PremiumButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case PremiumButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case PremiumButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle get _textStyle {
    final baseStyle = widget.size == PremiumButtonSize.large 
        ? AppDesignSystem.buttonLarge 
        : AppDesignSystem.buttonMedium;
        
    return baseStyle.copyWith(
      color: _getTextColor(),
    );
  }

  Color _getTextColor() {
    switch (widget.type) {
      case PremiumButtonType.primary:
      case PremiumButtonType.glow:
        return AppDesignSystem.neutralWhite;
      case PremiumButtonType.secondary:
        return AppDesignSystem.primaryBlue;
      case PremiumButtonType.ghost:
        return widget.customColor ?? AppDesignSystem.primaryBlue;
    }
  }

  Decoration _getDecoration() {
    final isDisabled = widget.onPressed == null;
    
    switch (widget.type) {
      case PremiumButtonType.primary:
        return BoxDecoration(
          gradient: isDisabled 
              ? LinearGradient(colors: [
                  AppDesignSystem.neutralGray300,
                  AppDesignSystem.neutralGray400,
                ])
              : AppDesignSystem.primaryGradient,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
          boxShadow: _isHovered && !isDisabled
              ? [
                  BoxShadow(
                    color: AppDesignSystem.accentTeal.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : AppDesignSystem.cardShadow,
        );

      case PremiumButtonType.secondary:
        return BoxDecoration(
          color: isDisabled 
              ? AppDesignSystem.neutralGray200
              : AppDesignSystem.neutralWhite,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
          border: Border.all(
            color: isDisabled 
                ? AppDesignSystem.neutralGray300
                : AppDesignSystem.primaryBlue,
            width: 2,
          ),
          boxShadow: _isHovered && !isDisabled
              ? AppDesignSystem.elevatedCardShadow
              : AppDesignSystem.cardShadow,
        );

      case PremiumButtonType.ghost:
        return BoxDecoration(
          color: _isHovered && !isDisabled
              ? (widget.customColor ?? AppDesignSystem.primaryBlue).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
        );

      case PremiumButtonType.glow:
        return BoxDecoration(
          gradient: isDisabled 
              ? LinearGradient(colors: [
                  AppDesignSystem.neutralGray300,
                  AppDesignSystem.neutralGray400,
                ])
              : AppDesignSystem.goldGradient,
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusLarge),
          boxShadow: !isDisabled ? [
            BoxShadow(
              color: AppDesignSystem.primaryGold.withOpacity(
                0.3 + (_glowAnimation.value * 0.4)
              ),
              blurRadius: 20 + (_glowAnimation.value * 20),
              offset: const Offset(0, 8),
            ),
          ] : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
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
              onTapDown: (_) => _tapController.forward(),
              onTapUp: (_) => _tapController.reverse(),
              onTapCancel: () => _tapController.reverse(),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: AnimatedContainer(
                duration: AppDesignSystem.animationMedium,
                curve: Curves.easeInOut,
                width: widget.isFullWidth ? double.infinity : null,
                height: _buttonHeight,
                padding: _buttonPadding,
                decoration: _getDecoration(),
                child: Row(
                  mainAxisSize: widget.isFullWidth 
                      ? MainAxisSize.max 
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getTextColor(),
                          ),
                        ),
                      )
                    else ...[
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: widget.size == PremiumButtonSize.large ? 20 : 18,
                          color: _getTextColor(),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: _textStyle,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}