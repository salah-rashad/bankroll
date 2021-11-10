import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundTextComponent<T extends TextRenderer<BaseTextConfig>>
    extends TextComponent<T> {
  final Color? bgColor;
  final Radius? radius;
  final bool hasShadow;
  BackgroundTextComponent(
    String text, {
    required this.bgColor,
    this.radius,
    this.hasShadow = true,
    T? textRenderer,
    Vector2? position,
    Vector2? size,
    int? priority,
  }) : super(
          text,
          position: position,
          priority: priority,
          size: size,
          textRenderer: textRenderer,
        );

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    var bgRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center.toOffset(), width: width, height: height),
      radius ?? Radius.zero,
    );

    if (bgColor != null && hasShadow) {
      canvas.drawShadow(Path()..addRRect(bgRRect), Colors.black, 15.0, true);
    }
    canvas.drawRRect(
      bgRRect,
      Paint()..color = bgColor ?? Colors.black,
    );

    super.render(canvas);
  }
}
