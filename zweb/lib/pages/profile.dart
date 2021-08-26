import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/user.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/textheader.dart';

import '../config.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // int dashboardQuota = 0;
  // int deviceQuota = 0;
  // int currentDashboard = 0;
  // int currentDevice = 0;

  // Future<void> getQuota() async {
  //   var currentDeviceNumber = await FirebaseFirestore.instance.collection('devices').where('user', isEqualTo: userUid).get();
  //   log('#no of device = ' + currentDeviceNumber.docs.length.toString());

  //   var currentDashboardNumber = await FirebaseFirestore.instance.collection('dashboards').where('user', isEqualTo: userUid).get();
  //   log('#no of dashboard = ' + currentDashboardNumber.docs.length.toString());

  //   var userQuota = await FirebaseFirestore.instance.collection('users').doc(userUid).get();
  //   log('dashboard quota = ' + userQuota['dashboard_quota'].toString());
  //   log('device quota = ' + userQuota['device_quota'].toString());

  //   setState(() {
  //     dashboardQuota = userQuota['dashboard_quota'];
  //     currentDashboard = currentDashboardNumber.docs.length;
  //     deviceQuota = userQuota['device_quota'];
  //     currentDevice = currentDeviceNumber.docs.length;
  //   });
  // }

  @override
  void initState() {
    // getQuota();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DashboardMenu(),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) => Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextHeader(title: "Profile"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    shape: kCardBorderRadius,
                    child: Container(
                      width: constraints.maxWidth,
                      padding: EdgeInsets.all(16),
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
                                    userDisplayName,
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    "Credential",
                                    style: Theme.of(context).textTheme.headline5,
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
                                          child: Text(
                                            "Access Key",
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                //width: (constraints.maxWidth < 412) ? (constraints.maxWidth - 48) : (constraints.maxWidth * 0.5),
                                                padding: EdgeInsets.all(16),
                                                decoration: kContainerRecRoundDecoration,
                                                child: SelectableText(userUid!),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.copy, size: 16),
                                              onPressed: () {
                                                FlutterClipboard.copy(userUid!);
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
                                          child: Text("API Key"),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                //width: (constraints.maxWidth < 412) ? (constraints.maxWidth - 48) : (constraints.maxWidth * 0.5),
                                                padding: EdgeInsets.all(16),
                                                decoration: kContainerRecRoundDecoration,
                                                child: SelectableText(WEB_KEY),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.copy, size: 16),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    "Quota",
                                    style: Theme.of(context).textTheme.headline5,
                                  ),
                                ),
                                Wrap(
                                  children: [
                                    FutureBuilder(
                                      future: FirebaseFirestore.instance.collection('dashboards').where('user', isEqualTo: userUid).get(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (snapshot.hasData) {
                                          var docs = snapshot.data!.docs;
                                          var currentDashboard = docs.length;

                                          final formatter = new NumberFormat("#,###");

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularPercentIndicator(
                                              radius: 375 / 2,
                                              lineWidth: 12,
                                              progressColor: Theme.of(context).primaryColor,
                                              percent: (currentDashboard / DASHBOARD_QUOTA),
                                              center: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Dashboard Quota"),
                                                  SizedBox(height: 8.0),
                                                  Text(formatter.format((currentDashboard / DASHBOARD_QUOTA) * 100) + "%"),
                                                ],
                                              ),
                                              animation: true,
                                            ),
                                          );
                                        }
                                        return Container();
                                      },
                                    ),
                                    FutureBuilder(
                                      future: FirebaseFirestore.instance.collection('devices').where('user', isEqualTo: userUid).get(),
                                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                        if (snapshot.hasData) {
                                          var docs = snapshot.data!.docs;
                                          var currentDevice = docs.length;

                                          final formatter = new NumberFormat("#,###");

                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularPercentIndicator(
                                              radius: 375 / 2,
                                              lineWidth: 12,
                                              progressColor: Theme.of(context).primaryColor,
                                              percent: (currentDevice / DEVICE_QUOTA),
                                              center: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("Device Quota"),
                                                  SizedBox(height: 8.0),
                                                  Text(formatter.format((currentDevice / DEVICE_QUOTA) * 100) + "%"),
                                                ],
                                              ),
                                              animation: true,
                                            ),
                                          );
                                        }
                                        return Container();
                                      },
                                    ),
                                  ],
                                )
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
      ),
    );
  }
}
