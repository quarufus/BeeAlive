import 'dart:async';

import 'package:bee_alive/widgets/apiary_marker.dart';
import 'package:flutter/material.dart';
import 'package:bee_alive/screens/map.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:bee_alive/tools/appdata.dart';
import 'package:bee_alive/assets/beealive_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

var latlng = LatLng(0, 0);
bool isRec = false;
var apiRegion = Polyline(points: [LatLng(0, 0)], borderColor: Colors.blue);
var apiaryPolygon = Polygon(
  points: [LatLng(0, 0)],
  isFilled: true,
  color: Colors.red,
  borderStrokeWidth: 3,
  borderColor: Colors.black,
);

var apiPolygon = [LatLng(0, 0)];

var testPolygon = Polygon(
  points: [LatLng(1, 1), LatLng(1, 1.1), LatLng(1.1, 1.1), LatLng(1.1, 1)],
  isFilled: true,
  color: Colors.red,
  borderColor: Colors.black,
  borderStrokeWidth: 5,
);

class Intro extends StatefulWidget {
  @override
  IntroState createState() => IntroState();
}

class IntroState extends State<Intro> {
  LatLng center = latlng;
  late Timer timer;

  @override
  initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Location().onLocationChanged.listen((here) => setState(() {
            center = LatLng(here.latitude ?? 0, here.longitude ?? 0);
          }));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            height: 200,
            width: 300,
            margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const ColoredBox(
                color: Color(0xffE28525),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text("lalala"),
                ),
              ),
            ),
          ),
          center != LatLng(0, 0) ? mapi(center) : noni(),
          Container(
            width: 267,
            height: 44,
            margin: const EdgeInsets.all(10),
            child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xffE28525),
                  foregroundColor: Colors.white,
                ),
                onPressed: (() {
                  isRec = true;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SetupPage()));
                }),
                child: const Text(
                  "Start",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Nuniko",
                  ),
                )),
          ),
          SizedBox(
            width: 267,
            height: 44,
            child: OutlinedButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffE28525),
                  side: const BorderSide(color: Color(0xffE28525)),
                ),
                onPressed: (() {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const MapPage()));
                }),
                child: const Text(
                  "Not Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Nuniko",
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

class SetupPage extends StatefulWidget {
  //final Widget content;
  final String left = 'Back';
  final String right = 'Next';

  const SetupPage({
    //content,
    left,
    right,
    Key? key,
  }) : super(key: key);

  @override
  SetupPageState createState() => SetupPageState();
}

class SetupPageState extends State<SetupPage> {
  final nameController = TextEditingController();
  final hivesController = TextEditingController();
  final notesController = TextEditingController();
  Location location = Location();
  late StreamSubscription<LocationData> _locationData;
  LatLng center = latlng;

  late final MapController mapController;

  void permission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {}
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {}
    }
  }

  void _onIntroEnd(context) {
    Apiary apiary = Apiary(
        name: nameController.text,
        latlng: center,
        hives: int.parse(hivesController.text),
        notes: notesController.text,
        area: apiaryPolygon);
    apiariesData.add(apiary);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPage()),
    );
  }

  @override
  initState() {
    permission();
    mapController = MapController();
    _locationData = location.onLocationChanged.listen((here) => setState(() {
          center = LatLng(here.latitude ?? 0, here.longitude ?? 0);
          apiRegion.points.add(center);
          latlng = center;
          if (apiRegion.points[0] == LatLng(0, 0)) {
            apiRegion.points.removeAt(0);
          }
        }));
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    hivesController.dispose();
    notesController.dispose();
    _locationData.cancel();
    super.dispose();
  }

  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setup Apiary',
          textAlign: TextAlign.center,
        ),
      ),
      body: IntroductionScreen(
        key: _introKey,
        onDone: () => _onIntroEnd(context),
        showBackButton: true,
        back: const Icon(Icons.chevron_left_rounded),
        overrideNext: TextButton(
            onPressed: (() {
              isRec = false;
              apiaryRegion();
              _introKey.currentState?.next();
            }),
            child: const Icon(Icons.chevron_right)),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        pages: [
          PageViewModel(
              title: "Location",
              //body: "Download the Stockpile app and master the market with our mini-lesson.",
              bodyWidget: Center(
                child: center != LatLng(0, 0) ? bigMap(center) : noni(),
              )),
          PageViewModel(
            title: "Information",
            bodyWidget: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Name"),
                ),
                Container(height: 20),
                TextField(
                  controller: hivesController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Hives"),
                ),
                Container(height: 20),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "Notes"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget mapi(center) {
  return Container(
    height: 200,
    width: 300,
    margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: const Color(0xffE28525),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: FlutterMap(
            //mapController: mapController,
            options: MapOptions(
              center: center,
              zoom: 7.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/timonp/cl9vdua29004g14mi23fh7vay/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGltb25wIiwiYSI6ImNsOXZkbGMwbjA0YXozb25zd3Q5ZnU1MmwifQ.atnk0-TxkGgRDpIASpITRw',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              MarkerLayer(markers: <Marker>[
                Marker(
                    point: center,
                    builder: (ctx) => const Icon(
                          Beealive.hex,
                          color: Color(0xff312f2f),
                        ))
              ]),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget bigMap(center) {
  return SizedBox(
    height: 400,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: FlutterMap(
        //mapController: mapController,
        options: MapOptions(
          center: center,
          zoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/timonp/cl9vdua29004g14mi23fh7vay/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidGltb25wIiwiYSI6ImNsOXZkbGMwbjA0YXozb25zd3Q5ZnU1MmwifQ.atnk0-TxkGgRDpIASpITRw',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          MarkerLayer(markers: <Marker>[
            Marker(
                point: center,
                builder: (ctx) => SvgPicture.asset(
                      'lib/assets/svg/hex.svg',
                      semanticsLabel: 'location',
                    ))
          ]),
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              apiRegion,
            ],
          ),
          PolygonLayer(
            polygonCulling: false,
            polygons: [
              apiaryPolygon,
            ],
          ),
        ],
      ),
    ),
  );
}

Widget noni() {
  return Container(
      height: 200,
      width: 300,
      margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const ColoredBox(
            color: Colors.white10,
          )));
}

void position() async {
  Location location = Location();

  location.onLocationChanged.listen((event) {
    LatLng now = LatLng(event.latitude ?? 0, event.longitude ?? 0);
    apiRegion.points.add(now);
    latlng = now;
    if (apiRegion.points[0] == LatLng(0, 0)) {
      apiRegion.points.removeAt(0);
    }
  });
}

LatLng currentLocation() {
  Location location = Location();
  LatLng here = LatLng(0, 0);

  location.onLocationChanged.listen((event) {
    here = LatLng(event.latitude ?? 0, event.longitude ?? 0);
  });

  return here;
}

void apiaryRegion() {
  apiaryPolygon.points.addAll(apiRegion.points);
  if (apiaryPolygon.points[0] == LatLng(0, 0)) {
    apiaryPolygon.points.removeAt(0);
  }
}
