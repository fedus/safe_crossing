import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'package:flutter_map/flutter_map.dart';

class CrossingMap extends StatefulWidget {
  final LatLng crossingPosition;

  CrossingMap({ this.crossingPosition });

  @override
  _CrossingMapState createState() => _CrossingMapState();
}

class _CrossingMapState extends State<CrossingMap> {

  MapController mapController;
  LatLng circlePosition;

  void _handleTap(LatLng newPosition) {
    setState(() {
      circlePosition = newPosition;
    });
  }

  @override
  void initState() {
    super.initState();
    circlePosition = widget.crossingPosition;
  }


  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        //interactiveFlags: InteractiveFlag.none,
        center: widget.crossingPosition,
        zoom: 20.0,
        onTap: _handleTap,
      ),
      layers: [
        TileLayerOptions(
            //urlTemplate: "https://api.maptiler.com/tiles/satellite/{z}/{x}/{y}.jpg?key=4tU816YhKHyTCL9UrWcy",
            urlTemplate: "https://maps.vdl.lu/arcgis/rest/services/BASEMAP/ORTHO_2019/MapServer/tile/{z}/{y}/{x}",
            maxNativeZoom: 20,
            maxZoom: 22
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 50.0,
              height: 50.0,
              point: widget.crossingPosition,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              builder: (ctx) => Container(
                child: Icon(Icons.add, size: 50),
              ),
            ),
            Marker(
              width: 10.0,
              height: 10.0,
              point: circlePosition,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              builder: (ctx) => Container(
                child: Icon(Icons.circle, size: 10, color: Colors.blueAccent,),
              ),
            ),
          ],
        ),
        CircleLayerOptions(circles: [
          CircleMarker(
              point: circlePosition,
              color: Colors.blue.withOpacity(0.25),
              borderColor: Colors.blue,
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
              radius: 5 // 2000 meters | 2 km
          ),
        ]),
      ],
    );
  }
}
