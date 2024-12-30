import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/models/property_model.dart';
import 'package:inmoworld_web/services/property.dart';

// Controlador separado para manejar la lógica de propiedades
class PropertyController extends GetxController {
  final PropertyService _propertyService = PropertyService();
  final RxList<PropertyModel> properties = <PropertyModel>[].obs;
  final RxList<PropertyModel> mapProperties = <PropertyModel>[].obs;
  final RxBool isLoading = false.obs;

  /// Obtener lista de propiedades (listado general)
  Future<void> fetchProperties({
    required int page,
    required int limit,
    required double distance,
    required String sort,
  }) async {
    isLoading.value = true;
    try {
     Position  position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _propertyService.updateLocation(position);
       final fetchedProperties = await _propertyService.getProperties(
        page,
        limit,
        distance,
        sort.isEmpty ? '' : sort, // Pasar cadena vacía si no hay búsqueda
      );
      properties.assignAll(fetchedProperties);
    } catch (e) {
      print('Error al obtener propiedades: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener propiedades para marcadores en el mapa
  Future<void> fetchMapProperties({
    required double distance,
    required int page,
    required int limit,
    required String search,
  }) async {
    isLoading.value = true;
    try {
     Position  position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _propertyService.updateLocation(position);
      final fetchedMapProperties = await _propertyService.getMapProperties(
          distance, page, limit, search);
      mapProperties.assignAll(fetchedMapProperties);
    } catch (e) {
      print('Error al obtener propiedades para el mapa: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProperty(PropertyModel property) async {
    try {
      print('ESTOY EN EL CREATE PORPERTYYYYYYYYYYY$property');
      await _propertyService.createProperty(property);
      properties.add(property);
    } catch (e) {
      print('Error creating property: $e');
    }
  }

  Future<void> updateProperty(PropertyModel property) async {
    try {
      await _propertyService.updateProperty(property);
      int index = properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        properties[index] = property;
      }
    } catch (e) {
      print('Error updating property: $e');
    }
  }
}
