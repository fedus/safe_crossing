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