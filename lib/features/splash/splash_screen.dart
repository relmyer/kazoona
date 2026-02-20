import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    await auth.loadUser();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/welcome');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1628),
              Color(0xFF231E35),
              Color(0xFF1A1628),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background floating particles
            ..._buildParticles(),
            // Main content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(
                                    0.4 * _glowAnim.value,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🎯',
                                style: TextStyle(fontSize: 56),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // App name
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: AppColors.goldGradient,
                            ).createShader(bounds),
                            child: const Text(
                              'KAZOONA',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kazan • Kaşif • Kazoona',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Loading dots
                          _LoadingDots(progress: _glowAnim.value),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    return [
      _Particle(top: 80, left: 40, emoji: '⭐', size: 16),
      _Particle(top: 120, right: 60, emoji: '✨', size: 20),
      _Particle(top: 200, left: 80, emoji: '🎉', size: 14),
      _Particle(bottom: 150, right: 40, emoji: '🌟', size: 18),
      _Particle(bottom: 200, left: 60, emoji: '💫', size: 16),
      _Particle(bottom: 100, right: 100, emoji: '🎊', size: 22),
    ];
  }
}

class _Particle extends StatefulWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final String emoji;
  final double size;

  const _Particle({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.emoji,
    required this.size,
  });

  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + (widget.size * 100).toInt()),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      bottom: widget.bottom,
      left: widget.left,
      right: widget.right,
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Opacity(
              opacity: 0.6,
              child: Text(
                widget.emoji,
                style: TextStyle(fontSize: widget.size),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  final double progress;

  const _LoadingDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final dotProgress = (progress - i * 0.2).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(dotProgress),
          ),
        );
      }),
    );
  }
}
