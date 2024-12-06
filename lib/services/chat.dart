import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final String wsUrl = "ws://127.0.0.1:3001/chat"; // Cambia esta URL según tu backend
  WebSocketChannel? channel;  // Hacemos el canal nullable

  // Método para establecer la conexión
  Future<void> connect() async {
    try {
      channel = WebSocketChannel.connect(Uri.parse(wsUrl)); // Inicializamos el canal
      print('Conexión establecida');
    } catch (e) {
      print('Error al conectar a WebSocket: $e');
    }
  }

  // Stream para escuchar mensajes
  Stream<dynamic> get messages {
    // Verificamos si el canal está inicializado antes de intentar acceder al stream
    if (channel == null) {
      throw Exception("WebSocketChannel no está conectado. Llama a connect() primero.");
    }
    return channel!.stream; // Usamos el operador '!' porque sabemos que channel no es null
  }

  // Método para enviar un mensaje
  Future<void> sendMessage(String message) async {
    // Verificamos que el canal esté inicializado antes de enviar el mensaje
    if (channel == null) {
      print('Error: Intentando enviar mensaje sin conexión establecida');
      return;
    }

    // Si el canal está conectado, enviamos el mensaje
    channel!.sink.add(message);
    print('Mensaje enviado: $message');
  }

  // Método para desconectar el canal
  void disconnect() {
    // Verificamos si el canal está inicializado antes de intentar cerrar la conexión
    if (channel != null) {
      channel!.sink.close();
      print('Conexión cerrada');
    } else {
      print('Error: No hay conexión para cerrar');
    }
  }
}
