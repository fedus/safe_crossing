import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedestrianCrossing {
  final String nodeId;
  final LatLng position;
  final int votesTooClose;
  final int votesOk;
  final int votesNotSure;

  PedestrianCrossing({
    this.nodeId,
    this.position,
    this.votesTooClose,
    this.votesOk,
    this.votesNotSure
  });

  factory PedestrianCrossing.fromJson(Map<String, dynamic> json) {
    GeoPoint _position = json['position'] as GeoPoint;
    return PedestrianCrossing(
      nodeId: json['nodeId'] as String,
      position: LatLng(_position.latitude, _position.longitude),
      votesTooClose: json['votes_too_close'] != null ? json['votes_too_close'] as int : 0,
      votesOk: json['votes_ok'] != null ? json['votes_ok'] as int : 0,
      votesNotSure: json['votes_not_sure'] != null ? json['votes_not_sure'] as int : 0,
    );
  }
}
