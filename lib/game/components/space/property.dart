import 'dart:math';
import 'dart:ui' as ui;

import 'package:bankroll/game/components/space/city.dart';
import 'package:bankroll/game/components/space/public.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:bankroll/game/extensions/custom_extensions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/gestures.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../player/player.dart';
import 'space.dart';

abstract class Property extends Space {
  final int initPrice;
  final int initRent;
  final int? groupId;
  Player? owner;

  int get sellPrice => (price * 0.8).toInt().nearest;
  Color get topRectColor => color.darken(0.15);
  Color get topRectTextColor {
    return topRectColor.computeLuminance() > 0.5
        ? Colors.grey.darken(0.7)
        : Colors.grey.brighten(0.7);
  }

  Property({
    required String name,
    required this.initPrice,
    required this.initRent,
    required SpaceType type,
    Color color = Colors.blue,
    this.groupId,
  }) : super(name: name, type: type, color: color);

  int price = 0;
  int rent = 0;
  int tempRent = 0;

  @override
  ui.Image? get icon => super.icon;

  @override
  Future<void>? onLoad() {
    rent = initRent;
    tempRent = initRent;
    price = initPrice;
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    var paint = Paint()..color = topRectColor;

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

    var priceTextPaint = TextPaint(
        config: TextPaintConfig(
      color: topRectTextColor,
      fontSize: max(10, height * 0.16),
    ));

    priceTextPaint.render(
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

      TextPaint(config: priceTextPaint.config.withColor(owner!.initTextColor))
          .render(
        canvas,
        rentText,
        r.center.toVector2(),
        anchor: Anchor.center,
      );
    }
  }

  @override
  Future<void> showInfoCard([String? state]) async {
    final player = gameRef.primaryPlayer;

    final buttonTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16.0,
    );

    var buttonStyle = ElevatedButton.styleFrom(
      primary: color.darken(0.2),
      onPrimary: topRectTextColor,
      textStyle: buttonTextStyle,
      visualDensity: VisualDensity.comfortable,
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    );

    return await Get.dialog<void>(
      Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.center,
          child: Builder(
            builder: (ctx) {
              final w = Get.width * 0.6;
              final h = w * 1.2;
              final r = 10.0;
              final e = max(4.0, h * 0.025);
              return Stack(
                fit: StackFit.loose,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: color.darken(0.3),
                        borderRadius: BorderRadius.circular(r)),
                    width: w,
                    height: h,
                  ),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(r),
                    ),
                    width: w,
                    height: h - e,
                    child: Stack(
                      children: [
                        if (this is PublicProperty) _publicView(w),
                        Column(
                          children: [
                            SizedBox(
                              height: 60.0,
                              child: Center(
                                child: Text(
                                  name.toUpperCase(),
                                  style: TextStyle(
                                      color: nameTextColor, fontSize: 22.0),
                                ),
                              ),
                            ),
                            _values(),
                            Expanded(
                              child: Container(),
                            ),
                            if (this is CityProperty) _cityView(),
                            if (state == "buy" && player.isTurn)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => Get.back(),
                                        child: Text("PASS"),
                                        style: buttonStyle,
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Get.back();
                                          buy(player);
                                        },
                                        label: Text("BUY"),
                                        style: buttonStyle,
                                        icon: Icon(Icons.add_business_rounded),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (state == "upgrade" && player.isTurn)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Get.back();
                                      this.upgrade();
                                    },
                                    label: Text("UPGRADE"),
                                    style: buttonStyle,
                                    icon: Icon(Icons.upgrade_rounded),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            child: Icon(Icons.close_rounded),
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              padding: EdgeInsets.zero,
                              primary: topRectColor,
                              visualDensity: VisualDensity.compact,
                              minimumSize: Size(50.0, 50.0),
                              splashFactory: NoSplash.splashFactory,
                              shadowColor: Colors.transparent,
                            ),
                          ),
                        ),
                        if (owner == player && player.isTurn)
                          ElevatedButton(
                            onPressed: () {
                              Get.back();
                              sell();
                            },
                            child: Text("SELL"),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.redAccent.darken(0.1),
                              onPrimary: Colors.redAccent.brighten(0.5),
                              textStyle: buttonTextStyle,
                              padding: EdgeInsets.symmetric(
                                horizontal: 26.0,
                                vertical: 12.0,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ],
              );
            },
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
        owner!.increaseCash(sellPrice);
        owner = null;
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void upgrade() {}

  void trade() {}

  @override
  bool onTapUp(TapUpInfo info) {
    // print("$name: \$$price");
    // if (gameRef.primaryPlayer.isTurn) buy(gameRef.primaryPlayer);

    showInfoCard("buy");
    return super.onTapUp(info);
  }

  Widget _values() {
    final textStyle = TextStyle(
      color: nameTextColor.withOpacity(0.7),
      fontSize: 16.0,
    );
    final textStyle2 = TextStyle(
      fontSize: 22.0,
      color: nameTextColor,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Price",
                style: textStyle,
              ),
              Text(
                price.toCurrencyString(),
                style: textStyle2,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Rent",
                style: textStyle,
              ),
              Text(
                rent.toCurrencyString(),
                style: textStyle2,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Sell Price",
                softWrap: true,
                style: textStyle,
              ),
              Text(
                sellPrice.toCurrencyString(),
                style: textStyle2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cityView() {
    var city = this as CityProperty;
    return Expanded(
      child: Column(
        children: [
          Text(
            "Each upgrade costs " + city.upgradePrice.toCurrencyString(),
            style: TextStyle(
                color: topRectTextColor,
                backgroundColor: topRectColor,
                fontSize: 14.0),
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                  CityProperty.maxUpgrades,
                  (index) => Column(
                        children: [
                          Icon(
                            index < city.upgrades
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                          ),
                          Text(city.upgradePrice.toCurrencyString()),
                        ],
                      )),
            ),
          )
        ],
      ),
    );
  }

  Widget _publicView(double width) {
    var public = this as PublicProperty;

    return Align(
      alignment:
          name.contains("Rail") ? Alignment.centerLeft : Alignment.center,
      child: iconPath != null
          ? Opacity(
              opacity: 0.3,
              child: Image.asset(
                ("assets/images/" + iconPath.toString()),
                fit: BoxFit.contain,
                width: width * 0.7,
                errorBuilder: (context, error, stackTrace) {
                  return Container();
                },
              ),
            )
          : Container(),
    );
  }
}
