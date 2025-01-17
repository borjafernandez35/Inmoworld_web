import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/controllers/user_model_controller.dart';
import 'package:inmoworld_web/widgets/user_card.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Locale currentLocale = Get.deviceLocale ?? const Locale('en');

  @override
  void initState() {
    super.initState();

    // Guarda la ruta actual al abrir la pantalla
    final box = GetStorage();
    box.write('lastRoute', Get.currentRoute);
  }

  void _changeLanguage(Locale locale) {
    print('Cambiando idioma a: ${locale.languageCode}');
    // Guarda la ruta actual antes de actualizar el idioma
    final box = GetStorage();
    box.write('lastRoute', Get.currentRoute);
    S.load(locale);
    setState(() {
      currentLocale = locale;
    });
    StorageService.saveLocale(
        locale.languageCode); // Guarda el idioma en GetStorage
    Get.updateLocale(locale); // Cambia el idioma global
    print('Idioma actual: ${Get.locale}');
  }

  Widget _buildLanguageSelector() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PopupMenuButton<Locale>(
          onSelected: (Locale locale) {
            _changeLanguage(locale);
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
            PopupMenuItem<Locale>(
              value: const Locale('en'),
              child: Row(
                children: [
                  Image.asset(
                    'assets/us.png', // Bandera de EE. UU.
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(S.current.English),
                ],
              ),
            ),
            PopupMenuItem<Locale>(
              value: Locale('es', 'ES'),
              child: Row(
                children: [
                  Image.asset(
                    'assets/es.png', // Bandera de España
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(S.current.Espanol),
                ],
              ),
            ),
             PopupMenuItem<Locale>(
              value: Locale('ca', 'CA'),
              child: Row(
                children: [
                  Image.asset(
                    'assets/cat.png', // Bandera de España
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(S.current.Catalan),
                ],
              ),
            ),
            PopupMenuItem<Locale>(
              value: Locale('ro', 'RO'),
              child: Row(
                children: [
                  Image.asset(
                    'assets/ru.png', // Bandera de España
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(S.current.Rumanno),
                ],
              ),
            ),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cambiamos el Icon por la imagen personalizada
              Image.asset(
                S.of(context).flag, // Bandera de España
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                S.current.EN,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserModelController>();

    // Cargar usuario al abrir la pantalla
    userController.fetchUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.PerfilUsuario),
        actions: [
          _buildLanguageSelector(), // Aquí se incluye el selector de idioma
        ],
      ),
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
                            // Acción para actualizar datos del usuario
                            await userController.updateUser(
                              name: 'Nuevo Nombre',
                              email: 'nuevoemail@example.com',
                            );
                          },
                          child: const Text('Actualizar Usuario'),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF6200EE),
                          ),
                          onPressed: () async {
                            // Acción para eliminar el usuario
                            await userController.deleteUser();
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
