import 'package:flutter/material.dart';
import 'package:inmoworld_web/models/userModel.dart';
import 'package:inmoworld_web/services/user.dart';

class ReviewModel with ChangeNotifier {
  final String id;
  final String owner;
  final String property;
  final DateTime date;
  final double rating;
  String description;

  UserModel? ownerDetails; // Detalles del propietario

  // Constructor
  ReviewModel({
    required this.id,
    required this.owner,
    required this.property,
    required this.date,
    required this.rating,
    required this.description,
    this.ownerDetails,
  });

  // Método para crear una instancia desde un JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _validateObjectId(json['_id']),
      owner: _validateObjectId(json['user']),
      property: _validateObjectId(json['property']),
      date: DateTime.parse(json['date']),
      rating: (json['rating'] as num).toDouble(),
      description: json['description']?.toString() ?? 'Sin descripción',
    );
  }

  // Helper function to validate ObjectId
  static String _validateObjectId(dynamic id) {
    if (id is String && id.isNotEmpty) {
      return id;
    }
    print("Invalid ObjectId: $id");
    return ''; // Return an empty string if id is invalid
  }

  // Método para convertir el modelo en JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': owner, // Solo el ID
      'property': property, // Solo el ID de la propiedad
      'date': date.toIso8601String(),
      'rating': rating,
      'description': description,
    };
  }

  // Método para cargar los detalles del propietario
  Future<void> loadDetails() async {
    final userService = UserService();

    try {
      // Obtener detalles del propietario utilizando getUser
      final ownerDetails = await userService.getUser();
      if (ownerDetails != null) {
        this.ownerDetails = ownerDetails;
        print('Detalles del propietario cargados: ${ownerDetails.name}');
      } else {
        print('Propietario no encontrado: $owner');
      }

      // Notificar cambios
      notifyListeners();
    } catch (e) {
      print("Error al cargar detalles de la reseña: $e");
    }
  }
}

