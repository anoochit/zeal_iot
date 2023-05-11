import 'package:flutter/material.dart';
import 'package:zweb/const.dart';

class BlankWidget extends StatefulWidget {
  const BlankWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.offset,
    required this.title,
  }) : super(key: key);

  final int width;
  final int height;
  final int offset;
  final String title;

  @override
  State<BlankWidget> createState() => _BlankWidgetState();
}

class _BlankWidgetState extends State<BlankWidget> {
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
        decoration: const BoxDecoration(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.zoom_out_map),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        )),
      ),
    );
  }
}
