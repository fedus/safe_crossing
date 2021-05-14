import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';
import 'package:safe_crossing/widgets/crossing_map.dart';

import 'package:swipe_cards/swipe_cards.dart';
import 'package:flutter_map/flutter_map.dart';

class CrossingsSwiper extends StatefulWidget {
  @override
  _CrossingsSwiperState createState() => _CrossingsSwiperState();
}

class _CrossingsSwiperState extends State<CrossingsSwiper> {

  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);

  List<SwipeItem> _swipeItems = [];
  MatchEngine _matchEngine;

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
  void initState() {
    for (int i = 0; i < _positions.length; i++) {
      _swipeItems.add(SwipeItem(
          content: PedestrianCrossing(id: i, position: _positions[i]),
          likeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Liked $i"),
              duration: Duration(milliseconds: 500),
            ));
          },
          nopeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Nope $i"),
              duration: Duration(milliseconds: 500),
            ));
          },
          superlikeAction: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Superliked $i"),
              duration: Duration(milliseconds: 500),
            ));
          }));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
    super.initState();
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
              child: SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  print(index);
                  return Container(
                    alignment: Alignment.center,
                    child: CrossingMap(crossingPosition: _positions[index],),
                  );
                },
                onStackFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Stack Finished"),
                    duration: Duration(milliseconds: 500),
                  ));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem.nope();
                    },
                    child: Text("All clear")),
/*                ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem.superLike();
                    },
                    child: Text("Superlike")),*/
                ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem.like();
                    },
                    child: Text("Parking too close"),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)))
              ],
            )
          ]))
    );
  }
}
