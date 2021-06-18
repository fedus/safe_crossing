import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';
import 'package:safe_crossing/repository/reactive_crossings_repository.dart';
import 'package:safe_crossing/util/util.dart';
import 'package:cloud_functions/cloud_functions.dart';


class CrossingsRepository implements ReactiveCrossingsRepository {
  static const String CROSSINGS_COLLECTION = 'crossing';

  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  CollectionReference<PedestrianCrossing> crossingsCollection;

  CrossingsRepository({ @required this.firestore, @required this.functions }) {
    crossingsCollection = firestore
        .collection('crossings')
        .withConverter<PedestrianCrossing>(
          fromFirestore: (snapshots, _) =>
            PedestrianCrossing.fromJson(snapshots.data()),
    );
  }

  @override
  Future<List<PedestrianCrossing>> getNextBatch(
      String userId,
      int quantity,
      PedestrianCrossing lastCrossing)
  async {
    HttpsCallableResult<List<dynamic>> callableResult = await functions
        .httpsCallable('getNextBatch')({'userId': userId, 'quantity': quantity, 'lastCrossingId': lastCrossing != null ? lastCrossing.nodeId : null});

    final List<PedestrianCrossing> nextBatch = callableResult.data.map((rawCrossing) => PedestrianCrossing.fromJson(new Map<String, dynamic>.from(rawCrossing))).toList();

    return nextBatch;
  }

  @override
  Stream<PedestrianCrossing> getStreamForCrossing(PedestrianCrossing pedestrianCrossing) {
    final String crossingFirebaseId = nodeIdToFirestoreId(pedestrianCrossing.nodeId);

    return crossingsCollection
        .doc(crossingFirebaseId)
        .snapshots()
        .map((crossingSnapshot) => crossingSnapshot.data());
  }
}
