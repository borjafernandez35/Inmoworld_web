import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/screen/login.dart';
import 'package:inmoworld_web/screen/register.dart';
import 'package:inmoworld_web/widgets/bottom_navigation_bar.dart';
import 'package:inmoworld_web/screen/perfil.dart';
import 'package:inmoworld_web/screen/user.dart';
import 'package:inmoworld_web/screen/property.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inmoworld_web/controllers/userModelController.dart';
// Importa el controlador
// Importa LatLng
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inmoworld_web/screen/title.dart';
import 'package:inmoworld_web/screen/map.dart'; // Importa la pantalla de mapa
import 'package:inmoworld_web/screen/add_property.dart';

void main() async {
  await GetStorage.init();
  Get.put(UserModelController());

  runApp(
    const MyApp(),
  );

/*   // Prueba rápida de la función getCoordinatesFromAddress
  await testGeocoding(); */
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Future<LatLng> getDefaultLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permiso de ubicación denegado.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Los permisos de ubicación están denegados permanentemente.');
      }

      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error obteniendo ubicación: $e');
      // Coordenadas por defecto si falla la ubicación
      return LatLng(41.27552212202214, 1.9863014220734023);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LatLng>(
        future: getDefaultLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
          }

          final defaultLocation = snapshot.data ??
              LatLng(41.27552212202214, 1.9863014220734023);
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/login',
            getPages: [
              GetPage(
                name: '/login',
                page: () => TitleScreen(),
              ),
              GetPage(
                name: '/logearse',
                page: () => LogInScreen(),
              ),
              GetPage(
                name: '/register',
                page: () => const RegisterScreen(),
              ),
              GetPage(
                name: '/usuarios',
                page: () => BottomNavScaffold(child: const UserScreen()),
              ),
              GetPage(
                name: '/properties',
                page: () => BottomNavScaffold(child: const PropertyScreen()),
              ),
              GetPage(
                name: '/perfil',
                page: () => BottomNavScaffold(child: const PerfilScreen()),
              ),
              GetPage(
                name: '/property',
                page: () => BottomNavScaffold(
                    child: PropertyAddScreen(defaultLocation: defaultLocation)),
              ),
              GetPage(
                name: '/map',
                page: () => BottomNavScaffold(
                    child: MapScreen(
                        defaultLocation:
                            defaultLocation)), // Nueva pantalla de mapa
              ),
            ],
          );
        });
  }
}

/* // Función de prueba rápida
Future<void> testGeocoding() async {
  final PropertyController propertyController = PropertyController();
  final address = '1600 Amphitheatre Parkway, Mountain View, CA, 94043, USA';
  try {
    LatLng location =
        await propertyController.getCoordinatesFromAddress(address);
    print('Coordinates for $address: $location');
  } catch (e) {
    print('Failed to get coordinates for $address: $e');
  }
} */
