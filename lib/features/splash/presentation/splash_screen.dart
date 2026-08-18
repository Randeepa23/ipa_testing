import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<Offset> _position;
  late final Animation<double> _backgroundScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 20,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 56),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 24,
      ),
    ]).animate(_controller);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.72,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 22,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 54),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.92,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 24,
      ),
    ]).animate(_controller);
    _position = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 22,
      ),
      TweenSequenceItem(tween: ConstantTween(Offset.zero), weight: 54),
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(0, -0.08),
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 24,
      ),
    ]).animate(_controller);
    _backgroundScale = Tween<double>(
      begin: 1,
      end: 1.025,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _completeSplash();
  }

  Future<void> _completeSplash() async {
    try {
      // Complete the full entrance-and-exit animation before navigation so
      // the next route never interrupts the visual sequence.
      await _controller.forward().orCancel;
      if (mounted) {
        await ref.read(loginControllerProvider.notifier).bootstrap();
      }
    } on TickerCanceled {
      // Hot restart/disposal cancels animations; this is an expected exit.
      return;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAFF),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return FadeTransition(
            opacity: _opacity,
            child: Transform.scale(
              scale: _backgroundScale.value,
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF002E73),
                          Color(0xFF063B8F),
                          Color(0xFFEAF4FF),
                        ],
                        stops: [0, 0.42, 1],
                      ),
                    ),
                  ),
                  const IgnorePointer(
                    child: CustomPaint(painter: _AutomotiveBackdropPainter()),
                  ),
                  const Positioned(
                    top: 108,
                    right: -28,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.09,
                        child: Icon(
                          Icons.directions_car_rounded,
                          size: 184,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 74,
                    left: -46,
                    child: IgnorePointer(
                      child: _SplashRing(
                        diameter: 184,
                        color: Color(0x33FFFFFF),
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.translate(
                      offset: const Offset(0, -24),
                      child: SlideTransition(
                        position: _position,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 122,
                                height: 122,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0x4DFFFFFF),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x52063B8F),
                                      blurRadius: 30,
                                      spreadRadius: 7,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Semantics(
                                    label: 'SR Rent A Car',
                                    image: true,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/splash screen.png',
                                        fit: BoxFit.contain,
                                        cacheWidth: 220,
                                        filterQuality: FilterQuality.medium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFEAF4FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SplashRing extends StatelessWidget {
  const _SplashRing({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.25),
      ),
      child: SizedBox(width: diameter, height: diameter),
    );
  }
}

class _AutomotiveBackdropPainter extends CustomPainter {
  const _AutomotiveBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.56;
    final center = Offset(size.width * 0.57, horizon);

    final road = Path()
      ..moveTo(center.dx - 38, horizon)
      ..lineTo(-size.width * 0.18, size.height)
      ..lineTo(size.width * 1.22, size.height)
      ..lineTo(center.dx + 38, horizon)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0x1F002E73));

    final lanePaint = Paint()
      ..color = const Color(0x73FFFFFF)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(size.width * 0.31, size.height), lanePaint);
    canvas.drawLine(
      Offset(center.dx + 18, center.dy),
      Offset(size.width * 0.79, size.height),
      lanePaint,
    );

    final skylinePaint = Paint()..color = const Color(0x12002E73);
    for (var index = 0; index < 9; index++) {
      final width = 18.0 + (index % 3) * 11;
      final height = 20.0 + (index % 4) * 14;
      final left = index * (size.width / 8.0) - 12;
      canvas.drawRect(
        Rect.fromLTWH(left, horizon - height, width, height),
        skylinePaint,
      );
    }

    final arcPaint = Paint()
      ..color = const Color(0x4295C8EE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.16, size.height * 0.68),
        radius: size.width * 0.46,
      ),
      -1.45,
      1.4,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AutomotiveBackdropPainter oldDelegate) => false;
}
