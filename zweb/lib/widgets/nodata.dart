import 'package:flutter/material.dart';
import 'package:zweb/const.dart';

class NoDataWidget extends StatefulWidget {
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
  State<NoDataWidget> createState() => _NoDataWidgetState();
}

class _NoDataWidgetState extends State<NoDataWidget> {
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
          child: Stack(
            children: [
              Positioned.fill(
                child: SizedBox(
                  width: ((width * ((0.25) * constrainWidth))) * 0.8,
                  height: ((height * ((0.25) * height))) * 0.8,
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
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
