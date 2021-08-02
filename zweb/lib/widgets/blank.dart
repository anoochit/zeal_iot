import 'package:flutter/material.dart';
import 'package:zweb/const.dart';

class BlankWidget extends StatelessWidget {
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
        decoration: BoxDecoration(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.zoom_out_map),
            Text(
              title,
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        )),
      ),
    );
  }
}
