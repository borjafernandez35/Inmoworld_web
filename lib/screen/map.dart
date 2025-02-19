import 'package:flutter/material.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inmoworld_web/controllers/property_controller.dart';
//import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

class MapScreen extends StatefulWidget {
  final LatLng defaultLocation;

  const MapScreen({Key? key, required this.defaultLocation}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Set<Marker> _markers = <Marker>{};
  Position? _currentPosition;
  bool _isLoading = true;
  final PropertyController _propertyController = PropertyController();
  double _selectedDistance = 5.0;
  final List<double> _validDistances = [
    5.0,
    10.0,
    20.0,
    50.0,
    100.0,
    500.0,
    1000.0
  ];
  static const int _pageSize = 10;
  String _searchQuery = "Price";
  String sortOption = "Price"; // Opciones: "Date", "Price", etc.
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _selectedDistance = box.read('distance') ?? 5.0;
    if (!_validDistances.contains(_selectedDistance)) {
      _selectedDistance = 5.0;
    }
    _initializeLocationAndProperties();
  }

  Future<void> _initializeLocationAndProperties() async {
    await _determinePosition();
    await _fetchProperties();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Los servicios de ubicación están deshabilitados.')),
      );
      return;
    }

    // Solicita permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Permisos de ubicación permanentemente denegados.')),
      );
      return;
    }

    // Obtén la posición actual
    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Mueve la cámara a la ubicación actual
      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14.0,
        ),
      );

      // Añade un marcador en la ubicación actual
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: 'Tu ubicación actual'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al obtener la ubicación: soy tu errrrrooooorrrrrrr $e')),
      );
    }
  }

  Future<void> _fetchProperties() async {
    try {
      await _propertyController.fetchPropertiesMarkers(
        distance: _selectedDistance * 1000,
        sort: _searchQuery,
      );

      setState(() {
        _markers.clear();
        _markers.addAll(_propertyController.properties.map((property) {
          return Marker(
            markerId: MarkerId(property.id),
            position: LatLng(
              property.location.latitude,
              property.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: property.description,
              snippet: S.current.PrecioPropiedad(': €${property.price}'),
              onTap: () => _showPropertyDetails(property),
            ),
          );
        }));
      });
    } catch (e) {
      _showSnackbar('Error al obtener propiedades: $e');
    }
  }

  void _showPropertyDetails(dynamic property) {
    print('Descripción: ${property.description}');
    print('URL de la imagen: ${property.imageUrl}');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(property.description),
          content: Row(
            children: [
              property.imageUrl != null && property.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        property.imageUrl!,
                        height: 50, // Tamaño pequeño
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 50);
                        },
                      ),
                    )
                  : const Icon(Icons.image_not_supported, size: 50),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  S.current.PrecioPropiedad(': €${property.price}'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.current.Close),
            ),
          ],
        );
      },
    );
  }

  void _onDistanceChanged(double? newDistance) {
    if (newDistance != null && _validDistances.contains(newDistance)) {
      setState(() {
        _selectedDistance = newDistance;
        box.write('distance', _selectedDistance);
        _fetchProperties();
      });
    } else {
      _showSnackbar(S.current.DistanciaNoValida);
    }
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _fetchProperties();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Marcadores pasados al GoogleMap: $_markers");
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.MapaPropiedades),
        actions: [
          // Filtro de distancia
          DropdownButton<double>(
            value: _selectedDistance,
            onChanged: _onDistanceChanged,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
            items: _validDistances.map((double value) {
              return DropdownMenuItem<double>(
                value: value,
                child: Text(S.current.Hasta('$value km')),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.defaultLocation,
                    zoom: 14,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) => _controller = controller,
                ),
                // Barra de búsqueda
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: _onSearchQueryChanged,
                        decoration: InputDecoration(
                          labelText: S.current.SearchProperties,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/property'),
        tooltip: S.current.AnadirPropiedad,
        child: const Icon(Icons.add),
      ),
    );
  }
}
