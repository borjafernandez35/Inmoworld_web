import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/models/userModel.dart';
import 'package:inmoworld_web/models/propertyModel.dart';

class UserService extends ChangeNotifier {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend Web
  final Dio dio = Dio();
  int totalPages = 1;
  int totalUsers = 1;
  final List<UserModel> _usersList = [];

  UserService() {
    // Configurar Interceptor para manejar tokens
    _configureInterceptors();
  }

  List<UserModel> getUsersList(){
    return _usersList;
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
  
  // Método para agregar o actualizar usuarios en la lista
  void addOrUpdateUser(UserModel user) {
    final index = _usersList.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _usersList[index] = user;
    } else {
      _usersList.add(user);
    }
    notifyListeners(); // Notifica a los listeners sobre los cambios
  }

  Future<List<UserModel>> getUsers(int page, int limit) async {
    print('Fetching all users...');
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

      // Almacenar los valores adicionales como totalPages y totalUsers
      totalPages = responseData['totalPages'] ?? 1;
      totalUsers = responseData['totalUsers'] ?? 1;

      // Convertir los datos recibidos a una lista de UserModel
      final List<UserModel> users =
          usersData.map((data) => UserModel.fromJson(data)).toList();
      print('Usuarios obtenidos: ${users.length}');
      
      // Actualizar la lista interna y notificar cambios
      _usersList.clear();
      _usersList.addAll(users);
      print("Lista de usuarios: $_usersList");
      StorageService.saveUserList(_usersList);
      notifyListeners();
      return users;
    } catch (e) {
      print('Error en getUsers: $e');
      rethrow; // Relanzar el error para manejarlo en el llamador
    }
  }

  void logout() {
    // StorageService.clearSession(); // Limpia todos los datos almacenados
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
    try {
      final response = await dio.get('$baseUrl/user/${StorageService.getId()}');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error en getUser: $e');
      rethrow; // Propaga el error
    }
  }

  // Obtener Otro Usuario por ID
  Future<UserModel> getAnotherUser(String userId) async {
    try {
      final response = await dio.get('$baseUrl/user/$userId');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error en getAnotherUser: $e');
      rethrow; // Propaga el error
    }
  }

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

  Future<List<PropertyModel>> getProperties(int page, int limit) async {
    try {
      print('Intentando obtener propiedades para la página $page con límite $limit...');
      final response = await dio.get('$baseUrl/property/$page/$limit');
      print('Respuesta recibida: ${response.data}');

      if (response.data == null || response.data['properties'] == null) {
        throw Exception("Datos de propiedades no encontrados en la respuesta.");
      }

      final List<dynamic> propertiesData = response.data['properties'] as List<dynamic>;

      return propertiesData.map((data) => PropertyModel.fromJson(data)).toList();
    } catch (e, stackTrace) {
      print('Error al obtener propiedades: $e');
      print('Detalles del error: $stackTrace');
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
