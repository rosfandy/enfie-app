import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return;
    }

    try {
      final String url = '${dotenv.env['API_URL']}/user';
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(url), headers: headers);
      // print('res: ${response.body}');
      final responseBody = jsonDecode(response.body);
      final responseMessage = responseBody['message'];
      final responseStatus = responseBody['status'];

      if (responseStatus == "success") {
        final userData = responseBody['data'];
        print('datas: ${userData[0]['name']}');
        setState(() {
          name = userData[0]['name'];
          email = userData[0]['email'];
        });
      }
    } catch (e) {
      print('error http: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Name: $name',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
