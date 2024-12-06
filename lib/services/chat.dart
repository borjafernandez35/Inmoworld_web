import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final String wsUrl = "ws://127.0.0.1:3001/chat"; // Cambia esta URL según tu backend
  late WebSocketChannel channel;

  void connect() {
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
  }

  Stream<dynamic> get messages => channel.stream;

  /// Ahora acepta cualquier dato serializable (ejemplo: Map)
  void sendMessage(Map<String, dynamic> message) {
    channel.sink.add(json.encode(message)); // Codifica el mapa como JSON
  }

  void disconnect() {
    channel.sink.close();
  }
}
