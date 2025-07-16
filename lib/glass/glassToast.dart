import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_corner/smooth_corner.dart';
import 'dart:async';
import 'dart:ui';

import 'glassCard.dart';


// 기존 CupertinoToastWidget 코드에서 스타일만 GlassCard처럼 수정
class CupertinoToastWidget extends StatefulWidget {
  final String message;
  final OverlayEntry overlayEntry;

  const CupertinoToastWidget({
    Key? key,
    required this.message,
    required this.overlayEntry,
  }) : super(key: key);

  @override
  _CupertinoToastWidgetState createState() => _CupertinoToastWidgetState();
}

class _CupertinoToastWidgetState extends State<CupertinoToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 2), () {
      _controller.reverse().whenComplete(() {
        if (mounted) {
          widget.overlayEntry.remove();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.14),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.11),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
          child: Text(
            widget.message,
            style: const TextStyle(
              fontSize: 14.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}