import 'package:latlong/latlong.dart';

class PedestrianCrossing {
  final int id;
  final LatLng position;

  PedestrianCrossing({ this.id, this.position });

  factory PedestrianCrossing.fromJson(Map<String, dynamic> json) {
    return PedestrianCrossing(
      id: json['id'] as int,
      position: LatLng(json['lat'] as double, json['lon'] as double),
    );
  }
}
