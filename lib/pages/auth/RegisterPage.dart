// ignore: file_names
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_flutter_app/pages/auth/LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  void _showTermsAndConditionsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // ignore: prefer_const_constructors
          title: Text('Términos y Condiciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ignore: prefer_const_constructors
              Text(
                'Términos y Condiciones de Uso',
                // ignore: prefer_const_constructors
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // ignore: prefer_const_constructors
              SizedBox(height: 10),
              // ignore: prefer_const_constructors
              Text(
                '1. Al utilizar esta red social, aceptas cumplir con los siguientes términos y condiciones.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '2. Eres responsable de toda la actividad que ocurra bajo tu cuenta.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '3. No se permite el acoso, el discurso de odio ni la violencia en esta plataforma.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '4. No compartas información personal sensible en la red social.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '5. No publiques contenido que viole los derechos de autor.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '6. Respetar la privacidad de otros usuarios y no compartir información confidencial sin su consentimiento.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '7. No utilizar la red social para fines comerciales sin autorización.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '8. La red social no se hace responsable del contenido compartido por los usuarios.',
              ),
              // ignore: prefer_const_constructors
              Text(
                '9. Se reserva el derecho de eliminar contenido que viole estos términos y condiciones.',
              ),
              // ignore: prefer_const_constructors
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _registerUser() async {
    const String apiUrl = 'https://co-api-vjvb.onrender.com/api/auth/signup';

    final Map<String, String> data = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    final String jsonData = jsonEncode(data);

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    if (response.statusCode == 201) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Successful registration!!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // ignore: avoid_print
      print('Error al registrar usuario');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // ignore: prefer_const_constructors
            Column(
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
                        Navigator.popUntil(context, ModalRoute.withName('/'));
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
                // ignore: prefer_const_constructors
                Text(
                  'WELCOME',
                  // ignore: prefer_const_constructors
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    // ignore: prefer_const_constructors
                    color: Color(0xFFDD2525),
                  ),
                ),
                // ignore: prefer_const_constructors
                Text(
                  'Sign up to access all features',
                  // ignore: prefer_const_constructors
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    'assets/img/img.png',
                    width: 200,
                    height: 200,
                  ),
                ),
                // const SizedBox(height: 5),
                // const Text(
                //   'COOKIE, The new social network for people with visual disabilities.',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 20,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
              ],
            ),
            Column(
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  // ignore: prefer_const_constructors
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFFDD2525)),
                  ),
                ),
                // ignore: prefer_const_constructors
                SizedBox(height: 10), // Agregar espacio entre los campos
                TextFormField(
                  controller: _emailController,
                  // ignore: prefer_const_constructors
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.email, color: Color(0xFFDD2525)),
                  ),
                ),
                // ignore: prefer_const_constructors
                SizedBox(height: 10), // Agregar espacio entre los campos
                TextFormField(
                  controller: _passwordController,
                  // ignore: prefer_const_constructors
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password',

                    // ignore: prefer_const_constructors
                    border: OutlineInputBorder(
                      // ignore: prefer_const_constructors
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                // ignore: prefer_const_constructors
                SizedBox(height: 10), // Agregar espacio entre los campos
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value!;
                        });
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        // Mostrar la modal de términos y condiciones
                        _showTermsAndConditionsModal(context);
                      },
                      // ignore: prefer_const_constructors
                      child: Text(
                        'Accept  ',
                        // ignore: prefer_const_constructors
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Mostrar la modal de términos y condiciones
                        _showTermsAndConditionsModal(context);
                      },
                      // ignore: prefer_const_constructors
                      child: Text(
                        'terms and conditions',
                        // ignore: prefer_const_constructors
                        style:
                            // ignore: prefer_const_constructors
                            TextStyle(fontSize: 14, color: Color(0xFFDD2525)),
                      ),
                    ),
                  ],
                ),
                // ignore: prefer_const_constructors
                SizedBox(
                  height: 10,
                ), // Espacio entre los campos y el botón de registro
                ElevatedButton(
                  onPressed: _acceptTerms ? _registerUser : null,
                  // ignore: sort_child_properties_last, prefer_const_constructors
                  child: Text(
                    'Sing Up',
                    // ignore: prefer_const_constructors
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    // ignore: prefer_const_constructors
                    backgroundColor: Color(0xFFDD2525),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // ignore: prefer_const_constructors
                SizedBox(height: 10), // Agregar espacio entre los campos
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
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
                          text: 'You have account? ',
                        ),
                        // ignore: prefer_const_constructors
                        TextSpan(
                          text: 'Sing In Now',
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

            const Text(
              '© 2024 Cookie. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
