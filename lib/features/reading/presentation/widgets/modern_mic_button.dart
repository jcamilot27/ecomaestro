import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernMicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;

  const ModernMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          if (isListening)
            Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.6, 1.6),
                  duration: 1200.ms,
                  curve: Curves.easeOut,
                )
                .fadeOut(duration: 1200.ms),

          // Main Button Body
          AnimatedContainer(
                duration: 400.ms,
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isListening
                        ? [const Color(0xFF00E5FF), const Color(0xFF00B0FF)]
                        : [const Color(0xFF00B0FF), const Color(0xFF01579B)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isListening
                                  ? const Color(0xFF00E5FF)
                                  : const Color(0xFF00B0FF))
                              .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              )
              .animate(target: isListening ? 1 : 0)
              .shimmer(duration: 2.seconds, color: Colors.white24),

          // Rotating ring when active
          if (isListening)
            CustomPaint(
              size: const Size(90, 90),
              painter: _CircleProgressPainter(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
        ],
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final Color color;
  _CircleProgressPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      0.8, // Small segment
      false,
      paint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14,
      0.8, // Opposite segment
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
