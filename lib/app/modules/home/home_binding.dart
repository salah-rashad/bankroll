import 'dart:io';

import 'package:bankroll/app/modules/home/home_controller.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());

    // sound effects (SFX)
    if (!Platform.isWindows) {
      FlameAudio.audioCache.load("sfx/step.ogg");
      FlameAudio.audioCache.load("sfx/dice-roll.ogg");
    }

    // dice
    Flame.images.loadAll(
      List<String>.generate(6, (i) => "dice/dieRed_border${i + 1}.png"),
    );
    Flame.images.loadAll(
      List<String>.generate(6, (i) => "dice/dieRed${i + 1}.png"),
    );
    Flame.images.loadAll(
      List<String>.generate(6, (i) => "dice/dieWhite_border${i + 1}.png"),
    );
    Flame.images.loadAll(
      List<String>.generate(6, (i) => "dice/dieWhite${i + 1}.png"),
    );

    // events
    Flame.images.load("icons/event/home.png");
    Flame.images.load("icons/event/jail5.png");
    Flame.images.load("icons/event/auction.png");
    Flame.images.load("icons/event/lucky_card.png");

    // public
    Flame.images.load("icons/public/air_cargo.png");
  }
}
