import 'package:bankroll/app/modules/home/home_controller.dart';
import 'package:bankroll/game/bankroll.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GamePage extends GetView<HomeController> {
  final bankroll = new Bankroll();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget<Bankroll>(game: bankroll),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: IconButton(
              onPressed: () => Get.back(),
              color: Colors.white,
              icon: Icon(Icons.arrow_back),
            ),
          )
        ],
      ),
    );
  }
}
