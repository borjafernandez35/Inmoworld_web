import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:inmoworld_web/services/sign_in.dart';
import 'package:dio/dio.dart';
import 'dart:math';

// ignore: must_be_immutable
class RegisterGoogleScreen extends StatefulWidget {
  final VoidCallback onRegistrationComplete;
  GoogleSignInAccount? currentUser;

  RegisterGoogleScreen(
      {required this.onRegistrationComplete, required this.currentUser});

  @override
  _RegisterGoogleScreenState createState() => _RegisterGoogleScreenState();
}

class _RegisterGoogleScreenState extends State<RegisterGoogleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _autoGeneratedPassword = '';
  final _birthdayController = TextEditingController();
  //final _imageController = TextEditingController();
  final Dio dio = Dio();
  late StorageService _storageService;

  // ignore: prefer_final_fields
  SignInService _signInService = SignInService(
    clientId:
        '103614501225-t83dvlcomsl5j8h2d10grk4o4sgu6ijl.apps.googleusercontent.com',
  );
 

// Función para generar una contraseña aleatoria
  String generateRandomPassword({int length = 8}) {
    const charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return List.generate(
        length, (index) => charset[random.nextInt(charset.length)]).join();
  }

  // Función para enviar datos al backend usando dio
  Future<void> sendDataToBackend() async {
    const String baseUrl = 'http://127.0.0.1:3000';
    //const String baseUrl = 'http://147.83.7.157:3000';

    try {
      // Construir el cuerpo de la solicitud
      var requestData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'password':
            _autoGeneratedPassword, // Aquí puedes generar una contraseña aleatoria si es necesario
        'birthday': _birthdayController.text,
        //'image': _imageController.text,
        // Otros campos según sea necesario
      };

      final response = await dio.post(
        '$baseUrl/user/google',
        data: requestData,
      );

      if (response.statusCode == 201) {
        var token = response.data['token'];
        // var refresh_token = response.data['refreshToken'];

        var id = response.data['id'];
        var isAdmin = response.data['user']['isAdmin'];
        StorageService.saveToken(token);
        StorageService.saveId(id);
        StorageService.saveAdmin(isAdmin);

        Get.toNamed('/perfil');
        // Llamar a la función de callback para indicar que el registro fue exitoso
        _handleLoginResponse(response.statusCode ?? 0);
      } else {
        _handleLoginResponse(response.statusCode ?? 0);
      }
    } catch (e) {
      // ignore: deprecated_member_use
      if (e is DioError) {
        print('Error creating user: ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response!.statusCode}');
          print('Response data: ${e.response!.data}');
        } else {
          print('No response received.');
        }
      } else {
        print('Error creating user: $e');
      }
    }
  }

  void _handleLoginResponse(int statusCode) {
    if (statusCode == 201 || statusCode == 200) {
      Get.snackbar('Success', 'Login successful',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed('/perfil');
    } else if (statusCode == 400) {
      _showError('Incorrect credentials. Please try again.');
    } else if (statusCode == 500) {
      _showError('Server error. Please try later.');
    } else {
      _showError('Unknown error. Contact support.');
    }
  }

  void _showError(String message) {
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthdayController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe way to get ancestor widgets
    _storageService = StorageService();
  }

  @override
  void initState() {
    super.initState();
    // Puedes inicializar los campos de nombre y email con los datos del usuario de Google Sign-In
    _nameController.text = widget.currentUser?.displayName ?? '';
    _emailController.text = widget.currentUser?.email ?? '';
    // _imageController.text = widget.currentUser?.photoUrl ?? '';
    _autoGeneratedPassword = generateRandomPassword();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Sign Up'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, fill in your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, fill in your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthdayController,
                decoration: InputDecoration(
                  labelText: 'Birthday',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please, select the date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Aquí puedes manejar el registro del usuario con los datos proporcionados
                    sendDataToBackend(); // Llama a la función para enviar los datos al backend
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
