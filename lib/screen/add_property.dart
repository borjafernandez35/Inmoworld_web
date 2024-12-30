import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:inmoworld_web/controllers/propertyController.dart';
import 'package:inmoworld_web/services/storage.dart';

class PropertyAddScreen extends StatefulWidget {
  final LatLng defaultLocation;

  const PropertyAddScreen({Key? key, required this.defaultLocation})
      : super(key: key);

  @override
  _PropertyAddScreenState createState() => _PropertyAddScreenState();
}

class _PropertyAddScreenState extends State<PropertyAddScreen> {
 GoogleMapController? _controller;
  final PropertyController _propertyController = Get.put(PropertyController());

  @override
  void initState() {
    super.initState();
    _propertyController.fetchProperties(
      page: 1,
      limit: 10,
      distance: 10000,
      sort: '',
    );
  }

  void _addNewProperty(LatLng location) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear nueva propiedad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio'),
              ),
            ],
          ),
          actions: [
           TextButton(
        child: const Text('Cancelar'),
         onPressed: () {
           Navigator.of(context).pop(); // Cierra el diálogo
          Get.toNamed('/map'); // Navega a la ruta '/map'
        },
        ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                final description = descriptionController.text.trim();
                final priceText = priceController.text.trim();
                double? price;

                if (description.isEmpty || priceText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios.'),
                    ),
                  );
                  return;
                }

                try {
                  price = double.parse(priceText);
                  if (price <= 0) throw FormatException();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El precio debe ser un número positivo.'),
                    ),
                  );
                  return;
                }

                final newProperty = PropertyModel(
                  id: '',
                  owner: StorageService.getId(),
                  description: description,
                  price: price,
                  location: LatLng(
                    location.latitude,
                    location.longitude,
                  ),
                );

              try {
                  await _propertyController.createProperty(newProperty); // Espera a que termine la operación
                  Navigator.of(context).pop();
                  Get.toNamed('/map');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear la propiedad: ${e.toString()}'),
                    ),
                  );
                }
                },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Propiedad')),
      body: Stack(
        children: [
          Obx(() => GoogleMap(
                onMapCreated: (controller) => _controller = controller,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.defaultLocation.latitude,
                    widget.defaultLocation.longitude,
                  ),
                  zoom: 14,
                ),
                markers: _propertyController.properties.map((property) {
                  return Marker(
                    markerId: MarkerId(property.id),
                    position: LatLng(
                      property.location.latitude,
                      property.location.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: '${property.description} - \$${property.price}',
                    ),
                  );
                }).toSet(),
                onTap: _addNewProperty,
              )),
          Obx(() => _propertyController.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
