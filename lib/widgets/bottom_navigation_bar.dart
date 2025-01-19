import 'package:flutter/material.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/navigation_controller.dart';

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
                label: S.current.Usuarios,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: S.current.Perfil,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: S.current.Home,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy),
                label: S.current.ChatBot,
              ),
              BottomNavigationBarItem( 
                icon: const Icon(Icons.location_pin),
                label: S.current.Mapa,
              ),  
            ],
          )),
    );
  }
}
