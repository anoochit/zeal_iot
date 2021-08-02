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

  @override
  Widget build(BuildContext context) {
    var _constrainWidth = widget.width;
    var _offset;

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
            MapLayoutBuilder(
              controller: controller,
              builder: (context, transformer) {
                final markerPositions = markers.map(transformer.fromLatLngToXYCoords).toList();
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
                      Map(
                        controller: controller,
                        builder: (context, x, y, z) {
                          //Legal notice: This url is only used for demo and educational purposes. You need a license key for production use.

                          //Google Maps
                          final url = 'https://www.google.com/maps/vt/pb=!1m4!1m3!1i$z!2i$x!3i$y!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';

                          //final darkUrl ='https://maps.googleapis.com/maps/vt?pb=!1m5!1m4!1i$z!2i$x!3i$y!4i256!2m3!1e0!2sm!3i556279080!3m17!2sen-US!3sUS!5e18!12m4!1e68!2m2!1sset!2sRoadmap!12m3!1e37!2m1!1ssmartmaps!12m4!1e26!2m2!1sstyles!2zcC52Om9uLHMuZTpsfHAudjpvZmZ8cC5zOi0xMDAscy5lOmwudC5mfHAuczozNnxwLmM6I2ZmMDAwMDAwfHAubDo0MHxwLnY6b2ZmLHMuZTpsLnQuc3xwLnY6b2ZmfHAuYzojZmYwMDAwMDB8cC5sOjE2LHMuZTpsLml8cC52Om9mZixzLnQ6MXxzLmU6Zy5mfHAuYzojZmYwMDAwMDB8cC5sOjIwLHMudDoxfHMuZTpnLnN8cC5jOiNmZjAwMDAwMHxwLmw6MTd8cC53OjEuMixzLnQ6NXxzLmU6Z3xwLmM6I2ZmMDAwMDAwfHAubDoyMCxzLnQ6NXxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjV8cy5lOmcuc3xwLmM6I2ZmNGQ2MDU5LHMudDo4MnxzLmU6Zy5mfHAuYzojZmY0ZDYwNTkscy50OjJ8cy5lOmd8cC5sOjIxLHMudDoyfHMuZTpnLmZ8cC5jOiNmZjRkNjA1OSxzLnQ6MnxzLmU6Zy5zfHAuYzojZmY0ZDYwNTkscy50OjN8cy5lOmd8cC52Om9ufHAuYzojZmY3ZjhkODkscy50OjN8cy5lOmcuZnxwLmM6I2ZmN2Y4ZDg5LHMudDo0OXxzLmU6Zy5mfHAuYzojZmY3ZjhkODl8cC5sOjE3LHMudDo0OXxzLmU6Zy5zfHAuYzojZmY3ZjhkODl8cC5sOjI5fHAudzowLjIscy50OjUwfHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE4LHMudDo1MHxzLmU6Zy5mfHAuYzojZmY3ZjhkODkscy50OjUwfHMuZTpnLnN8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmd8cC5jOiNmZjAwMDAwMHxwLmw6MTYscy50OjUxfHMuZTpnLmZ8cC5jOiNmZjdmOGQ4OSxzLnQ6NTF8cy5lOmcuc3xwLmM6I2ZmN2Y4ZDg5LHMudDo0fHMuZTpnfHAuYzojZmYwMDAwMDB8cC5sOjE5LHMudDo2fHAuYzojZmYyYjM2Mzh8cC52Om9uLHMudDo2fHMuZTpnfHAuYzojZmYyYjM2Mzh8cC5sOjE3LHMudDo2fHMuZTpnLmZ8cC5jOiNmZjI0MjgyYixzLnQ6NnxzLmU6Zy5zfHAuYzojZmYyNDI4MmIscy50OjZ8cy5lOmx8cC52Om9mZixzLnQ6NnxzLmU6bC50fHAudjpvZmYscy50OjZ8cy5lOmwudC5mfHAudjpvZmYscy50OjZ8cy5lOmwudC5zfHAudjpvZmYscy50OjZ8cy5lOmwuaXxwLnY6b2Zm!4e0&key=AIzaSyAOqYYyBbtXQEtcHG7hwAwyCPQSYidG8yU&token=31440';

                          //Mapbox Streets
                          //final url = 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$z/$x/$y?access_token=YOUR_MAPBOX_ACCESS_TOKEN';

                          return CachedNetworkImage(
                            imageUrl: url,
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
