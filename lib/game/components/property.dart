import 'dart:ui';

import 'package:bankroll/game/components/space.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

abstract class Property extends Space {
  final int price;
  final int rentPrice;
  final int? blockId;

  Property({
    required String name,
    required this.price,
    required this.rentPrice,
    required SpaceType type,
    Color color = Colors.blue,
    this.blockId,
  }) : super(name: name, type: type, color: color);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    var paint = Paint()..color = color.darken(0.15);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
          Rect.fromLTWH(
            position.toRect().left,
            position.toRect().top,
            width,
            height / 3.7,
          ).deflate(padding),
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0)),
      paint,
    );

    String text = "\$" + price.toString();

    var textPaint = TextPaint(
        config: TextPaintConfig(
      color: Colors.black87,
      fontSize: 10.0,
    ));

    textPaint.render(
      canvas,
      text,
      Vector2(width / 2, 2.7),
      anchor: Anchor.topCenter,
    );
  }

  void buy() {}

  void sell() {}

  void trade() {}

  @override
  bool onTapUp(TapUpInfo info) {
    print("$name: \$$price");
    return super.onTapUp(info);
  }
}
