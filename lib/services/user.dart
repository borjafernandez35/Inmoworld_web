import 'package:dio/dio.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/models/userModel.dart';
import 'package:inmoworld_web/models/propertyModel.dart';

class UserService {
  //final String baseUrl = "http://127.0.0.1:3001"; // URL de tu backend Web
  final String baseUrl = 'http://147.83.7.157:3000';
  //final String baseUrl = "http://10.0.2.2:3001"; // URL de tu backend Android
  final Dio dio = Dio();
  //final GetStorage box = GetStorage();
  int totalPages = 1;
  int totalUsers = 1;

  UserService() {
    // Configurar Interceptor para manejar tokens
    _configureInterceptors();
  }

  // Configurar Interceptores
  void _configureInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = StorageService.getToken();
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        handler.next(options);
      },
      onError: (DioException e, handler) {
        print('Error en petición: ${e.response?.statusCode}');
        handler.next(e); // Pasar el error al flujo siguiente
      },
    ));
  }

  Future<List<UserModel>> getUsers(int page, int limit) async {
    print('Fetching all users...');
    //_configureInterceptors();
    try {
      // Realizar la solicitud GET al endpoint `/user`
      final response = await dio.get('$baseUrl/user/$page/$limit');

      // Validar la respuesta
      final statusCode = _validateResponse(response);
      if (statusCode == -1) {
        throw Exception('Error en la respuesta del servidor');
      }

// Asegurarse de que response.data sea un Map y no una lista
      final Map<String, dynamic> responseData = response.data;

      // Extraer la lista de usuarios
      final List<dynamic> usersData = responseData['users'];

      print('aquiii etnras???:$usersData');
      // Almacenar los valores adicionales como totalPages y totalUsers
      totalPages = responseData['totalPages'] ?? 1; // Usar 0 si es null
      totalUsers = responseData['totalUsers'] ?? 1; // Usar 0 si es null

      // Convertir los datos recibidos a una lista de UserModel
      final List<UserModel> users =
          usersData.map((data) => UserModel.fromJson(data)).toList();
      print('los usuarios son:$users');

      print('Usuarios obtenidos: ${users.length}');
      print('los total users son:$totalUsers,y las paginas son:$totalPages');
      return users;
    } catch (e) {
      print('Error en getUsers: $e');
      rethrow; // Relanzar el error para manejarlo en el llamador
    }
  }

  void logout() {
    StorageService.clearSession(); // Limpia todos los datos almacenados
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
      final response =
          await dio.post('$baseUrl/user/register', data: newUser.toJson());
      return _validateResponse(response);
    } catch (e) {
      print('Error en createUser: $e');
      return -1;
    }
  }

  // Actualizar Usuario
  Future<int> updateUser(UserModel user) async {
    try {
      final response =
          await dio.put('$baseUrl/user/${user.id}', data: user.toJson());
      return _validateResponse(response);
    } catch (e) {
      print('Error en updateUser: $e');
      return -1;
    }
  }

  // Obtener Usuario Actual
  Future<UserModel> getUser() async {
    print('GETTTTTUSEEERRRR!!!! me llamaaaaannnn!!!');
    try {
      final response = await dio.get('$baseUrl/user/${StorageService.getId()}');
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
        StorageService.saveToken(response.data['token']);
        StorageService.saveId(response.data['user']['id']);
        StorageService.saveAdmin(response.data['user']['isAdmin']);
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
      final response =
          await dio.delete('$baseUrl/user/${StorageService.getId()}');
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
