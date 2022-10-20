import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderables/reorderables.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/dashboard_widget.dart';
import 'package:zweb/widgets/line.dart';
import 'package:zweb/widgets/textheader.dart';

class DashboardDetailPage extends StatefulWidget {
  DashboardDetailPage({Key? key}) : super(key: key);

  @override
  _DashboardDetailPageState createState() => _DashboardDetailPageState();
}

class _DashboardDetailPageState extends State<DashboardDetailPage> {
  String dashboardId = Get.parameters['id']!;

  @override
  Widget build(BuildContext context) {
    log("dashboardId -> " + dashboardId);

    return Scaffold(
      appBar: AppBar(
        title: DashboardMenu(),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('dashboards').doc(dashboardId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // has error
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong!'),
            );
          }

          // has data
          if (snapshot.hasData) {
            return DashboardDetail(data: snapshot.data);
          }

          // wait snapshot
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class DashboardDetail extends StatefulWidget {
  DashboardDetail({
    Key? key,
    required this.data,
  }) : super(key: key);

  final DocumentSnapshot<Object?>? data;

  @override
  _DashboardDetailState createState() => _DashboardDetailState();
}

class _DashboardDetailState extends State<DashboardDetail> {
  void removeWidget({required String id}) {
    FirebaseFirestore.instance.collection("dashboards").doc(widget.data!.id).collection("items").doc(id).delete();
  }

  int widgetCount = 0;

  bool setOrder = false;

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextHeader(title: widget.data!['title']),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: (scWidth > 450)
                  ? Row(
                      children: [
                        TextButton.icon(
                          icon: Icon(Icons.reorder),
                          label: (setOrder) ? Text("Exit Reorder") : Text("Reorder"),
                          onPressed: () {
                            // add widget dialog
                            setState(() {
                              setOrder = !setOrder;
                            });
                          },
                        ),
                        SizedBox(width: 8.0),
                        TextButton.icon(
                          icon: Icon(Icons.add_circle),
                          label: Text("Add Widget"),
                          onPressed: () {
                            log("dashboard item count" + widgetCount.toString());
                            // add widget dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                shape: kCardBorderRadius,
                                insetPadding: EdgeInsets.all(10),
                                child: AddWidget(dashboardId: widget.data!.id, itemCount: widgetCount),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.add_circle),
                            onPressed: () {
                              // add widget dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => Dialog(
                                  shape: kCardBorderRadius,
                                  insetPadding: EdgeInsets.all(10),
                                  child: AddWidget(dashboardId: widget.data!.id, itemCount: widgetCount),
                                ),
                              );
                            }),
                      ],
                    ),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('dashboards')
                      .doc(widget.data!.id)
                      .collection('items')
                      .orderBy("order")
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text("Something went wrong");
                    }

                    // has data show widget
                    if (snapshot.hasData) {
                      var widgetDocs = snapshot.data!.docs;
                      widgetCount = snapshot.data!.docs.length;
                      log("widget total = " + widgetDocs.length.toString());

                      // if set order is true load blank widget as placeholder
                      if (setOrder) {
                        return ReorderableWrap(
                          children: widgetDocs.map((widget) {
                            return BlankWidget(
                              width: widget['width'],
                              height: widget['height'],
                              offset: 64,
                              title: widget['title'],
                            );
                          }).toList(),
                          onReorder: (int oldIndex, int newIndex) {
                            debugPrint(
                                '${DateTime.now().toString().substring(5, 22)} reorder oldIndex:$oldIndex newIndex:$newIndex');
                            log('${widget.data!.id}/${widgetDocs[oldIndex].id}');
                            FirebaseFirestore.instance
                                .collection("dashboards")
                                .doc(widget.data!.id)
                                .collection("items")
                                .doc(widgetDocs[oldIndex].id)
                                .update({'order': newIndex});
                            log(widgetDocs[oldIndex].id);
                          },
                        );
                      } else {
                        // show widget in wrap
                        return Wrap(
                          children: widgetDocs.map((widget) {
                            // widget type gauge
                            if (widget['type'] == "guage") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("messages").doc(messageDoc).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    var widgetData = snapshot.data;

                                    if (widgetData!.exists) {
                                      return RadialGaugeWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        gaugeMin: widget['min'],
                                        gaugeMax: widget['max'],
                                        value: double.parse(widgetData[messageField].toString()),
                                        title: widget['title'],
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    } else {
                                      return NoDataWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    }
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget text
                            if (widget['type'] == "text") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);

                              return StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("messages").doc(messageDoc).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Container();
                                  }
                                  if (snapshot.hasData) {
                                    var widgetData = snapshot.data;

                                    if (widgetData!.exists) {
                                      return TextWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        value: widgetData[messageField].toString(),
                                        title: widget['title'],
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    } else {
                                      return NoDataWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    }
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget line chart
                            if (widget['type'] == "line") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("messages")
                                    .doc(messageDoc)
                                    .collection("log")
                                    .orderBy('timestamp')
                                    .limitToLast(60)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    List<QueryDocumentSnapshot> widgetData = snapshot.data!.docs;
                                    return LineChartWidget(
                                      width: widget['width'],
                                      height: widget['height'],
                                      offset: 64,
                                      data: widgetData,
                                      field: messageField,
                                      title: widget['title'],
                                      onDelete: () {
                                        log("delete");
                                        removeWidget(id: widget.id);
                                      },
                                    );
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget araa chart
                            if (widget['type'] == "area") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("messages")
                                    .doc(messageDoc)
                                    .collection("log")
                                    .orderBy('timestamp')
                                    .limitToLast(60)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    List<QueryDocumentSnapshot> widgetData = snapshot.data!.docs;
                                    return AreaChartWidget(
                                      width: widget['width'],
                                      height: widget['height'],
                                      offset: 64,
                                      data: widgetData,
                                      field: messageField,
                                      title: widget['title'],
                                      onDelete: () {
                                        log("delete");
                                        removeWidget(id: widget.id);
                                      },
                                    );
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget bar chart
                            if (widget['type'] == "bar") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("messages")
                                    .doc(messageDoc)
                                    .collection("log")
                                    .orderBy('timestamp')
                                    .limitToLast(60)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    List<QueryDocumentSnapshot> widgetData = snapshot.data!.docs;
                                    return BarChartWidget(
                                      width: widget['width'],
                                      height: widget['height'],
                                      offset: 64,
                                      data: widgetData,
                                      field: messageField,
                                      title: widget['title'],
                                      onDelete: () {
                                        log("delete");
                                        removeWidget(id: widget.id);
                                      },
                                    );
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget spine chart
                            if (widget['type'] == "spline") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);
                              return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("messages")
                                    .doc(messageDoc)
                                    .collection("log")
                                    .orderBy('timestamp')
                                    .limitToLast(60)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    List<QueryDocumentSnapshot> widgetData = snapshot.data!.docs;
                                    return SplineChartWidget(
                                      width: widget['width'],
                                      height: widget['height'],
                                      offset: 64,
                                      data: widgetData,
                                      field: messageField,
                                      title: widget['title'],
                                      onDelete: () {
                                        log("delete");
                                        removeWidget(id: widget.id);
                                      },
                                    );
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget switch
                            if (widget['type'] == "switch") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);

                              return StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("messages").doc(messageDoc).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Container();
                                  }
                                  if (snapshot.hasData) {
                                    var widgetData = snapshot.data;
                                    log("snapshot value = " + widgetData![messageField].toString());
                                    return SwitchWidget(
                                      width: widget['width'],
                                      height: widget['height'],
                                      offset: 64,
                                      value: widgetData[messageField],
                                      title: widget['title'],
                                      onDelete: () {
                                        log("delete");
                                        removeWidget(id: widget.id);
                                      },
                                      onChange: (bool value) {
                                        // chnage value
                                        log("switch value = " + value.toString());
                                        FirebaseFirestore.instance.collection("messages").doc(messageDoc).update({
                                          messageField: value,
                                        });
                                      },
                                    );
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget map
                            if (widget['type'] == "map") {
                              var messageDoc1 = widget['data1'].toString().split("/").first;
                              var messageField1 = widget['data1'].toString().split("/").last;
                              //var messageDoc2 = widget['data2'].toString().split("/").first;
                              var messageField2 = widget['data2'].toString().split("/").last;
                              log(messageDoc1);

                              return StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("messages").doc(messageDoc1).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Container();
                                  }
                                  if (snapshot.hasData) {
                                    var widgetData = snapshot.data;

                                    if (widgetData!.exists) {
                                      return MapWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        lat: widgetData[messageField1],
                                        lon: widgetData[messageField2],
                                        title: widget['title'],
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    } else {
                                      return NoDataWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    }
                                  }

                                  return Container();
                                },
                              );
                            }

                            // widget status
                            if (widget['type'] == "status") {
                              var messageDoc = widget['data'].toString().split("/").first;
                              var messageField = widget['data'].toString().split("/").last;
                              log(messageDoc);

                              return StreamBuilder(
                                stream: FirebaseFirestore.instance.collection("messages").doc(messageDoc).snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Container();
                                  }
                                  if (snapshot.hasData) {
                                    var widgetData = snapshot.data;
                                    log("snapshot value = " + widgetData![messageField].toString());

                                    if (widgetData.exists) {
                                      return StatusWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        value: widgetData[messageField],
                                        title: widget['title'],
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    } else {
                                      return NoDataWidget(
                                        width: widget['width'],
                                        height: widget['height'],
                                        offset: 64,
                                        onDelete: () {
                                          log("delete");
                                          removeWidget(id: widget.id);
                                        },
                                      );
                                    }
                                  }

                                  return Container();
                                },
                              );
                            }

                            return Container(
                              child: Text("Wrong type!"),
                            );
                          }).toList(),
                        );
                      }
                    }

                    return Container(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class AddWidget extends StatefulWidget {
  const AddWidget({
    Key? key,
    required this.dashboardId,
    required this.itemCount,
  }) : super(key: key);

  final String dashboardId;
  final int itemCount;

  @override
  _AddWidgetState createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  final _formKey = GlobalKey<FormState>();
  String? selectWidgetType;
  String? selectWidgetId;
  String? selectWidgetField;
  String? selectWidgetField2;
  int? selectWidgetWidth;
  int? selectWidgetHeight;
  TextEditingController _textInputTitle = TextEditingController();
  TextEditingController _textInputWidgetMin = TextEditingController();
  TextEditingController _textInputWidgetMax = TextEditingController();
  TextEditingController _textInputWidgetUnit = TextEditingController();

  AppController controller = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: 375,
            padding: EdgeInsets.all(16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    child: Text(
                      "Add widget",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ),

                // drop down select widget type
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Select widget type",
                      ),
                      items: listDashboardWidget
                          .map((widget) => DropdownMenuItem<String>(
                                value: widget.slug,
                                child: Text(widget.title),
                              ))
                          .toList(),
                      onChanged: (value) {
                        // set value here
                        log("widget type = " + value.toString());
                        setState(() {
                          selectWidgetType = value.toString();
                          selectWidgetId = null;
                          selectWidgetField = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select widget type';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('devices')
                      .where('user', isEqualTo: controller.userUid.value)
                      .get(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      var deviceDocs = snapshot.data!.docs;
                      //log(deviceDocs.length.toString());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: kContainerRecRoundDecoration,
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Select device",
                            ),
                            items: deviceDocs
                                .map((device) => DropdownMenuItem<String>(
                                      value: device.id.toString(),
                                      child: Text(device['name']),
                                    ))
                                .toList(),
                            value: selectWidgetId,
                            onChanged: (value) {
                              // set value here
                              setState(() {
                                selectWidgetId = value.toString();
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select device';
                              }
                              return null;
                            },
                          ),
                        ),
                      );
                    }

                    return Container(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),

                // device field
                (selectWidgetId != null)
                    ? FutureBuilder(
                        future: FirebaseFirestore.instance.collection('devices').doc(selectWidgetId).get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            var deviceDocs = snapshot.data;
                            List<dynamic> listDataField = [];

                            // check field for input or output
                            if ((selectWidgetType != "switch") && (selectWidgetType != "status")) {
                              listDataField = deviceDocs!['data'];
                            } else {
                              listDataField = deviceDocs!['control'];
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: kContainerRecRoundDecoration,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: (selectWidgetType == "map") ? "Select latitude field" : "Select field",
                                  ),
                                  items: listDataField
                                      .map((device) => DropdownMenuItem<String>(
                                            value: device.toString(),
                                            child: Text(device.toString()),
                                          ))
                                      .toList(),
                                  value: selectWidgetField,
                                  onChanged: (value) {
                                    // set value here
                                    setState(() {
                                      selectWidgetField = value.toString();
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select field';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            );
                          }

                          return Container(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Container(),

                // device 2d field
                ((selectWidgetId != null) && (selectWidgetType == "map"))
                    ? FutureBuilder(
                        future: FirebaseFirestore.instance.collection('devices').doc(selectWidgetId).get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            var deviceDocs = snapshot.data;
                            List<dynamic> listDataField = [];

                            // check field for input or output
                            if (selectWidgetType != "switch") {
                              listDataField = deviceDocs!['data'];
                            } else {
                              listDataField = deviceDocs!['control'];
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: kContainerRecRoundDecoration,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: (selectWidgetType == "map") ? "Select longitude field" : "Select field",
                                  ),
                                  items: listDataField
                                      .map((device) => DropdownMenuItem<String>(
                                            value: device.toString(),
                                            child: Text(device.toString()),
                                          ))
                                      .toList(),
                                  value: selectWidgetField2,
                                  onChanged: (value) {
                                    // set value here
                                    setState(() {
                                      selectWidgetField2 = value.toString();
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select field';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            );
                          }

                          return Container(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Container(),

                // widget min
                ((selectWidgetType != "switch") && (selectWidgetType != "map") && (selectWidgetType != "status"))
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: (constraints.maxWidth > 412) ? (330 / 3) : ((constraints.maxWidth - 50) / 3),
                          padding: EdgeInsets.all(8),
                          decoration: kContainerRecRoundDecoration,
                          child: TextFormField(
                            controller: _textInputWidgetMin,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Min value',
                            ),
                            validator: (value) {
                              return (value!.isEmpty) ? "Please enter min value" : null;
                            },
                          ),
                        ),
                      )
                    : Container(),

                // widget max
                ((selectWidgetType != "switch") && (selectWidgetType != "map") && (selectWidgetType != "status"))
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: (constraints.maxWidth > 412) ? (330 / 3) : ((constraints.maxWidth - 50) / 3),
                          padding: EdgeInsets.all(8),
                          decoration: kContainerRecRoundDecoration,
                          child: TextFormField(
                            controller: _textInputWidgetMax,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Max value',
                            ),
                            validator: (value) {
                              return (value!.isEmpty) ? "Please enter max value" : null;
                            },
                          ),
                        ),
                      )
                    : Container(),

                // widget unit
                ((selectWidgetType != "switch") && (selectWidgetType != "map") && (selectWidgetType != "status"))
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: (constraints.maxWidth > 412) ? (330 / 3) : ((constraints.maxWidth - 50) / 3),
                          padding: EdgeInsets.all(8),
                          decoration: kContainerRecRoundDecoration,
                          child: TextFormField(
                            controller: _textInputWidgetUnit,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Unit',
                            ),
                            validator: (value) {
                              return (value!.isEmpty) ? "Please enter unit" : null;
                            },
                          ),
                        ),
                      )
                    : Container(),

                // width size
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: (constraints.maxWidth > 412) ? (330 / 2) : ((constraints.maxWidth - 40) / 2),
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Width",
                      ),
                      items: [
                        for (int i = 0; i < 4; i++)
                          DropdownMenuItem<int>(
                            value: (i + 1),
                            child: Text((i + 1).toString()),
                          )
                      ],
                      value: selectWidgetWidth,
                      onChanged: (value) {
                        // set value here
                        selectWidgetWidth = int.parse(value.toString());
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select width';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                // height size
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: (constraints.maxWidth > 412) ? (330 / 2) : ((constraints.maxWidth - 40) / 2),
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Height",
                      ),
                      items: [
                        for (int i = 0; i < 4; i++)
                          DropdownMenuItem<int>(
                            value: (i + 1),
                            child: Text((i + 1).toString()),
                          )
                      ],
                      value: selectWidgetHeight,
                      onChanged: (value) {
                        // set value here
                        selectWidgetHeight = int.parse(value.toString());
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select height';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                // widget title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: TextFormField(
                      controller: _textInputTitle,
                      autofocus: false,
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

                // button
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
                            if ((selectWidgetType == "switch") || (selectWidgetType == "status")) {
                              // create field in device message
                              FirebaseFirestore.instance
                                  .collection('messages')
                                  .doc(controller.userUid.value + "_" + selectWidgetId!)
                                  .update({
                                selectWidgetField.toString(): false,
                              });
                              // create dashboard widget for switch type
                              FirebaseFirestore.instance
                                  .collection('dashboards')
                                  .doc(widget.dashboardId)
                                  .collection('items')
                                  .add({
                                'data': controller.userUid + "_" + selectWidgetId! + "/" + selectWidgetField!,
                                'width': selectWidgetWidth!,
                                'height': selectWidgetHeight!,
                                'type': selectWidgetType,
                                'title': _textInputTitle.text.trim(),
                                'order': widget.itemCount,
                              }).then((value) => Get.back());
                            } else if (selectWidgetType == "map") {
                              // create dashboard widget for map type
                              FirebaseFirestore.instance
                                  .collection('dashboards')
                                  .doc(widget.dashboardId)
                                  .collection('items')
                                  .add({
                                'data1': controller.userUid + "_" + selectWidgetId! + "/" + selectWidgetField!,
                                'data2': controller.userUid + "_" + selectWidgetId! + "/" + selectWidgetField2!,
                                'width': selectWidgetWidth!,
                                'height': selectWidgetHeight!,
                                'type': selectWidgetType,
                                'title': _textInputTitle.text.trim(),
                                'order': widget.itemCount,
                              }).then((value) => Get.back());
                            } else {
                              // create dashboard widget for graph type
                              FirebaseFirestore.instance
                                  .collection('dashboards')
                                  .doc(widget.dashboardId)
                                  .collection('items')
                                  .add({
                                'data': controller.userUid + "_" + selectWidgetId! + "/" + selectWidgetField!,
                                'width': selectWidgetWidth!,
                                'height': selectWidgetHeight!,
                                'min': double.parse(_textInputWidgetMin.text.trim()),
                                'max': double.parse(_textInputWidgetMax.text.trim()),
                                'unit': _textInputWidgetUnit.text.trim(),
                                'type': selectWidgetType,
                                'title': _textInputTitle.text.trim(),
                                'order': widget.itemCount,
                              }).then((value) => Get.back());
                            }
                          }
                        },
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        style: kElevatedButtonRedButton,
                        child: Text("Close"),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
