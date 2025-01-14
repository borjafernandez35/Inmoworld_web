
import 'package:dialogflow_flutter/language.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dialogflow_flutter/dialogflowFlutter.dart';
import 'package:dialogflow_flutter/googleAuth.dart';
  // Importar la librería dialogflow_flutter

void main() => runApp(ChatBotApp());

class ChatBotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
  }

  void response(String query) async {
    try {
      AuthGoogle authGoogle = await AuthGoogle(fileJson: "assets/credenciales.json").build();
      DialogFlow dialogflow = DialogFlow(authGoogle: authGoogle, language: Language.spanish);
      AIResponse aiResponse = await dialogflow.detectIntent(query);
      String botMessage = aiResponse.getListMessage()![0]["text"]["text"][0].toString();
      setState(() {
        messages.insert(0, {"data": 0, "message": botMessage});
      });
      print(botMessage);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot con Dialogflow")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]["message"]),
                  subtitle: Text(messages[index]["data"] == 0 ? "Bot" : "Usuario"),
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
                    decoration: InputDecoration(hintText: "Escribe un mensaje..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String userMessage = _messageController.text;
                    if (userMessage.isNotEmpty) {
                      setState(() {
                        messages.insert(0, {"data": 1, "message": userMessage});
                      });
                      _messageController.clear();
                      response(userMessage);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}