import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/firebase_options.dart';
import 'package:zweb/locations/application.dart';
import 'package:zweb/services/firebase_auth.dart';
import 'package:zweb/services/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
          return child!;
        },
      ),
    );
  }
}
