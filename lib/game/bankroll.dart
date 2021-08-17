import 'dart:math';

import 'package:bankroll/game/components/buttons/simple_button.dart';
import 'package:bankroll/game/components/city.dart';
import 'package:bankroll/game/components/dice.dart';
import 'package:bankroll/game/components/player.dart';
import 'package:bankroll/game/components/space.dart';
import 'package:bankroll/game/enums/property_type_enum.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'components/event_space.dart';
import 'components/public.dart';

class Bankroll extends BaseGame with HasTappableComponents, KeyboardEvents {
  RxList<Player> players = <Player>[].obs;

  RxInt _playerTurn = 0.obs;
  int get turn => this._playerTurn.value;
  set turn(int value) => this._playerTurn.value = value;

  int lastRoll = 1;

  double get sWidth => Get.width / 8;
  double get sHeight => sWidth + (sWidth * 0.2);
  double get BOARD_START => (Get.height % (8 * sHeight)) / 2;
  double get BOARD_END => Get.height - BOARD_START;

  List<Space> spaces = <Space>[];

  late final Space? startSpace;

  @override
  bool get debugMode => false;

  late final SimpleButtonComponent rollButton;
  final Dice dice = Dice();

  static List<Space> get _boardSpaces => [
        //
        EventSpace(
          name: "START",
          type: SpaceType.START,
          color: Colors.white,
          rect: Rect.zero,
        ),
        //
        // Block 1
        CityProperty("Rio", 100, 10, 50, 1),
        CityProperty("Delhi", 100, 10, 50, 1),
        // Block 2
        CityProperty("Bangkok", 150, 15, 70, 2),
        PublicProperty("Harbor", 100, 35),
        CityProperty("Cairo", 150, 15, 80, 2),
        CityProperty("Madrid", 150, 15, 80, 2),
        //
        EventSpace(
          name: "Lucky Card",
          type: SpaceType.LUCKY_CARD,
          color: Colors.white,
          rect: Rect.zero,
        ),
        //
        // Block 3
        CityProperty("Jakarta", 170, 20, 90, 3),
        CityProperty("Berlin", 180, 20, 100, 3),
        // Block 4
        CityProperty("Moscow", 200, 30, 120, 4),
        PublicProperty("Railway", 150, 35),
        CityProperty("Toronto", 200, 30, 120, 4),
        CityProperty("Seoul", 200, 30, 120, 4),
        //
        EventSpace(
          name: "Jail",
          type: SpaceType.JAIL,
          color: Colors.white,
          rect: Rect.zero,
        ),
        //
        // Block 5
        CityProperty("Zurich", 250, 70, 140, 5),
        CityProperty("Riyadh", 250, 70, 140, 5),
        // Block 6
        CityProperty("Sydney", 300, 40, 170, 6),
        PublicProperty("Electricity", 200, 35),
        CityProperty("Beijing", 300, 80, 170, 6),
        CityProperty("Dubai", 300, 80, 170, 6),
        //
        EventSpace(
          name: "Auction",
          type: SpaceType.AUCTION,
          color: Colors.white,
          rect: Rect.zero,
        ),
        //
        // Block 7
        CityProperty("Paris", 350, 45, 200, 7),
        CityProperty("Hong Kong", 350, 50, 200, 7),
        // Block 8
        CityProperty("London", 420, 70, 200, 8),
        PublicProperty("Airport", 250, 35),
        CityProperty("Tokyo", 420, 70, 200, 8),
        CityProperty("New York", 450, 80, 200, 8),
      ];

  List<Color?> blocksColors = [
    Colors.blue[200],
    Colors.green[300],
    Colors.pink[600],
    Colors.amber[400],
    Colors.teal[600],
    Colors.orange[700],
    Colors.purple[600],
    Colors.red[600],
  ];

  @override
  Future<void> onLoad() async {
    await buildGameBoard();

    players.addAll([
      Player("1", Colors.red, 1000),
      Player("2", Colors.green, 1050),
      Player("3", Colors.yellow, 1100),
      Player("4", Colors.blue, 1150),
    ]);

    await addAll(players);

    refreshPlayers();

    turn = randomTurn();

    rollButton = SimpleButtonComponent(
      "ROLL",
      onPressed: rollDice,
      position: Vector2(Get.width / 2, BOARD_END + 32.0),
      anchor: Anchor.topCenter,
      fontSize: 16.0,
      radius: Radius.circular(4.0),
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
    );
    add(rollButton);

    add(dice);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    // Drawing background
    Paint centerPanelFill = Paint()..color = Colors.purple[900]!;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.largest, Radius.circular(4.0)),
        centerPanelFill);

    TextPaint().render(
      canvas,
      "Rolled: $lastRoll",
      Vector2(Get.width / 2, 64.0),
      anchor: Anchor.center,
    );

    TextPaint().render(
      canvas,
      "Turn: " + players[turn].name,
      Vector2(Get.width - 8.0, 64.0),
      anchor: Anchor.centerRight,
    );

    super.render(canvas);
  }

  int randomTurn() {
    int r = Random().nextInt(players.length);
    if (r == 0) return randomTurn();
    return r;
  }

  Future<void> buildGameBoard() async {
    spaces = _boardSpaces;

    for (int i = 0; i < spaces.length; i++) {
      var space = spaces[i];
      space.id = i;
      if (space.type == SpaceType.START) startSpace = space;
      if (space is CityProperty) {
        space.color = blocksColors[space.blockId! - 1]!;
      }

      Vector2 position;

      // Start => Madrid
      position = Vector2(
        0.0,
        BOARD_START + sHeight * (7 - i),
      );

      // Lucky Card => Seoul
      if (i > 6)
        position = Vector2(
          sWidth * (i - 7),
          BOARD_START,
        );

      // Jail => Dubai
      if (i > 13)
        position = Vector2(
          Get.width - sWidth,
          BOARD_START + sHeight * (i - 14),
        );

      // Auction => New York
      if (i > 20)
        position = Vector2(
          sWidth * (spaces.length % i),
          BOARD_START + 7 * sHeight,
        );

      space.position = position;
      space.size = Vector2(sWidth, sHeight);

      await add(space);
    }
  }

  Future<void> rollDice() async {
    if (players[turn].isBusy) return;
    lastRoll = await dice.roll();

    int destination = players[turn].currentSpaceIndex + lastRoll;

    rollButton.isEnabled = false;
    await players[turn].moveTo(destination % spaces.length);
    rollButton.isEnabled = true;

    if (lastRoll == 6) return;

    turn = (turn + 1) % players.length;
  }

  void refreshPlayers() {
    for (var s in spaces) {
      final double w = s.toRect().width;
      final double h = s.toRect().height;

      final List<Vector2> rooms = List.generate(4, (i) {
        switch (i) {
          case 0:
            return Vector2(
              s.x + (w / 4),
              s.y + (h / 4),
            );

          case 1:
            return Vector2(
              s.x + (w - (w / 4)),
              s.y + (h / 4),
            );

          case 2:
            return Vector2(
              s.x + (w / 4),
              s.y + (h - (h / 4)),
            );

          case 3:
            return Vector2(
              s.x + (w - (w / 4)),
              s.y + (h - (h / 4)),
            );
          default:
            return s.center;
        }
      }, growable: false);

      var overlapping = <Player>[];

      for (var p in players) {
        if (s.toRect().overlaps(p.toRect())) overlapping.add(p);
      }

      for (int i = 0; i < overlapping.length; i++) {
        var p = overlapping[i];
        if (overlapping.length > 1) {
          p.size = p.isBusy ? p.originalSize : p.originalSize / 2;
          p.addEffect(MoveEffect(path: [rooms[i]], duration: 0.1));
        } else {
          p.size = p.originalSize;
          p.addEffect(MoveEffect(path: [s.center], duration: 0.1));
        }
      }
    }
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.numpad1)) turn = 0;
    if (event.isKeyPressed(LogicalKeyboardKey.numpad2)) turn = 1;
    if (event.isKeyPressed(LogicalKeyboardKey.numpad3)) turn = 2;
    if (event.isKeyPressed(LogicalKeyboardKey.numpad4)) turn = 3;
    if (event.isKeyPressed(LogicalKeyboardKey.space)) rollDice();
  }
}
