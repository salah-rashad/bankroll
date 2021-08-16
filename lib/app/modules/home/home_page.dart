import 'package:bankroll/app/modules/home/home_controller.dart';
import 'package:bankroll/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(32.0),
              child: Text("Bankroll", style: TextStyle(fontSize: 22.0)),
            ),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.GAME),
              child:
                  Text("START", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
