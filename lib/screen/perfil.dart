import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/user_model_controller.dart';
import 'package:inmoworld_web/widgets/user_card.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserModelController>();

    // Cargar usuario al abrir la pantalla
    userController.fetchUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final user = userController.user.value;

          // Mostrar mensaje de carga o error
          if (user == null) {
            return Center(
              child: userController.statusMessage.isEmpty
                  ? const CircularProgressIndicator()
                  : Text(userController.statusMessage.value),
            );
          }

          // Renderizar los datos del usuario
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserCard(user: user), // Mostrar datos en la tarjeta
              const SizedBox(height: 20),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('Información adicional'),
                      subtitle: Text(
                        'Aquí puedes agregar detalles extra del usuario.',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Puedes añadir más contenido dinámico aquí.',
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      ),
                    ),
                    OverflowBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6200EE),
                          ),
                          onPressed: () async {
                            if (user.name.isNotEmpty && user.email.isNotEmpty) {
                              // Actualizar datos solo si son válidos
                              await userController.updateUser(
                                name: user.name,
                                email: user.email,
                              );
                              Get.snackbar(
                                  'Actualización', 'Usuario actualizado correctamente');
                            } else {
                              Get.snackbar(
                                  'Error', 'Por favor, ingresa datos válidos');
                            }
                          },
                          child: const Text('Actualizar Usuario'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6200EE),
                          ),
                          onPressed: () async {
                            // Eliminar usuario y mostrar mensaje de confirmación
                            await userController.deleteUser();
                            Get.snackbar(
                                'Usuario Eliminado', 'El usuario fue eliminado correctamente');
                          },
                          child: const Text('Eliminar Usuario'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
