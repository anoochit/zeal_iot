import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:map/map.dart';
import 'package:zweb/const.dart';
import 'package:latlng/latlng.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.offset,
    required this.lat,
    required this.lon,
    required this.title,
    required this.onDelete,
  }) : super(key: key);

  final int width;
  final int height;
  final int offset;

  final double lat;
  final double lon;
  final String title;

  final VoidCallback onDelete;

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController controller;

  Widget _buildMarkerWidget(Offset pos, Color color) {
    return Positioned(
      left: pos.dx - 32,
      top: pos.dy - 32,
      width: 32,
      height: 32,
      child: Icon(Icons.location_pin, color: color, size: 32),
    );
  }

  // Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.
  String google(int z, int x, int y) {
    //Google Maps
    final url =
        'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

    return url;
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

    controller = MapController(location: LatLng(widget.lat, widget.lon));

    var markers = [LatLng(widget.lat, widget.lon)];

    return Card(
      shape: kCardBorderRadius,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: _containerWidth,
        height: _containerHeight,
        decoration: BoxDecoration(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Stack(
          children: [
            MapLayout(
              controller: controller,
              builder: (context, transformer) {
                final markerPositions = markers.map(transformer.toOffset).toList();
                final markerWidgets = markerPositions.map(
                  (pos) => _buildMarkerWidget(pos, Colors.red),
                );

                controller.zoom = 18;

                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final delta = event.scrollDelta;
                      controller.zoom -= delta.dy / 1000.0;
                      setState(() {});
                    }
                  },
                  child: Stack(
                    children: [
                      TileLayer(
                        builder: (context, x, y, z) {
                          final tilesInZoom = pow(2.0, z).floor();

                          while (x < 0) {
                            x += tilesInZoom;
                          }
                          while (y < 0) {
                            y += tilesInZoom;
                          }

                          x %= tilesInZoom;
                          y %= tilesInZoom;

                          return CachedNetworkImage(
                            imageUrl: google(z, x, y),
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      ...markerWidgets,
                    ],
                  ),
                );
              },
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
        ),
      ),
    );
  }
}
