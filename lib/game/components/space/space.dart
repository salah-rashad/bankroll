import 'dart:math';
import 'dart:ui';

import 'package:bankroll/game/bankroll.dart';
import 'package:bankroll/game/consts/priorities.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart' hide Image;

abstract class Space extends PositionComponent
    with Tappable, HasGameRef<Bankroll> {
  late final int id;
  final String name;
  final SpaceType type;
  Color color;
  String? iconPath;
  bool _onlyIcon = false;

  double _fontSize = 10;

  Image? get icon {
    if (iconPath != null) return Flame.images.fromCache(iconPath!);
  }

  Space({
    required this.name,
    required this.type,
    required this.color,
    this.iconPath,
    bool onlyIcon = false,
  })  : _onlyIcon = onlyIcon,
        super(priority: Priorities.SPACE.index);

  bool get onlyIcon => _onlyIcon;
  double get radius => max(2.0, width * 0.04);
  double get padding => max(1.0, height * 0.015);
  double get elevation => max(4.0, height * 0.05);
  Color get nameTextColor =>
      color.computeLuminance() > 0.5 ? color.darken(0.7) : color.brighten(0.7);

  get owner => null;

  @override
  Future<void>? onLoad() {
    _fontSize = max(10, width * 0.20);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    Paint fill = Paint()..color = color;

    fill.color = fill.color.darken(0.3);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            toRect().deflate(padding), Radius.circular(radius)),
        fill);

    Rect newRect =
        Rect.fromLTWH(toRect().left, toRect().top, width, height - elevation);

    fill.color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          newRect.deflate(padding), Radius.circular(radius)),
      fill..color,
    );

    String text = name.replaceAll(" ", "\n");

    var _textPaint = TextPaint(
      config: TextPaintConfig(
        color: nameTextColor,
        fontSize: _fontSize,
      ).withTextAlign(TextAlign.center),
    );

    var size = _textPaint.measureText(text);

    if (size.x + 4 > width) {
      _fontSize -= 1;
    }

    if (iconPath != null) {
      var rect = Rect.fromLTWH(
        0.0,
        0.0,
        icon!.width.toDouble(),
        icon!.height.toDouble(),
      );

      canvas.drawImageRect(
        icon!,
        rect,
        Rect.fromCenter(
          center:
              center.toOffset().translate(0.0, onlyIcon ? 0.0 : -height * 0.3),
          width: width * 0.8,
          height: width * 0.8,
        ),
        Paint(),
      );

      if (!onlyIcon)
        _textPaint.render(
          canvas,
          text,
          Vector2(center.x, toRect().bottom - height * 0.2),
          anchor: Anchor.bottomCenter,
        );
    } else {
      _textPaint.render(canvas, text, this.center, anchor: Anchor.center);
    }

    super.render(canvas);
  }

  @override
  bool onTapUp(TapUpInfo info) {
    // gameRef.currentPlayer.moveTo(id);

    return super.onTapUp(info);
  }

  Future<void> showInfoCard() async {}
}
