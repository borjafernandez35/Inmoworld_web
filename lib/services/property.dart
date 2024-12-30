import 'package:dio/dio.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/models/user_model.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:geolocator/geolocator.dart';

class PropertyService {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend Web
  //final String baseUrl = 'http://147.83.7.157:3000';
  //final String baseUrl = "http://10.0.2.2:3001"; // URL de tu backend Android
  final Dio dio = Dio();
  //final GetStorage box = GetStorage();
  int totalPages = 1;
  int totalUsers = 1;

  PropertyService() {
    // Configurar Interceptor para manejar tokens
    _configureInterceptors();
  }

  // Configurar Interceptores
  void _configureInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = StorageService.getToken();
        options.headers['x-access-token'] = token;
              handler.next(options);
      },
      onError: (DioException e, handler) {
        print('Error en petición: ${e.response?.statusCode}');
        handler.next(e); // Pasar el error al flujo siguiente
      },
    ));
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
  Future<int> createProperty(PropertyModel newProperty) async {
    try {
      final response =
          await dio.post('$baseUrl/property/new', data: newProperty.toJson());
      print('que le pasa!!!!$response');
      print('LAAASSSSS PROPIEDADES SON.........${response.data}');
      return _validateResponse(response);
    } catch (e) {
      print('Error en createProperty: $e');
      return -1;
    }
  }

  // Actualizar Usuario
  Future<int> updateProperty(PropertyModel property) async {
    try {
      final response = await dio.put('$baseUrl/property/${property.id}',
          data: property.toJson());
      return _validateResponse(response);
    } catch (e) {
      print('Error en updateUser: $e');
      return -1;
    }
  }

  Future<int> updateLocation(Position? location) async {
   

    final json ={
      'location': {
        'type': 'Point',
        'coordinates': [location!.longitude, location.latitude],
      }
    };
    Response response =await dio.put('$baseUrl/user/${StorageService.getId()}', data: json);
   var  data = response.data.toString();
    var statusCode = response.statusCode;
    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      print('201');
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    } else {
      // Otro caso no manejado
      print('-1');

      return -1;
    }
  }

   Future<int?> updateUserLocation(String userId, double latitude, double longitude) async {
  

  final data = {
    'latitude': latitude,
    'longitude': longitude,
  };

  try {
    Response response = await dio.put('$baseUrl/user/location/$userId', data: data);
    var statusCode = response.statusCode;
    return statusCode;
  } catch (e) {
    print('Error updating user location: $e');
    return -1;
  }
}

  Future<List<PropertyModel>> getProperties(
      int page, int limit, double selectedDistance, String sort) async {
    try {
      print(
          'Intentando obtener propiedades para la página $page con límite $limit...');
          print('los parametros pasados para la funcion son, page.$page,limit:$limit, distance:$selectedDistance, sort:$sort');
      final response = await dio
          .get('$baseUrl/property/$page/$limit/$selectedDistance/$sort');
      print('Respuesta recibida: ${response.data}');

      if (response.data == null || response.data['properties'] == null) {
        throw Exception("Datos de propiedades no encontrados en la respuesta.");
      }

      final List<dynamic> propertiesData =
          response.data['properties'] as List<dynamic>;

      print('Datos de propiedades procesados correctamente: $propertiesData');
      return propertiesData
          .map((data) => PropertyModel.fromJson(data))
          .toList();
    } catch (e, stackTrace) {
      print('Error al obtener propiedades: $e');
      print('Detalles del error: $stackTrace');
      rethrow; // Vuelve a lanzar el error para que pueda manejarse en otro nivel
    }
  }

  Future<List<PropertyModel>> getMapProperties(
      double selectedDistance, int page, int limit, String search) async {
    try {
      print(
          'Intentando obtener propiedades para la página de map properties $page con límite $limit...');
          print('estoy pasando por paramentros, page:$page, limit:$limit, id:${StorageService.getId()}, distance:$selectedDistance, search:$search');
      final response = await dio.get(
          '$baseUrl/property/by/name/$page/$limit/${StorageService.getId()}/$selectedDistance/$search');
      print('Respuesta recibida: ${response.data}');

      if (response.data == null || response.data['properties'] == null) {
        throw Exception("Datos de propiedades no encontrados en la respuesta.");
      }

      final List<dynamic> propertiesData =
          response.data['properties'] as List<dynamic>;

      print('Datos de propiedades procesados correctamente: $propertiesData');
      return propertiesData
          .map((data) => PropertyModel.fromJson(data))
          .toList();
    } catch (e, stackTrace) {
      print('Error al obtener propiedades: $e');
      print('Detalles del error: $stackTrace');
      rethrow; // Vuelve a lanzar el error para que pueda manejarse en otro nivel
    }
  }

  // Login

  // Eliminar Usuario Actual
  Future<int> deleteProperty() async {
    try {
      final response =
          await dio.delete('$baseUrl/user/${StorageService.getId()}');
      final statusCode = _validateResponse(response);

      if (statusCode == 201) {}

      return statusCode;
    } catch (e) {
      print('Error en deleteUser: $e');
      return -1;
    }
  }
}
