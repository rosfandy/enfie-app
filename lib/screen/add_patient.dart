import 'package:enfie/screen/patient_list.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert'; // Import the dart:convert library
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddPatient extends StatelessWidget {
  const AddPatient({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffF5F8FA),
      appBar: PreferredSize(
        child: AppBar(
          leading: Container(
            margin: EdgeInsets.only(top: 10),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF4CA6A7), size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          backgroundColor: Color(0xffF5F8FA),
          title: Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              'Tambah Pasien',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
              child: PatientForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class PatientForm extends StatefulWidget {
  @override
  _PatientFormState createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final _formKey = GlobalKey<FormState>();
  String _nama = '';
  String _tanggal = '';
  String _alamat = '';
  String? _jenisKelamin;
  TextEditingController _dateController = TextEditingController();
  bool _isDateInputFocused = false;
  FocusNode _dateFocusNode = FocusNode();

  Future<void> _postPatientData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    print("token ${token}");
    if (token != null) {
      final Map<String, dynamic> patientData = {
        'name': _nama,
        'birth': _tanggal,
        'address': _alamat,
        'gender': _jenisKelamin,
      };

      final String url = '${dotenv.env['API_URL']}/patient';

      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token to the headers
        },
        body: jsonEncode(patientData),
      );
      final responseBody = jsonDecode(response.body);
      final responseMessage = responseBody['message'];
      final responseStatus = responseBody['status'];
      if (responseStatus == "success") {
        Fluttertoast.showToast(
          msg: "${responseMessage}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "${responseMessage} (Status Code: 400)",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _dateFocusNode.addListener(() {
      if (!_dateFocusNode.hasFocus) {
        setState(() {
          _isDateInputFocused = false;
        });
      } else {
        setState(() {
          _isDateInputFocused = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _dateFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Silahkan masukkan informasi data diri pasien",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                SizedBox(height: 35),
                Text(
                  "Nama",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 5),
                TextFormField(
                  cursorColor: Color(0xff4CA6A7),
                  decoration: InputDecoration(
                    hintText: "masukan nama",
                    hintStyle:
                        TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(color: Color(0xffE8E8E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Color(0xff4CA6A7), width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                  ),
                  onChanged: (value) {
                    _nama = value;
                  },
                ),
                SizedBox(height: 10),
                Text(
                  "Tanggal lahir",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 5),
                TextFormField(
                  focusNode: _dateFocusNode,
                  onTap: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    ).then((selectedDate) {
                      if (selectedDate != null) {
                        // Mengambil tanggal saja (tanpa jam) dari tanggal yang dipilih
                        String formattedDate =
                            selectedDate.toLocal().toString().split(' ')[0];

                        // Mengatur nilai pada controller sesuai dengan tanggal yang dipilih
                        _dateController.text = formattedDate;
                        _tanggal = formattedDate;
                        print('tanggal: ${_tanggal}');
                      }
                    });
                  },
                  controller: _dateController,
                  cursorColor: Color(0xff4CA6A7),
                  decoration: InputDecoration(
                      hintText: "Pilih tanggal",
                      hintStyle:
                          TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                        borderSide: BorderSide(color: Color(0xffE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:
                            BorderSide(color: Color(0xff4CA6A7), width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                      prefixIcon: Icon(Icons.calendar_today,
                          color: _isDateInputFocused
                              ? Color(0xff4CA6A7)
                              : Colors.grey)),
                ),
                SizedBox(height: 10),
                Text(
                  "Alamat",
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 5),
                TextFormField(
                  cursorColor: Color(0xff4CA6A7),
                  decoration: InputDecoration(
                    hintText: "masukan alamat",
                    hintStyle:
                        TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                      borderSide: BorderSide(color: Color(0xffE8E8E8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Color(0xff4CA6A7), width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                  ),
                  onChanged: (value) {
                    _alamat = value;
                  },
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jenis Kelamin:"),
                    Row(
                      children: [
                        Radio(
                          value: "1",
                          groupValue: _jenisKelamin,
                          onChanged: (value) {
                            print("gender: ${value}");
                            setState(() {
                              _jenisKelamin = value as String;
                            });
                          },
                        ),
                        Text("Laki-laki"),
                        Radio(
                          value: "0",
                          groupValue: _jenisKelamin,
                          onChanged: (value) {
                            print("gender: ${value}");
                            setState(() {
                              _jenisKelamin = value as String;
                            });
                          },
                        ),
                        Text("Perempuan"),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 30, left: 25, right: 25),
          child: ElevatedButton(
            onPressed: () {
              _postPatientData();
              // print("test");
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xff4CA6A7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              minimumSize: Size(
                MediaQuery.of(context).size.width,
                0,
              ),
            ),
            child: Text(
              "Simpan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
