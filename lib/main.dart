import 'package:flutter/material.dart';
import 'package:cookie_flutter_app/pages/auth/LoginPage.dart' as login;
import 'package:cookie_flutter_app/pages/auth/RegisterPage.dart' as register;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HOME | COOKIE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFDD2525),
        ),
        // ignore: prefer_const_constructors
        primaryColor: Color(0xFFDD2525),
        primaryTextTheme: const TextTheme(
          // ignore: deprecated_member_use
          titleLarge: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: const MyHomePage(title: 'COOKIE | HOME'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 200,
                      child: Image.asset('assets/img/img.png'),
                    ),
                    const Text(
                      'COOKIE, another sensation',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDD2525),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const login.LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // ignore: prefer_const_constructors
                      backgroundColor: Color(0xFFDD2525),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.login,
                      color: Colors.white,
                    ),
                    // ignore: prefer_const_constructors
                    label: Text(
                      'LOGIN',
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const register.RegisterPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      // ignore: prefer_const_constructors
                      backgroundColor: Color(0xFFDD2525),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // ignore: prefer_const_constructors
                    icon: Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    // ignore: prefer_const_constructors
                    label: Text(
                      'REGISTER',
                      // ignore: prefer_const_constructors
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                '© 2024 Cookie. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
