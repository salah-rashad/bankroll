import 'dart:async';
import 'dart:math';

import 'package:bankroll/game/bankroll.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class Dice extends SpriteComponent with HasGameRef<Bankroll> {
  Dice() : super(priority: 6);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  bool _isAnimating = false;

  Future<int> roll() async {
    int n = new Random().nextInt(7);
    if (n == 0) return roll();

    _isAnimating = true;

    this.anchor = Anchor.center;
    sprite = Sprite(Flame.images.fromCache("dice/dieWhite$n.png"));
    this.size = sprite!.srcSize;
    this.position = Vector2(Get.width + width / 2, Get.height / 2);

    this.addEffect(
      CombinedEffect(
        onComplete: () {
          clearEffects();
          angle = 0.0;
          _isAnimating = false;
        },
        effects: [
          new RotateEffect(
            angle: 180,
            duration: 0.4,
          ),
          new MoveEffect(
            path: [gameRef.canvasSize / 2],
            duration: 0.4,
          ),
        ],
      ),
    );

    await _waitUntilDone();

    return n;
  }

  Future<void> _waitUntilDone() async {
    final completer = Completer();
    if (_isAnimating) {
      await Future.delayed(Duration(milliseconds: 100));
      return _waitUntilDone();
    } else {
      completer.complete();
    }
    return completer.future;
  }
}
