import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/firebase_auth.dart';
import 'package:zweb/services/user.dart';
import 'package:zweb/widgets/main_menu.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textInputEmail = TextEditingController();
  TextEditingController _textInputPassword = TextEditingController();
  bool _visibility = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: MainMenu(),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Card(
            shape: kCardBorderRadius,
            child: Container(
              width: 320,
              height: 300,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Sign In", style: kTextHeader),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Use your account to sign in"),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: kContainerRecRoundDecoration,
                    child: TextFormField(
                      controller: _textInputEmail,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                      ),
                      validator: (value) {
                        return (value!.isEmpty) ? "Please enter email" : null;
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: kContainerRecRoundDecoration,
                    child: TextFormField(
                      controller: _textInputPassword,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon((_visibility) ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _visibility = !_visibility;
                            });
                          },
                        ),
                      ),
                      obscureText: _visibility,
                      validator: (value) {
                        return (value!.isEmpty) ? "Please enter password" : null;
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                      child: Row(
                    children: [
                      TextButton(
                        child: Text("Sign Up"),
                        onPressed: () {
                          // goto signup page
                          context.beamToNamed('/signup');
                        },
                      ),
                      Spacer(),
                      ElevatedButton(
                        child: Text("Sign In"),
                        onPressed: () {
                          // sign in
                          if (_formKey.currentState!.validate()) {
                            firebaseSignIn(_textInputEmail.text.trim(), _textInputPassword.text.trim()).then(
                              (value) {
                                if (value != null) {
                                  setState(() {
                                    userUid = value.userUid;
                                    userDisplayName = value.userDisplayName;
                                    userPhotoURL = value.userPhotoURL;
                                    userRole = value.userRole;
                                    userDashboardQuota = value.userDashboardQuota;
                                    userDeviceQuota = value.userDeviceQuota;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signed in")));
                                  context.beamToNamed("/dashboard");
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Cannot sign in")));
                                  context.beamToNamed("/");
                                }
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
