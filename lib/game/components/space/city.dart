import 'dart:math';

import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'property.dart';

import 'package:flame/extensions.dart';

class CityProperty extends Property {
  int upgrades = 0;
  int upgradePrice;
  bool upgradeEnabled = false;

  static const int maxUpgrades = 3;

  CityProperty(
    String name,
    int price,
    int rentPrice,
    this.upgradePrice,
    int blockId,
  ) : super(
          name: name,
          initPrice: price,
          initRent: rentPrice,
          type: SpaceType.CITY,
          groupId: blockId,
        );

  Future<void> upgrade() async {
    if (owner == null || !upgradeEnabled || upgrades >= maxUpgrades) return;
    upgrades = min(upgrades + 1, maxUpgrades);
    rent *= 2;
    owner!.decreaseCash(upgradePrice);

    // TODO: working on upgrade cities
  }

  @override
  // int get rent => upgrades > 0 ? initPrice * (upgrades + 1) : super.rent;

  @override
  int get price => super.price + (upgradePrice * upgrades);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (upgradeEnabled) {
      canvas.drawCircle(
        Offset(width * 0.88, height * 0.1),
        8,
        Paint()..color = Colors.greenAccent,
      );
    }
  }

  @override
  Future<void> sell() {
    upgradeEnabled = false;
    upgrades = 0;
    return super.sell();
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (this.upgradeEnabled)
      showInfoCard("upgrade");
    else
      super.onTapUp(info);
    return true;
  }
}
