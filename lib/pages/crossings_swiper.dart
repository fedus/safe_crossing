import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';
import 'package:safe_crossing/widgets/crossing_map.dart';

import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter_map/flutter_map.dart';

class CrossingsSwiper extends StatefulWidget {
  @override
  _CrossingsSwiperState createState() => _CrossingsSwiperState();
}

class _CrossingsSwiperState extends State<CrossingsSwiper> {

  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);

  final swipeController = SwipableStackController();

  List<LatLng> _positions = [
    LatLng(49.5726531, 6.0971228),
    LatLng(49.6020238, 6.1004611),
    LatLng(49.5992074, 6.1223236),
    LatLng(49.6072024, 6.1149133),
    LatLng(49.6123993, 6.1258398)
  ];

  void _handleTap(LatLng latLng) {
    setState(() {
      circlePosition = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Safe Crossing"),
      ),
      body: Container(
          child: Column(children: [
            Container(
              height: 550,
              child: SwipableStack(
                controller: swipeController,
                builder: (context, index, constraints) {

                  print(index);
                  return Container(
                    alignment: Alignment.center,
                    child: CrossingMap(crossingPosition: _positions[index],),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      swipeController.next(
                        swipeDirection: SwipeDirection.left,
                      );
                    },
                    child: Text("All clear")),
/*                ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem.superLike();
                    },
                    child: Text("Superlike")),*/
                ElevatedButton(
                    onPressed: () {
                      swipeController.next(
                        swipeDirection: SwipeDirection.right,
                      );
                    },
                    child: Text("Parking too close"),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)))
              ],
            )
          ]))
    );
  }
}
