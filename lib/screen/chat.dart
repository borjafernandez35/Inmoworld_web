import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Para formatear timestamps
import '../models/chatModel.dart';
import '../services/chat.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/controllers/chatController.dart';
import 'package:inmoworld_web/controllers/navigationController.dart';

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
  late final ChatService chatService;
  final ChatController chatController = Get.put(ChatController());
  final NavigationController navController = Get.put(NavigationController());

  @override
  void initState() {
    super.initState();

    // Inicializa los servicios

    chatService = ChatService();

    // Conecta al servidor de Socket.IO
    chatService.connect();

    // Marcar mensajes como leídos
    //chatService.markMessagesAsRead(StorageService.getId()!, widget.userId);

    // Cargar mensajes iniciales desde el backend
    //chats = _loadChats();

     // Cargar mensajes históricos
    chatService.loadMessages(StorageService.getId()!);

    // Marcar mensajes como leídos
    //chatService.markAsRead(StorageService.getId()!, widget.userId);
     //navController.markMessagesAsRead();

      WidgetsBinding.instance.addPostFrameCallback((_) {
      navController.markMessagesAsRead();
    });

    // Listener para recibir mensajes históricos
    chatService.socket?.on('load-messages-response', (data) {
      List<Chat> messages = (data as List).map((item) {
        return Chat(
          receiver: item['receiver'],
          sender: item['sender'],
          message: item['message'],
          date: DateTime.parse(item['date']),
        );
      }).toList();

          // Asegurarse de no añadir duplicados
      final existingIds = chatController.chatMessages.map((m) => m.message).toSet();
      final newMessages = messages.where((m) => !existingIds.contains(m.message));

      // Añadir mensajes al controlador
      chatController.chatMessages.addAll(messages);
    });

    // Listener para mensajes en tiempo real
    chatService.socket?.on('message-receive', (data) {
      final message = Chat(
        receiver: data['receiver'],
        sender: data['sender'],
        message: data['message'],
        date: DateTime.parse(data['timestamp']),
      );

      chatController.chatMessages.insert(0, message);
    });

    // Listener para eventos de "escribiendo"
    chatService.socket?.on('typing', (_) {
      chatController.isTyping.value = true;
    });

    chatService.socket?.on('stop-typing', (_) {
      chatController.isTyping.value = false;
    });
  }

  // Método para enviar mensajes
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final chatMessage = {
        "receiver": widget.userId,
        "sender": StorageService.getId(),
        "message": text,
        "timestamp": DateTime.now().toIso8601String(),
      };

       // Enviar mensaje al servidor
      chatService.sendMessage(jsonEncode(chatMessage),widget.userId);

      // Limpiar el campo de texto
      _messageController.clear();

      // Detener el evento de "escribiendo"
      chatService.sendStopTypingEvent(widget.userId);
    }

    /* // Escuchar mensajes entrantes en tiempo real
    chatService.socket?.on('message', (data) {
      final messageData = jsonDecode(data);
      print('el mensaje esssssss........:$messageData');
      chatController.chatMessages.add(Chat(
        receiver: messageData['receiver'],
        sender: messageData['sender'],
        message: messageData['message'],
        date: DateTime.parse(messageData['timestamp']),
      ));
    });

  // Escuchar eventos de "escribiendo"
    chatService.socket?.on('typing', (data) {
      chatController.isTyping.value = true;
    });

    chatService.socket?.on('stop-typing', (data) {
      chatController.isTyping.value = false;
    });

    _loadChats(); */

  }

/*   // Función para cargar mensajes desde el backend
  Future<List<Map<String, dynamic>>> _loadChats() async {
    try {
      // Obtén el ID del usuario desde UserService
      final userId = StorageService.getId();

      // Llama al método de ChatService para obtener los chats
      final chatList = await chatService.chatStartup(userId!);

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
  } */
  @override
  void dispose() {
    chatService.disconnect(); // Desconectar el socket al salir
    super.dispose();
  }

/*   Future<void> _loadChats() async {
    final userId = StorageService.getId();
    if (userId != null) {
      final chats = await chatService.chatStartup(userId);
      chatController.chatMessages.addAll(chats);
    }
  }

  @override
  void dispose() {
    chatService.disconnect(); / */
/* 
   void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final chatMessage = {
        "receiver": widget.userId,
        "sender": StorageService.getId(),
        "message": text,
        "timestamp": DateTime.now().toIso8601String(),
      };

      chatService.sendMessage(jsonEncode(chatMessage));
      _messageController.clear();
    }
    chatService.sendStopTypingEvent(widget.userId); */
  

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName), // Nombre del usuario en la cabecera
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  reverse: true,
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    final message = chatController.chatMessages[index];
                    final isMe = message.sender == StorageService.getId();
                    final formattedTime =
                        DateFormat('HH:mm').format(message.date);

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? "Tú" : message.sender ?? "Desconocido",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            Text(message.message),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                formattedTime,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
          Obx(() => chatController.isTyping.value
              ? const Text("Typing...",
                  style: TextStyle(color: Colors.grey))
              : const SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                       onChanged: (value) {
                      if (value.isNotEmpty) {
                        chatService.sendTypingEvent(widget.userId);
                      } else {
                        chatService.sendStopTypingEvent(widget.userId);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
