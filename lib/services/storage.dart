import 'package:get_storage/get_storage.dart';
import 'package:inmoworld_web/models/userModel.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  // Métodos de lectura
  static String? getToken() => _box.read('token');
  static String? getId() => _box.read('id');
  static bool get isAdmin => _box.read('isAdmin') ?? false;
  static List<UserModel> getUserList() {
    // Leer la lista de usuarios almacenada como JSON
    final List<dynamic>? userListJson = _box.read('userList');
    if (userListJson == null) {
      return [];
    }

    // Convertir cada elemento de JSON a una instancia de UserModel
    return userListJson.map((user) => UserModel.fromJson(user)).toList();
  }

  // Métodos de escritura
  static void saveToken(String token) => _box.write('token', token);
  static void saveId(String id) => _box.write('id', id);
  static void saveAdmin(bool isAdmin) => _box.write('isAdmin', isAdmin);
  static void saveUserList(List<UserModel> userList) {
    // Convertir la lista de UserModel a JSON antes de almacenarla
    final userListJson = userList.map((user) => user.toJson()).toList();
    _box.write('userList', userListJson);
  }

  // Métodos para limpiar la sesión
  static void clearSession() => _box.erase();
}
