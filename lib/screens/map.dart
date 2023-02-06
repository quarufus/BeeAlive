import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:bee_alive/widgets/apiary_marker.dart';
import 'package:bee_alive/widgets/nav_bar.dart';
import 'package:bee_alive/tools/appdata.dart';
import 'package:location/location.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  int opened = 1;
  late final MapController _mapController;
  final PopupController _popupLayerController = PopupController();
  List apiaries = apiariesData;
  late LatLng center = LatLng(38.277183, 24.627108);

  late Apiary selMarker;

  var polygons = <Polygon>[];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    polygons = apiariesData.map((element) {
      return element.area;
    }).toList();
    markers = apiariesData.map((e) => ApiaryMarker(apiary: e)).toList();
    position();
  }

  void position() {
    Location().onLocationChanged.listen((event) {
      setState(() {
        center =
            LatLng(event.latitude ?? 38.277183, event.longitude ?? 24.627108);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(center, 10);
    });
  }

  void straighten() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.rotate(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            onTap: (tap, location) {
              polygons = apiariesData.map((element) {
                return element.area;
              }).toList();
              _popupLayerController.hideAllPopups();
            },
            center: center,
            zoom: 7.5,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/timonp/cl9vdua29004g14mi23fh7vay/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGltb25wIiwiYSI6ImNsOXZkbGMwbjA0YXozb25zd3Q5ZnU1MmwifQ.atnk0-TxkGgRDpIASpITRw',
              userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            ),
            polygons.isNotEmpty
                ? PolygonLayer(
                    polygonCulling: false,
                    polygons: polygons,
                  )
                : Container(),
            MarkerLayer(
              markers: [
                Marker(
                    point: center,
                    builder: (ctx) => SvgPicture.asset(
                          'lib/assets/svg/hex.svg',
                          semanticsLabel: 'location',
                        ))
              ],
            ),
            PopupMarkerLayerWidget(
              options: PopupMarkerLayerOptions(
                  markers: markers,
                  markerRotateAlignment:
                      PopupMarkerLayerOptions.rotationAlignmentFor(
                          AnchorAlign.center),
                  popupController: _popupLayerController,
                  popupBuilder: (_, Marker marker) {
                    if (marker is ApiaryMarker) {
                      //print(marker.apiary.name);
                      apiariesData.forEach((element) {
                        if (element.name == marker.apiary.name) {
                          selMarker = marker.apiary;
                        }
                      });
                      return ApiaryMarkerPopup(
                        apiary: selMarker,
                        index: apiariesData.indexOf(selMarker),
                      );
                    }
                    return const Card(child: Text('Not an apiary'));
                  }),
            )
          ],
        ),
        floatingActionButton:
            Wrap(spacing: 20, direction: Axis.vertical, children: [
          FloatingActionButton(
            backgroundColor: Color(0xff849324),
            heroTag: "loc",
            onPressed: position,
            child: const Icon(Icons.my_location),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff849324),
            heroTag: "north",
            onPressed: straighten,
            child: const Icon(Icons.north),
          )
        ]),
        bottomNavigationBar: BottomNavBar(index: opened));
  }
}
