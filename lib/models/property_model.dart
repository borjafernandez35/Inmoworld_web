import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importa LatLng

class PropertyModel {
  final String id;
  final String owner;
  final String description;
  final double price;
  final LatLng location; // Usa LatLng en lugar de GeoCoord
  final String? imageUrl;

  PropertyModel({
      required this.id,
    required this.owner,
    required this.price,
    required this.description,
    required this.location,
    this.imageUrl,
  });

  // Método para crear una instancia desde un JSON
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['_id'] ?? 'Sin ID',
      owner: json['owner'] ?? 'No hay propietario',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? 'Sin descripción',
      imageUrl: (json['imageUrl'] is List && json['imageUrl'].isNotEmpty)
          ? json['imageUrl'][0]
          : null,
      location: LatLng(
        json['location']['coordinates'][1], // Latitud
        json['location']['coordinates'][0], // Longitud
      ),
      
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'owner': owner,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'location': {
        'type': 'Point',
        'coordinates': [location.longitude, location.latitude], // LatLng usa longitude y latitude
      },
    };
  }
}
