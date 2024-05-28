// ignore_for_file: prefer_const_declarations, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, avoid_function_literals_in_foreach_calls

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
  final List<Map<String, String>> rolesData = [
    {'_id': '664764791b8d18c4f24304a0', 'name': 'user'},
    {'_id': '664764791b8d18c4f24304a1', 'name': 'admin'},
    {'_id': '664764791b8d18c4f24304a2', 'name': 'moderator'},
  ];

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

  Future<void> _toggleUserStatus(int index) async {
    var user = userData![index];
    var userId = user['_id'];
    var newStatus = user['status'] == 'active' ? 'inactive' : 'active';
    final String toggleStatusUrl =
        'https://co-api-vjvb.onrender.com/api/users/status/$userId';

    try {
      final http.Response response = await http.put(
        Uri.parse(toggleStatusUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': widget.token,
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData![index]['status'] = newStatus;
        });
        print('Estado del usuario actualizado exitosamente: $newStatus');
      } else {
        print(
            'Error al actualizar el estado del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al actualizar el estado del usuario: $e');
    }
  }

  Future<void> _changeUserRole(int index, String roleId) async {
    var user = userData![index];
    var userId = user['_id'];
    final String changeRoleUrl =
        'https://co-api-vjvb.onrender.com/api/users/changeRole';

    try {
      final http.Response response = await http.put(
        Uri.parse(changeRoleUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': widget.token,
        },
        body: jsonEncode({'userId': userId, 'roleId': roleId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userData![index]['role'] = {
            '_id': roleId,
            'name':
                rolesData.firstWhere((role) => role['_id'] == roleId)['name']
          };
        });
        print('Rol del usuario actualizado exitosamente');
      } else {
        print('Error al actualizar el rol del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al actualizar el rol del usuario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
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
                      var userRole = user['role'] != null
                          ? user['role']['name']
                          : 'No Role';
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
                                      color:
                                          isActive ? Colors.green : Colors.red,
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
                          subtitle: Text(
                            userRole,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isActive ? Icons.toggle_on : Icons.toggle_off,
                                  color: isActive ? Colors.green : Colors.red,
                                ),
                                onPressed: () => _toggleUserStatus(index),
                              ),
                              PopupMenuButton<String>(
                                child: const Text('Rol'),
                                onSelected: (String value) {
                                  _changeUserRole(index, value);
                                },
                                itemBuilder: (BuildContext context) {
                                  return rolesData.map((role) {
                                    return PopupMenuItem<String>(
                                      value: role['_id'],
                                      child: Text(role['name']!),
                                    );
                                  }).toList();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const CircularProgressIndicator(),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => _logout(context),
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
    );
  }
}
