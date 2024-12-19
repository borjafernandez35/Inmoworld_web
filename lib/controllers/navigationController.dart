import 'package:get/get.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  final List<String> routes = ['/chat',
    '/usuarios',
    '/properties',
    '/post',
    '/perfil', 
    '/map'
  ];

  void navigateTo(int index) {
    selectedIndex.value = index;
    Get.offNamed(routes[index]);
  }
}
