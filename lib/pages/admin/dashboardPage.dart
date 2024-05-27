import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/main.dart' as main;

class DashboardPage extends StatefulWidget {
  final String token;

  const DashboardPage({super.key, required this.token});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _logout(BuildContext context) async {
    const String logoutUrl = 'https://co-api-vjvb.onrender.com/api/auth/logout';

    final http.Response response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'x-access-token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      print('Sesión cerrada exitosamente');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const main.MyApp()),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Error al cerrar sesión: ${response.statusCode}');
    }
  }

  Future<void> _getUserData() async {
    const String getUserDataUrl = 'https://co-api-vjvb.onrender.com/api/users/';

    try {
      final http.Response response = await http.get(
        Uri.parse(getUserDataUrl),
        headers: {
          'x-access-token': widget.token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          userData = responseData;
        });
        print('Datos de usuario obtenidos exitosamente:');
        responseData.forEach((user) {
          print(user);
        });
      } else {
        print('Error al obtener datos de usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener datos de usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: userData != null
            ? ListView.builder(
                itemCount: userData!.length,
                itemBuilder: (context, index) {
                  var user = userData![index];
                  var imageUrl = user['image'] != null
                      ? user['image']['secure_url']
                      : null;
                  var isActive = user['status'] == 'active';
                  var isInactive = user['status'] == 'inactive';
                  return Card(
                    margin: const EdgeInsets.all(10.0),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl)
                                : null,
                            child: imageUrl == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          if (isActive || isInactive)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(user['username'] ?? 'No Username'),
                      subtitle: Text(user['email'] ?? 'No Email'),
                      // Agrega aquí cualquier otra información que desees mostrar
                    ),
                  );
                },
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
