import 'package:enfie/screen/bottom_bar.dart';
import 'package:enfie/screen/dashboard.dart';
import 'package:enfie/screen/dashboardPage.dart';
import 'package:enfie/screen/patients.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the dart:convert library
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Pairing extends StatefulWidget {
  final Patient patient;

  const Pairing({required this.patient, Key? key}) : super(key: key);
  @override
  _PairingState createState() => _PairingState();
}

class _PairingState extends State<Pairing> {
  String connectionStatus = "Disconnect";
  List<ScanResult> discoveredDevices = [];
  ScanResult? selectedDevice;
  bool isScanning = false;
  Timer? scanTimer;
  bool isPairing = false;
  BluetoothDevice? connectedDevice;
  Stream<List<int>>? messageStream;
  BluetoothCharacteristic? temperatureCharacteristic;

  @override
  void initState() {
    super.initState();
  }

  Future<void> connect() async {
    if (Platform.isAndroid) {
      final status = await Permission.location.request();
      if (status.isDenied) {
        setState(() {
          connectionStatus = "Location permission denied";
        });
        return;
      }
      try {
        await FlutterBluePlus.turnOn();
        setState(() {
          connectionStatus = "Scanning...";
          isScanning = true;
          selectedDevice = null;
        });

        FlutterBluePlus.scanResults.listen((results) {
          setState(() {
            discoveredDevices = results;
          });
        });

        scanTimer = Timer(Duration(seconds: 5), () {
          setState(() {
            isScanning = false;
            connectionStatus = "Scan Complete";
          });
          FlutterBluePlus.stopScan();
        });

        await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));
      } catch (e) {
        setState(() {
          connectionStatus = "Error: $e";
          isScanning = false;
        });
      }
    }
  }

  Future<void> pairing(ScanResult? selectedDevice) async {
    if (selectedDevice == null) {
      return;
    }

    setState(() {
      isPairing = true;
      connectionStatus = "Pairing...";
    });

    try {
      await selectedDevice.device.connect();
      selectedDevice.device.connectionState
          .listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.connected) {
          try {
            print("connected");
            await selectedDevice.device.connect();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BottomBar(
                  patient: widget.patient,
                  device: selectedDevice.device,
                ),
              ),
            );
            setState(() {
              connectionStatus = "Connected";
            });

            if (connectionStatus == "Connected") {
              final currentContext = context; // Simpan context dalam variabel
            }
          } catch (e) {
            print("error: ${e}");
            setState(() {
              connectionStatus = "Error Pairing";
            });
          } finally {
            setState(() {
              isPairing = false;
            });
          }
        }
      });
    } catch (e) {
      print("error: ${e}");
      setState(() {
        connectionStatus = "Error Pairing";
      });
    }
  }

  @override
  void dispose() {
    scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("patient: ${widget.patient}");
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FA),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    "assets/enfie_form.png",
                    height: 100,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    "assets/pairing.png",
                    height: 150,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Status",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA0A0A0),
                  ),
                ),
                Text(
                  connectionStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: connectionStatus != 'Disconnect' &&
                            !connectionStatus.contains("Error")
                        ? const Color(0xFF4CA6A7)
                        : Color(0xFFA0A0A0),
                    fontSize: 26,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                  ),
                  child: Text(
                    "Silahkan hubungkan aplikasi dengan perangkat yang tersedia",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA0A0A0),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Visibility(
                  visible: !isPairing && !isScanning,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: DropdownButton<ScanResult>(
                      value: selectedDevice,
                      onChanged: isScanning
                          ? null
                          : (value) {
                              setState(() {
                                pairing(value);
                              });
                            },
                      items: [
                        DropdownMenuItem<ScanResult>(
                          value: null,
                          child: Text(
                            "Select a device",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFA0A0A0),
                            ),
                          ),
                        ),
                        ...discoveredDevices
                            .where(
                                (result) => result.device.localName.isNotEmpty)
                            .map((result) {
                          var deviceName = result.device.localName;
                          var macAddress = result.device.remoteId.toString();

                          return DropdownMenuItem<ScanResult>(
                            value: result,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deviceName,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  macAddress,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFA0A0A0),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 40, right: 40, top: 70),
                  child: ElevatedButton(
                    onPressed: isScanning || isPairing ? null : connect,
                    style: ElevatedButton.styleFrom(
                      primary: isScanning || isPairing
                          ? Colors.grey
                          : const Color(0xff4CA6A7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 20,
                      ),
                      minimumSize: const Size(
                        double.infinity,
                        0,
                      ),
                    ),
                    child: isScanning
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : isPairing
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Scan",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
