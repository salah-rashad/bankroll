import 'dart:async';
import 'dart:ui';

import 'package:bankroll/game/bankroll.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class Player extends PositionComponent with HasGameRef<Bankroll> {
  final String name;
  final Color _color;
  final Color _textColor;
  int cash;
  int worth = 0;

  /// The duration that every step takes, in milliseconds.
  static const double STEP_DURATION = 0.2;

  late final Vector2 originalSize;

  int currentSpaceIndex = 0;

  bool isBusy = false;
  bool _isAnimating = false;

  Color get color => isTurn() ? _color : _color.darken(0.6);
  Color get textColor => isTurn() ? _textColor : _textColor.darken(0.6);

  Player(
    this.name,
    this._color,
    this.cash, [
    this._textColor = Colors.white,
  ]) : super(priority: 6, anchor: Anchor.center);

  bool isTurn() => gameRef.players[gameRef.turn] == this;

  @override
  Future<void>? onLoad() {
    worth = cash;
    originalSize = Vector2.all(gameRef.sWidth / 2);
    this.size = originalSize;
    position = gameRef.spaces[currentSpaceIndex].center;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final bool isFloating = isTurn() && !isBusy;
    var paint = Paint();
    final topPosition = position.toOffset().translate(0.0, -5.0);

    final shadowPath = Path();

    shadowPath.addOval(
      Rect.fromCircle(
          center: position.toOffset(),
          radius: size.x / (isFloating ? 1.6 : 1.8)),
    );

    canvas.drawShadow(
      shadowPath,
      Colors.black,
      isFloating ? 10.0 : 7.0,
      true,
    );

    // if (isTurn()) {
    //   paint.style = PaintingStyle.stroke;
    //   paint.color = Colors.white54;
    //   paint.strokeWidth = 5.0;
    //   canvas.drawCircle(
    //       position.toOffset().translate(0.0, isTurn() ? -4.0 : 0.0),
    //       size.x / 2,
    //       paint);
    //   canvas.drawCircle(
    //       topPosition.translate(0.0, isTurn() ? -3.5 : 0.0), size.x / 2, paint);
    // }

    paint.style = PaintingStyle.fill;

    paint.color = color.darken(0.3);
    canvas.drawCircle(
      position.toOffset().translate(0.0, isFloating ? -4.0 : 0.0),
      width / 2,
      paint,
    );
    paint.color = color;
    canvas.drawCircle(
      topPosition.translate(0.0, isFloating ? -3.5 : 0.0),
      width / 2,
      paint,
    );

    TextPaint(config: TextPaintConfig(color: textColor, fontSize: 12.0)).render(
      canvas,
      name,
      topPosition.translate(0.0, isFloating ? -3.5 : 0.0).toVector2(),
      anchor: Anchor.center,
    );

    super.render(canvas);
  }

  Future<bool> moveTo(int id) async {
    final from = currentSpaceIndex;
    final to = id;

    if (currentSpaceIndex == to || isBusy || _isAnimating) return false;

    isBusy = true;

    List<Vector2> path = generatePath(from, to);

    for (var p in path) {
      _isAnimating = true;
      var effects = CombinedEffect(
        effects: [
          MoveEffect(
            path: [p],
            duration: STEP_DURATION,
            isAlternating: false,
            curve: Curves.easeInOut,
          ),
          ScaleEffect(
            size: this.size * 1.5,
            duration: STEP_DURATION,
            isAlternating: true,
            curve: Curves.easeInOut,
          ),
        ],
        onComplete: () {
          // FlameAudio.audioCache.play("step.ogg", mode: PlayerMode.LOW_LATENCY);
          _isAnimating = false;
        },
      );

      addEffect(effects);

      await _waitUntilDone();

      currentSpaceIndex = gameRef.spaces.indexWhere((s) => p == s.center);

      if (currentSpaceIndex == gameRef.startSpace!.id) await increaseCash(200);

      gameRef.refreshPlayers();
      print(currentSpaceIndex);
    }

    isBusy = false;
    print("done");

    gameRef.refreshPlayers();

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
    if (_isAnimating) {
      await Future.delayed(Duration(milliseconds: 100));
      return _waitUntilDone();
    } else {
      completer.complete();
    }
    return completer.future;
  }

  Future<void> increaseCash(int amount) async {
    this.cash += amount;
    if (!cash.isNegative) worth += amount;
  }

  Future<void> decreaseCash(int amount) async {
    this.cash += amount;
    if (cash.isNegative) worth -= amount;
  }
}
