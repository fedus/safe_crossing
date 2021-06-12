import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedestrianCrossing {
  final String nodeId;
  final LatLng position;
  final int votesTooClose;
  final int votesOk;
  final int votesNotSure;
  final int votesTotal;
  final int currentResult;
  final String street;
  final String neighbourhood;

  PedestrianCrossing({
    this.nodeId,
    this.position,
    this.votesTooClose,
    this.votesOk,
    this.votesNotSure,
    this.votesTotal,
    this.currentResult,
    this.street,
    this.neighbourhood,
  });

  factory PedestrianCrossing.fromJson(Map<String, dynamic> json) {
    GeoPoint _position = json['position'] as GeoPoint;
    return PedestrianCrossing(
      nodeId: json['nodeId'] as String,
      position: LatLng(_position.latitude, _position.longitude),
      votesTooClose: json['votesTooClose'] != null ? json['votesTooClose'] as int : 0,
      votesOk: json['votesOk'] != null ? json['votesOk'] as int : 0,
      votesNotSure: json['votesNotSure'] != null ? json['votesNotSure'] as int : 0,
      votesTotal: json['votesTotal'] != null ? json['votesTotal'] as int : 0,
      currentResult: json['currentResult'] != null ? json['currentResult'] as int : null,
      street: json['street'] != null ? json['street'] as String : '',
      neighbourhood: json['neighbourhood'] != null ? json['neighbourhood'] as String : '',
    );
  }
}
