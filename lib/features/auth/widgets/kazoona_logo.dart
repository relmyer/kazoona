import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// The "kazoona" logo with the two 'oo' rendered as coral circles/bubbles.
class KazoonaLogo extends StatelessWidget {
  final double fontSize;
  final Color textColor;

  const KazoonaLogo({
    super.key,
    this.fontSize = 36,
    this.textColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = fontSize * 0.68;
    final style = TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
      height: 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('kaz', style: style),
        // First O
        _OCircle(size: circleSize, color: AppColors.primary),
        // Second O
        _OCircle(size: circleSize, color: AppColors.primary, shade: true),
        Text('na', style: style),
      ],
    );
  }
}

class _OCircle extends StatelessWidget {
  final double size;
  final Color color;
  final bool shade;

  const _OCircle({
    required this.size,
    required this.color,
    this.shade = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.symmetric(horizontal: size * 0.04),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: shade ? color.withAlpha(180) : color,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(100),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      // Inner highlight for depth
      child: Center(
        child: Container(
          width: size * 0.35,
          height: size * 0.35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(60),
          ),
        ),
      ),
    );
  }
}
