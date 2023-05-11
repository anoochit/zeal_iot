import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:zweb/const.dart';

class BarChartWidget extends StatefulWidget {
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
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  @override
  Widget build(BuildContext context) {
    var constrainWidth = widget.width;
    var offset = widget.offset;

    // if mobile overide width to 4 grid
    if ((MediaQuery.of(context).size.width > 960)) {
      offset = offset;
    } else if ((MediaQuery.of(context).size.width < 412)) {
      constrainWidth = 4;
      offset = 0;
    }

    if (constrainWidth == 2) {
      offset = offset - 16;
    }

    if (constrainWidth == 3) {
      offset = offset - 20;
    }

    if (constrainWidth == 4) {
      offset = 0;
    }

    var width = MediaQuery.of(context).size.width - offset;
    var height = MediaQuery.of(context).size.height;

    var containerWidth = ((width * ((0.25) * constrainWidth)));
    var containerHeight = ((height * ((0.25) * height)));

    return Card(
      shape: kCardBorderRadius,
      child: Container(
          width: containerWidth,
          height: containerHeight,
          decoration: const BoxDecoration(
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
                  title: ChartTitle(text: widget.title),
                  primaryYAxis: NumericAxis(),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries>[
                    ColumnSeries<ChartData, dynamic>(
                      color: Theme.of(context).primaryColor.withOpacity(0.6),
                      dataSource: buildChartData(
                          data: widget.data, field: widget.field),
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
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: Colors.grey),
                    itemBuilder: (context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text("Delete", style: kTextWarning)),
                    ],
                    onSelected: (value) {
                      if (value == "delete") widget.onDelete();
                    },
                  ),
                ),
              ),
            ],
          )),
    );
  }

  dynamic buildChartData(
      {required List<QueryDocumentSnapshot> data, required String field}) {
    List<ChartData> chartData = <ChartData>[];
    for (var doc in data) {
      chartData.add(
        ChartData(
          timestamp: Timestamp.fromDate(
              DateTime.fromMillisecondsSinceEpoch(doc['timestamp'] * 1000)),
          value: doc[field].toDouble(),
        ),
      );
    }
    return chartData;
  }
}
