import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/game_card_model.dart';

/// Scratch card widget — uses saveLayer + BlendMode.clear for real erase effect.
class ScratchCardWidget extends StatefulWidget {
  final GameCard card;
  final bool enabled;
  final bool compact;
  final VoidCallback? onFullyScratch;

  const ScratchCardWidget({
    super.key,
    required this.card,
    this.enabled = true,
    this.compact = false,
    this.onFullyScratch,
  });

  @override
  State<ScratchCardWidget> createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget>
    with SingleTickerProviderStateMixin {
  final List<Offset> _points = [];
  late AnimationController _fadeCtrl;
  bool _fullyRevealed = false;
  Size? _size;

  double get _brush => widget.compact ? 15.0 : 22.0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    if (widget.card.isRevealed) {
      _fullyRevealed = true;
      _fadeCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ScratchCardWidget old) {
    super.didUpdateWidget(old);
    if (widget.card.isRevealed && !_fullyRevealed) _triggerReveal();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _triggerReveal() {
    _fullyRevealed = true;
    _fadeCtrl.forward();
    widget.onFullyScratch?.call();
  }

  void _addPoint(Offset local) {
    if (_fullyRevealed) return;
    setState(() {
      _points.add(local);
      _checkCoverage();
    });
  }

  void _checkCoverage() {
    if (_size == null || _points.isEmpty) return;
    const grid = 18;
    int covered = 0;
    for (int gx = 0; gx < grid; gx++) {
      for (int gy = 0; gy < grid; gy++) {
        final cx = (_size!.width / grid) * (gx + 0.5);
        final cy = (_size!.height / grid) * (gy + 0.5);
        final cell = Offset(cx, cy);
        for (final p in _points) {
          if ((p - cell).distance <= _brush * 1.6) {
            covered++;
            break;
          }
        }
      }
    }
    if (covered / (grid * grid) >= 0.62 && !_fullyRevealed) {
      _triggerReveal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.compact ? 14.0 : 20.0;
    return LayoutBuilder(builder: (_, constraints) {
      _size = Size(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onPanStart: widget.enabled ? (d) => _addPoint(d.localPosition) : null,
        onPanUpdate: widget.enabled ? (d) => _addPoint(d.localPosition) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1 — revealed content (always visible underneath)
              _RevealedContent(card: widget.card, compact: widget.compact),

              // Layer 2 — scratch surface (fades out when revealed)
              if (!_fullyRevealed)
                AnimatedBuilder(
                  animation: _fadeCtrl,
                  builder: (_, __) => Opacity(
                    opacity: (1.0 - _fadeCtrl.value).clamp(0.0, 1.0),
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _ScratchSurfacePainter(
                          points: _points,
                          brush: _brush,
                          baseColor: AppColors.scratchGold,
                        ),
                        size: _size!,
                      ),
                    ),
                  ),
                ),

              // Layer 3 — "not your turn" dim
              if (!widget.enabled && !_fullyRevealed)
                Container(color: Colors.black.withAlpha(120)),

              // Layer 4 — hint (only big mode, before first scratch)
              if (!_fullyRevealed && _points.isEmpty && widget.enabled && !widget.compact)
                const _ScratchHint(),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Revealed card content ────────────────────────────────────────────────────
class _RevealedContent extends StatelessWidget {
  final GameCard card;
  final bool compact;

  const _RevealedContent({required this.card, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.all(compact ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: card.rarityColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: card.rarityColor.withAlpha(100)),
                ),
                child: Text(
                  card.rarityLabel,
                  style: TextStyle(
                    color: card.rarityColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: card.color,
                  boxShadow: [
                    BoxShadow(color: card.color.withAlpha(160), blurRadius: 6, spreadRadius: 2),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(card.emoji, style: TextStyle(fontSize: compact ? 26 : 40)),
          SizedBox(height: compact ? 4 : 8),
          Text(
            card.name,
            style: TextStyle(
              color: AppColors.white,
              fontSize: compact ? 10 : 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            card.activity,
            style: TextStyle(
              color: card.color,
              fontSize: compact ? 9 : 11,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Scratch surface painter ──────────────────────────────────────────────────
class _ScratchSurfacePainter extends CustomPainter {
  final List<Offset> points;
  final double brush;
  final Color baseColor;

  const _ScratchSurfacePainter({
    required this.points,
    required this.brush,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Must use saveLayer so BlendMode.clear creates transparent holes
    canvas.saveLayer(rect, Paint());

    // Golden gradient base
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, Color.lerp(baseColor, const Color(0xFFFF8C00), 0.4)!],
        ).createShader(rect),
    );

    // Diagonal metallic sheen
    for (int i = -20; i < (size.width + size.height).toInt(); i += 10) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble() - size.height * 0.45, size.height),
        Paint()
          ..color = Colors.white.withAlpha(15)
          ..strokeWidth = 5,
      );
    }
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [Colors.white.withAlpha(50), Colors.transparent],
        ).createShader(rect),
    );

    // ── Erase scratched areas using BlendMode.clear ──
    if (points.isNotEmpty) {
      final clearPaint = Paint()
        ..blendMode = BlendMode.clear
        ..isAntiAlias = true;

      for (final p in points) {
        canvas.drawCircle(p, brush, clearPaint);
      }

      if (points.length > 1) {
        final path = Path()..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(
          path,
          clearPaint
            ..style = PaintingStyle.stroke
            ..strokeWidth = brush * 2
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScratchSurfacePainter old) => points.length != old.points.length;
}

// ─── Hint ─────────────────────────────────────────────────────────────────────
class _ScratchHint extends StatefulWidget {
  const _ScratchHint();

  @override
  State<_ScratchHint> createState() => _ScratchHintState();
}

class _ScratchHintState extends State<_ScratchHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
    _slide = Tween(begin: -12.0, end: 12.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _slide,
        builder: (_, child) => Transform.translate(offset: Offset(_slide.value, 0), child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(130),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swipe, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Kazı!',
                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
