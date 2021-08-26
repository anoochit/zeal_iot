import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zweb/pages/dashboard.dart';
import 'package:zweb/pages/dashboard_detail.dart';
import 'package:zweb/pages/device.dart';
import 'package:zweb/pages/device_detail.dart';
import 'package:zweb/pages/document.dart';
import 'package:zweb/pages/home.dart';
import 'package:zweb/pages/profile.dart';
import 'package:zweb/pages/signin.dart';
import 'package:zweb/pages/signup.dart';

class AppLocation extends BeamLocation {
  AppLocation(BeamState state) : super(state);
  @override
  List<String> get pathBlueprints => [
        '/',
        '/feature',
        '/document',
        '/signin',
        '/signup',
        '/dashboard',
        '/dashboard/:dashboardId',
        '/device/:deviceId',
        '/device',
        '/profile',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          title: 'Zeal IoT',
          key: ValueKey('home'),
          child: HomePage(),
          type: BeamPageType.noTransition,
          keepQueryOnPop: false,
        ),
        if (state.uri.pathSegments.contains('document'))
          BeamPage(
            title: 'Document',
            key: ValueKey('document'),
            child: DocumentPage(),
            type: BeamPageType.noTransition,
          ),
        if (state.uri.pathSegments.contains('signin'))
          BeamPage(
            title: 'Sign In',
            key: ValueKey('signin'),
            child: SignInPage(),
            type: BeamPageType.noTransition,
          ),
        if (state.uri.pathSegments.contains('signup'))
          BeamPage(
            title: 'Sign Up',
            key: ValueKey('signup'),
            child: SignUpPage(),
            type: BeamPageType.noTransition,
          ),
        if (state.uri.pathSegments.contains('dashboard'))
          BeamPage(
            title: 'Dashboard',
            key: ValueKey('dashboard'),
            child: DashboardPage(),
            type: BeamPageType.noTransition,
          ),
        if (state.pathParameters.containsKey('dashboardId'))
          BeamPage(
            key: ValueKey('dashboard-${state.pathParameters['dashboardId']}'),
            title: 'Dashboard',
            child: DashboardDetailPage(dashboardId: state.pathParameters['dashboardId'].toString()),
            type: BeamPageType.noTransition,
          ),
        if (state.uri.pathSegments.contains('profile'))
          BeamPage(
            title: 'Profile',
            key: ValueKey('profile'),
            child: ProfilePage(),
            type: BeamPageType.noTransition,
          ),
        if (state.uri.pathSegments.contains('device'))
          BeamPage(
            title: 'Device',
            key: ValueKey('device'),
            child: DevicePage(),
            type: BeamPageType.noTransition,
          ),
        if (state.pathParameters.containsKey('deviceId'))
          BeamPage(
            key: ValueKey('dashboard-${state.pathParameters['deviceId']}'),
            title: 'Device',
            child: DeviceDetailPage(deviceId: state.pathParameters['deviceId'].toString()),
            type: BeamPageType.noTransition,
          ),
      ];
}
