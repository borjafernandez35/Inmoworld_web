import 'package:flutter/material.dart';
import 'package:inmoworld_web/models/userModel.dart';

class PropertyModel with ChangeNotifier {
  final String? _id; 
  final String owner;
  final String address;
  final String description;
  final String? picture;

  UserModel? ownerDetails; // Detalles del propietario
  List<UserModel>? participantsDetails;

  // Constructor
  PropertyModel({
    String? id,
    required this.owner,
    required this.address,
    required this.description,
    this.picture,
    this.ownerDetails,
    this.participantsDetails,
  }) : _id = id;


  // Método para crear una instancia desde un JSON
 factory PropertyModel.fromJson(Map<String, dynamic> json) {
  try {
    return PropertyModel(
      id: json['_id'],
      owner: json['owner'] ?? 'Sin Propietario',
      address: json['address'] ?? 'Sin Dirección',
      description: json['description'] ?? 'Sin Descripción',
      picture: (json['picture'] is List && json['picture'].isNotEmpty)
          ? json['picture'][0]
          : null,
    );
  } catch (e) {
    throw Exception('Error al procesar propiedad: $json');
  }
}
  String? get id => _id;


  // Helper function to validate ObjectId
  /* static String _validateObjectId(dynamic id) {
    if (id is String && id.isNotEmpty) {
      return id;
    }
    print("Invalid ObjectId: $id");
    return ''; // Return an empty string if id is invalid
  } */

  // Método para convertir el modelo en JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'owner': owner, // Solo el ID
      'address': address,
      'description': description,
      'picture': picture,
    };
  }

  /* Future<void> loadDetails(List<PropertyModel> experiences) async {
    final userService = UserService();

    try {
      // Obtener solo los IDs de los usuarios
      final usersId = await userService.getUsersId();

      if (usersId.isEmpty) {
        print("No se encontraron usuarios.");
        return;
      }

      print('GET IDs: $usersId');

      for (var experience in experiences) {
        print('Procesando experiencia ID: ${experience.id}');

        // Validar y cargar el propietario
        if (usersId.contains(experience.owner)) {
          final ownerDetails = await userService.getUser(experience.owner);
          experience.ownerDetails = ownerDetails;
          print(
              'Detalles del propietario cargados: ${ownerDetails.name} para experiencia ${experience.id}');
                } else {
          print(
              'El propietario con ID ${experience.owner} no está en la lista de usuarios.');
        }

        // Validar y cargar los detalles de los participantes
         experience.participantsDetails = await Future.wait(
        experience.participants.map((participantId) async {
          if (usersId.contains(participantId)) {
            return await userService.getUser(participantId);
          }
          return null; // Ignorar IDs de participantes no válidos
        }),
      ).then((list) => list.whereType<UserModel>().toList());

        print(
            'Detalles de participantes cargados para experiencia ${experience.id}: '
            '${experience.participantsDetails?.map((e) => e.name).toList()}');
      }

      // Notificar cambios
      notifyListeners();
    } catch (e) {
      print("Error al cargar detalles de las experiencias: $e");
    }
  } */
}