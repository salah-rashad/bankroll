import 'dart:ui';

import 'package:bankroll/game/components/space.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/material.dart';

class EventSpace extends Space {
  EventSpace({
    required String name,
    required SpaceType type,
    Rect rect = Rect.zero,
    Color color = Colors.white,
  }) : super(name: name, color: color, type: type);

  @override
  bool onTapUp(TapUpInfo info) {
    print("[$name]");
    return super.onTapUp(info);
  }
}
