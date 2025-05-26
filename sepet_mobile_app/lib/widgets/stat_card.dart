import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    this.gradient,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              onTapDown: (_) {
                _animationController.reverse();
              },
              onTapUp: (_) {
                _animationController.forward();
              },
              onTapCancel: () {
                _animationController.forward();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  color:
                      widget.gradient == null ? widget.backgroundColor : null,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient != null
                          ? (widget.gradient!.colors.first).withOpacity(0.2)
                          : AppColors.shadowColor,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.gradient != null
                            ? Colors.white
                            : AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Value with animation
                    TweenAnimationBuilder<int>(
                      tween: IntTween(
                        begin: 0,
                        end: int.tryParse(widget.value) ?? 0,
                      ),
                      duration: Duration(
                        milliseconds:
                            1000 + (int.tryParse(widget.value) ?? 0) * 50,
                      ),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: widget.gradient != null
                                ? Colors.white
                                : AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.gradient != null
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.textSecondary,
                        letterSpacing: 0.1,
                      ),
                    ),

                    // Decorative element
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 3,
                      decoration: BoxDecoration(
                        color: widget.gradient != null
                            ? Colors.white.withOpacity(0.3)
                            : AppColors.primaryBlue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
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

// Modern Enhanced Stat Card
class ModernStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final LinearGradient gradient;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isPositiveTrend;

  const ModernStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.gradient,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isPositiveTrend = true,
  });

  @override
  State<ModernStatCard> createState() => _ModernStatCardState();
}

class _ModernStatCardState extends State<ModernStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design için ekran boyutunu kontrol et
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: EdgeInsets.all(
                    isSmallScreen ? 16 : 20), // Responsive padding
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withOpacity(0.25),
                      blurRadius: isSmallScreen ? 8 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Önemli: minimum alan kapla
                  children: [
                    // Header with icon and trend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width:
                              isSmallScreen ? 40 : 48, // Responsive icon size
                          height: isSmallScreen ? 40 : 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size:
                                isSmallScreen ? 20 : 24, // Responsive icon size
                          ),
                        ),
                        if (widget.showTrend && widget.trendValue != null)
                          Flexible(
                            // Trend indicator responsive
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 6 : 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.isPositiveTrend
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${widget.trendValue!.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 10 : 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                        height: isSmallScreen ? 12 : 16), // Responsive spacing

                    // Value - Responsive font size
                    TweenAnimationBuilder<int>(
                      tween: IntTween(
                        begin: 0,
                        end: int.tryParse(widget.value) ?? 0,
                      ),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutExpo,
                      builder: (context, value, child) {
                        return FittedBox(
                          // Önemli: Text taşmasını önle
                          fit: BoxFit.scaleDown,
                          child: Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize:
                                  isSmallScreen ? 24 : 28, // Responsive font
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),

                    // Title - Responsive with text overflow
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14, // Responsive font
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1, // Single line
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),

                    // Subtitle if provided - Responsive
                    if (widget.subtitle != null) ...[
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11, // Responsive font
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1, // Single line
                        overflow: TextOverflow.ellipsis, // Handle overflow
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
