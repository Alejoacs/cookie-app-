// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, sort_child_properties_last
import 'package:cookie_flutter_app/pages/auth/LoginPage.dart';
import 'package:cookie_flutter_app/main.dart' as main;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

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
          title: Text('Términos y Condiciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Términos y Condiciones de Uso',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '1. Al utilizar esta red social, aceptas cumplir con los siguientes términos y condiciones.',
              ),
              Text(
                '2. Eres responsable de toda la actividad que ocurra bajo tu cuenta.',
              ),
              Text(
                '3. No se permite el acoso, el discurso de odio ni la violencia en esta plataforma.',
              ),
              Text(
                '4. No compartas información personal sensible en la red social.',
              ),
              Text(
                '5. No publiques contenido que viole los derechos de autor.',
              ),
              Text(
                '6. Respetar la privacidad de otros usuarios y no compartir información confidencial sin su consentimiento.',
              ),
              Text(
                '7. No utilizar la red social para fines comerciales sin autorización.',
              ),
              Text(
                '8. La red social no se hace responsable del contenido compartido por los usuarios.',
              ),
              Text(
                '9. Se reserva el derecho de eliminar contenido que viole estos términos y condiciones.',
              ),
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

    if (response.statusCode == 200) {
      showDialog(
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
      // Manejo de errores
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String errorMessage =
          responseData['message'] ?? 'Error al registrar usuario';

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
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
                Text(
                  'WELCOME',
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDD2525),
                  ),
                ),
                Text(
                  'Sign up to access all features',
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
              ],
            ),
            Column(
              children: <Widget>[
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFFDD2525)),
                  ),
                ),
                SizedBox(height: 10), // Agregar espacio entre los campos
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.email, color: Color(0xFFDD2525)),
                  ),
                ),
                SizedBox(height: 10), // Agregar espacio entre los campos
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                      child: Text(
                        'Accept  ',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Mostrar la modal de términos y condiciones
                        _showTermsAndConditionsModal(context);
                      },
                      child: Text(
                        'terms and conditions',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFFDD2525)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ), // Espacio entre los campos y el botón de registro
                ElevatedButton(
                  onPressed: _acceptTerms ? _registerUser : null,
                  //
                  child: Text(
                    'Sing Up',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFDD2525),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

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
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      // ignore: prefer_const_literals_to_create_immutables
                      children: [
                        TextSpan(
                          text: 'You have account? ',
                        ),
                        TextSpan(
                          text: 'Sing In Now',
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
