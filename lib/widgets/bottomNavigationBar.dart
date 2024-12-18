import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/navigationController.dart';

class BottomNavScaffold extends StatelessWidget {
  final Widget child;
  final NavigationController navController = Get.put(NavigationController());

  BottomNavScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: navController.selectedIndex.value,
            onTap: navController.navigateTo,
            selectedItemColor: const Color.fromARGB(255, 92, 14, 105),
            unselectedItemColor: Colors.black,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
             BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.chat),
                    Positioned(
                      right: 0,
                      child: Obx(() {
                        final unreadCount = navController.unreadMessages.value;
                        if (unreadCount > 0) {
                          return Badge(
                            label: Text(unreadCount.toString()),
                            backgroundColor: Colors.red,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                    ),
                  ],
                ),
                label: 'Mensajes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_activity),
                label: 'Properties',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              const BottomNavigationBarItem( 
                icon: Icon(Icons.location_pin),
                label: 'Mapa',
              ),  
            ],
          )),
    );
  }
}
