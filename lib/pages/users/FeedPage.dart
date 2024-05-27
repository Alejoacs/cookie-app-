// ignore: file_names
// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, use_key_in_widget_constructors, unused_local_variable, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/main.dart' as main;

class FeedPage extends StatefulWidget {
  final String token;

  const FeedPage({super.key, required this.token});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    // _getUserData(); // Elimina esta línea
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
    const String getUserDataUrl =
        'https://co-api-vjvb.onrender.com/api/profile/';

    try {
      final http.Response response = await http.get(
        Uri.parse(getUserDataUrl),
        headers: {
          'x-access-token': widget.token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          userData = responseData;
        });
      } else {
        print('Error al obtener datos de usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener datos de usuario: $e');
    }
  }

  void _showProfileModalWithUserData(BuildContext context) async {
    await _getUserData();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildProfileModal(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'User feed',
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          NavBar(
            logout: _logout,
            userData: userData,
            showProfileModal: _showProfileModalWithUserData,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileModal(BuildContext context) {
    return AlertDialog(
      title: Text('User Profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (userData != null) ...[
            Text('Email: ${userData!['email']}'),
            Text('Nombre: ${userData!['username']}'),
            Text('Teléfono: ${userData!['phone_number']}'),
          ] else ...[
            Text('Cargando datos...'),
          ],
        ],
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  final Function(BuildContext) logout;
  final Map<String, dynamic>? userData;
  final Function(BuildContext) showProfileModal;

  const NavBar({
    Key? key,
    required this.logout,
    required this.userData,
    required this.showProfileModal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Container(
            height: 65.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.red[900],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdownButton(context),
                TextButton(
                  onPressed: () {
                    showProfileModal(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.keyboard_arrow_up,
                          color: Colors.white, size: 24),
                      const SizedBox(height: 4),
                      const Text(
                        'Profile',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildDropdownItem(Icons.save, 'Save', context),
        _buildDropdownItem(Icons.search, 'Search', context),
        _buildDropdownItem(Icons.message, 'Message', context),
        _buildDropdownItem(Icons.bar_chart, 'Statistics', context),
        _buildDropdownItem(Icons.notifications, 'Notifications', context),
      ],
      offset: const Offset(0, -50),
      color: Colors.red[900],
    );
  }

  PopupMenuItem<String> _buildDropdownItem(
      IconData icon, String label, BuildContext context) {
    return PopupMenuItem<String>(
      value: label,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8.0),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
      onTap: () {
        _showModal(context, label);
      },
    );
  }

  void _showModal(BuildContext context, String item) {
    Widget modalContent;
    switch (item) {
      case 'Save':
        modalContent = _buildSaveModalContent(context);
        break;
      case 'Search':
        modalContent = _buildSearchModalContent(context);
        break;
      case 'Message':
        modalContent = _buildMessageModalContent(context);
        break;
      case 'Statistics':
        modalContent = _buildStatisticsModalContent(context);
        break;
      case 'Notifications':
        modalContent = _buildNotificationsModalContent(context);
        break;
      default:
        modalContent = Container();
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modal for $item'),
          content: modalContent,
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSaveModalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Save your data', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('You can save your files securely here.'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Save Now'),
        ),
      ],
    );
  }

  Widget _buildSearchModalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search for information',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Find what you need with our powerful search tools.'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Start Searching'),
        ),
      ],
    );
  }

  Widget _buildMessageModalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Send a message', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Compose your message and hit send.'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {},
          child: Text('Send Message'),
        ),
      ],
    );
  }

  Widget _buildStatisticsModalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('View your stats', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Analyze your performance with detailed statistics.'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('View Stats'),
        ),
      ],
    );
  }

  Widget _buildNotificationsModalContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Check your notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Stay updated with important notifications.'),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('View Notifications'),
        ),
      ],
    );
  }
}
