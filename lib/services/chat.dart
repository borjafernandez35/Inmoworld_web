import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:inmoworld_web/services/storage.dart';
import './user.dart';
import '../models/chatModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  final String socketUrl = "http://127.0.0.1:3000"; // Cambia esta URL según tu backend
  IO.Socket? socket; // Socket nullable
  final Dio dio = Dio();
  late final UserService userService; // Aseguramos inicialización

  ChatService(UserService userService) {
    this.userService = userService;
    _configureInterceptors();
  }

  // Conectar al servidor de Socket.IO
  void connect() {
    try {
      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Usar transporte WebSocket
            .disableAutoConnect() // Conexión manual
            .build(),
      );

      socket!.on('connect', (_) => print('Conexión establecida'));
      socket!.on('disconnect', (_) => print('Desconectado'));
      socket!.on('error', (error) => print('Error en el socket: $error'));
      socket!.on('message', (data) => print('Mensaje recibido: $data'));

      // Eventos personalizados
      socket!.on('load-messages-response', (data) {
        print('Mensajes históricos: $data');
      });
      socket!.on('unread-count-response', (data) {
        print('Mensajes no leídos: ${data['unreadCount']}');
      });

      socket!.connect();
    } catch (e) {
      print('Error al conectar al servidor de Socket.IO: $e');
    }
  }

  // Cargar mensajes históricos
  void loadMessages(String userId) {
    socket?.emit('load-messages', userId);
  }

  // Registro de usuario para chat
  void registerUser(String? userId) {
    socket?.emit('register-user', userId);
  }

  // Marcar mensajes como leídos
  void markAsRead(String userId, String senderId) {
    socket?.emit('mark-as-read', {"userId": userId, "senderId": senderId});
  }

  // Obtener el conteo de mensajes no leídos
  void getUnreadCount(String userId) {
    socket?.emit('unread-count', userId);
  }

  // Enviar mensaje
  void sendMessage(Map<String, dynamic> chatMessage) {
    socket?.emit('sendMessage', jsonEncode(chatMessage));
  }

  // Enviar eventos de escritura
  void sendTypingEvent(String receiverId) {
    socket?.emit('typing', {"receiver": receiverId});
  }

  void sendStopTypingEvent(String receiverId) {
    socket?.emit('stop-typing', {"receiver": receiverId});
  }

  // Cargar chats desde el backend
  Future<List<Chat>> chatStartup(String userId) async {
    try {
      final response = await dio.get('$socketUrl/chats/$userId');
      final List<Chat> chats = (response.data['chats'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();

      chats.sort((a, b) => a.date.compareTo(b.date));
      return chats;
    } on DioError catch (e) {
      if (e.response?.statusCode == 403) {
        print('Error 403: Acceso denegado. Verifica el token.');
      } else {
        print('Error al realizar la solicitud HTTP: ${e.message}');
      }
      return [];
    }
  }

  // Configurar interceptores de solicitudes HTTP
  void _configureInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = StorageService.getToken();
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        handler.next(options);
      },
      onError: (DioError e, handler) {
        print('Error en petición: ${e.response?.statusCode}');
        handler.next(e);
      },
    ));
  }

  // Desconectar el socket
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
      print('Socket desconectado');
    } else {
      print('Error: No hay conexión para cerrar');
    }
  }
}
