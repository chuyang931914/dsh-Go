// 聊天页的分层宠物（阶段 1）：整张透明立绘 + 程序化呼吸/摇晃/点击反应。
// 后续阶段会把头、眼、嘴拆成可动层，加眨眼与表情；现在先让宠物“活着”。
// 素材：app/assets/pets/bluefox/front.png（由蓝发少女立绘去底裁切）。

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/motion.dart';

class LayeredPet extends StatefulWidget {
  const LayeredPet({super.key, this.height = 150, this.busy = false});

  final double height;

  /// 对话正在生成：呼吸和摇晃幅度放大，像在盯着思考。
  final bool busy;

  @override
  State<LayeredPet> createState() => _LayeredPetState();
}

class _LayeredPetState extends State<LayeredPet> with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  )..repeat(reverse: true);

  late final AnimationController _squash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );

  /// 随机小动作：偶尔歪头/踮一下，让宠物不像循环动画。
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  Timer? _idleTimer;
  int _idleDir = 1;

  /// 眨眼：用程序化眼睑盖住眼睛，不依赖额外图层；坐标按 900×900 立绘标定。
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 130),
  );
  Timer? _blinkTimer;

  void _pressed() => _squash.forward(from: 0);

  void _released() => _squash.reverse();

  @override
  void initState() {
    super.initState();
    _scheduleIdle();
    _scheduleBlink();
  }

  void _scheduleIdle() {
    _idleTimer?.cancel();
    _idleTimer = Timer(
      Duration(milliseconds: 2800 + math.Random().nextInt(3600)),
      () {
        if (!mounted) return;
        _idleDir = math.Random().nextBool() ? 1 : -1;
        _idle.forward(from: 0).then((_) {
          if (mounted) _idle.reverse();
        });
        _scheduleIdle();
      },
    );
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer(Duration(milliseconds: 2400 + math.Random().nextInt(5200)), () {
      if (!mounted) return;
      _blink.forward(from: 0).then((_) {
        if (mounted) _blink.reverse();
      });
      _scheduleBlink();
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _blinkTimer?.cancel();
    _blink.dispose();
    _breath.dispose();
    _squash.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final phase = reduced ? 0.0 : _breath.value * math.pi * 2;
    final alive = widget.busy ? 1.5 : 1.0;
    return Semantics(
      button: true,
      label: '宠物',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressed(),
        onTapUp: (_) => _released(),
        onTapCancel: _released,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge([_breath, _squash, _idle, _blink]),
            builder: (context, _) {
              final scaleX = 1 + 0.006 * math.sin(phase) * alive;
              final scaleY = 1 + 0.014 * math.sin(phase) * alive - _squash.value * 0.08;
              final idleWave = math.sin(_idle.value * math.pi);
              final rotation = 0.4 * math.sin(phase) * alive + 2.2 * idleWave * _idleDir;
              final lift = 1.6 * math.sin(phase) * alive - 3.0 * idleWave;
              return Transform.translate(
                offset: Offset(0, lift),
                child: Transform.rotate(
                  angle: rotation * math.pi / 180,
                  child: Transform.scale(
                    scaleX: scaleX,
                    scaleY: scaleY,
                    alignment: Alignment.bottomCenter,
                    child: SizedBox.square(
                      dimension: widget.height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/pets/bluefox/front.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                          ),
                          if (!reduced)
                            IgnorePointer(
                              child: Opacity(
                                opacity: _blink.value,
                                child: Image.asset(
                                  'assets/pets/bluefox/closed.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
