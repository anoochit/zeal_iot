import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/locations/application.dart';
import 'package:zweb/services/firebase_auth.dart';
import 'package:zweb/services/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<FirebaseApp> _initialization = Firebase.initializeApp();

  late final _routerDelegate;

  @override
  void initState() {
    super.initState();

    // set router delegate
    _routerDelegate = BeamerDelegate(
      initialPath: '/',
      locationBuilder: (p0, p1) => AppLocation(),
      guards: <BeamGuard>[
        BeamGuard(
          pathPatterns: [
            '/device',
            '/device/:deviceId',
            '/dashboard',
            '/dashboard/:dashboardId',
            '/profile',
          ],
          check: (context, location) => isSignIn() == true,
          beamToNamed: (origin, target) => '/signin',
        ),
        BeamGuard(
          pathPatterns: ['/', '/signin', '/signup', '/document'],
          check: (context, location) => isSignIn() == false,
          beamToNamed: (origin, target) => '/dashboard',
        ),
      ],
    );

    // set firebase auth listener
    firebaseAuth.authStateChanges().listen((User? user) async {
      if (user == null) {
        log('User is currently signed out!');
        setState(() {});
      } else {
        log('User is signed in!');
        getUserSharedPreference();
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BeamerProvider(
      routerDelegate: _routerDelegate,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: kPrimarySwatch,
          //primaryColor: kPrimaryColor,
          canvasColor: Colors.grey.shade50,
          textTheme: TextTheme(
            bodyText2: TextStyle(fontSize: 16.0),
          ),
        ),
        routerDelegate: _routerDelegate,
        routeInformationParser: BeamerParser(),
        builder: (context, child) {
          return FutureBuilder(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(color: Colors.red);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                // this child is the Navigator stack produced by Beamer
                return child!;
              }
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
