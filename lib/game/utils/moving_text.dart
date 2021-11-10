import 'dart:async';
import 'dart:ui';

import 'package:bankroll/game/components/background_text_component.dart';
import 'package:bankroll/game/consts/priorities.dart';
import 'package:bankroll/game/enums/direction.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class MovingText {
  final BaseGame gameRef;
  final String text;
  final Vector2? position;
  final Direction direction;
  final TextPaintConfig? config;
  final double distance;
  final Color? bgColor;

  MovingText(
    this.text, {
    required this.gameRef,
    this.position,
    this.config,
    this.direction = Direction.RIGHT,
    this.distance = 30.0,
    this.bgColor,
  });

  bool _wait = false;

  Future<void> play() async {
    try {
      _wait = true;

      var tc = BackgroundTextComponent(
        this.text,
        bgColor: bgColor,
        radius: Radius.elliptical(8, 5),
        position: this.position ?? Vector2(0.0, 0.0),
        priority: Priorities.INTERFACE.index,
        textRenderer: TextPaint(
          config: this.config ?? TextPaintConfig(),
        ),
      );

      gameRef.add(tc);

      final Vector2 path;

      switch (direction) {
        case Direction.UP:
          path = Vector2(tc.x, tc.y - this.distance);
          break;
        case Direction.DOWN:
          path = Vector2(tc.x, tc.y + this.distance);
          break;
        case Direction.RIGHT:
          path = Vector2(tc.x + this.distance, tc.y);
          break;
        case Direction.LEFT:
          path = Vector2(tc.x - this.distance, tc.y);
          break;
      }

      tc.addEffect(SequenceEffect(
        effects: [
          MoveEffect(
            path: [path],
            duration: 1.5,
            curve: Curves.linearToEaseOut,
          ),
          // ScaleEffect(
          //   size: tc.size * 2,
          //   curve: Curves.easeInBack,
          //   duration: 0.5,
          // ),
        ],
        onComplete: () {
          _wait = false;
        },
      ));

      await _waitUntilDone();

      tc.remove();
    } catch (e) {
      printError(info: e.toString());
    }
  }

  Future<void> _waitUntilDone() async {
    final completer = Completer();
    if (_wait) {
      await 0.1.delay();
      return _waitUntilDone();
    } else {
      completer.complete();
    }
    return completer.future;
  }
}
