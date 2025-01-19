import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  // Métodos de lectura
  static String? getToken() => _box.read('token');
  static String getId() => _box.read('id');
  static bool get isAdmin => _box.read('isAdmin') ?? false;

  // Métodos de escritura
  static void saveToken(String token) => _box.write('token', token);
  static void saveId(String id) => _box.write('id', id);
  static void saveAdmin(bool isAdmin) => _box.write('isAdmin', isAdmin);

  // Métodos para limpiar la sesión
  static void clearSession() => _box.erase();
}