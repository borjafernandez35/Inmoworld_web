import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:inmoworld_web/models/property_model.dart';
import 'package:inmoworld_web/models/user_model.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/services/user.dart';

class DetallesPropiedadScreen extends StatefulWidget {
  final PropertyModel property;

  const DetallesPropiedadScreen({required this.property, Key? key})
      : super(key: key);

  @override
  State<DetallesPropiedadScreen> createState() =>
      _DetallesPropiedadScreenState();
}

class _DetallesPropiedadScreenState extends State<DetallesPropiedadScreen> {
  String? _address;
  bool _isLoadingAddress = false;

  String? _ownerName; // Nombre del propietario
  bool _isLoadingOwner = false; // Estado de carga del propietario

  final UserService _userService = UserService(); // Instancia del servicio

  @override
  void initState() {
    super.initState();

    final latitude = widget.property.location.latitude;
    final longitude = widget.property.location.longitude;

    // Cargar la dirección si las coordenadas son válidas
    if (latitude != 0.0 && longitude != 0.0) {
      _fetchAddress(longitude, latitude);
    } else {
      setState(() {
        _address = 'Coordenadas no válidas';
      });
    }

    // Cargar el propietario
    if (widget.property.owner != null) {
      _fetchOwner(widget.property.owner!);
    } else {
      setState(() {
        _ownerName = 'Desconocido';
      });
    }
  }

  Future<void> _fetchAddress(double longitude, double latitude) async {
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
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

  Future<void> _fetchOwner(String ownerId) async {
    setState(() {
      _isLoadingOwner = true;
    });

    try {
      final user = await _userService.getUserById(ownerId);
      setState(() {
        _ownerName = user?.name ?? 'Desconocido';
      });
    } catch (e) {
      print('Error al obtener el propietario: $e');
      setState(() {
        _ownerName = 'Error al cargar propietario';
      });
    } finally {
      setState(() {
        _isLoadingOwner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.DetallesPropiedad),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la propiedad
              if (widget.property.imageUrl != null &&
                  widget.property.imageUrl!.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.grey[200], // Fondo para mejor visualización
                      child: Image.network(
                        widget.property.imageUrl!,
                        fit: BoxFit.contain, // Ajusta la imagen completa dentro del contenedor
                        width: MediaQuery.of(context).size.width * 0.9, // Ocupa 90% del ancho disponible
                        height: MediaQuery.of(context).size.height * 0.3, // Máximo 30% de la altura de la pantalla
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.image, size: 50)),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: Colors.grey[300],
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: const Center(child: Icon(Icons.image_not_supported)),
                ),

              const SizedBox(height: 16),

              // Propietario
              Text(
                S.current.Propietario,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _isLoadingOwner
                  ? Text(S.current.CargadoPropietario)
                  : Text(
                      _ownerName ?? S.current.Desconocido,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                S.current.Descripcion,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                widget.property.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Dirección
              Text(
                S.current.Direccion,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _isLoadingAddress
                  ?  Text(S.current.CargandoDireccion)
                  : Text(
                      _address ?? S.current.NoDisponible,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
              const SizedBox(height: 16),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.chat),
                    label:  Text(S.current.Chat),
                    onPressed: () {
                      Get.toNamed('/usuarios');
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.star),
                    label:  Text(S.current.Resena),
                    onPressed: () {
                      Get.toNamed('/reviews', arguments: widget.property.id);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.book_online),
                    label: Text(S.current.Reserva),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                          content: Text(S.current.ReservaConfirmada),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


