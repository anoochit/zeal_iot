import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zweb/const.dart';

class RadialGaugeWidget extends StatelessWidget {
  const RadialGaugeWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.offset,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.value,
    required this.title,
    required this.onDelete,
  }) : super(key: key);

  final int width;
  final int height;
  final int offset;

  final double gaugeMin;
  final double gaugeMax;
  final double value;
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
                child: SfRadialGauge(
                  enableLoadingAnimation: true,
                  title: GaugeTitle(text: title),
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: gaugeMin,
                      maximum: gaugeMax,
                      pointers: <GaugePointer>[
                        RangePointer(cornerStyle: CornerStyle.bothFlat, color: Theme.of(context).primaryColor, value: value),
                        NeedlePointer(needleLength: 0.7, needleEndWidth: 4, needleStartWidth: 1, value: value),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Container(child: Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                          angle: 90,
                          positionFactor: 0.75,
                        )
                      ],
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
}
