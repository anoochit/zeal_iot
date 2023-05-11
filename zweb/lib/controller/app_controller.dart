import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zweb/const.dart';

class AppController extends GetxController {
  // app variable
  RxString userUid = "".obs;
  RxString userDisplayName = "".obs;
  RxString userPhotoURL = "".obs;
  RxString userRole = "".obs;

  @override
  void onInit() {
    super.onInit();
    userUid.value = auth.currentUser?.uid ?? "";
  }

  saveUserData({required String uid, required String displayName, required String photoUrl, required String role}) {
    // save new user to firebase

    userDisplayName.value = displayName;
    userUid.value = uid;
    userPhotoURL.value = photoUrl;
    userRole.value = role;

    // save to sharepreference
    setUserSharedPreference(
      uid: FirebaseAuth.instance.currentUser!.uid,
      displayname: '$userDisplayName',
      photoURL: '$userPhotoURL',
      role: role,
    );

    // save to firebase
    FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'name': userDisplayName,
        'image': userPhotoURL,
        'role': role,
      },
    );

    update();
  }

  loadUserData() async {
    var value = await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).get();

    log('get user data');
    log("uid = ${value.id}");
    log("name = " + value['name']);
    log("photo = " + value['image']);
    log("role = " + value['role']);

    setUserSharedPreference(
      uid: auth.currentUser!.uid,
      displayname: value['name'],
      photoURL: value['image'],
      role: value['role'],
    );

    userUid.value = auth.currentUser!.uid;
    userDisplayName.value = value['name'];
    userPhotoURL.value = value['image'];
    userRole.value = value['role'];

    update();
  }

  getUserSharedPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String uid = pref.getString("uid") ?? "";
    String displayName = pref.getString("displayName") ?? "";
    String photo = pref.getString("photoURL") ?? "";
    String role = pref.getString("role") ?? "u";

    log('get uid -> $uid');
    log('get displayName -> $displayName');
    log('get photoURL -> $photo');

    userUid.value = uid;
    userDisplayName.value = displayName;
    userPhotoURL.value = photo;
    userRole.value = role;
  }

  setUserSharedPreference({
    required String uid,
    required String displayname,
    required String photoURL,
    required String role,
  }) async {
    log('save preference user data');
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("uid", uid);
    pref.setString("displayName", displayname);
    pref.setString("photoURL", photoURL);
    pref.setString("role", role);

    userUid.value = uid;
    userDisplayName.value = displayname;
    userPhotoURL.value = photoURL;

    userRole.value = role;
  }

  Future<void> firebaseSignOut() async {
    return await auth.signOut();
  }

  bool isSignIn() {
    User? user = auth.currentUser;
    if (user == null) {
      return false;
    } else {
      getUserSharedPreference();
      return true;
    }
  }
}
