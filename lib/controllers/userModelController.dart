import 'package:get/get.dart';
import 'package:inmoworld_web/models/userModel.dart';
import 'package:inmoworld_web/services/user.dart';

class UserModelController extends GetxController {
  final UserService userService=UserService(); // Instancia del servicio
  final Rx<UserModel?> user =
      Rx<UserModel?>(null); // Estado reactivo del usuario
  final RxString statusMessage = ''.obs; // Mensajes para la UI

  


// Cargar datos del usuario desde el backend
  Future<void> fetchUser() async {
    try {
      statusMessage.value = 'Cargando datos del usuario...';
      final fetchedUser = await userService.getUser(); // Llamada al backend
      user.value = fetchedUser;
      statusMessage.value = 'Datos del usuario cargados correctamente.';
    } catch (e) {
      statusMessage.value = 'Error al cargar datos del usuario.';
      print('Error en fetchUser: $e');
    }
  }

  // Actualizar datos del usuario en el backend
  Future<void> updateUser({
    String? name,
    String? email,
    String? password,
    bool? isAdmin,
  }) async {
    if (user.value == null) {
      statusMessage.value = 'No hay usuario cargado para actualizar.';
      return;
    }

    try {
      // Actualizar los datos en el modelo local
      user.update((currentUser) {
        if (currentUser != null) {
          currentUser.setUser(
            name ?? currentUser.name,
            email ?? currentUser.email,
            password ?? currentUser.password,
            isAdmin ?? currentUser.isAdmin,
            id: currentUser.id,
          );
        }
      });

      // Sincronizar cambios con el backend
      if (user.value != null) {
        statusMessage.value = 'Actualizando datos en el servidor...';
        final statusCode = await userService.updateUser(user.value!);
        if (statusCode == 200) {
          statusMessage.value = 'Usuario actualizado correctamente.';
        } else {
          statusMessage.value = 'Error al actualizar usuario en el servidor.';
        }
      }
    } catch (e) {
      statusMessage.value = 'Error al actualizar usuario.';
      print('Error en updateUser: $e');
    }
  }

  // Eliminar datos del usuario en el backend
  Future<void> deleteUser() async {
    if (user.value == null) {
      statusMessage.value = 'No hay usuario cargado para eliminar.';
      return;
    }

    try {
      statusMessage.value = 'Eliminando usuario en el servidor...';
      final statusCode = await userService.deleteUser();
      if (statusCode == 201) {
        user.value = null; // Limpiar el modelo local
        statusMessage.value = 'Usuario eliminado correctamente.';
      } else {
        statusMessage.value = 'Error al eliminar usuario en el servidor.';
      }
    } catch (e) {
      statusMessage.value = 'Error al eliminar usuario.';
      print('Error en deleteUser: $e');
    }
  }

  // Verificar si hay un usuario cargado
  bool isUserLoaded() {
    return user.value != null;
  }
}
