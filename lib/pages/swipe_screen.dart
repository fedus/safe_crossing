import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:safe_crossing/widgets/action_buttons.dart';
import 'package:safe_crossing/widgets/crossing_infos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'package:safe_crossing/repository/crossings_repository.dart';
import 'package:safe_crossing/model/models.dart';
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
  final CrossingsRepository crossingsRepository = CrossingsRepository(
      firestore: FirebaseFirestore.instance,
      functions: FirebaseFunctions.instanceFor(region: 'europe-west1'));

  MapController mapController;
  LatLng circlePosition = LatLng(49.5726531, 6.0971228);

  MapImagery mapImagery = MapImagery.GEOPORTAIL_ORTHO_2020;
  
  double actionButtonsHeight = 10;
  double actionButtonsOpacity = 0;

  List<PedestrianCrossing> loadedCrossings = [];
  Future _initializationFuture;

  int percentCompleted = 0;
  double percentOk = 0;
  double percentNotSure = 0;
  double percentTooClose = 0;
  double percentTie = 0;
  double percentPlaceholder = 100;

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

    await _updateCrossingsQuery();

    actionButtonsHeight = 100;
    actionButtonsOpacity = 1;
  }

  Future<void> _updateCrossingsQuery() async {
    List<PedestrianCrossing> newCrossings = await crossingsRepository
        .getNextBatch(userUuid, 10, loadedCrossings.isEmpty ? null : loadedCrossings.last);

    setState(() {
      loadedCrossings.addAll(newCrossings);
    });

    loadedCrossings.asMap().forEach((index, crossing) {
      print('Id ${crossing.nodeId} at index $index');
    });
  }

  void _vote(String crossingNodeId, Vote vote ) async {
    HttpsCallable voteCallable = functions.httpsCallable('vote');
    HttpsCallableResult<String> voteResult = await voteCallable(({'userUuid': userUuid, 'crossingNodeId': crossingNodeId, 'vote': vote.index}));
    print("Vote result for $crossingNodeId: ${voteResult.data}");
  }

  void _openStreetViewUrl() async {
    LatLng streetViewPosition = loadedCrossings[swipeController.currentIndex].position;
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

  void _toggleMapImagery() {
    setState(() {
      mapImagery = (
          mapImagery == MapImagery.CITY_OF_LUXEMBOURG_ORTHO_2019
              ? MapImagery.GEOPORTAIL_ORTHO_2020
              : MapImagery.CITY_OF_LUXEMBOURG_ORTHO_2019
      );
    });
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

                      PedestrianCrossing currentCrossing = loadedCrossings[index];

                      _vote(currentCrossing.nodeId, vote);

                      print("Swiped ${currentCrossing.nodeId} at index $index, ${loadedCrossings.length} elements in list");

                      if (loadedCrossings.length - index <= 5) {
                        print("Loading more ...");
                        _updateCrossingsQuery();
                      }
                    },
                    builder: (context, index, constraints) {
                      PedestrianCrossing currentCrossing = loadedCrossings[index];

                      return index < loadedCrossings.length
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
                                      mapImagery: mapImagery,
                                    )),
                                SafeArea(child: CrossingInfos(
                                  currentCrossing: currentCrossing,
                                  currentCrossingStream: crossingsRepository.getStreamForCrossing(currentCrossing),
                                  percentCompleted: percentCompleted,
                                )),
                              ])))
                          : Center(child: Text("Hooray! You're at the end."));
                    },
                  ),
                ),
                SafeArea(child: ActionButtons(
                  helpCallback: _showHelpDialog,
                  streetViewCallback: _openStreetViewUrl,
                  rewindCallback: swipeController.rewind,
                  toggleCallback: _toggleMapImagery,
                  canRewind: swipeController.canRewind,
                  percentOk: percentOk,
                  percentNotSure: percentNotSure,
                  percentTooClose: percentTooClose,
                  percentTie: percentTie,
                  percentPlaceholder: percentPlaceholder
                )),
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
