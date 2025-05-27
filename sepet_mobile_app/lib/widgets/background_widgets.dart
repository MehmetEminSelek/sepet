import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

// Animated Gradient Background
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFFF8F9FE),
      Color(0xFFEEF2FF),
      Color(0xFFF0F9FF),
    ],
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
              transform: GradientRotation(_animation.value * 2 * math.pi),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Floating Particles Background
class FloatingParticlesBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;
  final double maxParticleSize;
  final double minParticleSize;

  const FloatingParticlesBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor = const Color(0x10000000),
    this.maxParticleSize = 4.0,
    this.minParticleSize = 1.0,
  });

  @override
  State<FloatingParticlesBackground> createState() =>
      _FloatingParticlesBackgroundState();
}

class _FloatingParticlesBackgroundState
    extends State<FloatingParticlesBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<double> _particleSizes;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _particleSizes = [];

    for (int i = 0; i < widget.particleCount; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 10 + math.Random().nextInt(10)),
        vsync: this,
      );

      final animation = Tween<Offset>(
        begin: Offset(
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 2 - 1,
        ),
        end: Offset(
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 2 - 1,
        ),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      final size = widget.minParticleSize +
          math.Random().nextDouble() *
              (widget.maxParticleSize - widget.minParticleSize);

      _controllers.add(controller);
      _animations.add(animation);
      _particleSizes.add(size);

      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...List.generate(widget.particleCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width * 0.5 +
                    _animations[index].value.dx *
                        MediaQuery.of(context).size.width *
                        0.3,
                top: MediaQuery.of(context).size.height * 0.5 +
                    _animations[index].value.dy *
                        MediaQuery.of(context).size.height *
                        0.3,
                child: Container(
                  width: _particleSizes[index],
                  height: _particleSizes[index],
                  decoration: BoxDecoration(
                    color: widget.particleColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

// Geometric Shapes Background
class GeometricShapesBackground extends StatefulWidget {
  final Widget child;
  final List<Color> shapeColors;

  const GeometricShapesBackground({
    super.key,
    required this.child,
    this.shapeColors = const [
      Color(0x08000000),
      Color(0x06000000),
      Color(0x04000000),
    ],
  });

  @override
  State<GeometricShapesBackground> createState() =>
      _GeometricShapesBackgroundState();
}

class _GeometricShapesBackgroundState extends State<GeometricShapesBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _rotationAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _rotationAnimations = [];
    _scaleAnimations = [];

    for (int i = 0; i < 5; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 15 + i * 5),
        vsync: this,
      );

      final rotationAnimation = Tween<double>(
        begin: 0.0,
        end: 2 * math.pi,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.linear,
      ));

      final scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));

      _controllers.add(controller);
      _rotationAnimations.add(rotationAnimation);
      _scaleAnimations.add(scaleAnimation);

      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        widget.child,
        // Background shapes
        Positioned(
          top: -100,
          right: -100,
          child: AnimatedBuilder(
            animation: _controllers[0],
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimations[0].value,
                child: Transform.scale(
                  scale: _scaleAnimations[0].value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: widget.shapeColors[0],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: AnimatedBuilder(
            animation: _controllers[1],
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimations[1].value,
                child: Transform.scale(
                  scale: _scaleAnimations[1].value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: widget.shapeColors[1],
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: size.height * 0.3,
          left: -30,
          child: AnimatedBuilder(
            animation: _controllers[2],
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimations[2].value,
                child: Transform.scale(
                  scale: _scaleAnimations[2].value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.shapeColors[2],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: size.height * 0.6,
          right: -20,
          child: AnimatedBuilder(
            animation: _controllers[3],
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimations[3].value,
                child: Transform.scale(
                  scale: _scaleAnimations[3].value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.shapeColors[0],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: size.height * 0.1,
          left: size.width * 0.3,
          child: AnimatedBuilder(
            animation: _controllers[4],
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimations[4].value,
                child: Transform.scale(
                  scale: _scaleAnimations[4].value,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.shapeColors[1],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Professional Card Background
class ProfessionalCardBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final BorderRadius? borderRadius;
  final Border? border;

  const ProfessionalCardBackground({
    super.key,
    required this.child,
    this.backgroundColor,
    this.shadows,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: border ??
            Border.all(
              color: AppColors.borderLight.withOpacity(0.5),
              width: 0.5,
            ),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 40,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
      ),
      child: child,
    );
  }
}

// Glassmorphism Background
class GlassmorphismBackground extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;

  const GlassmorphismBackground({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withOpacity(opacity),
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

// Mesh Gradient Background
class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color> colors;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFFF8F9FE),
      Color(0xFFEEF2FF),
      Color(0xFFF0F9FF),
      Color(0xFFFDF2F8),
    ],
  });

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                math.sin(_controller.value * 2 * math.pi) * 0.5,
                math.cos(_controller.value * 2 * math.pi) * 0.5,
              ),
              radius: 1.5,
              colors: widget.colors,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
