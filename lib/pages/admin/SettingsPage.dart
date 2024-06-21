// ignore_for_file: file_names, use_super_parameters, prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/main.dart' as main;
import 'package:cookie_flutter_app/pages/admin/AnalysisPage.dart';
import 'package:cookie_flutter_app/pages/admin/dashboardPage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  final String token;

  const SettingsPage({Key? key, required this.token}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Future<Map<String, dynamic>> _profileFuture;

  static const String profileUrl =
      'https://co-api-vjvb.onrender.com/api/profile/';
  static const String logoutUrl =
      'https://co-api-vjvb.onrender.com/api/auth/logout';

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfile(widget.token);
  }

  Future<Map<String, dynamic>> _getProfile(String token) async {
    final response = await http.get(
      Uri.parse(profileUrl),
      headers: {
        'x-access-token': token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Error al obtener el perfil: ${response.statusCode}');
    }
  }

  Future<void> _logout(BuildContext context, String token) async {
    final response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'x-access-token': token,
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

  Future<void> _updateProfile(
      String token,
      String username,
      String email,
      String password,
      String fullName,
      String gender,
      String phoneNumber,
      String description,
      File? imageFile) async {
    var request = http.MultipartRequest('PUT', Uri.parse(profileUrl))
      ..headers['x-access-token'] = token
      ..fields['username'] = username
      ..fields['email'] = email
      ..fields['password'] = password
      ..fields['fullname'] = fullName
      ..fields['gender'] = gender
      ..fields['phone_number'] = phoneNumber
      ..fields['description'] = description;

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Perfil actualizado exitosamente');
      setState(() {
        _profileFuture = _getProfile(token);
      });
    } else {
      throw Exception('Error al actualizar el perfil: ${response.statusCode}');
    }
  }

  void _showEditProfileModal(
      BuildContext context, Map<String, dynamic> profileData) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController usernameController =
            TextEditingController(text: profileData['username']);
        final TextEditingController emailController =
            TextEditingController(text: profileData['email']);
        final TextEditingController passwordController =
            TextEditingController();
        final TextEditingController fullNameController =
            TextEditingController(text: profileData['fullname']);
        final TextEditingController phoneNumberController =
            TextEditingController(text: profileData['phone_number']);
        final TextEditingController descriptionController =
            TextEditingController(text: profileData['description']);
        String gender = profileData['gender'];
        File? _selectedImage;

        Future<void> _pickImage() async {
          final picker = ImagePicker();
          final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);

          if (pickedFile != null) {
            setState(() {
              _selectedImage = File(pickedFile.path);
            });
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Nombre de usuario'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(labelText: 'Nombre completo'),
                ),
                DropdownButtonFormField<String>(
                  value: gender,
                  items: <String>['male', 'female', 'not binary']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      gender = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Género'),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: 'Número de teléfono'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                SizedBox(height: 10),
                _selectedImage == null
                    ? Text('No image selected.')
                    : Image.file(_selectedImage!, height: 100),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Seleccionar imagen'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _updateProfile(
                        widget.token,
                        usernameController.text,
                        emailController.text,
                        passwordController.text,
                        fullNameController.text,
                        gender,
                        phoneNumberController.text,
                        descriptionController.text,
                        _selectedImage,
                      );
                      Navigator.pop(context);
                      // Optionally, refresh the profile data on the screen
                    } catch (e) {
                      print('Error al actualizar el perfil: $e');
                      // Optionally, show an error message to the user
                    }
                  },
                  child: Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Esto quita la flecha hacia atrás
        title: Text('Settings', style: TextStyle(color: Colors.white)),
        iconTheme:
            IconThemeData(color: Colors.white), // Cambiar color de íconos
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AnalysisPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons
                .person), // Cambiado el ícono de configuración por el ícono de perfil
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context, widget.token);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron datos del perfil.'));
          } else {
            final profileData = snapshot.data!;
            final profileImage = profileData['image']['secure_url'];
            final fullName = profileData['fullname'];
            final username = profileData['username'];
            final description = profileData['description'];

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    SizedBox(height: 20),
                    Text(fullName, style: TextStyle(fontSize: 18)),
                    Text(username,
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 10),
                    Text(description, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _showEditProfileModal(context, profileData);
                      },
                      child: Text('Editar perfil'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
