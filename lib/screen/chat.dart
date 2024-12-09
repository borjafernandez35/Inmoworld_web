import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/chat.dart';
import '../services/user.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Lista de mensajes
  late final ChatService chatService;
  late final UserService userService;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    chatService = ChatService();
    chatService.connect(); // Conecta al servidor de Socket.IO

    // Escuchar mensajes entrantes
    chatService.socket?.on('message', (data) {
      final messageData = jsonDecode(data); // Suponiendo que el mensaje es un JSON
      setState(() {
        _messages.add({
          "receiver": messageData['receiver'],
          "sender": messageData['sender'],
          "message": messageData['message'],
          "timestamp": DateTime.parse(messageData['timestamp']),
        });
      });
    });
  }

  @override
  void dispose() {
    chatService.disconnect(); // Desconectar cuando se destruye el widget
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final timestamp = DateTime.now();

      // Enviar mensaje al servidor
      chatService.sendMessage(jsonEncode({
        "receiver": widget.userId,
        "sender": userService.getId(),
        "message": text,
        "timestamp": timestamp.toIso8601String(),
      }));

      // Añadir mensaje local
      setState(() {
        _messages.add({
          "sender": "me",
          "message": text,
          "timestamp": timestamp,
        });
      });

      _messageController.clear(); // Limpia el campo de texto
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName), // Nombre del usuario en la cabecera
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Mostrar los mensajes más recientes al final
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
