import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:zweb/middleware/routeguard.dart';
import 'package:zweb/pages/authgate.dart';
import 'package:zweb/pages/dashboard.dart';
import 'package:zweb/pages/dashboard_detail.dart';
import 'package:zweb/pages/device.dart';
import 'package:zweb/pages/device_detail.dart';
import 'package:zweb/pages/document.dart';
import 'package:zweb/pages/home.dart';
import 'package:zweb/pages/profile.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class Menu {
  final String title;
  final String link;

  Menu(this.title, this.link);
}

final listMenu = [
  Menu("Home", "/"),
  Menu("Document", "/document"),
  Menu("Sign In", "/signin"),
];

final listDashboardMenu = [
  Menu("Dashboard", "/dashboard"),
  Menu("Device", "/device"),
  Menu("Profile", "/profile"),
  Menu("Sign Out", "/signout"),
];

class DashboardWidget {
  final String title;
  final String slug;

  DashboardWidget(this.title, this.slug);
}

final listDashboardWidget = [
  DashboardWidget("Text", "text"),
  DashboardWidget("Radial Gauge", "guage"),
  DashboardWidget("Line Chart", "line"),
  DashboardWidget("Spline Chart", "spline"),
  DashboardWidget("Area Chart", "area"),
  DashboardWidget("Bar Chart", "bar"),
  DashboardWidget("Switch", "switch"),
  DashboardWidget("Map", "map"),
  DashboardWidget("Status", "status"),
];

class ChartData {
  final Timestamp timestamp;
  final double value;

  ChartData({required this.timestamp, required this.value});
}

// theme

const kPrimarySwatch = Colors.blue;

const kPrimaryColor = Colors.blue;

final kContainerRecRoundDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.grey.shade200),
  borderRadius: BorderRadius.circular(10),
);

const kTextHeader = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const kTextHeaderPage = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const kTextWarning = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
const kTextItemTitle = TextStyle(fontWeight: FontWeight.bold);

final kElevatedButtonRedButton = ElevatedButton.styleFrom(backgroundColor: Colors.red);
final kElevatedButtonGreenButton = ElevatedButton.styleFrom(backgroundColor: Colors.green);
final kElevatedButtonPinkButton = ElevatedButton.styleFrom(backgroundColor: Colors.pink);
final kElevatedButtonAmberButton = ElevatedButton.styleFrom(backgroundColor: Colors.amber);

const kCardBorderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)));

const defaultAvatar = "https://via.placeholder.com/150";

final themeData = ThemeData(
  primarySwatch: kPrimarySwatch,
  canvasColor: Colors.white,
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
      // backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
      // foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    ),
  ),
);

// route

final getPages = [
  GetPage(
    name: "/",
    page: () => const HomePage(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/document",
    page: () => const DocumentPage(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/signin",
    page: () => const AuthGate(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/dashboard",
    page: () => const DashboardPage(),
    middlewares: [
      RouteGuard(),
    ],
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/dashboard/:id",
    page: () => const DashboardDetailPage(),
    middlewares: [
      RouteGuard(),
    ],
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/device",
    page: () => const DevicePage(),
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/device/:id",
    page: () => const DeviceDetailPage(),
    middlewares: [
      RouteGuard(),
    ],
    transition: Transition.noTransition,
  ),
  GetPage(
    name: "/profile",
    page: () => const ProfilePage(),
    middlewares: [
      RouteGuard(),
    ],
    transition: Transition.noTransition,
  ),
];
