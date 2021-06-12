import 'package:safe_crossing/model/models.dart';

abstract class ReactiveCrossingsRepository {
  Future<List<PedestrianCrossing>> getNextBatch (
      String userId,
      int quantity,
      PedestrianCrossing lastCrossing);

  Stream<PedestrianCrossing> getStreamForCrossing(
      PedestrianCrossing pedestrianCrossing);
}