import 'dart:convert';
import 'package:dio/dio.dart';
import './user.dart';
import '../models/chatModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {

  final String socketUrl =
      "http://127.0.0.1:3001"; // Cambia esta URL según tu backend
  IO.Socket? socket; // Socket nullable
  final Dio dio = Dio();
  late final UserService userService; // Aseguramos inicialización

  ChatService(UserService userService) {
    // Asignamos UserService
    this.userService = userService;
    // Configuramos interceptores
    _configureInterceptors();
  }

  // Método para establecer la conexión
  void connect() {
    try {
      // Inicializamos el socket con la URL del servidor
      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Usar transporte WebSocket
            .disableAutoConnect() // Conexión manual
            .build(),
      );

      // Escuchar el evento de conexión
      socket!.on('connect', (_) {
        print('Conexión establecida con el servidor de Socket.IO');
      });

      // Escuchar el evento de desconexión
      socket!.on('disconnect', (_) {
        print('Desconectado del servidor de Socket.IO');
      });

      // Escuchar errores
      socket!.on('error', (error) {
        print('Error en el socket: $error');
      });

      // Escuchar mensajes personalizados (por ejemplo, "message")
      socket!.on('message', (data) {
        print('Mensaje recibido: $data');
      });

      // Conectar manualmente
      socket!.connect();
    } catch (e) {
      print('Error al conectar al servidor de Socket.IO: $e');
    }
  }

  // Método para enviar un mensaje
  void sendMessage(String message) {
    if (socket != null && socket!.connected) {
      // Emitir un evento "message" (asegúrate de que coincida con el backend)
      socket!.emit('sendMessage', message);
      print('Mensaje enviado: $message');
    } else {
      print(
          'Error: No se puede enviar el mensaje, el socket está desconectado.');
    }
  }

  // Cargar chats del usuario desde el backend
  Future<List<Chat>> chatStartup(String userId) async {
    try {
      // Realiza la solicitud para obtener los chats
      final response =
          await dio.get('$socketUrl/user/chats/guarda/usuarios/$userId');

      print('Respuesta recibida chats: ${response.data}');

      // Mapeamos la lista de datos a objetos del modelo Chat
      final List<Chat> chats = (response.data['chats'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();
      // Ordenar los chats por fecha
      chats.sort((a, b) => a.date.compareTo(b.date));

      return chats;
    } on DioError catch (e) {
      if (e.response?.statusCode == 403) {
        print('Error 403: Acceso denegado. Verifica el token.');
      } else {
        print('Error al realizar la solicitud HTTP: ${e.message}');
      }
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  // Configurar interceptores de solicitudes HTTP
  void _configureInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Obtener token del usuario
        final token = userService.getToken();
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        handler.next(options); // Continuar con la solicitud
      },
      onError: (DioError e, handler) {
        print('Error en petición: ${e.response?.statusCode}');
        handler.next(e); // Pasar el error al flujo siguiente
      },
    ));
  }

  // Método para desconectar el socket
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
      print('Socket desconectado');
    } else {
      print('Error: No hay conexión para cerrar');
    }
  }
}
