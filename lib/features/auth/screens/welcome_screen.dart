import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/kazoona_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const KazoonaLogo(fontSize: 44),
              const SizedBox(height: 12),
              Text(
                'arkadaşlarınla kazan',
                style: TextStyle(color: AppColors.grey, fontSize: 14, letterSpacing: 0.5),
              ),
              const Spacer(flex: 2),
              _CardRow(),
              const Spacer(flex: 2),
              _PrimaryButton(label: 'Hesap oluştur', onTap: () => context.push('/register')),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.push('/login'),
                child: Text(
                  'Zaten bir hesabım var',
                  style: TextStyle(color: AppColors.greyLight, fontSize: 14),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 24,
            child: Transform.rotate(
              angle: -0.18,
              child: _PreviewCard(color: AppColors.cardPurple, emoji: '🎉', label: 'Dans Et!'),
            ),
          ),
          Positioned(
            right: 24,
            child: Transform.rotate(
              angle: 0.18,
              child: _PreviewCard(color: AppColors.cardGreen, emoji: '🌟', label: 'Şarkı Söyle!'),
            ),
          ),
          _PreviewCard(color: AppColors.primary, emoji: '🏆', label: 'Kazan!', large: true),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Color color;
  final String emoji;
  final String label;
  final bool large;

  const _PreviewCard({
    required this.color,
    required this.emoji,
    required this.label,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final w = large ? 100.0 : 80.0;
    return Container(
      width: w,
      height: w * 1.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color,
        boxShadow: [
          BoxShadow(color: color.withAlpha(80), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: large ? 34 : 26)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: large ? 11 : 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: const Center(
          child: Text(
            'Hesap oluştur',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
