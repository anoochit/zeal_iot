import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:zweb/binding/root_binging.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/firebase_options.dart';
import 'package:zweb/middleware/routeguard.dart';
import 'package:zweb/pages/authgate.dart';
import 'package:zweb/pages/dashboard.dart';
import 'package:zweb/pages/dashboard_detail.dart';
import 'package:zweb/pages/device.dart';
import 'package:zweb/pages/device_detail.dart';
import 'package:zweb/pages/document.dart';
import 'package:zweb/pages/home.dart';
import 'package:zweb/pages/profile.dart';

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
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Zeal IoT",
      theme: ThemeData(
        primarySwatch: kPrimarySwatch,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(24),
            ),
            shape: MaterialStateProperty.all<OutlinedBorder>(kCardBorderRadius),
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ),
      initialBinding: RootBinding(),
      getPages: [
        GetPage(
          name: "/",
          page: () => HomePage(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/document",
          page: () => DocumentPage(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/signin",
          page: () => AuthGate(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/dashboard",
          page: () => DashboardPage(),
          middlewares: [
            RouteGuard(),
          ],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/dashboard/:id",
          page: () => DashboardDetailPage(),
          middlewares: [
            RouteGuard(),
          ],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/device",
          page: () => DevicePage(),
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/device/:id",
          page: () => DeviceDetailPage(),
          middlewares: [
            RouteGuard(),
          ],
          transition: Transition.noTransition,
        ),
        GetPage(
          name: "/profile",
          page: () => ProfilePage(),
          middlewares: [
            RouteGuard(),
          ],
          transition: Transition.noTransition,
        ),
      ],
    );
  }
}
