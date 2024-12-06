import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
    chatService.connect();  // Asegúrate de conectar al iniciar el widget
    chatService.messages.listen((message) {
      setState(() {
        messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    chatService.disconnect();
    super.dispose();
  }

  void _sendMessage() async {
    String message = _controller.text;
    if (message.isNotEmpty) {
      await chatService.sendMessage(message); // Envía el mensaje
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
                  onPressed: _sendMessage,  // Llama al método para enviar el mensaje
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
