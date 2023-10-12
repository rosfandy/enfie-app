import 'package:enfie/api/google_signin_api.dart';
import 'package:enfie/screen/bottom_bar.dart';
import 'package:enfie/screen/signin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import the dart:convert library
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F8FA),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    "assets/enfie_form.png",
                    height: 100,
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20),
                        child: SignUpForm(),
                      ),
                    ),
                    Container(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              "Sudah Punya Akun ?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight
                                    .w500, // Set the font weight to bold
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Define the action you want to take when the text is clicked.
                                // For example, you can navigate to the sign-in screen.
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignIn()));
                              },
                              child: Text(
                                "Sign In",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CA6A7),
                                  fontSize: 17,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ) // Add a Spacer widget to push the container to the bottom
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String _nama = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_password != '' &&
          _confirmPassword != '' &&
          _password == _confirmPassword) {
        // Data yang akan dikirim ke server
        Map<String, String> data = {
          'name': _nama,
          'email': _email,
          'password': _password,
        };

        final String url = '${dotenv.env['API_URL']}/user/register';

        try {
          // Sending a POST request
          final response = await http.post(
            Uri.parse(url),
            body: jsonEncode(data), // Use jsonEncode to encode the data
            headers: {'Content-Type': 'application/json'},
          );
          // Server responded with an error
          final responseBody = jsonDecode(response.body);
          final responseMessage = responseBody['message'];
          final responseStatus = responseBody['status'];

          print('status ${responseStatus}');
          if (responseStatus == "success") {
            // Server responded with success
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) =>
                      SignIn()), // Replace SignIn() with your sign-in screen
            );

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
              msg: "${responseMessage} (Status Code: ${response.statusCode})",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        } catch (e) {
          // Handle exceptions (e.g., network connection lost)
          print("Error: $e");
          Fluttertoast.showToast(
            msg: "Connection lost or other error occurred",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Password tidak cocok",
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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nama",
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          TextFormField(
            cursorColor: Color(0xff4CA6A7),
            decoration: InputDecoration(
              hintText: "masukan nama",
              hintStyle: TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide(color: Color(0xffE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Color(0xff4CA6A7), width: 2),
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
            "Email",
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          TextFormField(
            cursorColor: Color(0xff4CA6A7),
            decoration: InputDecoration(
              hintText: "email@gmail.com",
              hintStyle: TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide(color: Color(0xffE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Color(0xff4CA6A7), width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
            ),
            onChanged: (value) {
              _email = value;
            },
          ),
          SizedBox(height: 10),
          Text(
            "Password",
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 5),
          TextFormField(
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: "password",
              hintStyle: TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide(color: Color(0xffE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Color(0xff4CA6A7), width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: _isPasswordVisible ? Color(0xff4CA6A7) : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            onChanged: (value) {
              _password = value;
            },
          ),
          SizedBox(height: 10),
          Text(
            "Konfirmasi Password",
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 5),
          TextFormField(
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              hintText: "konfirmasi password",
              hintStyle: TextStyle(fontSize: 14, color: Color(0xffA1A3B0)),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14.0)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.0),
                borderSide: BorderSide(color: Color(0xffE8E8E8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Color(0xff4CA6A7), width: 2),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: _isConfirmPasswordVisible
                      ? Color(0xff4CA6A7)
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            onChanged: (value) {
              _confirmPassword = value;
            },
          ),
          // Submit Button
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Call a function to handle form submission here
              _submitForm();
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xff4CA6A7), // Set the button's background color
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
              "Daftar Akun",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
