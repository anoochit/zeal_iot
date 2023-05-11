import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:zweb/const.dart';

class RadialGaugeWidget extends StatefulWidget {
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
  State<RadialGaugeWidget> createState() => _RadialGaugeWidgetState();
}

class _RadialGaugeWidgetState extends State<RadialGaugeWidget> {
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
                child: SfRadialGauge(
                  enableLoadingAnimation: true,
                  title: GaugeTitle(text: widget.title),
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: widget.gaugeMin,
                      maximum: widget.gaugeMax,
                      pointers: <GaugePointer>[
                        RangePointer(
                            cornerStyle: CornerStyle.bothFlat,
                            color: Theme.of(context).primaryColor,
                            value: widget.value),
                        NeedlePointer(
                            needleLength: 0.7,
                            needleEndWidth: 4,
                            needleStartWidth: 1,
                            value: widget.value),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Container(
                              child: Text('${widget.value}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
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
}
