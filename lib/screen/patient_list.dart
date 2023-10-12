import 'package:enfie/screen/add_patient.dart';
import 'package:enfie/screen/blue_home.dart';
import 'package:enfie/screen/bluetooth.dart';
import 'package:enfie/screen/pairing.dart';
import 'package:enfie/screen/patients.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PatientState(),
    );
  }
}

class PatientState extends StatefulWidget {
  @override
  PatientListState createState() => PatientListState();
}

class PatientListState extends State<PatientState> {
  List<Patient> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/patient'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    var patients = <Patient>[];

    final responseBody = jsonDecode(response.body);
    final responseStatus = responseBody['status'];

    if (responseStatus == "success") {
      for (var data in responseBody['data']) {
        patients.add(Patient.fromJson(data));
      }
    }

    setState(() {
      _patients = patients;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchData();
    return Scaffold(
        backgroundColor: Color(0xffF5F8FA),
        appBar: PreferredSize(
          child: AppBar(
            backgroundColor: Color(0xffF5F8FA),
            title: Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                'Daftar Pasien',
                style: TextStyle(
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                ),
              ),
            ),
            centerTitle: true,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: Color(0xFFE8E8E8),
                height: 1.5,
              ),
            ),
          ),
          preferredSize: Size.fromHeight(70.0),
        ),
        body: Container(
          child: Container(
            child: _isLoading
                ? Container(
                    height: MediaQuery.of(context)
                        .size
                        .height, // Take up full height
                    child: Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: _patients.isEmpty
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/no_data.png",
                                    height: 200,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Tidak ada data',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffA1A3B0)),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _patients.length,
                                      itemBuilder: (context, index) {
                                        return PatientData(_patients[index]);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Container(
                        margin:
                            EdgeInsets.only(bottom: 30, left: 25, right: 25),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddPatient(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xff4CA6A7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20),
                            minimumSize: Size(
                              MediaQuery.of(context).size.width,
                              0,
                            ),
                          ),
                          child: Text(
                            "Tambah Pasien",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}

class PatientData extends StatefulWidget {
  final Patient patient;

  PatientData(this.patient);

  @override
  _PatientData createState() => _PatientData();
}

class _PatientData extends State<PatientData> {
  void _handleTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Pairing(patient: widget.patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 25, right: 25),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Color(0xFFE8E8E8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pasien",
                        textAlign: TextAlign.start,
                        style:
                            TextStyle(fontSize: 12, color: Color(0xffA1A3B0)),
                      ),
                      Text(
                        widget.patient.name,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF4CA6A7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
