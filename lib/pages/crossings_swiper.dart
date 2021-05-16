import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/demo/crossing_positions.dart';
import 'package:safe_crossing/widgets/crossing_map.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';

import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrossingsSwiper extends StatefulWidget {
  @override
  _CrossingsSwiperState createState() => _CrossingsSwiperState();
}

class _CrossingsSwiperState extends State<CrossingsSwiper> {
  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);

  List<PedestrianCrossing> crossings = [];

  final crossingsRef = FirebaseFirestore.instance
      .collection('crossings')
      .withConverter<PedestrianCrossing>(
    fromFirestore: (snapshots, _) => PedestrianCrossing.fromJson(snapshots.data()),
  );

  int queryAmount = 10;
  List<int> dataBounds;

  final swipeController = SwipableStackController();

  @override
  void initState() {
    super.initState();
    _updateMoviesQuery();
  }

  void _updateMoviesQuery() {
    setState(() {
      crossingsRef.limit(10).get().then((QuerySnapshot querySnapshot) {
        crossings.addAll(querySnapshot.docs.map((doc) => doc.data()));
      });
    });
  }

  Future<void> _showHelpDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                        'Look at the map presented to you. The cross indicates '
                        'the position of the relevant pedestrian crossing, and '
                        'the blue circle has a radius of 5m.')),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                        'First, put the blue circle on one end of the pedestrian '
                        'crossing by tapping on the relevant place on the map. Then, '
                        'repeat with the other end of the pedestrian crossing.')),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                        'Did you see parking spots in the 5m radius higlighted '
                        'by the circle on either end of the pedestrian crossing?')),
                Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                        'If no, tap the green button to show that all is good! If '
                        'you did see parking spots that were too close to the pedestrian '
                        'crossing, tap the red button.')),
                Text("If it's impossible to tell, press the orange button.")
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Safe Crossing"),
      ),
      body: Stack(children: [
        Container(
          child: SwipableStack(
            controller: swipeController,
            onSwipeCompleted: (index, direction) {
              print("${crossings.length} elements in list");
              if (crossings.length - 2 <= index) {
                print("Loading more ...");
                _updateMoviesQuery();
              }
            },
            builder: (context, index, constraints) {
              return index < crossings.length
              ? Container(
                alignment: Alignment.center,
                child: CrossingMap(
                  crossingPosition: crossings[index].position,
                ),
              )
              : Center(child: Text("Hooray! You're at the end."));
            },
          ),
        ),
        Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              child: Icon(Icons.help),
              backgroundColor: Colors.blue,
              heroTag: 1,
              onPressed: _showHelpDialog,
            )),
      ]),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                height: 100.0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: FittedBox(
                    child: FloatingActionButton.extended(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        label: Icon(Icons.check),
                        backgroundColor: Colors.green,
                        onPressed: () => swipeController.next(
                            swipeDirection: SwipeDirection.left)))),
            Container(
                height: 100.0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: FittedBox(
                    child: FloatingActionButton.extended(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        label: Icon(Icons.cancel),
                        backgroundColor: Colors.orange,
                        onPressed: () => swipeController.next(
                            swipeDirection: SwipeDirection.down)))),
            Container(
                height: 100.0,
                width: MediaQuery.of(context).size.width * 0.3,
                child: FittedBox(
                    child: FloatingActionButton.extended(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        label: Icon(Icons.warning),
                        backgroundColor: Colors.red,
                        onPressed: () => swipeController.next(
                            swipeDirection: SwipeDirection.right)))),
          ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
