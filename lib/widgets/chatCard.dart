import 'package:flutter/material.dart';
import 'dart:convert'; // Para procesar JSON
import '../services/chat.dart';
import '../services/user.dart';

class ChatWidget extends StatefulWidget {
  final String userId;

  ChatWidget({required this.userId});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatService chatService; // Servicio de chat
  late UserService userService; // Servicio de usuario
  late Future<List<Map<String, dynamic>>> chats; // Lista para cargar los chats iniciales
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = []; // Mensajes en pantalla

  @override
  void initState() {
    super.initState();

    // Inicializa UserService y ChatService
    userService = UserService();
    chatService = ChatService(userService);

    // Conecta el socket
    chatService.connect();

    // Cargar mensajes iniciales desde el backend
    chats = _loadChats();

    // Escuchar mensajes en tiempo real
    chatService.socket?.on('message', (data) {
      final messageData = jsonDecode(data); // Decodificar mensaje JSON
      setState(() {
        messages.add({
          "receiver": messageData['receiver'],
          "sender": messageData['sender'],
          "message": messageData['message'],
          "timestamp": DateTime.parse(messageData['timestamp']),
        });
      });
    });
  }

  // Carga los mensajes iniciales desde el backend
  Future<List<Map<String, dynamic>>> _loadChats() async {
    try {
      final userId = userService.getId(); // Obtén el ID del usuario
      final chatList = await chatService.chatStartup(userId);

      final convertedChats = chatList.map<Map<String, dynamic>>((chat) {
        return {
          "receiver": chat['receiver'],
          "sender": chat['sender'],
          "message": chat['message'],
          "timestamp": chat['timestamp'],
        };
      }).toList();

      setState(() {
        messages = convertedChats.map((chat) => {
              "receiver": chat['receiver'],
              "sender": chat['sender'],
              "message": chat['message'],
              "timestamp": DateTime.parse(chat['timestamp']),
            }).toList();
      });

      return convertedChats;
    } catch (error) {
      print("Error al cargar los chats: $error");
      return [];
    }
  }

  // Enviar mensaje al servidor
  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      final timestamp = DateTime.now();

      // Envía el mensaje al servidor
      chatService.sendMessage(jsonEncode({
        "receiver": widget.userId,
        "sender": userService.getId(),
        "message": message,
        "timestamp": timestamp.toIso8601String(),
      }));

      // Agrega el mensaje localmente
      setState(() {
        messages.add({
          "sender": "me",
          "message": message,
          "timestamp": timestamp,
        });
      });

      _controller.clear(); // Limpia el campo de texto
    }
  }

  @override
  void dispose() {
    chatService.disconnect(); // Desconectar el socket al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat - Usuario: ${widget.userId}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: chats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Muestra un indicador de carga
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los mensajes'));
                } else {
                  final loadedMessages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true, // Mostrar mensajes recientes primero
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMe = message['sender'] == 'me';

                      final timestamp = message['timestamp'] as DateTime;
                      final formattedTime =
                          "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.blue
                                    : Colors.grey.shade200,
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
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage, // Envía el mensaje
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
