import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:inmoworld_web/services/chat.dart'; // Asumiendo que existe un servicio para el chat

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Almacena mensajes junto con timestamps
  late final ChatService chatService; // Servicio para gestionar el chat

  @override
  void initState() {
    super.initState();
    chatService = ChatService(); // Inicializa el servicio de chat
    chatService.connect(); // Conecta el WebSocket al iniciar la pantalla

    // Escuchar mensajes entrantes del servidor
    chatService.messages.listen((event) {
      final data = jsonDecode(event); // Suponiendo que el evento contiene JSON con el mensaje y timestamp
      setState(() {
        _messages.add({
          "sender": data['sender'],
          "message": data['message'],
          "timestamp": DateTime.parse(data['timestamp']), // Convertir string a DateTime
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    chatService.disconnect(); // Desconectar WebSocket cuando se salga de la pantalla
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final timestamp = DateTime.now();

      // Enviar mensaje al servidor
      chatService.sendMessage(json.encode({
        "receiverId": widget.userId,
        "message": text,
        "timestamp": timestamp.toIso8601String(),
      }));

      // Agregar mensaje local
      setState(() {
        _messages.add({
          "sender": "me",
          "message": text,
          "timestamp": timestamp,
        });
      });

      _messageController.clear(); // Limpiar el campo de entrada
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName), // Nombre del usuario en el encabezado
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              reverse: true, // Los mensajes más recientes se muestran al final
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message['sender'] == 'me';

                final timestamp = message['timestamp'] as DateTime;
                final formattedTime =
                    "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['message'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Text(
                          formattedTime,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Campo de texto para escribir un mensaje
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
