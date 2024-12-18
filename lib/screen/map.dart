import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inmoworld_web/controllers/propertyController.dart';
import 'package:inmoworld_web/models/propertyModel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  Set<Marker> _markers = Set<Marker>();
  bool _isLoading = true;
  final PropertyController _propertyController = PropertyController();
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchAndMarkProperties(1, _pageSize);
  }

  LatLng? _firstLocation; // Guardar la primera ubicación temporalmente

  Future<void> _fetchAndMarkProperties(int page, int limit) async {
    try {
      final properties = await _propertyController.fetchProperties(page, limit);
      print(
          'Properties for map: ${properties.map((p) => p.toJson()).toList()}');

      for (var i = 0; i < properties.length; i++) {
        final property = properties[i];
        final address = property.address;

        try {
          LatLng location =
              await _propertyController.getCoordinatesFromAddress(address);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Properties Map'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(41.2755, 1.9872),
                //target: LatLng(37.38647, -6.07729),
                zoom: 14.0,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                // Mover la cámara a la primera ubicación si está disponible
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
