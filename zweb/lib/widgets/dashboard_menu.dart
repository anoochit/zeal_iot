import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/firebase_auth.dart';

class DashboardMenu extends StatelessWidget {
  const DashboardMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(Icons.memory, size: 32),
        Text("Zeal IoT"),
        Spacer(),
        (scWidth > 510)
            ? Flex(
                direction: Axis.horizontal,
                children: [
                  for (int i = 0; i < listDashboardMenu.length; i++)
                    (listDashboardMenu[i].link.contains('signout'))
                        ? ElevatedButton(
                            style: kElevatedButtonRedButton,
                            child: Text(listDashboardMenu[i].title),
                            onPressed: () {
                              firebaseSignOut().then((value) {
                                context.beamToNamed('/signin');
                              });
                            },
                          )
                        : InkWell(
                            child: Container(padding: EdgeInsets.all(16), child: Text(listDashboardMenu[i].title, style: TextStyle(fontSize: 16.0))),
                            onTap: () {
                              context.beamToNamed(listDashboardMenu[i].link);
                            },
                          )
                ],
              )
            : PopupMenuButton(
                child: Icon(Icons.menu),
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
      ],
    );
  }
}
