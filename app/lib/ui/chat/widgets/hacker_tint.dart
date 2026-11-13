// 红后模式：思考中上半屏绿光扫描，失败时换红光。纯装饰，禁用手势、不挡内容。


import 'package:flutter/material.dart';

enum HackerTone { thinking, failure }

class HackerTint extends StatefulWidget {
  const HackerTint({super.key, required this.tone});

  final HackerTone tone;

  @override
  State<HackerTint> createState() => _HackerTintState();
}

class _HackerTintState extends State<HackerTint> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final green = widget.tone == HackerTone.thinking;
    final color = green ? const Color(0xFF39FF14) : const Color(0xFFFF2D2D);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _ScanPainter(
              t: _c.value,
              color: color,
              lines: green ? 14 : 8,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  _ScanPainter({required this.t, required this.color, required this.lines});

  final double t;
  final Color color;
  final int lines;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(rect);
    // 淡淡的底光 + 一条向下扫的光带。
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.0)],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final sweepY = (t * 1.6 - 0.3) * size.height;
    final sweep = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.0), color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, sweepY - 60, size.width, 120));
    canvas.drawRect(Rect.fromLTWH(0, sweepY - 60, size.width, 120), sweep);

    final line = Paint()..color = color.withValues(alpha: 0.10);
    final step = size.height / lines;
    for (var i = 0; i < lines; i++) {
      final y = (i * step + t * step * 2) % size.height;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }
    // 顶边一条实线，像开机自检。
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 2), Paint()..color = color.withValues(alpha: 0.35));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScanPainter old) => old.t != t || old.color != color;
}
