import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/widgets/crossing_infos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:safe_crossing/model/pedestrian_crossing.dart';
import 'package:safe_crossing/model/vote.dart';
import 'package:safe_crossing/widgets/big_loading.dart';
import 'package:safe_crossing/widgets/crossing_map.dart';
import 'package:safe_crossing/widgets/help_dialog.dart';
import 'package:safe_crossing/widgets/voting_buttons.dart';


class SwipeScreen extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  FirebaseFunctions functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);
  
  double actionButtonsHeight = 10;
  double actionButtonsOpacity = 0;

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

    await _updateCrossingsQuery(0);

    actionButtonsHeight = 100;
    actionButtonsOpacity = 1;
  }

  Future<void> _updateCrossingsQuery(currentIndex) async {
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
        return HelpDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _initializationFuture,
          builder: (context, snapshot) {
            Widget dynamicWidget;

            if (snapshot.hasError) {
              dynamicWidget = Center(
                child: Text("Something went wrong. Please restart the application.")
              );
            } else if (snapshot.connectionState != ConnectionState.done) {
              dynamicWidget = BigLoading();
            } else {
              dynamicWidget = Stack(children: [
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
                        _updateCrossingsQuery(index);
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
                                SafeArea(child: CrossingInfos(
                                  currentCrossing: currentCrossing,
                                  currentCrossingSnapshot: currentCrossingSnapshot,
                                  percentCompleted: percentCompleted,
                                )),
                              ])))
                          : Center(child: Text("Hooray! You're at the end."));
                    },
                  ),
                ),
                SafeArea(child: Stack(children: [Positioned(
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
                          )))])),
              ]);
            }

            return AnimatedSwitcher(
                duration: Duration(seconds: 1),
                child: dynamicWidget
            );
          }),
      floatingActionButton: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: actionButtonsOpacity,
    child: AnimatedContainer(
          duration: Duration(seconds: 1),
          height: actionButtonsHeight,
          child: VotingButtons(
              okCallback: () => swipeController.next(swipeDirection: SwipeDirection.left),
              notSureCallback: () => swipeController.next(swipeDirection: SwipeDirection.down),
              tooCloseCallback: () => swipeController.next(swipeDirection: SwipeDirection.right)
          ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
