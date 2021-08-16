import 'package:bankroll/app/modules/game/game_binding.dart';
import 'package:bankroll/app/modules/game/game_page.dart';
import 'package:bankroll/app/modules/home/home_binding.dart';
import 'package:bankroll/app/modules/home/home_page.dart';
import 'package:bankroll/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  AppPages._();

  static List<GetPage> get pages => [
        GetPage(
          name: Routes.HOME,
          page: () => HomePage(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: Routes.GAME,
          page: () => GamePage(),
          binding: GameBinding(),
        )
      ];
}
