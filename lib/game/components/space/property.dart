import 'dart:math';
import 'dart:ui';

import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:bankroll/game/extensions/custom_extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:get/get.dart';

import '../player/player.dart';
import 'space.dart';

abstract class Property extends Space {
  final int price;
  final int initRent;
  final int? groupId;
  Player? owner;

  int get sellPrice => (price * 0.8).ceil();

  Property({
    required String name,
    required this.price,
    required this.initRent,
    required SpaceType type,
    Color color = Colors.blue,
    this.groupId,
  }) : super(name: name, type: type, color: color);

  int rent = 0;

  @override
  Image? get icon => super.icon;

  @override
  Future<void>? onLoad() {
    rent = initRent;
    return super.onLoad();
  }

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
          height * 0.25,
        ).deflate(padding),
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(0.0),
        bottomRight: Radius.circular(0.0),
      ),
      paint,
    );

    String priceText = price.toCurrencyString();
    String rentText = rent.toCurrencyString();

    var textPaint = TextPaint(
        config: TextPaintConfig(
      color: paint.color.computeLuminance() > 0.5
          ? Colors.grey.darken(0.5)
          : Colors.grey.brighten(0.7),
      fontSize: max(10, height * 0.16),
    ));

    textPaint.render(
      canvas,
      priceText,
      Vector2(width / 2, 2.7),
      anchor: Anchor.topCenter,
    );

    if (owner != null) {
      var r = Rect.fromLTWH(
        width % (width * 0.95) / 2,
        0.0,
        width * 0.95,
        height * 0.30,
      ).deflate(height * 0.030);

      canvas.drawRect(
        r,
        Paint()..color = Colors.white,
      );

      canvas.drawRect(
        Rect.fromCenter(
          center: r.center,
          width: width * 0.95,
          height: height * 0.30,
        ).deflate(height * 0.050),
        Paint()..color = owner!.initColor,
      );

      TextPaint(config: textPaint.config.withColor(owner!.initTextColor))
          .render(
        canvas,
        rentText,
        r.center.toVector2(),
        anchor: Anchor.center,
      );
    }
  }

  Future<void> showInfoCard([String? state]) async {
    final player = gameRef.generalPlayer;

    return await Get.dialog<void>(
      Align(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16.0)),
          width: Get.width * 0.6,
          height: 200.0,
          child: Column(
            children: [
              if (state == "buy")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Text("PASS"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        buy(player);
                      },
                      child: Text("BUY"),
                    ),
                  ],
                )
              else if (state == "sell")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        sell();
                        Get.back();
                      },
                      child: Text("SELL"),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Text("CLOSE"),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("CLOSE"),
                ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.decelerate,
    );
  }

  Future<void> buy(Player player) async {
    owner = player;
    await player.decreaseCash(price);
  }

  Future<void> sell() async {
    try {
      if (owner != null) {
        await owner!.increaseCash(sellPrice);
        owner = null;
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void trade() {}

  @override
  bool onTapUp(TapUpInfo info) {
    // print("$name: \$$price");
    // if (gameRef.currentPlayer == gameRef.generalPlayer)
    //   buy(gameRef.generalPlayer);
    if (owner == gameRef.generalPlayer && gameRef.generalPlayer.isTurn)
      showInfoCard("sell");
    else
      showInfoCard();
    return super.onTapUp(info);
  }

  @override
  bool onTapCancel() {
    sell();
    return super.onTapCancel();
  }
}
