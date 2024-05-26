// ignore: file_names
// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/pages/auth/LoginPage.dart';

class FeedPage extends StatelessWidget {
  final String token;

  const FeedPage({super.key, required this.token});

  Future<void> _logout(BuildContext context) async {
    const String logoutUrl = 'https://co-api-vjvb.onrender.com/api/auth/logout';

    final http.Response response = await http.post(
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
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Error al cerrar sesión: ${response.statusCode}');
    }
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
          NavBar(logout: _logout),
        ],
      ),
    );
  }
}

class NavBar extends StatelessWidget {
  final Function(BuildContext) logout;

  const NavBar({Key? key, required this.logout});

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
                  onPressed: () {},
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
      onSelected: (String value) {
        _showModal(context, value);
      },
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
    );
  }

  void _showModal(BuildContext context, String item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modal for $item'),
          content: Text('This is the modal for $item.'),
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
}
