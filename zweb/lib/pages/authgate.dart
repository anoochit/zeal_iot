import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:get/get.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/pages/dashboard.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: const [
              EmailProviderConfiguration(),
            ],
            actions: [
              // add sign in action here
              AuthStateChangeAction<SignedIn>(
                (context, state) {
                  // signin
                  controller.loadUserData();
                },
              ),

              // add register action here
              AuthStateChangeAction<UserCreated>(
                (context, state) {
                  // register new user
                  controller.saveUserData(
                      uid: state.credential.user!.uid,
                      displayName: state.credential.user!.email!,
                      photoUrl: defaultAvatar,
                      role: "u");
                },
              )
            ],
          );
        }

        // load user share preference
        controller.loadUserData();
        return const DashboardPage();
      },
    );
  }
}
