import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

final kPrimarySwatch = Colors.blue;

final kPrimaryColor = Colors.blue;

final kContainerRecRoundDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: Colors.grey.shade200),
  borderRadius: BorderRadius.circular(10),
);

final kTextHeader = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
final kTextHeaderPage = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
final kTextWarning = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
final kTextItemTitle = TextStyle(fontWeight: FontWeight.bold);

final kElevatedButtonRedButton = ElevatedButton.styleFrom(backgroundColor: Colors.red);
final kElevatedButtonGreenButton = ElevatedButton.styleFrom(backgroundColor: Colors.green);
final kElevatedButtonPinkButton = ElevatedButton.styleFrom(backgroundColor: Colors.pink);
final kElevatedButtonAmberButton = ElevatedButton.styleFrom(backgroundColor: Colors.amber);

final kCardBorderRadius = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)));

final defaultAvatar = "https://via.placeholder.com/150";
