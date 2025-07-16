import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'dart:ui';

// Glassmorphism Card - 유리 효과 카드 위젯 (Glass effect card widget)
class GlassCard extends StatelessWidget {
  final Widget child;
  final List<BoxShadow>? boxShadow;
  final EdgeInsets padding;
  final bool minWidthMax; // If true, minWidth = maxWidth (가로 최대 넓이)

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(12.5),
    this.boxShadow,
    this.minWidthMax = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12.5);

    return Stack(
      children: [
        // SmoothClipRRect로 blur 및 자식 클리핑 / Apply blur and clip children
        SmoothClipRRect(
          smoothness: 1,
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.22),
                borderRadius: borderRadius,
                boxShadow: boxShadow ??
                    [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.14),
                        blurRadius: 8,
                        offset: Offset(-4, -4),
                      ),
                      BoxShadow(
                        color: CupertinoColors.black.withOpacity(0.11),
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
              ),
              child: ConstrainedBox(
                constraints: minWidthMax
                    ? const BoxConstraints(minWidth: double.infinity)
                    : const BoxConstraints(),
                child: child,
              ),
            ),
          ),
        ),
        // border를 SmoothClipRRect 곡률에 맞게 CustomPaint로 위에 그리기
        // Draw border on top, matching SmoothClipRRect corners
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _SmoothBorderPainter(
                borderRadius: borderRadius,
                borderWidth: 1.8,
                borderColor: Colors.white.withOpacity(0.18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 부드러운 라운드 border 그리기용 painter
// Painter for smooth rounded border
class _SmoothBorderPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color borderColor;

  _SmoothBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _SmoothBorderPainter oldDelegate) {
    return borderRadius != oldDelegate.borderRadius ||
        borderWidth != oldDelegate.borderWidth ||
        borderColor != oldDelegate.borderColor;
  }
}