import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:safe_crossing/model/pedestrian_crossing.dart';

class CrossingInfos extends StatelessWidget {
  final PedestrianCrossing currentCrossing;
  final QueryDocumentSnapshot<PedestrianCrossing> currentCrossingSnapshot;
  final int percentCompleted;

  CrossingInfos({
    @required this.currentCrossing,
    @required this.currentCrossingSnapshot,
    @required this.percentCompleted
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(
          top: 20,
          left: 20,
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(currentCrossing.neighbourhood,
                style: TextStyle(
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
            Text(currentCrossing.street,
                style: TextStyle(
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
              Padding(
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    labelPadding: EdgeInsets.all(5.0),
                    avatar: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: currentCrossingSnapshot.reference.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('?');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          return Text(
                              snapshot.data.get('votesTotal').toString(),
                              style: TextStyle(
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
                  ),
                  padding: EdgeInsets.only(top: 10)),
              Padding(
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    labelPadding: EdgeInsets.all(5.0),
                    avatar: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(percentCompleted.toString(),
                          style: TextStyle(
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
                  ),
                  padding: EdgeInsets.only(top: 10, left: 10))
            ])
          ]))
    ]);
  }
}
