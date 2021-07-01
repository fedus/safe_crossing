import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:safe_crossing/model/map_imagery.dart';

class CrossingMap extends StatefulWidget {
  final LatLng crossingPosition;
  final MapImagery mapImagery;

  CrossingMap({ this.crossingPosition, this.mapImagery });

  @override
  _CrossingMapState createState() => _CrossingMapState();
}

class _CrossingMapState extends State<CrossingMap> {

  MapController mapController;
  bool controllerReady = false;
  bool buildFinished = false;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    mapController.onReady.then((value) {
      setState(() {
        controllerReady = true;
      });
    });
    WidgetsBinding.instance
        .addPostFrameCallback((_) => buildFinished = true);
  }

  void _handleMove(position, hasGesture) {
    if (buildFinished) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        //interactiveFlags: InteractiveFlag.none,
        center: widget.crossingPosition,
        zoom: 20.0,
        onPositionChanged: _handleMove
      ),
      layers: [
        TileLayerOptions(
            //urlTemplate: "https://api.maptiler.com/tiles/satellite/{z}/{x}/{y}.jpg?key=4tU816YhKHyTCL9UrWcy",
            urlTemplate: widget.mapImagery.getUrlTemplate,
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
              point: controllerReady ? mapController.center : widget.crossingPosition,
              anchorPos: AnchorPos.align(AnchorAlign.center),
              builder: (ctx) => Container(
                child: Icon(Icons.circle, size: 10, color: Colors.blueAccent,),
              ),
            ),
          ],
        ),
        CircleLayerOptions(circles: [
          CircleMarker(
              point: controllerReady ? mapController.center : widget.crossingPosition,
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
