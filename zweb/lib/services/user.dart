import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? userUid;
late String userDisplayName;
late String userPhotoURL;
late String userRole;
late int userDashboardQuota;
late int userDeviceQuota;
late UserCredential userCredential;
late AuthCredential authCredential;
late User firebaseUser;

User? user;

class UserInfo {
  final String userUid;
  final String userDisplayName;
  final String userPhotoURL;
  final String userRole;
  final int userDashboardQuota;
  final int userDeviceQuota;

  UserInfo(this.userUid, this.userDisplayName, this.userPhotoURL, this.userRole, this.userDashboardQuota, this.userDeviceQuota);
}

saveUser({required UserCredential userCredential, required String displayName, String? photoUrl, required String role, required int dashboardQuota, required int deviceQuota}) {
  // save new user to firebase
  FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get().then(
    (value) {
      if (value.exists) {
        // set value
        userDisplayName = value['name'];
        userPhotoURL = value['image'];
        userUid = value.id;

        userRole = value['role'];
        userDashboardQuota = value['dashboard_quota'];
        userDeviceQuota = value['device_quota'];

        log('Already has user in firestore collection');

        // save to sharepreference
        setUserSharedPreference(
          uid: userUid!,
          displayname: userDisplayName,
          photoURL: userPhotoURL,
          role: userRole.toString(),
          dashboardQuota: userDashboardQuota,
          deviceQuota: userDeviceQuota,
        );
      } else {
        log('No user data in firestore collection');

        // set value
        userDisplayName = userCredential.user!.displayName ?? displayName;
        userUid = userCredential.user!.uid;
        userPhotoURL = (userCredential.user!.photoURL ?? photoUrl)!;
        userRole = "u";

        // save to sharepreference
        setUserSharedPreference(uid: userUid!, displayname: userDisplayName, photoURL: userPhotoURL, role: role, dashboardQuota: dashboardQuota, deviceQuota: deviceQuota);

        // save to firebase
        FirebaseFirestore.instance.collection('users').doc(userUid).set(
          {
            'name': userDisplayName,
            'image': userPhotoURL,
            'role': role,
            'dashboard_quota': dashboardQuota,
            'device_quota': deviceQuota,
          },
        );
      }
    },
  );
}

Future<UserInfo> getUserSharedPreference() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  String uid = pref.getString("uid") ?? "";
  String displayName = pref.getString("displayName") ?? "";
  String photo = pref.getString("photoURL") ?? "";
  String role = pref.getString("role") ?? "u";
  int dashboardQuota = pref.getInt("dashboardQuota") ?? 3;
  int deviceQuota = pref.getInt("deviceQuota") ?? 5;

  log('get uid -> ' + uid);
  log('get displayName -> ' + displayName);
  log('get photoURL -> ' + photo);

  userUid = uid;
  userDisplayName = displayName;
  userPhotoURL = photo;

  userRole = role;
  userDashboardQuota = dashboardQuota;
  userDeviceQuota = deviceQuota;

  return UserInfo(uid, displayName, photo, role, dashboardQuota, deviceQuota);
}

setUserSharedPreference({required String uid, required String displayname, required String photoURL, required String role, required int dashboardQuota, required int deviceQuota}) async {
  log('save preference user data');
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("uid", uid);
  pref.setString("displayName", displayname);
  pref.setString("photoURL", photoURL);

  pref.setString("role", role);
  pref.setInt("dashboardQuota", dashboardQuota);
  pref.setInt("deviceQuota", deviceQuota);

  userUid = uid;
  userDisplayName = displayname;
  userPhotoURL = photoURL;

  userRole = role;
  userDashboardQuota = dashboardQuota;
  userDeviceQuota = deviceQuota;
}
