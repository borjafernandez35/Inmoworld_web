import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:inmoworld_web/services/storage.dart';
import './user.dart';
import '../models/chatModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  final String socketUrl =
      "http://127.0.0.1:3000"; // Cambia esta URL según tu backend
  //final String socketUrl = 'http://147.83.7.157:3000';
  IO.Socket? socket; // Socket nullable
  final Dio dio = Dio();
  late final UserService userService; // Aseguramos inicialización

  ChatService() {
    // Asignamos UserService
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
       // Conectar manualmente
      socket!.connect();

      /* socket!.on('connect', (_) => print('Conexión establecida'));
      socket!
          .on('new-message', (data) => print('Nuevo mensaje recibido: $data'));
      socket!.on('disconnect', (_) => print('Desconectado'));
      socket!.on('error', (error) => print('Error en el socket: $error'));
      socket!.on('message', (data) => print('Mensaje recibido: $data')); */

      socket!.on('connect', (_) => print('Conexión establecida'));
      socket!.on('disconnect', (_) => print('Desconectado'));
      socket!.on('error', (error) => print('Error en socket: $error'));

     
    } catch (e) {
      print('Error al conectar al servidor de Socket.IO: $e');
    }
  }

  void loadMessages(String userId) {
    socket?.emit('load-messages', userId);
    socket?.on('load-messages-response', (data) {
      print('Mensajes históricos: $data');
      // Aquí puedes actualizar el controlador con los mensajes recibidos
    });
  }

  void markAsRead(String userId, String senderId) {
    socket?.emit('mark-as-read', {"userId": userId, "senderId": senderId});
    socket?.on('mark-as-read-success', (_) {
      print('Mensajes marcados como leídos');
    });
  }

  void getUnreadCount(String userId) {
    socket?.emit('unread-count', userId);
    socket?.on('unread-count-response', (data) {
      print('Mensajes no leídos: ${data['unreadCount']}');
    });
  }

  // Método para enviar un mensaje
  void sendMessage(String message, String receiverId) {
    final chatMessage = {
      "receiver": receiverId,
      "sender": StorageService.getId(),
      "message": message,
      "timestamp": DateTime.now().toIso8601String(),
    };
    socket?.emit('sendMessage', jsonEncode(chatMessage));
  }

    void sendTypingEvent(String receiverId) {
    socket?.emit('typing', {"receiver": receiverId});
  }

  void sendStopTypingEvent(String receiverId) {
    socket?.emit('stop-typing', {"receiver": receiverId});
  }

  // Cargar chats del usuario desde el backend
  Future<List<Chat>> chatStartup(String userId) async {
    try {
      // Realiza la solicitud para obtener los chats
      final response = await dio.get('$socketUrl/chats/$userId');

      print('Respuesta recibida chats: ${response.data}');

      // Mapeamos la lista de datos a objetos del modelo Chat
      final List<Chat> chats = (response.data['chats'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();

      print('los chats son........!!!!!!!!:$chats');
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

  Future<void> markMessagesAsRead(String userId, String senderId) async {
    try {
      await dio.post('$socketUrl/chats/mark-as-read', data: {
        'userId': userId,
        'senderId': senderId,
      });
    } catch (e) {
      print('Error al marcar mensajes como leídos: $e');
    }
  }

 /*  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await dio.get('$socketUrl/chats/unread/$userId');
      return response.data['unreadCount'] ?? 0;
    } catch (e) {
      print('Error al obtener mensajes no leídos: $e');
      return 0;
    }
  } */

  // Configurar interceptores de solicitudes HTTP
  void _configureInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Obtener token del usuario
        final token = StorageService.getToken();
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
