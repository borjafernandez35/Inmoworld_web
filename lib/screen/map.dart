import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inmoworld_web/controllers/propertyController.dart';
import 'package:inmoworld_web/models/propertyModel.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  Set<Marker> _markers = Set<Marker>();
  Position? _currentPosition;
  bool _isLoading = true;
  final PropertyController _propertyController = PropertyController();
  double distance = 10000;
  static const int _pageSize = 10;
  LatLng? _firstLocation;
   String searchQuery = "";
  String sortOption = "Date"; // Opciones: "Date", "Price", etc.

  @override
  void initState() {
    super.initState();
    _fetchAndMarkProperties(distance, 1, _pageSize, searchQuery, sortOption);
     _determinePosition(); // Inicia el proceso para obtener la posición del usuario
  }

    Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los servicios de ubicación están deshabilitados.')),
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
        const SnackBar(content: Text('Permisos de ubicación permanentemente denegados.')),
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
      if (_controller != null) {
        _controller.animateCamera(
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
    }
  }

Future<void> _fetchAndMarkProperties(double distance, int page, int limit, String search, String sort) async {
  try {
    final properties = await _propertyController.fetchProperties(distance,page, limit,search);
    print('Properties for map: ${properties.map((p) => p.toJson()).toList()}');

    for (var i = 0; i < properties.length; i++) {
      final property = properties[i];
      final address = property.address;

      try {
        LatLng location = await _propertyController.getCoordinatesFromAddress(address);
        print('Coordinates for $address: $location');

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(property.id),
              position: location,
              infoWindow: InfoWindow(title: address),
            ),
          );
        });

        // Guardar la primera ubicación para mover la cámara después de que el mapa se cree
        if (i == 0) {
          _firstLocation = location;
        }
      } catch (e) {
        print('Failed to get coordinates for $address: $e');
      }
    }
  } catch (e) {
    print('Error occurred: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

 void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _isLoading = true;
    });
    _fetchAndMarkProperties(distance, 1, _pageSize, searchQuery, sortOption);
  }

  void _onSortChanged(String sort) {
    setState(() {
      sortOption = sort;
      _isLoading = true;
    });
    _fetchAndMarkProperties(distance, 1, _pageSize, searchQuery, sortOption);
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Properties Map'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PropertySearchDelegate(
                  onSearchChanged: _onSearchChanged,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _onSortChanged,
            itemBuilder: (BuildContext context) {
              return ["Date", "Price"].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(41.2755, 1.9872),
                zoom: 14.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                if (_firstLocation != null) {
                  _controller.animateCamera(
                    CameraUpdate.newLatLngZoom(_firstLocation!, 14.0),
                  );
                }
              },
              mapType: MapType.normal,
            ),
    );
  }
}

class PropertySearchDelegate extends SearchDelegate {
  final Function(String) onSearchChanged;

  PropertySearchDelegate({required this.onSearchChanged});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearchChanged(query);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearchChanged(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

}

