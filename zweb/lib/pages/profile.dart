import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/textheader.dart';

import '../config.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
        init: AppController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: const DashboardMenu(),
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextHeader(title: "Profile"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        shape: kCardBorderRadius,
                        child: Container(
                          width: constraints.maxWidth,
                          padding: const EdgeInsets.all(16),
                          child: LayoutBuilder(
                            builder: (context, constraints) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Text(
                                        '${controller.userDisplayName}',
                                        style: Theme.of(context).textTheme.headlineMedium,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                                      child: Text(
                                        "Credential",
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                    ),
                                    Wrap(
                                      direction: Axis.horizontal,
                                      alignment: WrapAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              child: const Text(
                                                "Access Key",
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    //width: (constraints.maxWidth < 412) ? (constraints.maxWidth - 48) : (constraints.maxWidth * 0.5),
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: kContainerRecRoundDecoration,
                                                    child: SelectableText(controller.userUid.value),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy, size: 16),
                                                  onPressed: () {
                                                    FlutterClipboard.copy(controller.userUid.value);
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                                              child: const Text("API Key"),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    //width: (constraints.maxWidth < 412) ? (constraints.maxWidth - 48) : (constraints.maxWidth * 0.5),
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: kContainerRecRoundDecoration,
                                                    child: const SelectableText(WEB_KEY),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.copy, size: 16),
                                                  onPressed: () {
                                                    FlutterClipboard.copy(WEB_KEY);
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
