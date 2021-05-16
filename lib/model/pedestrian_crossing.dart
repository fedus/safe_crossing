import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedestrianCrossing {
  final int nodeId;
  final LatLng position;

  PedestrianCrossing({ this.nodeId, this.position });

  factory PedestrianCrossing.fromJson(Map<String, dynamic> json) {
    GeoPoint _position = json['position'] as GeoPoint;
    return PedestrianCrossing(
      nodeId: json['id'] as int,
      position: LatLng(_position.latitude, _position.longitude),
    );
  }
}
