import 'package:flutter/material.dart';
import 'package:bee_alive/screens/map.dart';
import 'package:bee_alive/ble/ble_logger.dart';
import 'package:bee_alive/ble/ble_scanner.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:bee_alive/ble/ble_status_monitor.dart';
import 'package:bee_alive/ble/ble_device_connector.dart';
import 'package:bee_alive/ble/ble_device_interactor.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final _ble = FlutterReactiveBle();
  final _bleLogger = BleLogger(ble: _ble);
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _monitor = BleStatusMonitor(_ble);
  final _connector = BleDeviceConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );
  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: _ble.discoverServices,
    readCharacteristic: _ble.readCharacteristic,
    writeWithResponse: _ble.writeCharacteristicWithResponse,
    writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: _ble.subscribeToCharacteristic,
    logMessage: _bleLogger.addToLog,
  );
  runApp(MultiProvider(providers: [
    Provider.value(value: _scanner),
    Provider.value(value: _monitor),
    Provider.value(value: _connector),
    Provider.value(value: _serviceDiscoverer),
    Provider.value(value: _bleLogger),
    StreamProvider<BleScannerState?>(
      create: (_) => _scanner.state,
      initialData: const BleScannerState(
        discoveredDevices: [],
        scanIsInProgress: false,
      ),
    ),
    StreamProvider<BleStatus?>(
      create: (_) => _monitor.state,
      initialData: BleStatus.unknown,
    ),
    StreamProvider<ConnectionStateUpdate>(
      create: (_) => _connector.state,
      initialData: const ConnectionStateUpdate(
        deviceId: 'Unknown device',
        connectionState: DeviceConnectionState.disconnected,
        failure: null,
      ),
    ),
  ], child: DisplayLogo()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MapPage(),
      theme: ThemeData(
        colorScheme: ColorScheme.light(primary: const Color(0xffE28525)),
      ),
    );

    /*
    return const MaterialApp(
      title: 'Flutter Map Example',
      home: MapPage(),
    );*/
  }
}

class DisplayLogo extends StatefulWidget {
  @override
  State createState() => _State();
}

class _State extends State<DisplayLogo> {
  @override
  initState() {
    super.initState();

    ///add delay here
    Timer(const Duration(seconds: 2), () {
      if (mounted) runApp(const MyApp());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xfffebc11),
        child: Center(
          child: Image.asset("lib/assets/bee.png"),
        ));
  }
}
