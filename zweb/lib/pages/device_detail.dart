import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:zweb/const.dart';
import 'package:zweb/services/user.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/textheader.dart';

class DeviceDetailPage extends StatefulWidget {
  DeviceDetailPage({Key? key, required this.deviceId}) : super(key: key);

  final String deviceId;

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  @override
  void initState() {
    getDeviceFields().then((value) {
      getDeviceMessageLog().then((value) {
        setState(() {
          deviceMessageLog = value;
        });
      });
    });

    super.initState();
  }

  late QuerySnapshot<Object?> deviceMessageLog;

  String deviceTitle = "";

  List<String> deviceFields = [];

  Future<void> getDeviceFields() async {
    // get device field
    DocumentSnapshot<Map<String, dynamic>> result = await FirebaseFirestore.instance.collection('devices').doc(widget.deviceId).get();
    //List<dynamic> controlField = result['control'];
    List<dynamic> dataField = result['data'];
    deviceTitle = result['name'];
    // set device fields
    deviceFields.add("timestamp");
    // controlField.forEach((element) {
    //   log(element);
    //   deviceFields.add(element);
    // });
    dataField.forEach((element) {
      //log(element);
      deviceFields.add(element);
    });
    //log("total field = " + deviceFields.length.toString());
  }

  Future<QuerySnapshot> getDeviceMessageLog() async {
    // get device message log
    return await FirebaseFirestore.instance.collection('messages').doc(userUid! + "_" + widget.deviceId).collection('log').orderBy('timestamp', descending: true).limit(50).get();
  }

  @override
  Widget build(BuildContext context) {
    //double scWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: DashboardMenu(),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextHeader(title: deviceTitle),
              // Spacer(),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 24),
              //   child: TextButton.icon(
              //     icon: Icon(Icons.connect_without_contact),
              //     label: Text("Create Dashboard"),
              //     onPressed: () {
              //       // create device dialog
              //       showDialog(
              //         context: context,
              //         builder: (BuildContext context) => Dialog(
              //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              //           insetPadding: EdgeInsets.all(10),
              //           child: Container(),
              //         ),
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
          (deviceFields.length == 0)
              ? Center(child: CircularProgressIndicator())
              : ((deviceFields.length > 1) && (deviceMessageLog.docs.length > 0))
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                        child: Card(
                          shape: kCardBorderRadius,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: Container(
                              child: SfDataGrid(
                                source: new DeviceDataSource(deviceMessageLog, deviceFields),
                                columns: deviceFields.map((field) {
                                  return GridColumn(
                                    columnWidthMode: ColumnWidthMode.auto,
                                    columnName: field,
                                    label: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        field,
                                        style: kTextItemTitle,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Text("no data"),
        ],
      ),
    );
  }
}

class DeviceDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];

  DeviceDataSource(QuerySnapshot<Object?> deviceMessageLog, List<String> deviceFields) {
    dataGridRows = deviceMessageLog.docs
        .map<DataGridRow>(
          (dataGridRow) => DataGridRow(
            cells: deviceFields.map<DataGridCell>(
              (cellData) {
                return DataGridCell<String>(
                    columnName: cellData,
                    value: (cellData == "timestamp") ? DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(dataGridRow[cellData] * 1000)) : dataGridRow[cellData].toString());
              },
            ).toList(),
          ),
        )
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList());
  }
}
