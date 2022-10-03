import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zweb/controller/app_controller.dart';

class RouteGuard extends GetMiddleware {
  AppController controller = Get.find<AppController>();

  @override
  RouteSettings? redirect(String? route) {
    return controller.isSignIn() ? null : const RouteSettings(name: "/signin");
  }
}
