import 'dart:ui';

import 'package:bankroll/game/consts/priorities.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart' hide Image;

import 'space.dart';

class EventSpace extends Space {
  EventSpace({
    required String name,
    required SpaceType type,
    Rect rect = Rect.zero,
    Color color = Colors.white,
    String? iconPath,
    bool onlyIcon = false,
  }) : super(
          name: name.toUpperCase(),
          color: color,
          type: type,
          iconPath: iconPath,
          onlyIcon: onlyIcon,
        );

  @override
  int get priority => Priorities.EVENT_SPACE.index;

  @override
  bool onTapUp(TapUpInfo info) {
    print("[$name]");
    return super.onTapUp(info);
  }
}
