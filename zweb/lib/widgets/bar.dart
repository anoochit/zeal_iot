import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zweb/const.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.offset,
    required this.data,
    required this.field,
    required this.title,
    required this.onDelete,
  }) : super(key: key);

  final int width;
  final int height;
  final int offset;

  final List<QueryDocumentSnapshot> data;
  final String field;
  final String title;

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    var _constrainWidth = width;
    var _offset;

    // if mobile overide width to 4 grid
    if ((MediaQuery.of(context).size.width > 960)) {
      _offset = offset;
    } else if ((MediaQuery.of(context).size.width < 412)) {
      _constrainWidth = 4;
      _offset = 0;
    }

    if (_constrainWidth == 2) {
      _offset = offset - 16;
    }

    if (_constrainWidth == 3) {
      _offset = offset - 20;
    }

    if (_constrainWidth == 4) {
      _offset = 0;
    }

    var _width = MediaQuery.of(context).size.width - _offset;
    var _height = MediaQuery.of(context).size.height;

    var _containerWidth = ((_width * ((0.25) * _constrainWidth)));
    var _containerHeight = ((_height * ((0.25) * height)));

    return Card(
      shape: kCardBorderRadius,
      child: Container(
          width: _containerWidth,
          height: _containerHeight,
          decoration: BoxDecoration(
              //border: Border.all(color: Colors.grey.shade200),
              //borderRadius: BorderRadius.circular(8.0),
              ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: [
              Positioned.fill(
                child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.auto,
                    dateFormat: DateFormat('y MMM E d HH:mm'),
                  ),
                  title: ChartTitle(text: title),
                  primaryYAxis: NumericAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries>[
                    ColumnSeries<ChartData, dynamic>(
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      dataSource: buildChartData(data: data, field: field),
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                    )
                  ],
                ),
              ),
              // popup
              Positioned(
                right: 1,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: PopupMenuButton(
                    icon: Icon(Icons.more_vert, size: 18, color: Colors.grey),
                    itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(child: Text("Delete", style: kTextWarning), value: 'delete'),
                    ],
                    onSelected: (value) {
                      if (value == "delete") onDelete();
                    },
                  ),
                ),
              ),
            ],
          )),
    );
  }

  dynamic buildChartData({required List<QueryDocumentSnapshot> data, required String field}) {
    List<ChartData> chartData = <ChartData>[];
    data.forEach((doc) {
      chartData.add(
        ChartData(
          timestamp: Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(doc['timestamp'] * 1000)),
          value: doc[field].toDouble(),
        ),
      );
    });
    return chartData;
  }
}
