import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';

class MainMenu extends StatelessWidget {
  MainMenu({Key? key}) : super(key: key);

  AppController controller = Get.find<AppController>();

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
                        ? (controller.isSignIn() == false)
                            ? ElevatedButton(
                                style: kElevatedButtonGreenButton,
                                child: Text(listMenu[i].title, style: TextStyle(fontSize: 16.0)),
                                onPressed: () {
                                  // sign in button
                                  Get.toNamed('/signin');
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
                                    await controller.firebaseSignOut().then((value) {
                                      Get.toNamed('/signin');
                                    });
                                  } else {
                                    Get.toNamed(value.toString());
                                  }
                                },
                              )
                        : InkWell(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Text(listMenu[i].title, style: TextStyle(fontSize: 16.0)),
                            ),
                            onTap: () {
                              Get.toNamed(listMenu[i].link);
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
                        ? (controller.isSignIn() == false)
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
                    controller.firebaseSignOut().then((value) {
                      Get.toNamed('/dashboard');
                    });
                  } else {
                    Get.toNamed(value.toString());
                  }
                },
              )
      ],
    );
  }
}
