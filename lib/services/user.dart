import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inmoworld_web/models/userModel.dart';
import 'package:inmoworld_web/models/propertyModel.dart';

class UserService {
   final String baseUrl = "http://127.0.0.1:3001"; // URL de tu backend Web
  //final String baseUrl = "http://10.0.2.2:3001"; // URL de tu backend Android
  final Dio dio = Dio();
  final GetStorage box = GetStorage();

  UserService() {
    // Configurar Interceptor para manejar tokens
    _configureInterceptors();
  }

  // Configurar Interceptores
  void _configureInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = getToken();
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        handler.next(options);
      },
      onError: (DioError e, handler) {
        print('Error en petición: ${e.response?.statusCode}');
        handler.next(e); // Pasar el error al flujo siguiente
      },
    ));
  }

  Future<List<UserModel>> getUsers() async {
  print('Fetching all users...');
  try {
    // Realizar la solicitud GET al endpoint `/user`
    final response = await dio.get('$baseUrl/user');

    // Validar la respuesta
    final statusCode = _validateResponse(response);
    if (statusCode == -1) {
      throw Exception('Error en la respuesta del servidor');
    }

    // Convertir los datos recibidos a una lista de UserModel
    final List<dynamic> responseData = response.data; // JSON como lista
    final List<UserModel> users = responseData
        .map((data) => UserModel.fromJson(data))
        .toList();

    print('Usuarios obtenidos: ${users.length}');
    return users;
  } catch (e) {
    print('Error en getUsers: $e');
    rethrow; // Relanzar el error para manejarlo en el llamador
  }
}

  // Guardar datos de sesión
  void saveToken(String token) => box.write('token', token);
  void saveId(String id) => box.write('_id', id);
  void saveAdmin(bool isAdmin) => box.write('isAdmin', isAdmin);

  // Obtener datos de sesión
  String? getToken() => box.read('token');
  String? getId() => box.read('_id');
  bool get isAdmin => box.read('isAdmin') ?? false;

  // Eliminar datos de sesión
  void logout() {
    box.erase(); // Limpia todos los datos almacenados
  }

  // Validar y manejar respuesta
  int _validateResponse(Response response) {
    final statusCode = response.statusCode ?? -1;
    if (statusCode >= 200 && statusCode < 300) {
      return statusCode;
    } else {
      print('Error en respuesta: ${response.statusCode}');
      return -1;
    }
  }

  // Crear Usuario
  Future<int> createUser(UserModel newUser) async {
    try {
      final response = await dio.post('$baseUrl/user/register', data: newUser.toJson());
      return _validateResponse(response);
    } catch (e) {
      print('Error en createUser: $e');
      return -1;
    }
  }

  // Actualizar Usuario
  Future<int> updateUser(UserModel user) async {
    try {
      final response = await dio.put('$baseUrl/user/${user.id}', data: user.toJson());
      return _validateResponse(response);
    } catch (e) {
      print('Error en updateUser: $e');
      return -1;
    }
  }

  // Obtener Usuario Actual
  Future<UserModel> getUser() async {
    try {
      final response = await dio.get('$baseUrl/user/${getId()}');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error en getUser: $e');
      rethrow; // Propaga el error
    }
  }

  // Obtener Otro Usuario por ID
  /* Future<UserModel> getAnotherUser(String id) async {
    try {
      final response = await dio.get('$baseUrl/user/$id');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error en getAnotherUser: $e');
      rethrow;
    }
  } */

  // Obtener Lista de Propiedades
  Future<List<PropertyModel>> getData() async {
    try {
      final response = await dio.get('$baseUrl/property');
      return (response.data as List)
          .map((data) => PropertyModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Error en getData: $e');
      rethrow;
    }
  }

  // Login
  Future<int> logIn(Map<String, dynamic> logInData) async {
    try {
      final response = await dio.post('$baseUrl/auth/signin', data: logInData);
      final statusCode = _validateResponse(response);

      if (statusCode == 201) {
        // Guardar sesión si el login es exitoso
        saveToken(response.data['token']);
        saveId(response.data['user']['id']);
        saveAdmin(response.data['user']['isAdmin']);
      }

      return statusCode;
    } catch (e) {
      print('Error en logIn: $e');
      return -1;
    }
  }

  // Eliminar Usuario Actual
  Future<int> deleteUser() async {
    try {
      final response = await dio.delete('$baseUrl/user/${getId()}');
      final statusCode = _validateResponse(response);

      if (statusCode == 201) {
        logout(); // Limpiar sesión tras eliminar usuario
      }

      return statusCode;
    } catch (e) {
      print('Error en deleteUser: $e');
      return -1;
    }
  }
}