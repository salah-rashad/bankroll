import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SimpleButtonComponent extends PositionComponent with Tappable {
  final String text;
  final double fontSize;
  final EdgeInsets padding;
  final VoidCallback onPressed;
  final Radius radius;
  final Color textColor;
  final Color bgColor;

  double _elevation = 8.0;

  bool isEnabled = true;
  bool isTapDown = false;

  late final Rect rect;
  late final TextPaint textPaint;

  SimpleButtonComponent(
    this.text, {
    required Vector2 position,
    required this.onPressed,
    this.fontSize = 14.0,
    this.padding = const EdgeInsets.all(8.0),
    this.radius = const Radius.circular(8.0),
    this.textColor = Colors.black,
    this.bgColor = Colors.blue,
    Anchor anchor = Anchor.topLeft,
  }) : super(position: position, anchor: anchor);

  @override
  Future<void>? onLoad() {
    textPaint = TextPaint(
      config: TextPaintConfig(
        color: this.textColor,
        fontSize: this.fontSize,
      ).withTextAlign(TextAlign.center),
    );

    final textSize = textPaint.measureText(text).toRect();

    final w = textSize.width + padding.horizontal;
    final h = textSize.height + padding.vertical;

    size = Vector2(w, h);

    rect = Rect.fromCenter(
      center: this.center.toOffset(),
      width: w,
      height: h,
    );

    setByRect(rect);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    var p = Paint();

    p.color = isEnabled ? bgColor.darken(0.3) : bgColor.darken(0.6);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(0.0, _elevation), radius), p);

    p.color = isEnabled ? bgColor.darken(0.0) : bgColor.darken(0.5);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.translate(0.0, isTapDown ? _elevation / 2 : 0.0), radius),
        p);

    final textPosition = this
        .center
        .toOffset()
        .translate(0.0, isTapDown ? _elevation / 2 : 0.0);

    textPaint.render(
      canvas,
      text,
      textPosition.toVector2(),
      anchor: Anchor.center,
    );

    super.render(canvas);
  }

  @override
  bool onTapCancel() {
    isTapDown = false;
    return super.onTapCancel();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (isEnabled) isTapDown = true;
    return super.onTapDown(info);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isEnabled) {
      isTapDown = false;
      onPressed();
    }

    return super.onTapUp(info);
  }
}
