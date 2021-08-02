import 'package:flutter/material.dart';
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
    super.initState();
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
              TextHeader(title: "Device"),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TextButton.icon(
                  icon: Icon(Icons.connect_without_contact),
                  label: Text("Create Dashboard"),
                  onPressed: () {
                    // create device dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        insetPadding: EdgeInsets.all(10),
                        child: Container(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
