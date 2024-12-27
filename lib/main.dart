import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/screen/login.dart';
import 'package:inmoworld_web/screen/register.dart';
import 'package:inmoworld_web/widgets/bottomNavigationBar.dart';
import 'package:inmoworld_web/screen/perfil.dart';
import 'package:inmoworld_web/screen/user.dart';
import 'package:inmoworld_web/screen/property.dart';
import 'package:inmoworld_web/screen/property_creation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inmoworld_web/controllers/userModelController.dart';
import 'package:inmoworld_web/controllers/propertyController.dart'; // Importa el controlador
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importa LatLng
import 'package:inmoworld_web/screen/title.dart';
import 'package:inmoworld_web/screen/map.dart'; // Importa la pantalla de mapa

void main() async {
  await GetStorage.init();
  Get.put(UserModelController());

  runApp(
    const MyApp(),
  );

  // Prueba rápida de la función getCoordinatesFromAddress
  await testGeocoding();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          name: '/home',
          page: () => BottomNavScaffold(child: const PropertyScreen()),
        ),
        GetPage(
          name: '/usuarios',
          page: () => BottomNavScaffold(child: const UserScreen()),
        ),
        GetPage(
          name: '/post',
          page: () => BottomNavScaffold(child: const CloudinaryUploaderWeb()),
        ),
        GetPage(
          name: '/perfil',
          page: () => BottomNavScaffold(child: const PerfilScreen()),
        ),
        GetPage(
          name: '/map',
          page: () => BottomNavScaffold(child: MapScreen()), // Nueva pantalla de mapa
        ),
      ],
    );
  }
}

// Función de prueba rápida
Future<void> testGeocoding() async {
  final PropertyController propertyController = PropertyController();
  final address = '1600 Amphitheatre Parkway, Mountain View, CA, 94043, USA';
  try {
    LatLng location = await propertyController.getCoordinatesFromAddress(address);
    print('Coordinates for $address: $location');
  } catch (e) {
    print('Failed to get coordinates for $address: $e');
  }
}





