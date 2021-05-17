import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/widgets/crossing_map.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';

import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CrossingsSwiper extends StatefulWidget {
  @override
  _CrossingsSwiperState createState() => _CrossingsSwiperState();
}

class _CrossingsSwiperState extends State<CrossingsSwiper> {
  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);

  List<PedestrianCrossing> crossings = [];
  QueryDocumentSnapshot<PedestrianCrossing> _lastCrossingSnapshot;
  Future _initializationFuture;

  final crossingsRef = FirebaseFirestore.instance
      .collection('crossings')
      .withConverter<PedestrianCrossing>(
    fromFirestore: (snapshots, _) =>
        PedestrianCrossing.fromJson(snapshots.data()),
  );

  SharedPreferences prefs;
  String userUuid;

  int queryAmount = 10;

  final swipeController = SwipableStackController();

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeUuidAndQuery();
  }

  Future<String> getUserUuid() async {
    prefs = await SharedPreferences.getInstance();
    userUuid = prefs.getString('userUuid') ?? Uuid().v4();
    prefs.setString('userUuid', userUuid);
    print(userUuid);

    return userUuid;
  }

  Future<void> _initializeUuidAndQuery() async {
    await getUserUuid();
    return _updateMoviesQuery();
  }

  Future<void> _updateMoviesQuery() async {
    QuerySnapshot<
        PedestrianCrossing> _crossingsSnapshot = await (_lastCrossingSnapshot ==
        null
        ? crossingsRef.orderBy('nodeId').limit(10)
        : crossingsRef.orderBy('nodeId').startAfterDocument(
        _lastCrossingSnapshot).limit(10)
    ).get();

    setState(() {
      crossings.addAll(_crossingsSnapshot.docs.map((doc) => doc.data()));
      _lastCrossingSnapshot = _crossingsSnapshot.docs.last;
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
      body: FutureBuilder(
          future: _initializationFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Something went wrong. Please restart the application.")
              );
            }

            // Once complete, show your application
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                  child: CircularProgressIndicator()
              );
            }

            return Stack(children: [
              Container(
                child: SwipableStack(
                  controller: swipeController,
                  onSwipeCompleted: (index, direction) {
                    print("Swiped ${crossings[index].nodeId}, ${crossings
                        .length} elements in list");
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
            ]);
          }),
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
                height: 100.0,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.3,
                child: FittedBox(
                    child: FloatingActionButton.extended(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        label: Icon(Icons.check),
                        backgroundColor: Colors.green,
                        onPressed: () =>
                            swipeController.next(
                                swipeDirection: SwipeDirection.left)))),
            Container(
                height: 100.0,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.3,
                child: FittedBox(
                    child: FloatingActionButton.extended(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        label: Icon(Icons.cancel),
                        backgroundColor: Colors.orange,
                        onPressed: () =>
                            swipeController.next(
                                swipeDirection: SwipeDirection.down)))),
            Container(
                height: 100.0,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.3,
                child: FittedBox(
                    child: FloatingActionButton.extended(
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        label: Icon(Icons.warning),
                        backgroundColor: Colors.red,
                        onPressed: () =>
                            swipeController.next(
                                swipeDirection: SwipeDirection.right)))),
          ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
