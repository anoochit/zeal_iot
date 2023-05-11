import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/texsubtheader.dart';
import 'package:zweb/widgets/textheader.dart';

class DeviceDetailPage extends StatefulWidget {
  const DeviceDetailPage({Key? key}) : super(key: key);

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  // get parameter
  String? deviceId = Get.parameters['id'];

  late QuerySnapshot<Object?> deviceMessageLog;
  late List<dynamic> controlField;
  late List<dynamic> dataField;
  String deviceTitle = "";

  List<String> deviceFields = [];

  AppController controller = Get.find<AppController>();

  @override
  void initState() {
    super.initState();

    if (deviceId == null) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    //double scWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const DashboardMenu(),
        automaticallyImplyLeading: false,
      ),
      body: Container(
          child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: FirebaseFirestore.instance.collection('devices').doc(deviceId!).get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return const Text("Somthing went wrong!");
                }

                // has device data show device detail
                if (snapshot.hasData) {
                  // build list for data table parameter
                  var deviceData = snapshot.data;
                  controlField = deviceData['control'];
                  dataField = deviceData['data'];
                  // build data grid column
                  deviceFields.add("timestamp");
                  // controlField.forEach((element) {
                  //   log(element);
                  //   deviceFields.add(element);
                  // });
                  for (var element in dataField) {
                    //log(element);
                    deviceFields.add(element);
                  }

                  // show device info
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // device title
                      TextHeader(title: deviceData["name"]),
                      TextSubHeader(title: deviceData["description"]),

                      // device info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          shape: kCardBorderRadius,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Text("ID : "),
                                    Chip(
                                      label: SelectableText(deviceId!),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 16),
                                      onPressed: () {
                                        FlutterClipboard.copy(deviceId!);
                                      },
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Control : "),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Wrap(
                                        children: [
                                          for (int i = 0; i < controlField.length; i++)
                                            Chip(
                                              label: SelectableText(
                                                controlField[i],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("Data : "),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Wrap(
                                        children: [
                                          for (int i = 0; i < dataField.length; i++)
                                            Chip(
                                              label: SelectableText(
                                                dataField[i],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // device logs
                      Expanded(
                        child: FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('messages')
                              .doc("${controller.userUid.value}_${deviceId!}")
                              .collection('log')
                              .orderBy('timestamp', descending: true)
                              .limit(10)
                              .get(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return const Text("Cannot load device message log");
                            }

                            if (snapshot.hasData) {
                              var deviceMessageLog = snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: kCardBorderRadius,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SfDataGrid(
                                      source: DeviceDataSource(deviceMessageLog, deviceFields),
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
                              );
                            }

                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ],
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      )),
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
                    value: (cellData == "timestamp")
                        ? DateFormat('dd/MM/yyyy, HH:mm:ss')
                            .format(DateTime.fromMillisecondsSinceEpoch(dataGridRow[cellData] * 1000))
                        : dataGridRow[cellData].toString());
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
