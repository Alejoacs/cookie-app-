// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_flutter_app/pages/users/FeedPage.dart';
import 'package:cookie_flutter_app/pages/auth/RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String token = responseData['token'];
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => FeedPage(token: token)),
      );
    } else {
      // ignore: avoid_print
      print('Error en el inicio de sesión: ${response.statusCode}');
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
              // ignore: avoid_unnecessary_containers
              Container(
                // ignore: prefer_const_constructors
                margin: EdgeInsets.only(top: 20),

                // ignore: prefer_const_constructors
                child: Column(
                  // ignore: prefer_const_literals_to_create_immutables
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.popUntil(
                                context, ModalRoute.withName('/'));
                          },
                          // ignore: prefer_const_constructors
                          icon: Icon(
                            Icons.arrow_back,
                            // ignore: prefer_const_constructors
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

              // ignore: avoid_unnecessary_containers
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      // ignore: prefer_const_constructors
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

              // ignore: avoid_unnecessary_containers
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
                        // ignore: prefer_const_constructors
                        prefixIcon: Icon(Icons.email, color: Color(0xFFDD2525)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        // labelStyle: TextStyle(color: Color(0xFFDD2525)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // ignore: prefer_const_constructors
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
                        // ignore: prefer_const_constructors
                        text: TextSpan(
                          // ignore: prefer_const_constructors
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            // ignore: prefer_const_constructors
                            TextSpan(
                              text: 'Don´t have an account? ',
                            ),
                            // ignore: prefer_const_constructors
                            TextSpan(
                              text: 'Sign up now',
                              // ignore: prefer_const_constructors
                              style: TextStyle(
                                // ignore: prefer_const_constructors
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

              // ignore: avoid_unnecessary_containers
              Container(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _loginUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        // ignore: prefer_const_constructors
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

              // ignore: avoid_unnecessary_containers
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
