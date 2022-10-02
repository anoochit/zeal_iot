import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/user.dart';
import 'package:zweb/utils/utils.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/textheader.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int dashboardQuota = 0;
  int currentDashboard = 0;

  Future<void> getQuota() async {
    var currentDashboardNumber =
        await FirebaseFirestore.instance.collection('dashboards').where('user', isEqualTo: userUid).get();
    log('#no of dashboard = ' + currentDashboardNumber.docs.length.toString());

    var userQuota = await FirebaseFirestore.instance.collection('users').doc(userUid).get();
    log('dashboard quota = ' + userQuota['dashboard_quota'].toString());

    setState(() {
      dashboardQuota = userQuota['dashboard_quota'];
      currentDashboard = currentDashboardNumber.docs.length;
    });
  }

  @override
  void initState() {
    getQuota();
    super.initState();
  }

  createDashboard() {
    getQuota().then((value) {
      if (currentDashboard < dashboardQuota) {
        // create dashboard dialog
        showDialog(
          context: context,
          builder: (BuildContext context) => Dialog(
            shape: kCardBorderRadius,
            insetPadding: EdgeInsets.all(10),
            child: CreateDashboard(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dashboard quota exceed!")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: DashboardMenu(),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                TextHeader(title: "Dashboard"),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: (scWidth > 412)
                      ? TextButton.icon(
                          icon: Icon(Icons.add_circle),
                          label: Text("Create Dashboard"),
                          onPressed: () {
                            // create dashboard
                            createDashboard();
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () {
                            // create dashboard
                            createDashboard();
                          }),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder(
                  stream:
                      FirebaseFirestore.instance.collection('dashboards').where('user', isEqualTo: userUid).snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    // has error
                    if (snapshot.hasError) {
                      return Center(child: Text("Something, went wrong!"));
                    }
                    // has data
                    if (snapshot.hasData) {
                      var docs = snapshot.data!.docs;

                      if (docs.length > 0) {
                        return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: getGridSized(scWidth)),
                            itemCount: docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: LayoutBuilder(
                                  builder: (context, constraints) => Card(
                                    shape: kCardBorderRadius,
                                    child: Stack(
                                      children: [
                                        // icon
                                        Positioned.fill(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                hoverColor: Colors.transparent,
                                                child: Icon(
                                                  Icons.dashboard,
                                                  size: constraints.maxWidth * 0.65,
                                                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                                                ),
                                                onTap: () {
                                                  // open dashboard
                                                  context.beamToNamed('/dashboard/' + docs[index].id);
                                                },
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: constraints.maxWidth * 0.8,
                                                child: Text(
                                                  docs[index]['title'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  //style: kTextItemTitle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // popup
                                        Positioned(
                                          right: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: PopupMenuButton(
                                              icon: Icon(Icons.more_vert, size: 16),
                                              itemBuilder: (context) => <PopupMenuEntry>[
                                                PopupMenuItem(child: Text("Info"), value: 'info'),
                                                PopupMenuItem(
                                                    child: Text("Delete", style: kTextWarning), value: 'delete'),
                                              ],
                                              onSelected: (value) {
                                                if (value == "delete") {
                                                  // delete dashboard
                                                  FirebaseFirestore.instance
                                                      .collection('dashboards')
                                                      .doc(docs[index].id)
                                                      .delete();
                                                }
                                                if (value == "info") {
                                                  // show dialog

                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => Dialog(
                                                      shape: kCardBorderRadius,
                                                      child: Container(
                                                        width: 350,
                                                        padding: EdgeInsets.all(24),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Text(
                                                                docs[index]['title'],
                                                                style: Theme.of(context).textTheme.headline5,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Text(
                                                                docs[index]['description'],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      } else {
                        // document snapshot is 0
                        return Center(child: Text("No dashboard, please create a new one"));
                      }
                    }
                    // wainting snapshot
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateDashboard extends StatefulWidget {
  const CreateDashboard({
    Key? key,
  }) : super(key: key);

  @override
  _CreateDashboardState createState() => _CreateDashboardState();
}

class _CreateDashboardState extends State<CreateDashboard> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textInputTitle = TextEditingController();
  TextEditingController _textInputDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      log(constraints.maxWidth.toString());
      return Form(
        key: _formKey,
        child: Container(
          width: 375,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  child: Text(
                    "Create Dashboard",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: kContainerRecRoundDecoration,
                  child: TextFormField(
                    controller: _textInputTitle,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Title',
                    ),
                    validator: (value) {
                      return (value!.isEmpty) ? "Please enter title" : null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: kContainerRecRoundDecoration,
                  child: TextFormField(
                    controller: _textInputDescription,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Description',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      return (value!.isEmpty) ? "Please enter description" : null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      child: Text("Submit"),
                      onPressed: () {
                        // submit form
                        if (_formKey.currentState!.validate()) {
                          // create dashboard
                          FirebaseFirestore.instance.collection('dashboards').add(
                            {
                              'description': _textInputDescription.text.trim(),
                              'title': _textInputTitle.text.trim(),
                              'user': userUid,
                            },
                          ).then((value) {
                            log('docId ->' + value.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dashboard created!")));
                            Navigator.pop(context);
                          });
                        }
                      },
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      style: kElevatedButtonRedButton,
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
