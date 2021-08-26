import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:zweb/const.dart';

class SwitchWidget extends StatefulWidget {
  const SwitchWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.offset,
    required this.value,
    required this.title,
    required this.onDelete,
    required this.onChange,
  }) : super(key: key);

  final int width;
  final int height;
  final int offset;

  final bool value;
  final String title;

  final VoidCallback onDelete;

  final ValueChanged<bool> onChange;

  @override
  _SwitchWidgetState createState() => _SwitchWidgetState();
}

class _SwitchWidgetState extends State<SwitchWidget> {
  late bool switchValue;

  @override
  void initState() {
    super.initState();
    switchValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    var _constrainWidth = widget.width;
    var _offset = widget.offset;

    // if mobile overide width to 4 grid
    if ((MediaQuery.of(context).size.width > 960)) {
      _offset = widget.offset;
    } else if ((MediaQuery.of(context).size.width < 412)) {
      _constrainWidth = 4;
      _offset = 0;
    }

    if (_constrainWidth == 2) {
      _offset = widget.offset - 16;
    }

    if (_constrainWidth == 3) {
      _offset = widget.offset - 20;
    }

    if (_constrainWidth == 4) {
      _offset = 0;
    }

    var _width = MediaQuery.of(context).size.width - _offset;
    var _height = MediaQuery.of(context).size.height;

    var _containerWidth = ((_width * ((0.25) * _constrainWidth)));
    var _containerHeight = ((_height * ((0.25) * widget.height)));

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(widget.title),
                    Container(
                      width: _containerWidth * 0.8,
                      height: _containerHeight * 0.8,
                      child: FlutterSwitch(
                        width: 125.0,
                        height: 55.0,
                        valueFontSize: 25.0,
                        toggleSize: 45.0,
                        borderRadius: 30.0,
                        padding: 8.0,
                        showOnOff: true,
                        value: switchValue,
                        onToggle: (bool _value) {
                          widget.onChange(_value);
                          setState(() {
                            switchValue = _value;
                          });
                        },
                      ),
                    ),
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
