import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bankroll/game/bankroll.dart';
import 'package:bankroll/game/consts/priorities.dart';
import 'package:bankroll/game/custom_layers/player_interface.dart';
import 'package:bankroll/game/enums/direction.dart';
import 'package:bankroll/game/utils/moving_text.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class Player extends PositionComponent
    with HasGameRef<Bankroll>, Tappable {
  /// The duration that every step takes, in milliseconds.
  static const double STEP_DURATION = 0.21;

  final String name;
  final Color initColor;
  Color initTextColor;
  int _cash;
  int worth = 0;
  int jailedRounds = 0;

  late final Vector2 initSize;

  int currentSpaceId = 0;
  bool isBusy = false;

  bool _waitMoving = false;

  Player(
    this.name,
    this.initColor,
    this._cash, [
    this.initTextColor = Colors.white,
  ]) : super(priority: Priorities.PLAYER.index, anchor: Anchor.center);

  int get cash => _cash;

  bool get isTurn => gameRef.currentPlayer == this;
  Color get color => isTurn ? initColor : initColor.darken(0.6);
  Color get textColor => isTurn ? initTextColor : initTextColor.darken(0.6);
  PlayerInterface get interface =>
      PlayerInterface(player: this, gameRef: gameRef);
  bool get isJailed => jailedRounds > 0;

  @override
  Future<void>? onLoad() {
    worth = _cash;
    initTextColor = initColor.computeLuminance() > 0.5
        ? initColor.darken(0.7)
        : initColor.brighten(0.7);
    initSize = Vector2.all(gameRef.sWidth / 2);
    this.size = initSize;
    position = gameRef.spaces[currentSpaceId].center;
    return super.onLoad();
  }

  int get getIndex => gameRef.players.indexWhere((p) => p == this);

  @override
  void render(Canvas canvas) {
    final bool isFloating = isTurn && !isBusy;
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
      name.substring(0, 2),
      topPosition.translate(0.0, isFloating ? -3.5 : 0.0).toVector2(),
      anchor: Anchor.center,
    );

    interface.render(canvas);

    super.render(canvas);
  }

  Future<void> increaseCash(int amount) async {
    this._cash += amount;
    if (!_cash.isNegative) worth += amount;

    await MovingText(
      "+\$$amount",
      gameRef: gameRef,
      position: interface.center.toVector2(),
      config: TextPaintConfig(color: Colors.black, fontSize: 18.0),
      direction: Direction.UP,
      bgColor: Colors.greenAccent,
    ).play();
  }

  Future<void> decreaseCash(int amount, [bool paid = false]) async {
    this._cash -= amount;
    if (paid) {
      worth -= amount;

      await MovingText(
        "-\$$amount",
        gameRef: gameRef,
        position: interface.center.toVector2(),
        config: TextPaintConfig(color: Colors.black, fontSize: 18.0),
        direction: Direction.DOWN,
        bgColor: Colors.redAccent,
      ).play();
    }
  }

  Future<bool> moveTo(int id) async {
    final from = currentSpaceId;
    final to = id;

    if (currentSpaceId == to || isBusy || _waitMoving) return false;

    isBusy = true;

    List<Vector2> path = generatePath(from, to);

    this.size = initSize;

    for (var p in path) {
      _waitMoving = true;
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
          if (!Platform.isWindows)
            FlameAudio.audioCache.play("sfx/step.ogg", volume: 0.5);
          _waitMoving = false;
        },
      );

      addEffect(effects);

      await _waitUntilDone();

      currentSpaceId = gameRef.spaces.indexWhere((s) => p == s.center);

      if (currentSpaceId == gameRef.startSpace!.id) await increaseCash(200);

      print(currentSpaceId);
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
      if (i == to) break;
      if (i == spaces.last.id && path.last != spaces[to].center)
        return generatePath(-1, to, path);
    }

    return path;
  }

  Future<void> _waitUntilDone() async {
    final completer = Completer();
    if (_waitMoving) {
      await await 0.1.delay();
      return _waitUntilDone();
    } else {
      completer.complete();
    }
    return completer.future;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    this._cash += 500;
    return super.onTapUp(info);
  }
}
