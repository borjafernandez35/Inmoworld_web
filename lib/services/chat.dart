import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  final String socketUrl = "http://127.0.0.1:3001"; // Cambia esta URL según tu backend
  IO.Socket? socket; // Hacemos el socket nullable

  // Método para establecer la conexión
  void connect() {
    try {
      // Inicializamos el socket con la URL del servidor
      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket']) // Usar transporte WebSocket
            .disableAutoConnect()         // Conexión manual
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
      // Emitir un evento personalizado con el mensaje
      socket!.emit('sendMessage', message);
      print('Mensaje enviado: $message');
    } else {
      print('Error: No se puede enviar el mensaje, el socket está desconectado.');
    }
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
