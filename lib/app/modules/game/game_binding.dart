import 'package:bankroll/app/modules/game/game_controller.dart';
import 'package:get/get.dart';

class GameBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(GameController());
  }
}
