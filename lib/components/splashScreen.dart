// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/pages/users/FeedPage.dart';
import 'package:cookie_flutter_app/main.dart'; // Importar MyHomePage

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');
    if (token != null) {
      // Si el token existe, navega al FeedPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FeedPage(token: token)),
      );
    } else {
      // Si no hay token, navega al MyHomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'COOKIE | HOME')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
