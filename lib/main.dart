import 'package:enfie/screen/bottom_bar.dart';
import 'package:enfie/screen/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(); // Load dotenv here

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Set this to false
      title: 'enfie',
      theme: ThemeData(
        fontFamily: 'Poppins', // Set the default font family to Poppins
      ),
      home: SignUp(),
    );
  }
}
