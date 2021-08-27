import 'dart:ui';

import 'package:bankroll/game/components/player/player.dart';
import 'package:bankroll/game/consts/priorities.dart';
import 'package:flutter/material.dart';

class RemotePlayer extends Player {
  RemotePlayer(String name, Color color, int cash,
      [Color textColor = Colors.white])
      : super(name, color, cash, textColor);

  @override
  int get priority => Priorities.REMOTE_PLAYER.index;
}
