import 'dart:ffi';

import 'package:enfie/screen/chart.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:enfie/screen/patients.dart';

class Dashboard extends StatefulWidget {
  final BluetoothDevice device;
  final Patient patient;
  double temp;
  double hum;
  double gas;
  var popok;
  final List<Map<String, dynamic>> gasData; // Add this parameter

  Dashboard({
    required this.popok,
    required this.device,
    required this.patient,
    required this.temp,
    required this.hum,
    required this.gas,
    required this.gasData, // Add this parameter
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<Dashboard> {
  BluetoothCharacteristic? temperatureCharacteristic;
  late List<EnvironmentalData> yourVOCDataList;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    yourVOCDataList = widget.gasData.map((data) {
      double value = data['value'];
      DateTime time = data['time'];
      print('time');
      return EnvironmentalData(time, value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _widgetOptions = <Widget>[ChartWidget(data: yourVOCDataList)];
    });
    yourVOCDataList = widget.gasData.map((data) {
      double value = data['value'];
      DateTime time = data['time'];
      print('time');
      return EnvironmentalData(time, value);
    }).toList();

    return WillPopScope(
        onWillPop: () async {
          widget.device.disconnect();
          return true; // Kembalikan true jika Anda ingin membiarkan peristiwa kembali terjadi
        },
        child: Scaffold(
          backgroundColor: Color(0xffF5F8FA),
          body: SingleChildScrollView(
            child: widget.temp == 0 && widget.hum == 0 && widget.gas == 0
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Loading Data Sensor ...")
                          ],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        child: Stack(
                          children: [
                            Positioned(
                              child: Container(
                                child: Image.asset(
                                  "assets/bg.jpg",
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.0),
                                  margin: EdgeInsets.only(top: 45.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Image.asset(
                                        "assets/enfie_landscape.png",
                                        width: 80,
                                      ),
                                      const Icon(
                                        FluentSystemIcons
                                            .ic_fluent_alert_regular,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Align(
                                    alignment: Alignment
                                        .centerLeft, // Align text to the left (start).
                                    child: Text(
                                      "Pasien",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Align(
                                      alignment: Alignment
                                          .centerLeft, // Align text to the left (start).
                                      child: Text(
                                        widget.patient.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      )),
                                ),
                                SizedBox(height: 15),
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Align(
                                    alignment: Alignment
                                        .centerLeft, // Align text to the left (start).
                                    child: Text(
                                      "Jenis Kelamin",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 30),
                                  child: Align(
                                      alignment: Alignment
                                          .centerLeft, // Align text to the left (start).
                                      child: Text(
                                        widget.patient.gender != 0
                                            ? "laki-laki"
                                            : "perempuan", // Ternary operator to conditionally set text
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      )),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Color(0xffE8E8E8),
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                widget.device.disconnect().then(
                                                    (value) =>
                                                        Navigator.of(context)
                                                            .pop());
                                              },
                                              child: Text(
                                                "Ganti Pasien >",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 15,
                            ),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        border: Border.all(
                                            color: Color(0xffE8E8E8)),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 20,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFE4F2F2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10,
                                                    ),
                                                    height: 55,
                                                    child: SvgPicture.asset(
                                                      "assets/temperature.svg",
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    "Suhu",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xff4CA6A7),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${widget.temp}°C",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff4CA6A7),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE4F2F2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  height: 55,
                                                  child: SvgPicture.asset(
                                                    "assets/bau.svg",
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Gas",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xff4CA6A7),
                                                  ),
                                                ),
                                                Text(
                                                  "${widget.gas}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xff4CA6A7),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE4F2F2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 10,
                                                  ),
                                                  height: 55,
                                                  child: SvgPicture.asset(
                                                    "assets/humidity.svg",
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  "Lembab",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xff4CA6A7),
                                                  ),
                                                ),
                                                Text(
                                                  "${widget.hum}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xff4CA6A7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFE4F2F2),
                                        border: Border.all(
                                            color: Color(0xffE8E8E8)),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20.0),
                                          bottomRight: Radius.circular(20.0),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            FluentSystemIcons
                                                .ic_fluent_info_regular,
                                            color: Color(0xFF838383),
                                          ),
                                          SizedBox(width: 8),
                                          RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text:
                                                      "kondisi popok saat ini ",
                                                  style: TextStyle(
                                                    color: Color(0xFF838383),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "${widget.popok}",
                                                  style: TextStyle(
                                                    color: Color(0xC4209BFF),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 24),
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: ChartWidget(data: yourVOCDataList),
                                )
                                // Add the ChartWidget here
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ));
  }
}
