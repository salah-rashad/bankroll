import 'package:bankroll/app/modules/home/home_binding.dart';
import 'package:bankroll/app/routes/app_pages.dart';
import 'package:bankroll/app/routes/app_routes.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: HomeBinding(),
      initialRoute: Routes.HOME,
      getPages: AppPages.pages,
    ),
  );

  Flame.device.fullScreen();
  Flame.device.setPortraitUpOnly();
}
