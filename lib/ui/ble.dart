import 'dart:async';
import 'dart:io';

import 'package:bee_alive/ble/ble_scanner.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:vibration/vibration.dart';

const TEMP_UUID = "00002a6e-0000-1000-8000-00805f9b34fb";
const BATT_UUID = "00002a19-0000-1000-8000-00805f9b34fb";
const BOX_UUID = "ce3f3c3e-7653-11ed-a1eb-0242ac120002";
const GROUND_UUID = "abf00a8e-77e6-11ed-a1eb-0242ac120002";
const ON_UUID = "d7d35f12-d5e2-455f-aea8-806f2b14e3ae";
const SERVICE_UUID = "e4a4f162-7658-11ed-a1eb-0242ac120002";

class Value {
  Uuid id;
  String value;

  Value(this.id, this.value);
}

class BLEPage extends StatefulWidget {
  const BLEPage({Key? key}) : super(key: key);

  @override
  BLEPageState createState() => BLEPageState();
}

class BLEPageState extends State<BLEPage> {
  bool isOn = false;
  bool isBack = false;
  bool alert = false;
// Some state management stuff
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;
// Bluetooth related variables
  late List<DiscoveredDevice> _devices = [];
  late DiscoveredDevice myDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();
  late StreamController<ConnectionStateUpdate> _connectionController =
      StreamController();
  late StreamSubscription<ConnectionStateUpdate> _currentConnectionStream;
  //late List<Uuid> discoveredServices;
  late QualifiedCharacteristic _rxCharacteristic;
// These are the UUIDs of your device
  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid =
      Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");
  late List<DiscoveredService> discoveredServices = [];
  late List<DiscoveredCharacteristic> discoveredCharacteristics = [];
  late List<QualifiedCharacteristic> qualifiedCharacteristics = [];
  late List<Value> values = [];

  @override
  void initState() {
    // TODO: implement initState
    _startScan();
    super.initState();
  }

  @override
  void dispose() {
    _scanStream.cancel();
    _stateStreamController.close();
    _connectionController.stream.listen((event) {
      if (event.connectionState == DeviceConnectionState.connected) {
        _currentConnectionStream.cancel();
        flutterReactiveBle.clearGattCache(myDevice.id);
      }
    });
    super.dispose();
  }

  void getServices(String id) async {
    final results = await flutterReactiveBle.discoverServices(id);
    setState(() {
      discoveredServices = results;
    });
  }

  void _startScan() async {
// Platform permissions handling stuff
    bool permGranted = false;
    setState(() {
      _scanStarted = true;
    });
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) permGranted = true;
    } else if (Platform.isIOS) {
      permGranted = true;
    }
// Main scanning logic happens here ⤵️
    if (permGranted) {
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        final knownDeviceIndex = _devices.indexWhere((d) => d.id == device.id);
        // Change this string to what you defined in Zephyr
        setState(() {
          if (knownDeviceIndex >= 0) {
            _devices[knownDeviceIndex] = device;
          } else {
            _devices.add(device);
          }
          _stateStreamController.add(BleScannerState(
              discoveredDevices: _devices,
              scanIsInProgress: _scanStream != null));
          //_foundDeviceWaitingToConnect = true;
        });
      });
    }
  }

  void _connectToDevice(DiscoveredDevice device) {
    myDevice = device;
    // We're done scanning, we can cancel it
    _scanStream.cancel();
    // Let's listen to our connection so we can make updates on a state change
    //BleDeviceConnector connector =
    //BleDeviceConnector(ble: flutterReactiveBle, logMessage: logMessage);
    //connector.connect(device.id);
    _currentConnectionStream = flutterReactiveBle
        .connectToDevice(
      id: device.id,
    )
        .listen((event) {
      _connectionController.add(event);
      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: event.deviceId);

            setState(() {
              _foundDeviceWaitingToConnect = false;
              _connected = true;
            });

            setState(() {
              getChars(() => _partyTime());
              getServices(device.id);
              //discoveredServices = await flutterReactiveBle.discoverServices(device.id);
              discoveredServices.map((e) {
                if (e.serviceId.toString() == SERVICE_UUID) {
                  for (DiscoveredCharacteristic characteristic
                      in e.characteristics) {
                    final knownIndex = discoveredCharacteristics
                        .indexWhere((element) => element == characteristic);
                    if (knownIndex >= 0) {
                    } else {
                      if (characteristic.characteristicId.toString() ==
                              BATT_UUID ||
                          characteristic.characteristicId.toString() ==
                              ON_UUID) {
                        discoveredCharacteristics.add(characteristic);
                      }
                      discoveredCharacteristics.add(characteristic);
                    }
                  }
                }
              }).toList();
            });
            print(discoveredServices);
            print(discoveredCharacteristics);

            //_partyTime();
            break;
          }
        // Can add various state state updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            break;
          }
        case DeviceConnectionState.connecting:
          {
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            //showDialog(
            //  context: context,
            //builder: (BuildContext context) => myAlert(context));
            break;
          }
        default:
          break;
      }
    }, onError: ((error) {}));
  }

  void _disconnect() async {
    _foundDeviceWaitingToConnect = false;
    showDialog(
        context: context, builder: (BuildContext context) => myAlert(context));
    try {
      await _currentConnectionStream.cancel();
    } on Exception catch (e, _) {
      print(e);
    } finally {
      _connectionController.add(ConnectionStateUpdate(
          deviceId: myDevice.id,
          connectionState: DeviceConnectionState.disconnected,
          failure: null));
      Vibration.vibrate(duration: 1000);
      setState(() {
        _connected = false;
      });
    }
  }

  void _partyTime() async {
    if (_connected) {
      /*discoveredServices =
          await flutterReactiveBle.discoverServices(myDevice.id);
      discoveredServices.map((e) {
        if (e.serviceId.toString() == SERVICE_UUID) {
          discoveredCharacteristics.addAll(e.characteristics);
        }
      }).toList();*/
      setState(() {
        getServices(myDevice.id);
        //discoveredServices = await flutterReactiveBle.discoverServices(device.id);
        discoveredServices.map((e) {
          if (e.serviceId.toString() == SERVICE_UUID) {
            for (DiscoveredCharacteristic characteristic in e.characteristics) {
              final knownIndex = discoveredCharacteristics
                  .indexWhere((element) => element == characteristic);
              if (knownIndex >= 0) {
              } else {
                if (characteristic.characteristicId.toString() == BATT_UUID ||
                    characteristic.characteristicId.toString() == ON_UUID) {
                  discoveredCharacteristics.add(characteristic);
                }
                discoveredCharacteristics.add(characteristic);
              }
            }
          }
        }).toList();
      });
      qualifiedCharacteristics = discoveredCharacteristics
          .map((e) => QualifiedCharacteristic(
              characteristicId: e.characteristicId,
              serviceId: e.serviceId,
              deviceId: myDevice.id))
          .toList();
      for (QualifiedCharacteristic characteristic in qualifiedCharacteristics) {
        flutterReactiveBle.subscribeToCharacteristic(characteristic).listen(
            (data) {
          /*final int knownCharIndex = values.indexWhere(
              (element) => element.id == characteristic.characteristicId);
          setState(() {
            if (knownCharIndex >= 0) {
              values[knownCharIndex].value = String.fromCharCodes(data);
            } else {
              values.add(Value(
                  characteristic.characteristicId, String.fromCharCodes(data)));
            }
          });*/
        }, onError: (error) {
          values.add(Value(Uuid.parse("0000"), error.toString()));
        });
      }
      flutterReactiveBle.characteristicValueStream.listen((event) {
        final int knownCharIndex = values.indexWhere(
            (element) => element.id == event.characteristic.characteristicId);
        setState(() {
          if (knownCharIndex >= 0) {
            values[knownCharIndex].value = String.fromCharCodes(
                event.result.iif(success: (e) => e, failure: (e) => []));
          } else {
            values.add(Value(
                event.characteristic.characteristicId,
                String.fromCharCodes(
                    event.result.iif(success: (e) => e, failure: (e) => []))));
          }
        });
      }, onError: (error) {});
    }
    //values.add(Value(Uuid.parse("0000"), "errorrrr"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("BLE Devices"),
      ),
      body: Center(
        child: ListView(
            children: _devices.map((e) {
          return ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.name != "" ? e.name : "Unknown",
                    style: const TextStyle(fontSize: 20),
                  ),
                  !_connected
                      ? ElevatedButton(
                          onPressed: (() {
                            _connectToDevice(e);
                          }),
                          child: const Text("connect"))
                      : e.id == myDevice.id
                          ? ElevatedButton(
                              onPressed: (() {
                                _disconnect();
                              }),
                              child: const Text("disconnect"))
                          : const Text(""),
                ]),
            onTap: (() {
              if (_connected) _partyTime();
              print("Connected: " + _connected.toString());
              print(discoveredCharacteristics);
              print(qualifiedCharacteristics);
              print(values);
            }),
            subtitle: _connected
                ? ExpansionTile(
                    title: Text(e.id + ": " + e.rssi.toString()),
                    children: _connected
                        ? values
                            .map((entry) => ListTile(
                                  title: Text(characteristicName(entry)),
                                  subtitle: Text(entry.value),
                                ))
                            .toList()
                        : [Container()],
                  )
                : Text(e.id + ": " + e.rssi.toString()),
          );
        }).toList()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff849324),
        child: Icon(Icons.crisis_alert),
        onPressed: (() {
          Vibration.vibrate(duration: 500);
          showDialog(
              context: context,
              builder: (BuildContext context) => myAlert(context));
        }),
      ),
    );
  }
}

class DevicePage extends StatefulWidget {
  const DevicePage({required this.characteristics, Key? key}) : super(key: key);
  final List<Value> characteristics;

  @override
  DevicePageState createState() => DevicePageState();
}

class DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chracteristics"),
        /*leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              Navigator.pop(context, true);
            }),*/
      ),
      body: ListView(
        children: widget.characteristics
            .map((entry) => ListTile(
                  title: Text(characteristicName(entry)),
                  subtitle: Text(entry.value),
                ))
            .toList(),
      ),
    );
  }
}

String characteristicName(Value value) {
  String name = value.id.toString();
  switch (name) {
    case TEMP_UUID:
      return "Temperature";
    case BATT_UUID:
      return "Battery Level";
    case BOX_UUID:
      return "Check Box";
    case GROUND_UUID:
      return "Check Ground";
    case ON_UUID:
      return "Is On";
    default:
      return name;
  }
}

Widget myAlert(context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xbbE0442E), width: 5)),
    title: const Text(
      "Alert",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 30, color: Color(0xccE0442E)),
    ),
    content: const Text(
      "Υπάρχει κίνδυνος για φωτιά\n\nΗ κατάσταση του καπνιστηριού\nτο μελισσοκομείο",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
    actions: [
      TextButton(
        child: const Text('Ok'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

Future<List<DiscoveredService>> getServices(
    FlutterReactiveBle ble, String id) async {
  return await ble.discoverServices(id);
}

Future<void> getChars(party()) async {
  await party();
}
