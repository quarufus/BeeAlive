import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class SmokerPage extends StatefulWidget {
  @override
  SmokerPageState createState() => SmokerPageState();
}

class SmokerPageState extends State<SmokerPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  final ScanResults = [];
  ValueNotifier<List<Text>> resultsText =
      ValueNotifier<List<Text>>([Text("One")]);
  var freshResults = [Text("One")];

  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
      ScanResults.add(device.name);
      resultsText.value.add(Text(device.name));
    }, onError: (error) {
      ScanResults.add(error.toString());
      resultsText.value.add(Text(error.toString()));
    });
    _fetchData();
    timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      _fetchData();
    });
    //resultsText = ScanResults.map((device) => Text(device)).toList();
    //resultsText[0] = Text("Hello");
  }

  _fetchData() async {
    //var resultsText = [Text("One")];
    final newResults = [Text("Two")];
    ScanResults.forEach((element) {
      newResults.add(Text(element.toString()));
    });
    if (mounted) {
      setState(() {
        freshResults = newResults;
      });
    }
  }

  /*@override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }*/

  //var text = [Text("hello"), Text("oaifhj"), Text("ai")];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<List<Text>>(
        valueListenable: resultsText,
        builder: (BuildContext context, List<Text> value, Widget? widget) {
          return ListView(
            children: freshResults,
          );
        },
      ),
    );
  }
}
