import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:zweb/binding/root_binging.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/firebase_options.dart';

import 'const.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await auth.setPersistence(Persistence.LOCAL);

  setPathUrlStrategy();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppController controller = Get.put(AppController());
  @override
  Widget build(BuildContext context) {
    var getMaterialApp = GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Zeal IoT",
      theme: themeData,
      initialBinding: RootBinding(),
      getPages: getPages,
    );
    return getMaterialApp;
  }
}
