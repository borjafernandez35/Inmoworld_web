import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Para formatear timestamps
import '../services/chat.dart';
import '../services/user.dart';
import 'package:inmoworld_web/services/storage.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({Key? key, required this.userId, required this.userName})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // Lista de mensajes locales
  late final ChatService chatService;
  late final UserService userService;
  late Future<List<Map<String, dynamic>>>
      chats; // Lista futura para los chats iniciales

  @override
  void initState() {
    super.initState();

    // Inicializa los servicios
    userService = UserService();
    chatService = ChatService(userService);

    // Conecta al servidor de Socket.IO
    chatService.connect();

    // Cargar mensajes iniciales desde el backend
    chats = _loadChats();

    // Escuchar mensajes entrantes en tiempo real
    chatService.socket?.on('message', (data) {
      final messageData = jsonDecode(data); // Decodificar JSON
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

  // Función para cargar mensajes desde el backend
  Future<List<Map<String, dynamic>>> _loadChats() async {
    try {
      // Obtén el ID del usuario desde UserService
      final userId = StorageService.getId();

      // Llama al método de ChatService para obtener los chats
      final chatList = await chatService.chatStartup(userId);

      // Convierte los datos a Map<String, dynamic>
      final convertedChats = chatList.map<Map<String, dynamic>>((chat) {
        return {
          "receiver": chat.receiver, // Acceso directo a las propiedades
          "sender": chat.sender,
          "message": chat.message,
          "date": chat.date,
        };
      }).toList();

      // Actualiza la lista de mensajes locales
      setState(() {
        _messages.clear();
        _messages.addAll(convertedChats.map((chat) => {
              "receiver": chat['receiver'],
              "sender": chat['sender'],
              "message": chat['message'],
              "timestamp": DateTime.parse(chat['timestamp']),
            }));
      });

      return convertedChats;
    } catch (error) {
      print("Error al cargar los chats: $error");
      return []; // Devuelve una lista vacía en caso de error
    }
  }

  @override
  void dispose() {
    chatService.disconnect(); // Desconectar el socket al salir
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final timestamp = DateTime.now();

      // Crear el mensaje
      final chatMessage = {
        "receiver": widget.userId,
        "sender": StorageService.getId(),
        "message": text,
        "timestamp": timestamp.toIso8601String(),
      };

      // Enviar mensaje al servidor
      chatService.sendMessage(jsonEncode(chatMessage));

      // Añadir mensaje localmente
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: chats, // Future que contiene los chats cargados
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los mensajes'));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse:
                        true, // Mostrar los mensajes más recientes al final
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      final isMe = message['sender'] == 'me';

                      final timestamp = message['timestamp'] as DateTime;
                      final formattedTime =
                          DateFormat('HH:mm').format(timestamp);

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                                color:
                                    isMe ? Colors.blue : Colors.grey.shade200,
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
            );
          }
        },
      ),
    );
  }
}
