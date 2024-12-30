import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas
import 'dart:convert';
import '../services/chat.dart';
import '../services/user.dart';
import '../models/chatModel.dart'; // Importamos el modelo Chat
import 'package:inmoworld_web/services/storage.dart';

class ChatWidget extends StatefulWidget {
  final String userId;

  ChatWidget({required this.userId});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatService chatService; // Servicio de chat
  late UserService userService; // Servicio de usuario
  late Future<List<Chat>> chats; // Lista de chats
  TextEditingController _controller = TextEditingController();
  List<Chat> messages = []; // Lista local de mensajes

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
      final messageData = Chat.fromJson(data); // Convertir el mensaje a objeto Chat
      setState(() {
        messages.add(messageData);
      });
    });
  }

  // Carga los mensajes iniciales desde el backend
  Future<List<Chat>> _loadChats() async {
    try {
      final userId = StorageService.getId(); // Obtén el ID del usuario actual
      final chatList = await chatService.chatStartup(userId);

      setState(() {
        messages = chatList; // Actualizar la lista local de mensajes
      });

      return chatList;
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

      // Crear el mensaje como objeto Chat
      final chatMessage = Chat(
        receiver: widget.userId,
        sender: StorageService.getId(),
        message: message,
        date: timestamp,
      );

      // Envía el mensaje al servidor
      chatService.sendMessage(jsonEncode(chatMessage.toJson()));

      // Agrega el mensaje localmente
      setState(() {
        messages.add(chatMessage);
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
            child: FutureBuilder<List<Chat>>(
              future: chats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Indicador de carga
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los mensajes'));
                } else {
                  final loadedMessages = snapshot.data ?? [];
                  return ListView.builder(
                    reverse: true, // Mostrar mensajes recientes primero
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      final isMe = message.sender == StorageService.getId();

                      final formattedTime =
                          DateFormat('HH:mm').format(message.date);

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
                                message.message,
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
