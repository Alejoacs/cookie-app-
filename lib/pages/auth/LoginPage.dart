// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unused_element

import 'package:cookie_flutter_app/pages/admin/dashboardPage.dart';
import 'package:cookie_flutter_app/pages/auth/RegisterPage.dart';
import 'package:cookie_flutter_app/pages/users/FeedPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:cookie_flutter_app/main.dart' as main;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _loginUser(BuildContext context) async {
    const String apiUrl = 'https://co-api-vjvb.onrender.com/api/auth/signin';

    final Map<String, String> data = {
      'emailOrUsername': _emailController.text,
      'password': _passwordController.text,
    };

    final jsonData = jsonEncode(data);

    try {
      final http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonData,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];

        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final String role = decodedToken['role'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);

        // Verificar si el token fue almacenado correctamente
        // String? storedToken = prefs.getString('user_token');
        // if (storedToken != null) {
        //   print('Token almacenado correctamente: $storedToken');
        // } else {
        //   print('Error al almacenar el token');
        // }

        switch (role) {
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardPage(token: token)),
            );
            break;
          case 'moder':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardPage(token: token)),
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FeedPage(token: token)),
            );
            break;
        }
      } else {
        String errorMessage;
        switch (response.statusCode) {
          case 400:
            errorMessage = 'Solicitud incorrecta. Verifica tus datos.';
            break;
          case 401:
            errorMessage = 'Credenciales incorrectas. Inténtalo de nuevo.';
            break;
          case 500:
            errorMessage = 'Error del servidor. Inténtalo más tarde.';
            break;
          default:
            errorMessage = 'Error desconocido: ${response.statusCode}.';
        }
        _showErrorDialog(context, errorMessage);
      }
    } catch (error) {
      _showErrorDialog(
          context, 'Error de red. Verifica tu conexión a internet.');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('user_token');

    if (token != null) {
      print('Token recuperado: $token');
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String role = decodedToken['role'];
        Widget targetPage;

        switch (role) {
          case 'admin':
          case 'moder':
            targetPage = DashboardPage(token: token);
            break;
          default:
            targetPage = FeedPage(token: token);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      } catch (error) {
        print('Error al decodificar el token: $error');
      }
    } else {
      print('No se encontró ningún token almacenado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const main.MyApp(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: Color(0xFFDD2525),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'WELCOME',
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDD2525),
                      ),
                    ),
                    const Text(
                      'Sign in to access all features',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(2),
                      child: Image.asset(
                        'assets/img/img2.png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 5),
                    //   child: const Text(
                    //     'COOKIE, The new social network for people with visual disabilities.',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: 20,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.black,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email or Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.email, color: Color(0xFFDD2525)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFDD2525)),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: 'Don´t have an account? ',
                            ),
                            TextSpan(
                              text: 'Sign up now',
                              style: TextStyle(
                                color: Color(0xFFDD2525),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _loginUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDD2525),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sing In',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: const Text(
                  '© 2024 Cookie. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
