import 'package:bee_alive/widgets/apiary_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

List<Apiary> apiariesData = <Apiary>[
  Apiary(
      name: 'Γαλησσάς',
      hives: 30,
      latlng: LatLng(37.444, 24.897),
      area: Polygon(points: [
        LatLng(37.444, 24.897),
        LatLng(37.445, 24.898),
        LatLng(37.445, 24.896)
      ])),
  Apiary(
    name: 'Εύβοια',
    hives: 75,
    latlng: LatLng(38.968, 23.166),
    area: Polygon(points: [
      LatLng(38.968, 23.166),
      LatLng(38.969, 23.167),
      LatLng(38.969, 23.165)
    ]),
  ),
  Apiary(
    name: 'Τσαπού',
    hives: 50,
    latlng: LatLng(38.486, 23.808),
    area: Polygon(points: [
      LatLng(38.486, 23.808),
      LatLng(38.487, 23.809),
      LatLng(38.487, 23.807)
    ]),
  ),
  Apiary(
    name: 'Καλαμάτα',
    latlng: LatLng(37.093491, 22.105106),
    hives: 120,
    area: Polygon(points: [
      LatLng(37.093491, 22.105106),
      LatLng(37.094491, 22.106106),
      LatLng(37.094491, 22.104106)
    ]),
  ),
];

List<ApiaryMarker> markers = <ApiaryMarker>[];
