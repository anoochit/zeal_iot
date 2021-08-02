import 'package:flutter/material.dart';
import 'package:zweb/const.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.offset,
    required this.onDelete,
  }) : super(key: key);

  final int width;
  final int height;
  final int offset;

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
          decoration: BoxDecoration(),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  width: ((_width * ((0.25) * _constrainWidth))) * 0.8,
                  height: ((_height * ((0.25) * height))) * 0.8,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('No data!, please publish your data stream.'),
                    ),
                  ),
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
