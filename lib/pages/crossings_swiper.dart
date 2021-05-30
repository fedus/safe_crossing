import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/widgets/crossing_map.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';

import 'package:swipable_stack/swipable_stack.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_chart/fl_chart.dart';

enum Vote {
  CANT_SAY,
  OK,
  PARKING_CLOSE,
}

extension VoteToFirebaseProperty on Vote {
  String get firebaseProperty {
    switch(this) {
      case Vote.CANT_SAY:
        return 'votesNotSure';
      case Vote.OK:
        return 'votesOk';
      case Vote.PARKING_CLOSE:
        return 'votesTooClose';
      default:
        throw new Exception("Invalid vote to firebase property conversion");
    }
  }
}

class CrossingsSwiper extends StatefulWidget {
  @override
  _CrossingsSwiperState createState() => _CrossingsSwiperState();
}

class _CrossingsSwiperState extends State<CrossingsSwiper> {
  FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);

  List<QueryDocumentSnapshot<PedestrianCrossing>> crossingsSnapshots = [];
  Future _initializationFuture;

  int percentCompleted = 0;
  double percentOk = 0;
  double percentNotSure = 0;
  double percentTooClose = 0;
  double percentTie = 0;
  double percentPlaceholder = 100;

  final crossingsRef = FirebaseFirestore.instance
      .collection('crossings')
      .withConverter<PedestrianCrossing>(
    fromFirestore: (snapshots, _) =>
        PedestrianCrossing.fromJson(snapshots.data()),
  );

  final metaDoc = FirebaseFirestore.instance
      .collection('meta')
      .doc('meta');

  SharedPreferences prefs;
  String userUuid;

  int queryAmount = 10;

  final swipeController = SwipableStackController();

  @override
  void initState() {
    super.initState();
    swipeController.addListener(() => setState(() {}));
    metaDoc.snapshots().listen((snapshot) {
      int totalCrossings = snapshot.get('totalCrossings');
      int completedCrossings = snapshot.get('crossingsWithEnoughVotes');
      int okCrossings = snapshot.get('votesOk');
      int notSureCrossings = snapshot.get('votesNotSure');
      int tooCloseCrossings = snapshot.get('votesTooClose');
      int tieCrossings = snapshot.get('votesTie');

      setState(() {
        percentCompleted = (completedCrossings / totalCrossings * 100).floor();
        percentOk = okCrossings / completedCrossings * 100;
        percentNotSure = notSureCrossings / completedCrossings * 100;
        percentTooClose = tooCloseCrossings / completedCrossings * 100;
        percentTie = tieCrossings / completedCrossings * 100;

        percentPlaceholder = completedCrossings > 0 ? 0 : 100;
      });
    });
    _initializationFuture = _initializeUuidAndQuery();
  }

  Future<bool> getUserUuid() async {
    prefs = await SharedPreferences.getInstance();

    bool isNewUuid = !prefs.containsKey('userUuid');

    userUuid = prefs.getString('userUuid') ?? Uuid().v4();
    prefs.setString('userUuid', userUuid);

    print('User ID: $userUuid');

    return isNewUuid;
  }

  Future<void> _initializeUuidAndQuery() async {
    await getUserUuid();
    HttpsCallableResult<String> userInitializationResult = await functions.httpsCallable('initializeUser')({'userUuid': userUuid});
    print("User eligibility: ${userInitializationResult.data}");

    return _updateMoviesQuery(0);
  }

  Future<void> _updateMoviesQuery(currentIndex) async {
    Query<PedestrianCrossing> crossingQuery;

    if (currentIndex > 0 ) {
      crossingQuery = crossingsRef
          .where('unseenBy', arrayContains: userUuid)
          .orderBy('votesTotal')
          .startAfterDocument(crossingsSnapshots.last);
    } else {
      crossingQuery = crossingsRef
          .where('unseenBy', arrayContains: userUuid)
          .orderBy('votesTotal');
    }

    QuerySnapshot<PedestrianCrossing> _crossingsSnapshot = await crossingQuery
        .limit(10)
        .get();

    setState(() {
      crossingsSnapshots.addAll(_crossingsSnapshot.docs);
    });

    crossingsSnapshots.asMap().forEach((index, cSnap) {
      String id = cSnap.get('nodeId');
      print('Id $id at index $index');
    });
  }

  void _vote(String crossingNodeId, Vote vote ) async {
    HttpsCallable voteCallable = functions.httpsCallable('vote');
    HttpsCallableResult<String> voteResult = await voteCallable(({'userUuid': userUuid, 'crossingNodeId': crossingNodeId, 'vote': vote.index}));
    print("Vote result for $crossingNodeId: ${voteResult.data}");
  }

  void _openStreetViewUrl() async {
    LatLng streetViewPosition = crossingsSnapshots[swipeController.currentIndex].data().position;
    String url = 'http://maps.google.com/maps?q=&layer=c&cbll=${streetViewPosition.latitude},${streetViewPosition.longitude}&cbp=11,direction,0,0,0';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
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
                    Vote vote;

                    switch (direction) {
                      case SwipeDirection.left:
                        vote = Vote.OK;
                        break;
                      case SwipeDirection.right:
                        vote = Vote.PARKING_CLOSE;
                        break;
                      default:
                        vote = Vote.CANT_SAY;
                    }

                    PedestrianCrossing currentCrossing = crossingsSnapshots[index].data();

                    _vote(currentCrossing.nodeId, vote);

                    print("Swiped ${currentCrossing.nodeId} at index $index, ${crossingsSnapshots.length} elements in list");

                    if (crossingsSnapshots.length - index <= 5) {
                      print("Loading more ...");
                      _updateMoviesQuery(index);
                    }
                  },
                  builder: (context, index, constraints) {
                    QueryDocumentSnapshot<PedestrianCrossing> currentCrossingSnapshot = crossingsSnapshots[index];
                    PedestrianCrossing currentCrossing = currentCrossingSnapshot.data();

                    return index < crossingsSnapshots.length
                        ? Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                          // Absorb card swiping in favour of map gestures
                          onPanStart: (_) => {},
                          onPanUpdate: (_) => {},
                          onPanEnd: (_) => {},
                          child: Stack(children: [
                            Container(
                                foregroundDecoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(-1, -1),
                                    end: Alignment(-1, -0.75),
                                    colors: [Colors.black54, Colors.transparent],
                                  ),
                                ),
                          child: CrossingMap(
                              crossingPosition: currentCrossing.position,
                            )),
                            Positioned(
                                top: 20,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currentCrossing.neighbourhood, style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(0, 0),
                                          blurRadius: 10.0,
                                          color: Colors.black,
                                        ),
                                      ],
                                    )),
                                    Text(currentCrossing.street, style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      shadows: <Shadow>[
                                        Shadow(
                                          offset: Offset(0, 0),
                                          blurRadius: 10.0,
                                          color: Colors.black,
                                        ),
                                      ],
                                    )),
                                    Row(children: [
                                      Padding(child: Chip(
                                      visualDensity: VisualDensity.compact,
                                      labelPadding: EdgeInsets.all(5.0),
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: currentCrossingSnapshot.reference.snapshots(),
                                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                            if (snapshot.hasError) {
                                              return Text('?');
                                            }

                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            }

                                            return Text(snapshot.data.get('votesTotal').toString(), style: TextStyle(
                                              color: Colors.orange,
                                            ));
                                          },
                                        ),
                                      ),
                                      label: Text(
                                        'votes',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.orange,
                                      elevation: 8.0,
                                      shadowColor: Colors.black,
                                      padding: EdgeInsets.all(6.0),
                                    ), padding: EdgeInsets.only(top: 10)),
                                      Padding(child: Chip(
                                        visualDensity: VisualDensity.compact,
                                        labelPadding: EdgeInsets.all(5.0),
                                        avatar: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: Text(percentCompleted.toString(), style: TextStyle(
                                            color: Colors.green,
                                          )),
                                        ),
                                        label: Text(
                                          '% complete',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.green,
                                        elevation: 8.0,
                                        shadowColor: Colors.black,
                                        padding: EdgeInsets.all(6.0),
                                      ), padding: EdgeInsets.only(top: 10, left: 10))])
                                  ]
                                )),
                          ])))
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
              Positioned(
                  top: 100,
                  right: 20,
                  child: FloatingActionButton(
                    child: Icon(Icons.streetview),
                    backgroundColor: Colors.green,
                    heroTag: 2,
                    onPressed: _openStreetViewUrl,
                  )),
              Positioned(
                  top: 180,
                  right: 20,
                  child: Visibility(
                    visible: percentPlaceholder < 100,
                      child: SizedBox(width: 60, height: 60, child: Material(type: MaterialType.circle, color: Colors.blue.withAlpha(1), elevation: 10, child: PieChart(
                    PieChartData(
                        borderData: FlBorderData(
                          show: false,
                        ),
                        sectionsSpace: 0,
                        centerSpaceRadius: 15,
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: percentOk,
                            showTitle: false,
                            radius: 10,
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: percentNotSure,
                            showTitle: false,
                            radius: 10,
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: percentTooClose,
                            showTitle: false,
                            radius: 10,
                          ),
                          PieChartSectionData(
                            color: Colors.white60,
                            value: percentTie,
                            radius: 10,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: const Color(0xff0293ee).withAlpha(1),
                            value: percentPlaceholder,
                            radius: 10,
                            showTitle: false,
                          ),
                        ]),
                  )),
                  ))),
              Positioned(
                  top: percentPlaceholder < 100 ? 260 : 180,
                  right: 20,
                  child: Visibility(
                    visible: swipeController.canRewind,
                    child: FloatingActionButton(
                            child: Icon(Icons.undo),
                            backgroundColor: Colors.orange,
                            heroTag: 3,
                            onPressed: () => swipeController.rewind(),
                  ))),
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
                        label: Icon(Icons.help),
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
