import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';

class DashboardMenu extends StatefulWidget {
  const DashboardMenu({Key? key}) : super(key: key);

  @override
  State<DashboardMenu> createState() => _DashboardMenuState();
}

class _DashboardMenuState extends State<DashboardMenu> {
  AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        const Icon(Icons.memory, size: 32),
        const Text("Zeal IoT"),
        const Spacer(),
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
                              controller.firebaseSignOut().then((value) {
                                Get.toNamed('/signin');
                              });
                            },
                          )
                        : InkWell(
                            child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Text(listDashboardMenu[i].title,
                                    style: const TextStyle(fontSize: 16.0))),
                            onTap: () {
                              Get.toNamed(listDashboardMenu[i].link);
                            },
                          )
                ],
              )
            : PopupMenuButton(
                child: const Icon(Icons.menu),
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
                      Get.toNamed("/signin");
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
