import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bankroll/game/bankroll.dart';
import 'package:bankroll/game/consts/priorities.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:get/get.dart';

class Dice extends SpriteComponent with HasGameRef<Bankroll> {
  bool _isAnimating = false;
  Dice() : super(priority: Priorities.DICE.index);

  Future<int> roll() async {
    int n = new Random().nextInt(7);
    if (n == 0) return roll();

    _isAnimating = true;

    this.anchor = Anchor.center;
    sprite = Sprite(Flame.images.fromCache("dice/dieWhite$n.png"));
    this.size = sprite!.originalSize;
    this.position = Vector2(
      Get.width + width / 2,
      gameRef.BOARD_END - gameRef.sHeight - (height / 2),
    );

    if (!Platform.isWindows) FlameAudio.audioCache.play("sfx/dice-roll.ogg");

    addEffect(
      CombinedEffect(
        effects: [
          RotateEffect(
            angle: 180,
            duration: 0.4,
          ),
          MoveEffect(
            path: [Vector2(gameRef.canvasSize.x / 2, position.y)],
            duration: 0.4,
          ),
        ],
        onComplete: () {
          clearEffects();
          angle = 0.0;
          _isAnimating = false;
        },
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
