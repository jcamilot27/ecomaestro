import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class EnergyCore extends StatefulWidget {
  final double progress; // 0.0 to 1.0 (session progress)
  final double fluencyLevel; // 0.0 to 1.0 (activity level)
  final bool isListening;

  const EnergyCore({
    super.key,
    required this.progress,
    required this.fluencyLevel,
    required this.isListening,
  });

  @override
  State<EnergyCore> createState() => _EnergyCoreState();
}

class _EnergyCoreState extends State<EnergyCore> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fluency controls the "Life" of the core
    // 0.0 -> Grey/Small/Flat
    // 1.0 -> Bright Blue/Large/Glowing

    final Color idleColor = Colors.blueGrey.shade800.withValues(alpha: 0.4);
    final Color sessionColor = Color.lerp(
      const Color(0xFF00B0FF),
      const Color(0xFF00E5FF),
      widget.progress,
    )!;

    // The core color is based on fluency level
    final Color coreColor = Color.lerp(
      idleColor,
      sessionColor,
      widget.fluencyLevel,
    )!;

    // Growth: 40 (idle) -> 160 (active/full progress)
    final double baseSize =
        40.0 + (widget.fluencyLevel * 100.0) + (widget.progress * 40.0);
    final double glowRadius = 10.0 + (widget.fluencyLevel * 80.0);
    final double opacity = 0.3 + (widget.fluencyLevel * 0.7);

    return SizedBox(
      height: 300,
      width: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Deep Background Glow (Reactive)
          AnimatedContainer(
            duration: 400.ms,
            width: baseSize * 1.8,
            height: baseSize * 1.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: coreColor.withValues(
                    alpha: 0.15 * widget.fluencyLevel,
                  ),
                  blurRadius: glowRadius * 2,
                  spreadRadius: glowRadius / 2,
                ),
              ],
            ),
          ),

          // 2. Rotating Energy Rings (Only visible when active)
          if (widget.fluencyLevel > 0.1)
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.fluencyLevel,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRing(
                        _rotationController.value * 2 * math.pi,
                        baseSize * 1.3,
                        coreColor.withValues(alpha: 0.2),
                      ),
                      _buildRing(
                        -_rotationController.value * 3 * math.pi,
                        baseSize * 1.1,
                        coreColor.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                );
              },
            ),

          // 3. Particles (Bubbles)
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(baseSize, baseSize),
                    painter: _EnergyParticlesPainter(
                      color: coreColor,
                      activity: widget.fluencyLevel,
                      progress: widget.progress,
                    ),
                  ),
                ),
              );
            },
          ),

          // 4. The Core
          AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse =
                      1.0 +
                      (_pulseController.value * 0.05 * widget.fluencyLevel);
                  return AnimatedContainer(
                    duration: 400.ms,
                    width: baseSize * pulse,
                    height: baseSize * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(
                            alpha: 0.9 * widget.fluencyLevel,
                          ),
                          coreColor.withValues(alpha: 0.8),
                          coreColor.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4, 0.8, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: coreColor.withValues(
                            alpha: 0.4 * widget.fluencyLevel,
                          ),
                          blurRadius: glowRadius,
                          spreadRadius: widget.fluencyLevel * 10,
                        ),
                      ],
                    ),
                  );
                },
              )
              .animate(target: widget.isListening ? 1 : 0)
              .shake(hz: 8, duration: 200.ms),

          // 5. Reactive Water Ripples (Listening)
          if (widget.isListening)
            ...List.generate(3, (index) {
              return Container(
                    width: baseSize * 1.2,
                    height: baseSize * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: coreColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: Offset(1.5 + (index * 0.5), 1.5 + (index * 0.5)),
                    duration: (1500 + (index * 500)).ms,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(duration: (1500 + (index * 500)).ms);
            }),
        ],
      ),
    );
  }

  Widget _buildRing(double angle, double size, Color color) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.0),
        ),
      ),
    );
  }
}

class _EnergyParticlesPainter extends CustomPainter {
  final Color color;
  final double activity;
  final double progress;

  _EnergyParticlesPainter({
    required this.color,
    required this.activity,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    // Count depends on activity and progress
    final count = (10 + (activity * 30) + (progress * 20)).toInt();
    final radius = size.width / 2;

    for (int i = 0; i < count; i++) {
      final paint = Paint()
        ..color = color.withValues(
          alpha: (0.1 + activity * 0.4) * random.nextDouble(),
        )
        ..style = PaintingStyle.fill;

      final angle = random.nextDouble() * 2 * math.pi;
      final dist = (0.3 + random.nextDouble() * 0.9) * radius;
      final pSize = (random.nextDouble() * 4 + 1) * (0.5 + activity);

      final x = size.width / 2 + math.cos(angle) * dist;
      final y = size.height / 2 + math.sin(angle) * dist;

      canvas.drawCircle(Offset(x, y), pSize, paint);

      if (activity > 0.5) {
        // Add a small highlight to the bubble
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2 * activity);
        canvas.drawCircle(
          Offset(x - pSize * 0.2, y - pSize * 0.2),
          pSize * 0.2,
          highlightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
