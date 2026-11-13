// 红后模式：思考中上半屏黑客帝国式绿字雨（外加当前步骤），失败时红底告警。
// 纯装饰，IgnorePointer；只在生成中/失败时挂载，空闲不耗电。


import 'package:flutter/material.dart';

enum HackerTone { thinking, failure }

class HackerTint extends StatefulWidget {
  const HackerTint({super.key, required this.tone, this.lines = const []});

  final HackerTone tone;

  /// 屏上落字：绿屏是当前步骤，红屏是错误与建议。
  final List<String> lines;

  @override
  State<HackerTint> createState() => _HackerTintState();
}

class _HackerTintState extends State<HackerTint> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // 30fps 足够，省一半重绘。
    duration: const Duration(seconds: 8),
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
          builder: (context, _) => Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RainPainter(t: _c.value, color: color, matrix: green),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final line in widget.lines.take(3))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          line,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 12,
                            height: 1.3,
                            letterSpacing: 0.2,
                            color: color.withValues(alpha: 0.9),
                            shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
                          ),
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

/// 字符雨：固定列数与每列相位的确定性伪随机，避免每帧新建对象。
class _RainPainter extends CustomPainter {
  _RainPainter({required this.t, required this.color, required this.matrix});

  final double t;
  final Color color;
  final bool matrix;

  static const _glyphs = 'アイウエオカキクケコサシスセソタチツテトナ0123456789ABCDEF';
  static const _fontSize = 13.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // 底色：黑到透明的渐变，让字浮出来。
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: matrix ? 0.55 : 0.45), Colors.transparent],
        ).createShader(rect),
    );

    final columns = (size.width / 22).floor().clamp(8, 26);
    final charW = size.width / columns;
    for (var i = 0; i < columns; i++) {
      final seed = (i * 2654435761) & 0x7fffffff;
      final speed = 0.55 + (seed % 100) / 160;
      final phase = (seed % 997) / 997;
      final head = ((t * speed * 1.7 + phase) % 1.25 - 0.15) * size.height;
      final chars = matrix ? 9 : 6;
      for (var k = 0; k < chars; k++) {
        final y = head - k * _fontSize * 1.15;
        if (y < -_fontSize || y > size.height + _fontSize) continue;
        final g = (seed + i * 31 + k * 17) % _glyphs.length;
        final fade = 1 - k / chars;
        final a = (matrix ? 0.85 : 0.6) * fade;
        if (a <= 0.02) continue;
        final tp = TextPainter(
          text: TextSpan(
            text: _glyphs[g],
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: _fontSize,
              color: color.withValues(alpha: a),
              shadows: k == 0 ? [Shadow(color: color.withValues(alpha: 0.8), blurRadius: 8)] : null,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(i * charW + 4, y));
      }
    }

    // 顶边自检线 + 轻微的扫描线。
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 2), Paint()..color = color.withValues(alpha: 0.4));
    final line = Paint()..color = color.withValues(alpha: 0.05);
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), line);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter old) => old.t != t || old.color != color || old.matrix != matrix;
}
