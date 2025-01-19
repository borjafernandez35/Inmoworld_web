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
  DialogFlowtter? dialogFlowtter; // Hacer que sea opcional para verificar null.

  @override
  void initState() {
    super.initState();
    initializeDialogFlowtter();
  }

  Future<void> initializeDialogFlowtter() async {
    dialogFlowtter = await DialogFlowtter.fromFile(
      path: "assets/dialog_flow_auth.json",
    );
    setState(() {}); // Asegurarse de que se reconstruya la UI después de inicializar.
  }

  void response(String query) async {
    if (query.isEmpty || dialogFlowtter == null) return; // Verificar null.
    setState(() {
      messages.insert(0, {"data": 1, "message": query});
    });
    _messageController.clear();

    try {
      /*
      DetectIntentResponse response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(
          text: TextInput(text: query, languageCode: "es"),
        ),
      );
      */
      DetectIntentResponse response = await dialogFlowtter!.detectIntent(
        queryInput: QueryInput(
          text: TextInput(text: query, languageCode: "es")));

      String botMessage = response.queryResult.toString() ?? '';
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
                  backgroundImage: AssetImage("assets/robot.jpg"),
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
      body: dialogFlowtter == null // Mostrar indicador mientras se inicializa.
          ? Center(child: CircularProgressIndicator())
          : Column(
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
