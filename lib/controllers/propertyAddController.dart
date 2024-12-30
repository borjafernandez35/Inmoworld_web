import 'package:get/get.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:inmoworld_web/controllers/propertyController.dart';

class PropertyAddController extends GetxController {
  final PropertyController propertyController =
      Get.put(PropertyController()); // Vinculado al controlador principal
  final RxBool isLoading = false.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  /// Agregar una nueva propiedad
  Future<void> addNewProperty({
    required String description,
    required double price,
    required LatLng location,
     String? imageUrl, // Se incluye imageUrl
  }) async {
    isLoading.value = true;

    final newProperty = PropertyModel(
      id: '', // El ID se generará en el backend
      owner: StorageService.getId(), // Obtener el ID del usuario actual si es necesario
      description: description,
      price: price,
      location: location,
       imageUrl: imageUrl,
    );

    try {
      // Crear la propiedad utilizando el controlador principal
      await propertyController.createProperty(newProperty);

      // Actualizar marcadores del mapa
      markers.add(
        Marker(
          markerId: MarkerId(newProperty.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: description,
            snippet: '\$${price.toStringAsFixed(2)}',
          ),
        ),
      );
    } catch (e) {
      print('Error al agregar nueva propiedad: $e');
      throw Exception('No se pudo agregar la propiedad.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar propiedades y marcarlas en el mapa
  Future<void> loadPropertiesOnMap({
    required double distance,
    required int page,
    required int limit,
    required String search,
  }) async {
    isLoading.value = true;

    try {
      // Obtener propiedades desde el controlador principal
      await propertyController.fetchMapProperties(
        distance: distance,
        page: page,
        limit: limit,
        search: search,
      );

      // Actualizar marcadores
      markers.clear();
      for (var property in propertyController.mapProperties) {
        if (property.location != null) {
          markers.add(
            Marker(
              markerId: MarkerId(property.id),
              position: LatLng(
                  property.location.latitude, property.location.longitude),
              infoWindow: InfoWindow(
                title: property.description,
                snippet: '\$${property.price.toStringAsFixed(2)}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al cargar propiedades para el mapa: $e');
       throw Exception('No se pudieron cargar las propiedades en el mapa.');
    } finally {
      isLoading.value = false;
    }
  }
}
