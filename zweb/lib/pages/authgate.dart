import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:get/get.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/pages/dashboard.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providerConfigs: [
              EmailProviderConfiguration(),
            ],
            actions: [
              // TODO : add sign in action here
              AuthStateChangeAction<SignedIn>(
                (context, state) {
                  // signin
                  controller.loadUserData();
                },
              ),

              // TODO : add register action here
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
        return DashboardPage();
      },
    );
  }
}
