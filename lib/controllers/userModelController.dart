import 'package:get/get.dart';
import 'package:inmoworld_web/models/userModel.dart';
import 'package:get_storage/get_storage.dart';

class UserModelController extends GetxController {
  // Datos del usuario actual
  final Rx<UserModel> user = UserModel(
    name: 'Usuario desconocido',
    email: 'No especificado',
    password: '',
   // comment: '',
  ).obs;

  final GetStorage _storage = GetStorage(); // Almacenamiento local
  String? userId; // ID del usuario logueado

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage(); // Cargar datos al inicializar
  }

  // Cargar usuario desde el almacenamiento
  void _loadUserFromStorage() {
    userId = _storage.read<String>('userId');
    final storedUser = _storage.read<Map<String, dynamic>>('user');
    if (storedUser != null) {
      user.value = UserModel.fromJson(storedUser);
    }
    print(userId != null
        ? "Usuario cargado: ${user.value.name} con ID: $userId"
        : "No se encontró un usuario guardado.");
  }

  // Validar credenciales del usuario (simulado)
  bool validateCredentials(String email, String password) {
    if (user.value.email == email && user.value.password == password) {
      print("Credenciales válidas para: ${user.value.name}");
      return true;
    }
    print("Credenciales inválidas.");
    return false;
  }

  // Guardar usuario e ID en el almacenamiento
  void saveUser(String id, UserModel userModel) {
    userId = id;
    user.value = userModel;
    _storage.write('userId', id);
    _storage.write('user', userModel.toJson());
    print("Usuario guardado: ${userModel.name} con ID: $id");
  }

  // Actualizar información del usuario actual
  void updateUser({
    String? name,
    String? email,
    String? password,
    //String? comment,
    bool? isAdmin,
  }) {
    user.update((currentUser) {
      if (currentUser != null) {
        currentUser.setUser(
          name ?? currentUser.name,
          email ?? currentUser.email,
          password ?? currentUser.password,
         // comment ?? currentUser.comment,
          isAdmin ?? currentUser.isAdmin,
          id: userId,
        );
        _storage.write('user', currentUser.toJson()); // Guardar cambios
        print("Usuario actualizado: ${currentUser.name}");
      }
    });
  }

  // Eliminar usuario actual
  void clearUser() {
    userId = null;
    user.value = UserModel(
      name: 'Usuario desconocido',
      email: 'No especificado',
      password: '',
      //comment: '',
    );
    _storage.remove('userId');
    _storage.remove('user');
    print("Usuario eliminado del almacenamiento.");
  }

  // Manejar inicio de sesión
  bool logIn(String email, String password) {
    if (validateCredentials(email, password)) {
      print("Inicio de sesión exitoso para: ${user.value.name}");
      return true;
    }
    print("Inicio de sesión fallido.");
    return false;
  }

  // Verificar si hay un usuario logueado
  bool isUserLoggedIn() {
    return userId != null;
  }
}
