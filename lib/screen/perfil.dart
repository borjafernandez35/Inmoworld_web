import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inmoworld_web/controllers/user_model_controller.dart';
import 'package:intl/intl.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/controllers/profil_picture_controller.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserModelController>();
    final profilePictureController = Get.put(ProfilePictureController());

    // Cargar usuario al abrir la pantalla (asegurarse de que se carguen los datos del usuario)
    userController.fetchUser();

    return Scaffold(
      appBar: AppBar(title: Text(S.current.PerfilUsuario)),
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

          // Convertir y formatear la fecha de nacimiento
          String formattedBirthday;
          try {
            final birthdayDate = DateTime.parse(user.birthday).toLocal();
            formattedBirthday = DateFormat('dd-MM-yyyy').format(birthdayDate);
          } catch (e) {
            formattedBirthday = 'Fecha inválida';
          }

          // Renderizar los datos del usuario
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mostrar la imagen de perfil o la inicial
                  CircleAvatar(
                    radius: 50,
                    // Verificar si la URL de la imagen es válida
                    backgroundImage:
                        user.imageUser != null && user.imageUser!.isNotEmpty
                            ? NetworkImage(user.imageUser!)
                            : null,
                    child: user.imageUser == null || user.imageUser!.isEmpty
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                    backgroundColor: Colors.blueAccent,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.current.CorreoPropiedad(': ${user.email}'),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.current.CumpleanoPropiedad(': $formattedBirthday'),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.current.ContrasenaPropiedad(': ********'),
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Botones de acciones
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      print("Iniciando proceso para cambiar foto de perfil...");
                      await profilePictureController
                          .selectAndUploadProfileImage();

                      if (profilePictureController.uploadedPicture != null) {
                        print(
                            "Imagen seleccionada y subida, mostrando diálogo de confirmación...");
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(S.current.Confirmacion),
                              content: Text(S.current.DeseasActualizar),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(S.current.Cancelar),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    print(
                                        "Imagen confirmada, actualizando la base de datos...");
                                    await userController.updateProfilePicture(
                                        profilePictureController
                                            .uploadedPicture!);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(S.current.Aceptar),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        print("No se ha subido ninguna imagen.");
                      }
                    },
                    icon: const Icon(Icons.photo_camera),
                    label: Text(S.current.FotoPerfil),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Mostrar formulario en un diálogo
                      showDialog(
                        context: context,
                        builder: (context) {
                          final nameController =
                              TextEditingController(text: user.name);
                          final emailController =
                              TextEditingController(text: user.email);
                          final passwordController = TextEditingController();

                          return AlertDialog(
                            title: Text(S.current.ActualizarPerfil),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                    labelText: S.current.Name,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: S.current.CorreoElectronico,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: S.current.Contrasena,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(S.current.Cancelar),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final newName = nameController.text.trim();
                                  final newEmail = emailController.text.trim();
                                  final newPassword =
                                      passwordController.text.trim();

                                  await userController.updateUser(
                                    name: newName.isNotEmpty ? newName : null,
                                    email:
                                        newEmail.isNotEmpty ? newEmail : null,
                                    password: newPassword.isNotEmpty
                                        ? newPassword
                                        : null,
                                  );

                                  Navigator.of(context).pop();
                                },
                                child: Text(S.current.Actualizar),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.update),
                    label: Text(S.current.ActualizarDatos),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(S.current.Confirmacion),
                            content: Text(S.current.EstaSeguro),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(S.current.Cancelar),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await userController.deleteUser();
                                  Navigator.of(context).pop();
                                  Get.offAllNamed('/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(S.current.Eliminar),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(S.current.EliminarCuenta),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
