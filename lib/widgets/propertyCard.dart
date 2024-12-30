import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:http/http.dart' as http;

class PropertyCard extends StatefulWidget {
  final PropertyModel property;

  const PropertyCard({required this.property, Key? key}) : super(key: key);

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  String? _address; // Dirección obtenida a partir de las coordenadas
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    if (widget.property.location != null) {
      final latitude = widget.property.location.latitude;
      final longitude = widget.property.location.longitude;

      // Validar si las coordenadas son válidas
      if (latitude != 0.0 && longitude != 0.0) {
        _fetchAddress(longitude, latitude);
      } else {
        setState(() {
          _address = 'Coordenadas no válidas';
        });
      }
    } else {
      setState(() {
        _address = 'Ubicación no disponible';
      });
    }
  }

  Future<void> _fetchAddress(double longitude, double latitude) async {
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      setState(() {
        _address = 'Coordenadas inválidas';
        _isLoadingAddress = false;
      });
      return;
    }
    setState(() {
      _isLoadingAddress = true;
    });

    const apiKey =
        'AIzaSyDr6kIiCCTq-jp2JeIzaxDpJgtQBlaUPYI'; // Reemplaza con tu clave API de Google
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];
          setState(() {
            _address = address;
          });
        } else {
          setState(() {
            _address = 'Dirección no encontrada';
          });
        }
      } else {
        setState(() {
          _address = 'Error al obtener dirección: ${response.reasonPhrase}';
        });
      }
    } catch (e, stackTrace) {
      print(
          'Error al obtener dirección para: Latitude=$latitude, Longitude=$longitude');
      print('Detalles del error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _address = 'Error al obtener dirección';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.property.imageUrl != null &&
              widget.property.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                widget.property.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
              ),
            )
          else
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.description,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.property.price.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.green),
                ),
                const SizedBox(height: 8),
                if (widget.property.location != null)
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[300]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _isLoadingAddress
                            ? const Text('Cargando dirección...')
                            : Text(
                                _address ?? 'No disponible',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.location_off, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Ubicación no disponible',
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
