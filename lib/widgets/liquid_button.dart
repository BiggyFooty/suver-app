import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LiquidButton extends StatefulWidget {
  final VoidCallback onTap;
  final double fillLevel; // 0-100

  const LiquidButton({
    super.key,
    required this.onTap,
    required this.fillLevel,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with TickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: Stack(
            children: [
              // Liquid waves
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(220, 220),
                    painter: WavePainter(
                      wavePhase: _waveController.value * 2 * math.pi,
                      fillLevel: widget.fillLevel / 100,
                    ),
                  );
                },
              ),
              // Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_circle_filled,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SU AL',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppColors.primary,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'REKLAM İZLE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 2,
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

class WavePainter extends CustomPainter {
  final double wavePhase;
  final double fillLevel;

  WavePainter({required this.wavePhase, required this.fillLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final fillHeight = size.height * (1 - fillLevel);
    
    // Wave 1 - Primary blue
    _drawWave(
      canvas,
      size,
      fillHeight,
      wavePhase,
      AppColors.primary.withValues(alpha: 0.9),
      15,
    );
    
    // Wave 2 - Lighter blue
    _drawWave(
      canvas,
      size,
      fillHeight + 5,
      wavePhase + math.pi / 3,
      const Color(0xFF38BDF8).withValues(alpha: 0.7),
      12,
    );
    
    // Wave 3 - Cyan
    _drawWave(
      canvas,
      size,
      fillHeight + 10,
      wavePhase + math.pi / 1.5,
      const Color(0xFF06B6D4).withValues(alpha: 0.5),
      10,
    );
  }

  void _drawWave(Canvas canvas, Size size, double baseY, double phase, Color color, double amplitude) {
    final paint = Paint()..color = color;
    final path = Path();
    
    path.moveTo(0, size.height);
    path.lineTo(0, baseY);
    
    for (double x = 0; x <= size.width; x++) {
      final y = baseY + amplitude * math.sin((x / size.width * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase || oldDelegate.fillLevel != fillLevel;
  }
}
