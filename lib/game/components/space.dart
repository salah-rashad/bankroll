import 'dart:ui';

import 'package:bankroll/game/bankroll.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

abstract class Space extends PositionComponent
    with Tappable, HasGameRef<Bankroll> {
  late final int id;
  final String name;
  final SpaceType type;
  Color color;

  double radius = 2.0;
  double padding = 1.0;
  double elevation = 4.0;

  Space({
    required this.name,
    required this.type,
    required this.color,
  });

  var _textPaint = TextPaint(
    config: TextPaintConfig(
      color: Colors.black,
      fontSize: 12.0,
    ).withTextAlign(TextAlign.center),
  );

  @override
  void render(Canvas canvas) {
    Paint fill = Paint()..color = color;

    fill.color = fill.color.withAlpha(150);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            toRect().deflate(padding), Radius.circular(radius)),
        fill);

    Rect newRect =
        Rect.fromLTWH(toRect().left, toRect().top, width, height - elevation);

    fill.color = fill.color.withAlpha(255);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          newRect.deflate(padding), Radius.circular(radius)),
      fill..color,
    );

    String text = name.replaceAll(" ", "\n");

    var size = _textPaint.measureText(text);

    if (size.x + 4 > width) {
      _textPaint = _textPaint
          .copyWith((config) => TextPaintConfig(fontSize: config.fontSize - 1));
      // print(textPaint.config.fontSize);
    }

    _textPaint.render(canvas, text, this.center, anchor: Anchor.center);
    super.render(canvas);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    gameRef.players[gameRef.turn].moveTo(id);
    return super.onTapUp(info);
  }
}
