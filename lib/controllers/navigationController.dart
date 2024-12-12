import 'package:get/get.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  final List<String> routes = [
    '/home', '/usuarios',
   
    '/properties', // Nueva ruta para propiedades
    '/perfil', '/map'
  ];

  void navigateTo(int index) {
    selectedIndex.value = index;
    Get.offNamed(routes[index]);
  }
}
