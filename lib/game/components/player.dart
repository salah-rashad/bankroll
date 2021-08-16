import 'dart:async';
import 'dart:ui';

import 'package:bankroll/game/bankroll.dart';
import 'package:bankroll/game/components/space.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent with HasGameRef<Bankroll> {
  final String name;
  final Color color;
  final int cash;

  int currentIndex = 0;

  bool isBusy = false;
  bool _isMoving = false;

  Player({
    required this.name,
    required this.color,
    required this.cash,
    required Vector2 size,
  }) : super(size: size, priority: 6);

  @override
  Future<void>? onLoad() {
    position = gameRef.spaces[currentIndex].center;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    var paint = Paint();
    final topPosition = position.toOffset().translate(0.0, -6.0);

    canvas.drawShadow(
      Path()
        ..addOval(
            Rect.fromCircle(center: position.toOffset(), radius: size.x / 1.6)),
      Colors.black,
      7.0,
      true,
    );

    // paint.style = PaintingStyle.stroke;
    // paint.color = Colors.black;
    // paint.strokeWidth = 2.0;
    // canvas.drawCircle(position.toOffset(), size.x / 2, paint);
    // canvas.drawCircle(topPosition, size.x / 2, paint);

    paint.style = PaintingStyle.fill;

    paint.color = color.darken(0.3);
    canvas.drawCircle(position.toOffset(), size.x / 2, paint);
    paint.color = color;
    canvas.drawCircle(topPosition, size.x / 2, paint);

    TextPaint(config: TextPaintConfig(color: Colors.white, fontSize: 12.0))
        .render(
      canvas,
      name,
      topPosition.toVector2(),
      anchor: Anchor.center,
    );

    super.render(canvas);
  }

  Future<bool> moveTo(int id) async {
    final from = currentIndex;
    final to = id;

    if (currentIndex == to || isBusy || _isMoving) return false;

    isBusy = true;

    List<Vector2> path = generatePath(from, to);

    for (var p in path) {
      _isMoving = true;
      var effects = CombinedEffect(
        effects: [
          MoveEffect(
            path: [p],
            duration: 0.2,
            isAlternating: false,
            curve: Curves.easeInOut,
          ),
          ScaleEffect(
            size: this.size * 1.5,
            duration: 0.2,
            isAlternating: true,
            curve: Curves.easeInOut,
          ),
        ],
        onComplete: () => _isMoving = false,
      );

      addEffect(effects);

      await _waitUntilDone();

      currentIndex = gameRef.spaces.indexWhere((s) => p == s.center);
      print(currentIndex);
      // await Future.delayed(Duration(milliseconds: 500));
    }

    isBusy = false;
    print("done");
    return true;
  }

  List<Vector2> generatePath(int from, int to, [def = const <Vector2>[]]) {
    List<Vector2> path = List.of(def);
    final spaces = gameRef.spaces;

    if (from == spaces.last.id) from = -1;
    for (int i = from + 1; i < spaces.length; i++) {
      path.add(spaces[i].center);
      // print(path.length.toString() + "- " + spaces[i].name);
      if (i == to) break;
      if (i == spaces.last.id && path.last != spaces[to].center)
        return generatePath(-1, to, path);
    }

    return path;
  }

  Future<void> _waitUntilDone() async {
    final completer = Completer();
    if (_isMoving) {
      await Future.delayed(Duration(milliseconds: 100));
      return _waitUntilDone();
    } else {
      completer.complete();
    }
    return completer.future;
  }
}
