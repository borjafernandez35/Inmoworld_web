import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inmoworld_web/models/property_model.dart';
import 'package:inmoworld_web/controllers/reviewController.dart';
import 'package:inmoworld_web/controllers/user_model_controller.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/models/review_model.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/widgets/review_card.dart';
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
  final reviewController = Get.put(ReviewController());
  final userController = Get.find<UserModelController>();

  @override
  void initState() {
    super.initState();
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
    }

  Future<void> _showCreateReviewDialog(String propertyId) async {
    final TextEditingController _descriptionController = TextEditingController();
    final TextEditingController _ratingController = TextEditingController();
    

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.current.AgregarResena),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: S.current.Descripcion),
              ),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: S.current.Rating),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.current.Cancelar),
            ),
            TextButton(
              onPressed: () async {
                final newReview = ReviewModel(
                  id: '',
                  owner: StorageService.getId(),
                  property: propertyId,
                  date: DateTime.now(),
                  rating: double.parse(_ratingController.text),
                  description: _descriptionController.text,
                );
                await reviewController.createReview(newReview);
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text(S.current.Anadir),
            ),
          ],
        );
      },
    );
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.property.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image, size: 50)),
                ),
              ),
            ),
          )
        else
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
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
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}