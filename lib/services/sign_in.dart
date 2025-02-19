import 'dart:async';
import 'dart:convert' show base64Url;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:inmoworld_web/src/jwt.dart' as jwt;
import 'dart:math';
import 'package:google_identity_services_web/oauth2.dart';

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

String generateState() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
}

String? storedState;

class SignInService {
  final GoogleSignIn _googleSignIn;
  late final IdConfiguration idConfiguration;
  final Dio dio = Dio();
  //final String baseUrl = 'http://127.0.0.1:3000';
  final String baseUrl = 'http://147.83.7.157:3000';
  

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';
  String _token = '';
  bool _isRegistered = false;
   String idClient =
      '103614501225-t83dvlcomsl5j8h2d10grk4o4sgu6ijl.apps.googleusercontent.com'; 

  /* String idClient =
      '737041156442-u7cs8eqagg04f48tj4jhn1q3t6scruvg.apps.googleusercontent.com'; */ 

  SignInService({required String clientId})
      : _googleSignIn = GoogleSignIn(
          clientId: clientId,
          scopes: scopes,
        ) {
    idConfiguration = IdConfiguration(
      client_id: clientId,
      callback: (onCredentialResponse),
      use_fedcm_for_prompt: false,
    );
  }

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  String get contactText => _contactText;
  String get token => _token;
  bool get isRegistered => _isRegistered;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<void> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();

      if (_currentUser != null) {
        _isAuthorized = true;
      }
    } catch (e) {
      print("Error in signInSilently: $e");
    }
  }

  Future<void> onError(GoogleIdentityServicesError? error) async {
    print('Error! ${error?.type} (${error?.message})');
  }

  Future<void> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      print('el usuario es:$_currentUser');
      if (_currentUser != null) {
        _isAuthorized = true;
      }
    } catch (e) {
      print("Error in signIn: $e");
    }
  }

  Future<void> handleSignIn() async {
    try {
      print('estoy en el handlesignin del service!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      if (kIsWeb) {
        id.setLogLevel('debug');
        id.initialize(idConfiguration);
        print('voy a por el promptmomentWWWWWWWWWWWWWWWWWWW');

        id.prompt(onPromptMoment);

        final state = generateState();
        storedState = state;
      } else {
        await signIn();
      }
    } catch (error) {
      print("Error in handleSignIn: $error");
    }
  }

  void onPromptMoment(PromptMomentNotification o) {
    final MomentType type = o.getMomentType();
    print("Prompt moment: $type");
  }

  Future<void> handleSignOut() async => await _googleSignIn.disconnect();

  void onCredentialResponse(CredentialResponse response) {
    final Map<String, dynamic>? payload =
        jwt.decodePayload(response.credential);
    if (payload != null) {
    } else {
      print('Could not decode ${response.credential}');
    }
  }

  Future<bool> checkIfRegistered(String email) async {
    print('esto en checkemail y el correo es:$email');

    try {
      final response = await dio.get('$baseUrl/user/check/email/$email');

      print('la respuesta es...:$response');

      if (response.statusCode == 200) {
        // Parsea la respuesta como un objeto JSON
        final dynamic responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('isEmailRegistered')) {
            final bool isRegistered = responseData['isEmailRegistered'];
            return isRegistered;
          } else {
            throw Exception(
                'Datos de respuesta inválidos: falta "isEmailRegistered"');
          }
        } else {
          throw Exception('Datos de respuesta inválidos');
        }
      } else {
        throw Exception(
            'No se pudo verificar el estado de registro: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al verificar el estado de registro: $e');
      rethrow;
    }
  }

  Future<int> logIn(String email) async {
    try {
      Response response =
          await dio.post('$baseUrl/auth/signin/google', data: {'email': email});

      print('estoy en el login de google el response es:$response');

      var data = response.data;
      var statusCode = response.statusCode;

      print('los datos son:$data');

      print('statusCode es:$statusCode');

      if (statusCode == 200 || statusCode == 201) {
        StorageService.saveToken(response.data['token']);
        StorageService.saveId(response.data['user']['id']);
        StorageService.saveAdmin(response.data['user']['isAdmin']);

        if (statusCode == 201) {
          return 201;
        }
        return 200;
      }
      if (statusCode == 400) {
        print('400');
        return 400;
      } else if (statusCode == 500) {
        print('500');
        return 500;
      } else {
        return -1;
      }
    } on DioError catch (e) {
      if (e.response != null) {
        print('Error en la solicitud: ${e.response?.statusCode}');
        print('Datos de respuesta: ${e.response?.data}');
        print('Encabezados de respuesta: ${e.response?.headers}');
        return e.response?.statusCode ?? -2;
      } else {
        print('Error enviando la solicitud: ${e.message}');
        return -3;
      }
    }
  }
}
