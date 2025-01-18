import 'package:dio/dio.dart';
import 'package:inmoworld_web/models/reviewModel.dart';
import 'package:inmoworld_web/services/storage.dart';

class ReviewService {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend Web
  final Dio dio = Dio();
  int totalReviews = 1;

  ReviewService() {
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
      onError: (DioError e, handler) {
        print('Error en petición: ${e.response?.statusCode}');
        handler.next(e); // Pasar el error al flujo siguiente
      },
    ));
  }

    // Obtener todas las reseñas
    Future<List<ReviewModel>> getReviews() async {
    try {
      final response = await dio.get('$baseUrl/reviews/');
      // Validar la respuesta
      final statusCode = _validateResponse(response);
      if (statusCode == -1) {
        throw Exception('Error en la respuesta del servidor');
      }

      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> reviewsData = responseData['reviews'];

      // Almacenar el total de reseñas
      totalReviews = responseData['totalReview'] ?? 1;

      // Convertir los datos recibidos a una lista de ReviewModel
      return reviewsData.map((data) => ReviewModel.fromJson(data)).toList();
    } catch (e) {
      print('Error en getReviews: $e');
      rethrow; // Relanzar el error para manejarlo en el llamador
    }
  }


  // Obtener una reseña por ID
  Future<ReviewModel> getReview(String id) async {
    try {
      final response = await dio.get('$baseUrl/reviews/$id');
      return ReviewModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error en getReview: $e');
      rethrow;
    }
  }

  // Crear una nueva reseña
  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      final response = await dio.post('$baseUrl/reviews',
          options: Options(headers: {
            "Content-Type": "application/json",
            "x-access-token": StorageService.getToken()
          }),
          data: review.toJson());
      return ReviewModel.fromJson(response.data['review']);
    } catch (e) {
      print('Error en createReview: $e');
      rethrow;
    }
  }

  // Actualizar una reseña
  Future<ReviewModel> updateReview(String id, ReviewModel review) async {
    try {
      final response = await dio.put('$baseUrl/reviews/$id',
          options: Options(headers: {
            "Content-Type": "application/json",
            "x-access-token": StorageService.getToken()
          }),
          data: review.toJson());
      return ReviewModel.fromJson(response.data['data']);
    } catch (e) {
      print('Error en updateReview: $e');
      rethrow;
    }
  }

  // Eliminar una reseña
  Future<void> deleteReview(String id) async {
    try {
      final response = await dio.delete('$baseUrl/reviews/$id', options: Options(
        headers: {"x-access-token": StorageService.getToken()},
      ));
      _validateResponse(response);
    } catch (e) {
      print('Error en deleteReview: $e');
      rethrow;
    }
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
}
