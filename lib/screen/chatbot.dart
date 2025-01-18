// Seguda Versión ###############################################################
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
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
  late DialogFlowtter dialogFlowtter;

  @override
  void initState() {
    super.initState();
    initializeDialogFlowtter();
  }

  Future<void> initializeDialogFlowtter() async {
    dialogFlowtter = await DialogFlowtter.fromFile(
      path: "assets/credenciales.json",
    );
  }

  void response(String query) async {
    if (query.isEmpty) return;

    setState(() {
      messages.insert(0, {"data": 1, "message": query});
    });
    _messageController.clear();

    try {
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(
          text: TextInput(text: query, languageCode: "es"),
        ),
      );

      String botMessage = response.text ?? '';
      if (botMessage.isNotEmpty) {
        setState(() {
          messages.insert(0, {"data": 0, "message": botMessage});
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Widget buildMessage(String message, int data) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment:
            data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          data == 0
              ? CircleAvatar(
                  backgroundImage: AssetImage("assets/robot.png"),
                  radius: 20,
                )
              : SizedBox.shrink(),
          SizedBox(width: 10),
          Flexible(
            child: Bubble(
              radius: Radius.circular(15.0),
              color: data == 0
                  ? Color.fromRGBO(23, 157, 139, 1)
                  : Colors.orangeAccent,
              elevation: 0.0,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  message,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          data == 1
              ? CircleAvatar(
                  backgroundImage: AssetImage("assets/default.png"),
                  radius: 20,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot con Dialogflow"),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
              "Hoy, ${DateFormat("Hm").format(DateTime.now())}",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]["message"],
                    messages[index]["data"]);
              },
            ),
          ),
          Divider(
            height: 5.0,
            color: Colors.greenAccent,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Escribe un mensaje...",
                      hintStyle: TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: Color.fromRGBO(220, 220, 220, 1),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.greenAccent),
                  onPressed: () {
                    response(_messageController.text);
                    FocusScope.of(context).unfocus();
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



// Primera Versión ##############################################################
/*
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
*/