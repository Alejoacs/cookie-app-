import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/main.dart' as main;
import 'package:jwt_decoder/jwt_decoder.dart';

class FeedPage extends StatefulWidget {
  final String token;

  const FeedPage({Key? key, required this.token}) : super(key: key);

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Map<String, dynamic>? userData;
  final picker = ImagePicker();
  XFile? pickedImage;
  List<dynamic> posts = [];
  String? userLoggedId;

  @override
  void initState() {
    super.initState();
    _decodeToken();
    _getUserData();
    _getPosts();
  }

  Future<void> _decodeToken() async {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.token);
      setState(() {
        userLoggedId = decodedToken['id'];
        print(userLoggedId);
      });
    } catch (e) {
      print('Error decoding token: $e');
    }
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

  Future<void> _getPosts() async {
    const String getPostsUrl = 'https://co-api-vjvb.onrender.com/api/posts/';

    try {
      final http.Response response = await http.get(
        Uri.parse(getPostsUrl),
        headers: {
          'x-access-token': widget.token,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        List<dynamic> updatedPosts = [];

        for (var post in responseData.reversed) {
          String userId = post['userId'];

          // Obtener información del usuario que creó el post
          final userResponse = await http.get(
            Uri.parse('https://co-api-vjvb.onrender.com/api/users/$userId'),
            headers: {
              'x-access-token': widget.token,
            },
          );

          if (userResponse.statusCode == 200) {
            final userData = jsonDecode(userResponse.body);
            post['user'] = userData; // Añadir datos del usuario al post
            updatedPosts.add(post);
          } else {
            print(
                'Error al obtener información del usuario: ${userResponse.statusCode}');
          }
        }

        setState(() {
          posts = updatedPosts;
        });

        print('Posts actualizados: $posts');
      } else {
        print('Error al obtener posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener posts: $e');
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

  Future<void> _saveUserData(Map<String, dynamic> updatedData) async {
    const String saveUserDataUrl =
        'https://co-api-vjvb.onrender.com/api/profile/';

    try {
      final Uri uri = Uri.parse(saveUserDataUrl);
      var request = http.MultipartRequest('PUT', uri);

      request.headers['x-access-token'] = widget.token;

      // Convert dynamic fields to Map<String, String>
      Map<String, String> stringData = {};
      updatedData.forEach((key, value) {
        stringData[key] = value.toString();
      });

      // Add text fields to multipart request
      request.fields.addAll(stringData);

      if (pickedImage != null) {
        var stream =
            http.ByteStream(DelegatingStream.typed(pickedImage!.openRead()));
        var length = await pickedImage!.length();

        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: path.basename(pickedImage!.path),
        );

        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Datos de usuario actualizados exitosamente');
        setState(() {
          userData = updatedData;
        });
      } else {
        print('Error al actualizar datos de usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al actualizar datos de usuario: $e');
    }
  }

  Future<void> _updateProfilePicture() async {
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      try {
        // Intenta cargar la imagen seleccionada
        setState(() {
          pickedImage = image;
        });
      } catch (e) {
        // Captura cualquier error al cargar la imagen
        print('Error al cargar la imagen: $e');
      }
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Widget _buildEditProfileModal(BuildContext context) {
    TextEditingController fullnameController =
        TextEditingController(text: userData?['fullname']);
    TextEditingController usernameController =
        TextEditingController(text: userData?['username']);
    TextEditingController emailController =
        TextEditingController(text: userData?['email']);
    TextEditingController phoneController =
        TextEditingController(text: userData?['phone_number']);
    TextEditingController descriptionController =
        TextEditingController(text: userData?['description']);

    return AlertDialog(
      title: const Text('Editar Perfil'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (userData != null) ...[
              GestureDetector(
                onTap: () {
                  _updateProfilePicture();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    pickedImage != null
                        ? ClipOval(
                            child: Image.file(
                              File(pickedImage!.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : userData!['image'] != null &&
                                userData!['image']['secure_url'] != null
                            ? ClipOval(
                                child: Image.network(
                                  userData!['image']['secure_url'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                color: Colors.grey[300],
                                width: 100,
                                height: 100,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                    Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullnameController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
              ),
              TextField(
                controller: usernameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre de Usuario'),
              ),
              TextField(
                controller: emailController,
                decoration:
                    const InputDecoration(labelText: 'Correo Electrónico'),
              ),
              TextField(
                controller: phoneController,
                decoration:
                    const InputDecoration(labelText: 'Número de Teléfono'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ] else ...[
              const Text('Cargando datos...'),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            Map<String, dynamic> updatedData = {
              'fullname': fullnameController.text,
              'username': usernameController.text,
              'email': emailController.text,
              'phone_number': phoneController.text,
              'description': descriptionController.text,
            };
            await _saveUserData(updatedData);
            Navigator.of(context).pop(); // Cierra la modal después de guardar
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildProfileModal(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (userData != null) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                if (userData != null) ...[
                  if (userData!['image'] != null &&
                      userData!['image']['secure_url'] != null) ...[
                    Stack(
                      children: [
                        ClipOval(
                          child: Image.network(
                            userData!['image']['secure_url'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            userData!['status'] == 'active'
                                ? Icons.fiber_manual_record
                                : Icons.circle,
                            color: userData!['status'] == 'active'
                                ? Colors.green
                                : Colors.red,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text('${userData!['fullname']}'),
            Text(
              '@${userData!['username']}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text('${userData!['description']}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra la modal actual
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return _buildEditProfileModal(context);
                  },
                );
              },
              child: const Text('Editar Perfil'),
            ),
          ] else ...[
            const Text('Cargando datos...'),
          ],
        ],
      ),
    );
  }

  Widget _buildPostCard(dynamic post, {required VoidCallback onRefresh}) {
    Map<String, dynamic>? userData = post['user'] as Map<String, dynamic>?;

    bool isLoggedInUserPost = post['userId'] == userLoggedId;
    bool isLoggedUserFollowing = false;

    if (!isLoggedInUserPost && userData != null) {
      List<dynamic>? followers = userData['followers'] as List<dynamic>?;

      if (followers != null && followers.contains(userLoggedId)) {
        isLoggedUserFollowing = true;
      }
    }

    String? gender = userData != null ? userData['gender'] : null;
    String iconForGender = '';
    if (gender == 'female') {
      iconForGender = 'assets/pics/f.png';
    } else {
      iconForGender = 'assets/pics/m.png';
    }

    bool isSessionActive = userData != null &&
        userData['sesion'] != null &&
        userData['sesion'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userData != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSessionActive ? Colors.green : Colors.red,
                        width: 3,
                      ),
                    ),
                    child: userData['image'] != null &&
                            userData['image'] is Map<String, dynamic> &&
                            userData['image']['secure_url'] != null
                        ? ClipOval(
                            child: Image.network(
                              userData['image']['secure_url'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: AssetImage(iconForGender),
                            radius: 20,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['fullname'] ?? 'Sin nombre',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${userData['username']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isLoggedInUserPost)
                    IconButton(
                      onPressed: () {
                        _deletePost(post['id']);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  if (!isLoggedInUserPost && !isLoggedUserFollowing)
                    IconButton(
                      onPressed: () {
                        _followUser(post['userId']);
                      },
                      icon: const Icon(
                        Icons.person_add,
                        color: Colors.blue,
                      ),
                    ),
                  if (!isLoggedInUserPost && isLoggedUserFollowing)
                    IconButton(
                      onPressed: () {
                        _unfollowUser(post['userId']);
                      },
                      icon: const Icon(
                        Icons.person_remove,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ] else ...[
              const Text('Cargando datos...'),
            ],
            const SizedBox(
                height:
                    10), // Espacio entre fullname/username y contenido del post
            Text(
              post['content'] ?? 'Sin contenido',
            ),
            if (post['image'] != null && post['image'] is String) ...[
              const SizedBox(height: 8),
              Image.network(
                post['image'], // Usar directamente el campo 'image' como URL
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _followUser(String userId) async {
    final url = 'https://co-api-vjvb.onrender.com/api/users/follow/$userId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': widget.token,
        },
      );

      if (response.statusCode == 200) {
        print('Siguiendo al usuario con ID: $userId');
        final responseData = json.decode(response.body);
        print(responseData['message']);
      } else {
        final responseData = json.decode(response.body);
        print('Error: ${responseData['message']}');
      }
    } catch (error) {
      print('Error siguiendo al usuario: $error');
    }
  }

  void _unfollowUser(String userId) async {
    final url = 'https://co-api-vjvb.onrender.com/api/users/unfollow/$userId';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'x-access-token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      print('Dejando de seguir al usuario con ID: $userId');
    } else {
      print('Error al dejar de seguir al usuario: ${response.body}');
    }
  }

  void _deletePost(String postId) {
    // Implementar lógica para eliminar el post con el postId especificado
    print('Eliminando el post con ID: $postId');
    // Aquí podrías realizar una llamada a la API correspondiente para eliminar el post
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: RefreshIndicator(
              onRefresh: () async {
                await _getPosts(); // Llama a la función para obtener los posts nuevamente
              },
              child: posts.isNotEmpty
                  ? ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildPostCard(posts[index],
                              onRefresh:
                                  _getPosts); // Primer post con gesto de refresco
                        } else {
                          return _buildPostCard(posts[index],
                              onRefresh:
                                  () {}); // Otros posts sin gesto de refresco
                        }
                      },
                    )
                  : const CircularProgressIndicator(),
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.keyboard_arrow_up,
                          color: Colors.white, size: 24),
                      SizedBox(height: 4),
                      Text(
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
          content: modalContent,
        );
      },
    );
  }

  Widget _buildSaveModalContent(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Save item...'),
      ],
    );
  }

  Widget _buildSearchModalContent(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Search item...'),
      ],
    );
  }

  Widget _buildMessageModalContent(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Send message...'),
      ],
    );
  }

  Widget _buildStatisticsModalContent(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('View statistics...'),
      ],
    );
  }

  Widget _buildNotificationsModalContent(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('View notifications...'),
      ],
    );
  }
}
