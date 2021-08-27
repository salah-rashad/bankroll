import 'dart:ui';

import 'package:bankroll/game/consts/priorities.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flutter/material.dart' hide Image;

import 'property.dart';

class PublicProperty extends Property {
  PublicProperty(
    String name,
    int price,
    int rentPrice, [
    Image? icon,
  ]) : super(
          name: name,
          price: price,
          initRent: rentPrice,
          type: SpaceType.PUBLIC,
          color: Colors.blueGrey[600]!,
          groupId: 0,
        ) {
    this.icon = icon;
  }

  @override
  bool get onlyIcon => true;

  @override
  int get priority => Priorities.PUBLIC_PROPERTY.index;
}
