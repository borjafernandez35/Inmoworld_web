import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/screen/login.dart';
import 'package:inmoworld_web/screen/register.dart';
import 'package:inmoworld_web/widgets/bottomNavigationBar.dart';
//import 'package:flutter_application_1/screen/experiencies.dart';
import 'package:inmoworld_web/screen/perfil.dart';
import 'package:inmoworld_web/screen/user.dart';
import 'package:inmoworld_web/screen/property.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inmoworld_web/controllers/userModelController.dart';
//import 'package:flutter_application_1/controllers/experienceController.dart';
//import 'package:flutter_application_1/controllers/experienceListController.dart';

void main() async {
  await GetStorage.init();
  Get.put(UserModelController());
  
  

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        // Ruta de inicio de sesión
        GetPage(
          name: '/login',
          page: () => const LogInScreen(),
        ),
        // Ruta de registro
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
        ),
        // Ruta de la pantalla principal con BottomNavScaffold
       /*  GetPage(
          name: '/home',
          page: () => BottomNavScaffold(child: const HomePage()),
        ), */
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
      ],
    );
  }
}