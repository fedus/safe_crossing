import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:safe_crossing/model/pedestrian_crossing.dart';
import 'package:safe_crossing/repository/reactive_crossings_repository.dart';
import 'package:safe_crossing/util/util.dart';

class CrossingsRepository implements ReactiveCrossingsRepository {
  static const String CROSSINGS_COLLECTION = 'crossing';

  final FirebaseFirestore firestore;
  CollectionReference<PedestrianCrossing> crossingsCollection;

  CrossingsRepository({ @required this.firestore }) {
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
    Query<PedestrianCrossing> crossingQuery;

    if (lastCrossing != null) {
      final String lastCrossingFirebaseId = nodeIdToFirestoreId(lastCrossing.nodeId);

      DocumentSnapshot<PedestrianCrossing> lastCrossingReference = await crossingsCollection
          .doc(lastCrossingFirebaseId)
          .get();

      crossingQuery = crossingsCollection
          .where('unseenBy', arrayContains: userId)
          .orderBy('votesTotal')
          .startAfterDocument(lastCrossingReference);
    } else {
      crossingQuery = crossingsCollection
          .where('unseenBy', arrayContains: userId)
          .orderBy('votesTotal');
    }

    QuerySnapshot<PedestrianCrossing> _crossingsQuerySnapshot = await crossingQuery
        .limit(quantity)
        .get();

    return _crossingsQuerySnapshot.docs.map((crossingDocument) =>
      crossingDocument.data()).toList();
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
