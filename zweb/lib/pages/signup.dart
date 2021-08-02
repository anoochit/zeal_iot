import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/firebase_auth.dart';
import 'package:zweb/widgets/main_menu.dart';
import 'package:beamer/beamer.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textInputDisplayName = TextEditingController();
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
              height: 360,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Sign Up", style: kTextHeader),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Sign up new account"),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: kContainerRecRoundDecoration,
                    child: TextFormField(
                      controller: _textInputDisplayName,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Display Name',
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
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
                        if (value!.isEmpty) {
                          return "Please enter email";
                        }
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
                        if (value!.isEmpty) {
                          return "Please enter password";
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 300,
                    child: ElevatedButton(
                      child: Text("Sign up"),
                      onPressed: () {
                        // sign in
                        if (_formKey.currentState!.validate()) {
                          firebaseSignUp(_textInputDisplayName.text.trim(), _textInputEmail.text.trim(), _textInputPassword.text.trim()).then(
                            (value) {
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signed up, check out your profile.")));
                                //firebaseSignOut();
                                context.beamToNamed('/dashboard');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text("Cannot create your account.")));
                              }
                            },
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
