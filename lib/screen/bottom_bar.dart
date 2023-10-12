import 'dart:ffi';

import 'package:enfie/screen/patients.dart';
import 'package:enfie/screen/profile.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:typed_data';
import 'dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the dart:convert library
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

class BottomBar extends StatefulWidget {
  final BluetoothDevice device;
  final Patient patient;

  BottomBar({required this.device, required this.patient});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  List<Map<String, dynamic>> gasData = [];
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions; // Declare _widgetOptions
  Timer? dataSamplingTimer;

  var popok = 'pending';
  double temp = 0;
  double hum = 0;
  double gas = 0;
  String connectionStatus = "Disconnect";

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      Dashboard(
        popok: popok,
        patient: widget.patient,
        device: widget.device,
        temp: temp,
        hum: hum,
        gas: gas,
        gasData: gasData,
      ),
      ProfilePage(),
    ];
  }

  void connecting() async {
    try {
      widget.device.connect();
      setState(() {
        connectionStatus = "Connected";
      });
      _setupMessageListener();
    } catch (e) {
      print(e);
    }
  }

  void _setupMessageListener() async {
    Guid characteristicUuid = Guid('19b10000-2001-537e-4f6c-d104768a1214');
    double pengurang;
    Future<dynamic> sendData(double temp, double hum, double gas,
        List<Map<String, dynamic>> gasData) async {
      final String url = '${dotenv.env['API_URL']}/data';
      final String urls = '${dotenv.env['API_URL']}/data/status';

      int ids = widget.patient.id;
      Map<String, dynamic> data = {
        "suhu": temp,
        "humidity": hum,
        "voc": gas,
        "patient_id": ids
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode(data), // Use jsonEncode to encode the data
          headers: {'Content-Type': 'application/json'},
        );
        final responseBody = jsonDecode(response.body);
        final responseMessage = responseBody['message'];
        final responseStatus = responseBody['status'];

        if (responseStatus == "success") {
          if (gasData.length >= 11) {
            Map<String, dynamic> dataKe11 = gasData[10];
            pengurang = dataKe11['value'];
            print('pengurang: $pengurang');
            Map<String, dynamic> datas = {
              "variable": pengurang,
              "patient_id": ids
            };
            try {
              final responses = await http.post(
                Uri.parse(urls),
                body: jsonEncode(datas), // Use jsonEncode to encode the data
                headers: {'Content-Type': 'application/json'},
              );
              final bodyRes = jsonDecode(responses.body);
              return bodyRes['result'];
            } catch (e) {
              print("popok: $e");
            }
          }
        }

        // print("res: ${response.body}");
      } catch (e) {
        print(e);
      }
    }

    try {
      await Future.delayed(Duration(seconds: 3)); // Add a 1-second delay
      List<BluetoothService> services = await widget.device.discoverServices();
      services.forEach((service) async {
        print('s: $service');
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid == characteristicUuid) {
            characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) async {
              try {
                Float32List float32List =
                    Float32List.view(Uint8List.fromList(value).buffer);

                double tempValue =
                    double.parse(float32List[0].toStringAsFixed(2));
                double humValue =
                    double.parse(float32List[1].toStringAsFixed(2));
                double gasValue = float32List[2];

                DateTime currentTime = DateTime.now();

                Map<String, dynamic> gasDataEntry = {
                  'value': gasValue,
                  'time': currentTime,
                };

                if (gasData.length > 20) {
                  gasData.removeRange(0, 10);
                }

                gasData.add(gasDataEntry);

                var result =
                    await sendData(tempValue, humValue, gasValue, gasData);
                var status = "pending";
                if (result != null) {
                  status = result;
                }
                print('popok: $status');

                setState(() {
                  _widgetOptions = <Widget>[
                    Dashboard(
                      popok: status,
                      patient: widget.patient,
                      device: widget.device,
                      temp: tempValue,
                      hum: humValue,
                      gas: gasValue,
                      gasData: gasData,
                    ),
                    ProfilePage(),
                  ];
                });
              } catch (e) {
                print('Error: $e');
              }
            });
          }
        });
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print('selected index : ${_selectedIndex}');
  }

  @override
  Widget build(BuildContext context) {
    connecting();
    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set white background for the Container
          border: Border.all(
            color: Color.fromARGB(255, 239, 239,
                239), // Replace Colors.white with the desired border color
            width: 1.0, // Replace 2.0 with the desired border width
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: _selectedIndex,
          onTap: _onSelected,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xff4CA6A7),
          unselectedItemColor: Color(0xffA8A8AA),
          selectedLabelStyle:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle:
              TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.only(
                    bottom: 4, top: 4), // Add a vertical gap of 4 pixels.
                child: SvgPicture.asset(
                  'assets/dashboard.svg',
                  height: 20,
                  width: 20,
                  color: Color(0xFFA8A8AA),
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.only(
                    bottom: 4, top: 4), // Add a vertical gap of 4 pixels.
                child: SvgPicture.asset(
                  'assets/dashboard_filled.svg',
                  height: 20,
                  width: 20,
                ),
              ),
              label: "Dashboard",
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                FluentSystemIcons.ic_fluent_person_regular,
                size: 24,
              ),
              activeIcon: Icon(
                FluentSystemIcons.ic_fluent_person_filled,
                size: 24,
              ),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
