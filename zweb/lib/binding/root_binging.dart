import 'package:get/get.dart';
import 'package:zweb/controller/app_controller.dart';

class RootBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AppController());
  }
}
