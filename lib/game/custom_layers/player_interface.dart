import 'dart:math';

import 'package:bankroll/game/bankroll.dart';
import 'package:bankroll/game/components/player/player.dart';
import 'package:bankroll/game/extensions/custom_extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/layers.dart';
import 'package:flutter/material.dart';

class PlayerInterface extends PreRenderedLayer {
  final Bankroll gameRef;
  final Player player;

  PlayerInterface({
    required this.gameRef,
    required this.player,
  });

  Offset get center => Offset(
        (gameRef.canvasSize.x /
            (gameRef.players.length + 1) *
            (player.getIndex + 1)),
        gameRef.BOARD_START / 2,
      );

  @override
  void drawLayer() {
    final size = gameRef.canvasSize.x / (gameRef.players.length + 2);

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size, height: size),
      Radius.circular(size),
    );

    canvas.drawRRect(
      rect,
      Paint()..color = player.color,
    );

    if (player.isJailed) {
      TextPaint(
        config: TextPaintConfig(
          fontSize: max(10, size * 0.2),
          color: player.initTextColor,
        ),
      ).render(
        canvas,
        "🔒",
        Vector2(rect.right, rect.top),
        anchor: Anchor.topRight,
      );
    }

    String name = player.name;

    TextPaint _textPaint = TextPaint(
      config: TextPaintConfig(
        fontSize: max(10, size * 0.2),
        color: player.textColor,
      ),
    );

    for (var i = 0; i < name.length; i++) {
      if (_textPaint.measureTextWidth(name) > rect.width) {
        name = name.substring(0, name.length - 2);
        name += "…";
      } else
        break;
    }
    _textPaint.render(
      canvas,
      name,
      center.toVector2(),
      anchor: Anchor.center,
    );

    var cashText = TextPaint(
      config: TextPaintConfig(
        fontSize: max(10, size * 0.15),
        color: player.cash.isNegative
            ? Colors.redAccent
            : gameRef.backgroundColor().computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
      ).withTextAlign(TextAlign.center),
    );
    cashText.render(
      canvas,
      "💵 ${player.cash.toCurrencyString()}",
      Vector2(center.dx, rect.bottom + 4.0),
      anchor: Anchor.topCenter,
    );

    var worth = "💰 (${player.worth.toCurrencyString()})";
    var worthText = TextPaint(
      config: TextPaintConfig(
        fontSize: max(10, size * 0.15),
        color: Colors.greenAccent,
      ).withTextAlign(TextAlign.center),
    );
    worthText.render(
      canvas,
      worth,
      Vector2(center.dx, rect.bottom + 4.0 + cashText.measureTextHeight(worth)),
      anchor: Anchor.topCenter,
    );
  }
}
