import 'package:flutter/gestures.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/src/sign_in_button.dart';
import 'package:inmoworld_web/services/sign_in.dart';
import 'package:inmoworld_web/controllers/userModelController.dart';
import 'package:google_identity_services_web/id.dart' as gis_id;
import 'package:inmoworld_web/screen/register_google.dart';

late SignInService _signInService;

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class TitleScreen extends StatefulWidget {
  @override
  _TitleScreenState createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final UserModelController userModelController = Get.find();
  // late SignInService signInService;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String email = '';
  late TokenClient tokenClient;
  late TokenClientConfig config;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  String idClient =
      '103614501225-t83dvlcomsl5j8h2d10grk4o4sgu6ijl.apps.googleusercontent.com';

  @override
  void initState() {
    super.initState();

    _signInService = SignInService(
      clientId: idClient,
    );

    _signInService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        gis_id.id.setLogLevel('debug');
        gis_id.id.initialize(_signInService.idConfiguration);

        gis_id.id.prompt(_signInService.onPromptMoment);

        print('el account es...:$account');

        _handleSignIn();
        _currentUser = account;
        print('EL USUARIO ES...:$_currentUser');
      });
    });

    _signInService.signInSilently();
  }

  Future<void> _handleSignIn() async {
    if (_currentUser != null) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _signInService.handleSignIn();

      email = _currentUser?.email ?? '';

      print('el email es...:$email');
      final isRegistered = await _signInService.checkIfRegistered(email);

      if (!isRegistered) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return RegisterGoogleScreen(
              onRegistrationComplete: () async {
                setState(() {
                  _isAuthorized = true;
                });
                Navigator.of(context).pop();
              },
              currentUser: _currentUser,
            );
          },
        );
      } else {
        final statusCode = await _signInService.logIn(email);
        _handleLoginResponse(statusCode);
      }
    } catch (e) {
      _showError('Error during sign-in: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleLoginResponse(int statusCode) {
    if (statusCode == 201 || statusCode == 200) {
      Get.snackbar('Success', 'Login successful',
          snackPosition: SnackPosition.BOTTOM);
      Get.toNamed('/properties');
    } else if (statusCode == 400) {
      _showError('Incorrect credentials. Please try again.');
    } else if (statusCode == 500) {
      _showError('Server error. Please try later.');
    } else {
      _showError('Unknown error. Contact support.');
    }
  }

  Future<void> _handleSignOut() async {
    await _signInService.handleSignOut();
    // Get.toNamed('/');
  }

  void _showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Text(
          'Google sign in.',
          style: TextStyle(color: Colors.black),
        ),
        buildSignInButton(
          onPressed: _handleSignIn,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Fondo de pantalla
          /* Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ), */
          // Contenido de la pantalla
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo de Inmoworld
              Image.asset(
                'assets/logo.png',
                height: 200,
                width: 200,
              ),
              Container(
                margin: const EdgeInsets.all(
                  20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
                    Get.toNamed('/logearse');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, // Cambia el color del botón a salmón
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 26, // Ajusta el tamaño del texto aquí
                      color: Color.fromARGB(
                          255, 21, 9, 9), // Cambia el color del texto a blanco
                    ),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(
                      text: "No tienes cuenta? ",
                    ),
                    TextSpan(
                      text: "Registrarse",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration
                            .underline, // Subraya el texto "Sign up"
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed('/register');
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildBody(),
            ],
          ),
        ],
      ),
    );
  }
}
