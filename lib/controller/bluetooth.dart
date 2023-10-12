import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  Future<void> scanDevices() async {
    // Start scanning for Bluetooth devices
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
  }

  Stream<List<ScanResult>> get scanResult => FlutterBluePlus.scanResults;
}
