import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPageState createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? targetCharacteristic;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    flutterBlue.scanResults.listen((scanResult) {
      setState(() {
        for (ScanResult result in scanResult) {
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        }
      });
    });

    flutterBlue.startScan();
  }

  Future<void> _pairToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.properties.write) {
          targetCharacteristic = characteristic;
        }
      });
    });

    if (targetCharacteristic != null) {
      targetCharacteristic!.setNotifyValue(true);
      targetCharacteristic!.value.listen((value) {
        if (value.isNotEmpty) {
          String receivedMessage = utf8.decode(value);
          print('Received message: $receivedMessage');
        }
      });

      setState(() {
        connectedDevice = device;
      });
    }
  }

  void _sendMessage(String message) {
    if (connectedDevice != null && targetCharacteristic != null) {
      List<int> bytes = utf8.encode(message);
      targetCharacteristic!.write(bytes);
    }
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    connectedDevice?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Page'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(devices[index].name ?? 'Unknown Device'),
            subtitle: Text(devices[index].id.id),
            onTap: () {
              _pairToDevice(devices[index]);
            },
          );
        },
      ),
    );
  }
}
