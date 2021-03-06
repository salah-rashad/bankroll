import 'dart:math';

import 'package:bankroll/game/components/player/general_player.dart';
import "package:collection/collection.dart";
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'components/buttons/simple_button.dart';
import 'components/dice.dart';
import 'components/player/player.dart';
import 'components/player/remote_player.dart';
import 'components/space/city.dart';
import 'components/space/event_space.dart';
import 'components/space/property.dart';
import 'components/space/public.dart';
import 'components/space/space.dart';
import 'enums/property_type_enum.dart';

class Bankroll extends BaseGame with HasTappableComponents, KeyboardEvents {
  RxList<Player> players = <Player>[].obs;

  RxInt _turn = 0.obs;

  int lastRoll = 1;
  bool isRolling = false;
  List<Space> spaces = <Space>[];

  late final Space? startSpace;
  late final SimpleButtonComponent rollButton;

  final Dice dice = Dice();

  double get BOARD_END => Get.height - BOARD_START;
  double get BOARD_START => (Get.height % (8 * sHeight)) / 2;
  double get BOARD_WIDTH => Get.width;
  double get BOARD_HEIGHT => sHeight * 8;

  Player get currentPlayer => players[turn];

  @override
  bool get debugMode => false;

  Player get primaryPlayer => players.singleWhere((p) => p is GeneralPlayer);
  double get sHeight => sWidth * 1.2;
  double get sWidth => Get.width / 8;

  int get turn => this._turn.value;
  set turn(int value) => this._turn.value = value;

  Future<void> buildGameBoard() async {
    spaces = _boardSpaces;

    for (int i = 0; i < spaces.length; i++) {
      var space = spaces[i];
      space.id = i;
      if (space.type == SpaceType.START) startSpace = space;
      if (space is CityProperty) {
        space.color = _blocksColors[space.groupId! - 1]!;
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

  @override
  Future<void> onLoad() async {
    await buildGameBoard();

    players.addAll([
      GeneralPlayer("P1", Colors.red[700]!, 1000),
      RemotePlayer("P2", Colors.green, 1050),
      RemotePlayer("P3", Colors.yellow[600]!, 1100),
      RemotePlayer("P4", Colors.blue, 1150),
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
    Paint background = Paint()..color = Colors.purple.darken(0.8);
    canvas.drawRect(
      Rect.largest,
      background,
    );

    canvas.drawShadow(
      Path()
        ..moveTo(10.0, BOARD_END + 10.0)
        ..relativeLineTo(16.0, 16.0)
        ..relativeArcToPoint(
          Offset(60.0, 30.0),
          radius: Radius.circular(60.0),
          clockwise: false,
        )
        ..relativeLineTo(BOARD_WIDTH, 0.0)
        ..relativeLineTo(0.0, -80),
      Colors.black,
      5.0,
      true,
    );

    var boardRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0.0, BOARD_START, BOARD_WIDTH, BOARD_HEIGHT + 16.0),
        Radius.circular(16.0));

    final boardColor = Colors.blueGrey;
    Paint board = Paint()..color = boardColor.darken(0.5);
    canvas.drawRRect(
      boardRect,
      board,
    );
    board.color = boardColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0.0, BOARD_START, BOARD_WIDTH, BOARD_HEIGHT),
          Radius.circular(8.0)),
      board,
    );

    super.render(canvas);
  }

  @override
  void update(double dt) {
    try {
      var properties =
          spaces.where((s) => s is Property).toList().cast<Property>();
      var groups = properties.groupListsBy((p) => p.groupId);

      for (var player in players) {
        groups.forEach((i, props) {
          var shared = props.where((p) => p.owner == player).toList();
          int sumRent =
              shared.fold<int>(0, (prev, next) => prev + next.initRent);

          List<CityProperty> cities = props.whereType<CityProperty>().toList();

          shared.forEach((p) {
            if (!cities.singleWhere((e) => e.id == p.id).upgradeEnabled)
              p.rent = sumRent;
          });

          if (cities.every((element) => element.owner == primaryPlayer)) {
            cities.forEach((city) {
              if (city.owner == primaryPlayer && primaryPlayer.isTurn)
                city.upgradeEnabled = true;
              else
                city.upgradeEnabled = false;
            });
          } else
            cities.forEach((element) => element.upgradeEnabled = false);
        });
      }
    } catch (e) {
      print(e);
    }
    super.update(dt);
  }

  int randomTurn() {
    int r = Random().nextInt(players.length);
    if (r == 0) return randomTurn();
    return r;
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

      var overlapping = players.where((p) => p.currentSpaceId == s.id).toList();

      for (int i = 0; i < overlapping.length; i++) {
        var p = overlapping[i];
        if (overlapping.length > 1) {
          p.size = p.isBusy ? p.initSize : p.initSize / 2;
          p.addEffect(MoveEffect(path: [rooms[i]], duration: 0.1));
        } else {
          p.size = p.initSize;
          p.addEffect(MoveEffect(path: [s.center], duration: 0.1));
        }
      }
    }
  }

  Future<void> rollDice([int? forceDest]) async {
    if (currentPlayer.isBusy || isRolling)
      return;
    else if (currentPlayer.isJailed) {
      return nextTurn();
    }

    isRolling = true;
    rollButton.isEnabled = false;

    lastRoll = await dice.roll();

    int destination = (currentPlayer.currentSpaceId + lastRoll) % spaces.length;

    if (forceDest != null) destination = forceDest;

    await currentPlayer.moveTo(destination);

    // Destination space
    var destSpace = spaces[destination];

    if (destSpace is Property) {
      var owner = destSpace.owner;
      if (currentPlayer == primaryPlayer) {
        if (owner == null) {
          if (primaryPlayer.cash >= destSpace.price)
            await destSpace.showInfoCard("buy");
        } else {
          if (owner == primaryPlayer) {
            if (primaryPlayer.cash.isNegative) {
              await destSpace.showInfoCard("sell");
            }
          } else {
            owner.increaseCash(destSpace.rent);
            await primaryPlayer.decreaseCash(destSpace.rent, true);
          }
        }
      } else {
        if (owner == null) {
          if (destSpace is Property && currentPlayer.cash >= destSpace.price) {
            await destSpace.buy(currentPlayer);
          }
        } else {
          if (owner != currentPlayer) {
            owner.increaseCash(destSpace.rent);
            await currentPlayer.decreaseCash(destSpace.rent, true);
          }
        }
      }
    }

    if (destSpace.type == SpaceType.JAIL) {
      currentPlayer.jailedRounds = 3;
      Get.showSnackbar(
        GetBar(
          title: currentPlayer.name,
          message: "Jailed for (${currentPlayer.jailedRounds}) rounds!",
          duration: Duration(seconds: 5),
          backgroundColor: Colors.black87,
          borderColor: currentPlayer.initColor,
          borderRadius: 2.0,
          borderWidth: 2.0,
        ),
      );

      await 2.delay();
      await nextTurn();
      return;
    }

    rollButton.isEnabled = true;
    isRolling = false;

    if (lastRoll == 6 && !currentPlayer.isJailed) return;
    await nextTurn();
  }

  Future<void> nextTurn() async {
    turn = (turn + 1) % players.length;

    if (currentPlayer.isJailed) {
      rollButton.isEnabled = false;
      isRolling = true;

      Get.showSnackbar(
        GetBar(
          icon: Text(
            currentPlayer.jailedRounds.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: currentPlayer.initColor, fontSize: 22.0),
          ),
          titleText: Text(
            currentPlayer.name,
            style: TextStyle(color: currentPlayer.initColor),
          ),
          message: "rounds remaining in jail.",
          duration: Duration(seconds: 5),
          backgroundColor: Colors.black87,
          borderColor: currentPlayer.initColor,
          borderRadius: 2.0,
          borderWidth: 2.0,
        ),
      );
      currentPlayer.jailedRounds--;
      await 2.delay();
      nextTurn();
      return;
    }
    rollButton.isEnabled = true;
    isRolling = false;
  }

  @override
  Future<void> onKeyEvent(RawKeyEvent event) async {
    if (event.isKeyPressed(LogicalKeyboardKey.numpad1)) turn = 0;
    if (event.isKeyPressed(LogicalKeyboardKey.numpad2)) turn = 1;
    if (event.isKeyPressed(LogicalKeyboardKey.numpad3)) turn = 2;
    if (event.isKeyPressed(LogicalKeyboardKey.numpad4)) turn = 3;
    if (event.isKeyPressed(LogicalKeyboardKey.space)) {
      if (isRolling) return;
      rollDice();
      rollButton.isTapDown = true;
      await await 0.1.delay();
      rollButton.isTapDown = false;
    }
    if (event.isKeyPressed(LogicalKeyboardKey.enter))
      turn = (turn + 1) % players.length;

    if (event.isKeyPressed(LogicalKeyboardKey.backspace)) Get.back();

    if (event.isKeyPressed(LogicalKeyboardKey.end)) rollDice(14);
  }
}

List<Color?> get _blocksColors => [
      Color(0xFFd4ee92),
      Color(0xFF6b98ea),
      Color(0xFF7a9d51),
      Color(0xFFa94ff6),
      Color(0xFF74d7b6),
      Color(0xFFFFB01C),
      Color(0xFFeb54ce),
      Color(0xFFb93f47),
    ];

List<Space> get _boardSpaces => [
      //
      EventSpace(
        name: "START",
        type: SpaceType.START,
        color: Colors.white,
        rect: Rect.zero,
        iconPath: "icons/event/home.png",
      ),
      //
      // Block 1
      CityProperty("Rio", 100, 10, 50, 1),
      CityProperty("Delhi", 100, 10, 50, 1),
      // Block 2
      CityProperty("Bangkok", 130, 15, 70, 2),
      PublicProperty(
        "Trucking",
        100,
        35,
        "icons/public/trucking.png",
      ),
      CityProperty("Cairo", 150, 15, 80, 2),
      CityProperty("Madrid", 150, 15, 80, 2),
      //
      EventSpace(
        name: "Lucky Card",
        type: SpaceType.LUCKY_CARD,
        color: Colors.white,
        rect: Rect.zero,
        iconPath: "icons/event/lucky_card.png",
      ),
      //
      // Block 3
      CityProperty("Jakarta", 170, 20, 90, 3),
      CityProperty("Berlin", 180, 20, 100, 3),
      // Block 4
      CityProperty("Moscow", 200, 30, 120, 4),
      PublicProperty(
        "Rail Freight",
        150,
        35,
        "icons/public/rail.png",
      ),
      CityProperty("Toronto", 200, 30, 120, 4),
      CityProperty("Seoul", 200, 30, 120, 4),
      //
      EventSpace(
        name: "Jail",
        type: SpaceType.JAIL,
        color: Colors.grey[200]!,
        rect: Rect.zero,
        iconPath: "icons/event/jail5.png",
      ),
      //
      // Block 5
      CityProperty("Zurich", 250, 35, 140, 5),
      CityProperty("Riyadh", 250, 35, 140, 5),
      // Block 6
      CityProperty("Sydney", 300, 40, 170, 6),
      PublicProperty(
        "Ocean Freight",
        200,
        35,
        "icons/public/ocean.png",
      ),
      CityProperty("Beijing", 300, 40, 170, 6),
      CityProperty("Dubai", 300, 40, 170, 6),
      //
      EventSpace(
        name: "Auction",
        type: SpaceType.AUCTION,
        color: Colors.white,
        rect: Rect.zero,
        iconPath: "icons/event/auction.png",
        onlyIcon: true,
      ),
      //
      // Block 7
      CityProperty("Paris", 350, 45, 200, 7),
      CityProperty("Hong Kong", 350, 50, 200, 7),
      // Block 8
      CityProperty("London", 420, 70, 200, 8),
      PublicProperty(
        "Air Cargo",
        250,
        35,
        "icons/public/air.png",
      ),
      CityProperty("Tokyo", 420, 70, 200, 8),
      CityProperty("New York", 450, 80, 200, 8),
    ];
