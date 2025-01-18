// Versión 2 ###########################################
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/chatModel.dart';
import '../services/chat.dart';
import '../services/user.dart';
import '../services/storage.dart';
import '../controllers/chatController.dart';
import '../controllers/navigationController.dart';

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
  late UserService userService;
  final ChatController chatController = Get.put(ChatController());
  final NavigationController navController = Get.put(NavigationController());

  @override
  void initState() {
    super.initState();

    // Inicializar servicios
    userService = UserService();
    chatService = ChatService(userService);
    chatService.connect();
    chatService.registerUser(StorageService.getId()); 
    print("Socket conectado: ${chatService.socket?.connected}");

    // Cargar mensajes iniciales
    chatService.loadMessages(StorageService.getId()!);

    // Marcar mensajes como leídos al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navController.markMessagesAsRead();
    });

    // Listener para mensajes y eventos
    chatService.socket?.on('load-messages-response', (data) {
      List<Chat> messages = (data as List).map((item) {
        return Chat(
          receiver: item['receiver'],
          sender: item['sender'],
          message: item['message'],
          date: DateTime.parse(item['date']),
        );
      }).toList();

      // Filtrar mensajes duplicados
      final existingMessages =
          chatController.chatMessages.map((m) => m.message).toSet();
      final newMessages =
          messages.where((m) => !existingMessages.contains(m.message)).toList();

      chatController.chatMessages.addAll(newMessages);
    });

    chatService.socket?.on('message-receive', (data) {
      final message = Chat(
        receiver: data['receiver'],
        sender: data['sender'],
        message: data['message'],
        date: DateTime.parse(data['timestamp']),
      );
      chatController.chatMessages.insert(0, message);
    });

    chatService.socket?.on('typing', (_) {
      chatController.isTyping.value = true;
    });

    chatService.socket?.on('stop-typing', (_) {
      chatController.isTyping.value = false;
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final timestamp = DateTime.now();
      final chatMessage = Chat(
        receiver: widget.userId,
        sender: StorageService.getId(),
        message: text,
        date: timestamp,
      );

      // Agregar el mensaje localmente
      chatController.chatMessages.insert(0, chatMessage);

      // Enviar el mensaje al servidor
      chatService.sendMessage(chatMessage.toJson());

      // Limpiar el campo de texto
      _messageController.clear();

      // Detener el evento "typing"
      chatService.sendStopTypingEvent(widget.userId);
    }
  }

  Widget buildMessage(Chat message, bool isMe) {
    final formattedTime = DateFormat('HH:mm').format(message.date);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              backgroundImage: AssetImage("assets/default.png"),
              radius: 20,
            ),
          if (!isMe) const SizedBox(width: 10),
          Flexible(
            child: Bubble(
              radius: Radius.circular(15.0),
              color: isMe ? Colors.blueAccent : Colors.grey.shade200,
              elevation: 0.0,
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? "Tú" : widget.userName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message.message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        formattedTime,
                        style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 10),
          if (isMe)
            CircleAvatar(
              backgroundImage: AssetImage("assets/default.png"),
              radius: 20,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
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
                    return buildMessage(message, isMe);
                  },
                )),
          ),
          Obx(() => chatController.isTyping.value
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Escribiendo...",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
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
                      filled: true,
                      fillColor: Color.fromRGBO(220, 220, 220, 1),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
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


/* Versión 1 ###########################################
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/chatModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/chat.dart';
import '../services/user.dart';
import '../services/storage.dart';
import '../controllers/chatController.dart';
import '../controllers/navigationController.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatService chatService;
  late UserService userService;
  final ChatController chatController = Get.put(ChatController());
  final NavigationController navController = Get.put(NavigationController());

  @override
  void initState() {
    super.initState();

    // Inicializar servicios
    userService = UserService();
    chatService = ChatService(userService);
    chatService.connect();
    chatService.registerUser(StorageService.getId());
    print("Socket conectado: ${chatService.socket?.connected}");

    // Cargar mensajes iniciales
    // _loadChats();

    chatService.loadMessages(StorageService.getId()!);

    // Marcar mensajes como leídos al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navController.markMessagesAsRead();
    });

    // Listener para mensajes y eventos
    chatService.socket?.on('load-messages-response', (data) {
      // Parsear los mensajes recibidos
      List<Chat> messages = (data as List).map((item) {
        return Chat(
          receiver: item['receiver'],
          sender: item['sender'],
          message: item['message'],
          date: DateTime.parse(item['date']),
        );
      }).toList();

      // Filtrar mensajes duplicados
      final existingMessages = chatController.chatMessages.map((m) => m.message).toSet();
      final newMessages = messages.where((m) => !existingMessages.contains(m.message)).toList();

      // Añadir solo los nuevos mensajes
      chatController.chatMessages.addAll(newMessages);
    });


    chatService.socket?.on('message-receive', (data) {
      print("Mensaje recibido: $data");
      final message = Chat(
        receiver: data['receiver'],
        sender: data['sender'],
        message: data['message'],
        date: DateTime.parse(data['timestamp']),
      );
      chatController.chatMessages.insert(0, message);
    });

    chatService.socket?.on('typing', (_) {
      chatController.isTyping.value = true;
    });

    chatService.socket?.on('stop-typing', (_) {
      chatController.isTyping.value = false;
    });
  }

  void _sendMessage() {
  final text = _messageController.text.trim();
  if (text.isNotEmpty) {
    final timestamp = DateTime.now();
    final chatMessage = Chat(
      receiver: widget.userId,
      sender: StorageService.getId(),
      message: text,
      date: timestamp,
    );

    // Agregar el mensaje localmente si no existe ya
    /*final existingMessages = chatController.chatMessages.map((m) => m.message).toSet();
    if (!existingMessages.contains(chatMessage.message)) {
      chatController.chatMessages.insert(0, chatMessage);
    }
    */ chatController.chatMessages.insert(0, chatMessage);

    // Enviar el mensaje al servidor
    chatService.sendMessage(chatMessage.toJson());

    // Limpiar el campo de texto
    _messageController.clear();

    // Detener el evento "typing"
    chatService.sendStopTypingEvent(widget.userId);
  }
  }


  @override
  void dispose() {
    chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
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
              ? const Text("Escribiendo...",
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
*/