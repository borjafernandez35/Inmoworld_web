import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _box = GetStorage();


    // Métodos de idioma
  static String getLocale() => _box.read('locale') ?? 'es'; // 'en' por defecto
  static void saveLocale(String locale) => _box.write('locale', locale);


  // Métodos de rutas
  static String getLastRoute() => _box.read('lastRoute') ?? '/login'; // Predeterminada a '/login'
  static void saveLastRoute(String route) => _box.write('lastRoute', route);

  // Métodos de primera ejecución
  static bool isFirstLaunch() => _box.read('isFirstLaunch') ?? true;
  static void setFirstLaunch(bool isFirst) => _box.write('isFirstLaunch', isFirst);

  // Métodos de lectura
  static String getToken() => _box.read('token');
  static String getId() => _box.read('id');
  static bool get isAdmin => _box.read('isAdmin') ?? false;

  // Métodos de escritura
  static void saveToken(String token) => _box.write('token', token);
  static void saveId(String id) => _box.write('id', id);
  static void saveAdmin(bool isAdmin) => _box.write('isAdmin', isAdmin);

  // Métodos para limpiar la sesión
  static void clearSession() => _box.erase();

   // Métodos para el estado de cierre
  static void markAppClosed(bool isClosed) => _box.write('appClosed', isClosed);
  static bool wasAppClosed() => _box.read('appClosed') ?? true;
}
