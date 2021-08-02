import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/firebase_auth.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Icon(Icons.memory, size: 32),
        Text("Zeal IoT"),
        Spacer(),
        (scWidth > 660)
            ? Flex(
                direction: Axis.horizontal,
                children: [
                  for (int i = 0; i < listMenu.length; i++)
                    (listMenu[i].title.toLowerCase() == "sign in")
                        ? (isSignIn() == false)
                            ? ElevatedButton(
                                style: kElevatedButtonGreenButton,
                                child: Text(listMenu[i].title, style: TextStyle(fontSize: 16.0)),
                                onPressed: () {
                                  // sign in button
                                  context.beamToNamed('/signin');
                                },
                              )
                            : PopupMenuButton(
                                child: CircleAvatar(
                                  child: Icon(Icons.account_circle, size: 32),
                                ),
                                itemBuilder: (context) => <PopupMenuEntry>[
                                  for (int i = 0; i < listDashboardMenu.length; i++)
                                    PopupMenuItem<String>(
                                      value: listDashboardMenu[i].link,
                                      child: Text(listDashboardMenu[i].title),
                                    ),
                                ],
                                onSelected: (value) async {
                                  if (value.toString().contains("signout")) {
                                    await firebaseSignOut().then((value) {
                                      context.beamToNamed("/signin");
                                    });
                                  } else {
                                    context.beamToNamed(value.toString());
                                  }
                                },
                              )
                        : InkWell(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Text(listMenu[i].title, style: TextStyle(fontSize: 16.0)),
                            ),
                            onTap: () {
                              context.beamToNamed(listMenu[i].link);
                            },
                          ),
                ],
              )
            // show popupmenu if in mobile size
            : PopupMenuButton(
                icon: Icon(Icons.menu),
                itemBuilder: (context) => <PopupMenuEntry>[
                  for (int i = 0; i < listMenu.length; i++)
                    (listMenu[i].title.toLowerCase() == "sign in")
                        ? (isSignIn() == false)
                            ? PopupMenuItem<String>(
                                value: listMenu[i].link,
                                child: Text(listMenu[i].title),
                              )
                            : PopupMenuItem<String>(
                                value: '/dashboard',
                                child: Text("Dashboard"),
                              )
                        : PopupMenuItem<String>(
                            value: listMenu[i].link,
                            child: Text(listMenu[i].title),
                          )
                ],
                onSelected: (value) {
                  if (value.toString().contains("dashboard")) {
                    firebaseSignOut().then((value) {
                      context.beamToNamed('/dashboard');
                    });
                  } else {
                    context.beamToNamed(value.toString());
                  }
                },
              )
      ],
    );
  }
}
