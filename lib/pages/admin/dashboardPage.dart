// ignore_for_file: prefer_const_declarations, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, prefer_const_constructors, deprecated_member_use

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
  List<dynamic>? filteredUserData;
  final List<Map<String, String>> rolesData = [
    {'_id': '664764791b8d18c4f24304a0', 'name': 'user'},
    {'_id': '664764791b8d18c4f24304a1', 'name': 'admin'},
    {'_id': '664764791b8d18c4f24304a2', 'name': 'moderator'},
  ];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserData();
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          filteredUserData = responseData;
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

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUserData = userData!.where((user) {
        final username = user['username']?.toLowerCase() ?? '';
        final fullname = user['fullname']?.toLowerCase() ?? '';
        return username.contains(query) || fullname.contains(query);
      }).toList();
    });
  }

  Future<void> _toggleUserStatus(int index) async {
    var user = filteredUserData![index];
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
          userData![userData!.indexWhere((u) => u['_id'] == userId)]['status'] =
              newStatus;
          filteredUserData![index]['status'] = newStatus;
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
    var user = filteredUserData![index];
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
          userData![userData!.indexWhere((u) => u['_id'] == userId)]['role'] = {
            '_id': roleId,
            'name':
                rolesData.firstWhere((role) => role['_id'] == roleId)['name']
          };
          filteredUserData![index]['role'] = {
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

  void _showUserDetails(dynamic user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: contentBox(context, user),
        );
      },
    );
  }

  contentBox(context, dynamic user) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full Name: ${user['fullname'] ?? 'N/A'}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Gender: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${user['gender'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Phone Number: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${user['phone_number'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text('Description: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('${user['description'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 13)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    TextSpan(
                      text: 'Followers: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${user['followers']?.length ?? 0}',
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    TextSpan(
                      text: 'Following: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${user['following']?.length ?? 0}',
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    TextSpan(
                      text: 'Friends: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${user['friends']?.length ?? 0}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(int index) {
    var user = filteredUserData![index];
    var userId = user['_id'];

    TextEditingController fullnameController =
        TextEditingController(text: user['fullname']);
    TextEditingController genderController =
        TextEditingController(text: user['gender']);
    TextEditingController phoneNumberController =
        TextEditingController(text: user['phone_number']);
    TextEditingController descriptionController =
        TextEditingController(text: user['description']);

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: fullnameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  TextField(
                    controller: genderController,
                    decoration: const InputDecoration(labelText: 'Gender'),
                  ),
                  TextField(
                    controller: phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        var updatedFields = {
                          if (fullnameController.text != user['fullname'])
                            'fullname': fullnameController.text,
                          if (genderController.text != user['gender'])
                            'gender': genderController.text,
                          if (phoneNumberController.text !=
                              user['phone_number'])
                            'phone_number': phoneNumberController.text,
                          if (descriptionController.text != user['description'])
                            'description': descriptionController.text,
                        };

                        if (updatedFields.isNotEmpty) {
                          final String updateUserUrl =
                              'https://co-api-vjvb.onrender.com/api/users/$userId';

                          try {
                            final http.Response response = await http.put(
                              Uri.parse(updateUserUrl),
                              headers: {
                                'Content-Type': 'application/json',
                                'x-access-token': widget.token,
                              },
                              body: jsonEncode(updatedFields),
                            );

                            if (response.statusCode == 200) {
                              setState(() {
                                userData![userData!
                                    .indexWhere((u) => u['_id'] == userId)] = {
                                  ...userData![userData!
                                      .indexWhere((u) => u['_id'] == userId)],
                                  ...updatedFields
                                };
                                filteredUserData![index] = {
                                  ...filteredUserData![index],
                                  ...updatedFields
                                };
                              });
                              print('Usuario actualizado exitosamente');
                              Navigator.of(context).pop();
                            } else {
                              print(
                                  'Error al actualizar el usuario: ${response.statusCode}');
                            }
                          } catch (e) {
                            print('Excepción al actualizar el usuario: $e');
                          }
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search by username',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: filteredUserData != null
                        ? ListView.builder(
                            itemCount: filteredUserData!.length,
                            itemBuilder: (context, index) {
                              var user = filteredUserData![index];
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
                                  onTap: () {
                                    _showUserDetails(user);
                                  },
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
                                              color: (user['sesion'] == true ||
                                                      user['sesion'] == 'true')
                                                  ? Colors.green
                                                  : Colors.red,
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
                                  title:
                                      Text(user['username'] ?? 'No Username'),
                                  subtitle: Text(
                                    userRole,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditUserDialog(index);
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isActive
                                              ? Icons.toggle_on
                                              : Icons.toggle_off,
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        onPressed: () =>
                                            _toggleUserStatus(index),
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
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _logout(context),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: const Icon(Icons.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
