import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zweb/config.dart';
import 'package:zweb/services/user.dart' as zUser;

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

Future<bool> firebaseSignUp(String displayName, String email, String password) async {
  try {
    zUser.userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    zUser.userCredential.user!.updateDisplayName(displayName);
    zUser.userCredential.user!.updatePhotoURL("https://via.placeholder.com/150");

    // save to firestore
    zUser.saveUser(displayName: displayName, photoUrl: "https://via.placeholder.com/150", userCredential: zUser.userCredential, role: 'u', dashboardQuota: DASHBOARD_QUOTA, deviceQuota: DEVICE_QUOTA);

    return true;
  } on FirebaseAuthException catch (e) {
    log('$e.message');

    return false;
  }
}

Future<zUser.UserInfo?> firebaseSignIn(String email, String password) async {
  try {
    zUser.authCredential = EmailAuthProvider.credential(email: email, password: password);

    zUser.userCredential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    //get userdata from firebase
    var value = await FirebaseFirestore.instance.collection('users').doc(zUser.userCredential.user!.uid).get();
    log('get user data');
    log("uid = " + zUser.userCredential.user!.uid);
    log("name = " + value['name']);
    log("photo = " + value['image']);
    log("role = " + value['role']);
    log("dashboard = " + value['dashboard_quota'].toString());
    log("device = " + value['device_quota'].toString());

    zUser.setUserSharedPreference(
      uid: zUser.userCredential.user!.uid,
      displayname: value['name'],
      photoURL: value['image'],
      role: value['role'],
      dashboardQuota: value['dashboard_quota'],
      deviceQuota: value['device_quota'],
    );

    return zUser.UserInfo(zUser.userCredential.user!.uid, value['name'], value['image'], value['role'], value['dashboard_quota'], value['device_quota']);
  } on FirebaseAuthException catch (e) {
    log('$e.message');

    return null;
  }
}

Future<void> firebaseSignOut() async {
  return await firebaseAuth.signOut();
}

bool isSignIn() {
  User? _user = FirebaseAuth.instance.currentUser;
  if (_user == null) {
    return false;
  } else {
    zUser.getUserSharedPreference();
    return true;
  }
}
