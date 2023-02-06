import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bee_alive/screens/apiary.dart';

class Apiary {
  static const double size = 50;

  final String name;
  final int hives;
  final LatLng latlng;
  final String notes;
  final Polygon area;

  const Apiary(
      {required this.name,
      required this.latlng,
      required this.hives,
      this.notes = "",
      required this.area});
}

class ApiaryMarker extends Marker {
  ApiaryMarker({required this.apiary})
      : super(
          width: Apiary.size,
          height: Apiary.size,
          point: apiary.latlng,
          anchorPos: AnchorPos.align(AnchorAlign.center),
          builder: (ctx) => const Icon(
            Icons.hexagon_rounded,
            color: Color(0xffE28525),
            size: Apiary.size,
          ),
        );

  final Apiary apiary;
}

class ApiaryMarkerPopup extends StatelessWidget {
  const ApiaryMarkerPopup({
    Key? key,
    required this.index,
    required this.apiary,
  }) : super(key: key);
  final Apiary apiary;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: ListTile(
                  title: Text(apiary.name),
                  subtitle: Text(apiary.hives.toString()),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 50,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ApiariesPage(
                                  apiary: apiary,
                                  index: index,
                                )));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
