import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/chat_model.dart';
import '../services/chat.dart';
import '../services/user.dart';
import '../services/storage.dart';
import '../controllers/chat_controller.dart';
import '../controllers/navigation_controller.dart';

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