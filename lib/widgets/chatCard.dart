import 'package:flutter/material.dart';
import '../services/chat.dart';

class ChatWidget extends StatefulWidget {
  final String userId;

  ChatWidget({required this.userId});

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatService chatService;
  TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    chatService = ChatService();
    chatService.connect(); // Conecta al servidor

    // Escuchar mensajes recibidos
    chatService.socket?.on('message', (data) {
      setState(() {
        messages.add(data.toString()); // Agrega el mensaje al listado
      });
    });
  }

  @override
  void dispose() {
    chatService.disconnect(); // Desconectar el socket
    super.dispose();
  }

  void _sendMessage() {
    String message = _controller.text.trim();
    if (message.isNotEmpty) {
      chatService.sendMessage(message); // Envía el mensaje al servidor
      _controller.clear(); // Limpia el campo de texto
    }
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
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
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
