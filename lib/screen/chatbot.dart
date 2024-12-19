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
  List<Map<String, String>> _messages = [];
  late DialogFlow _dialogflow;  // Declaramos la instancia de Dialogflow

  // Este método se llama cuando el widget se inicializa
  @override
  void initState() {
    super.initState();
    _initializeDialogflow();
  }

  // Inicialización de Dialogflow usando las credenciales
  Future<void> _initializeDialogflow() async {
    try {
      // Autenticación con el archivo JSON de credenciales
      AuthGoogle authGoogle = await AuthGoogle(fileJson: "assets/credenciales.json").build();  // Asegúrate de que el archivo .json esté correctamente ubicado
      _dialogflow = DialogFlow(authGoogle: authGoogle, language: 'es');
      print('Dialogflow inicializado correctamente');
    } catch (e) {
      print('Error al inicializar Dialogflow: $e');
    }
  }

  // Función para enviar el mensaje al chatbot y obtener la respuesta
  void _sendMessage(String text) async {
    setState(() {
      _messages.add({'sender': 'Usuario', 'text': text});
    });

    _messageController.clear();

    // Conectar a Dialogflow para obtener la respuesta
    String response = await _getBotResponse(text);

    setState(() {
      _messages.add({'sender': 'Bot', 'text': response});
    });
  }

  // Función para obtener la respuesta del bot utilizando Dialogflow
  Future<String> _getBotResponse(String message) async {
  try {
    // Detectar la intención del mensaje

     Map<String, dynamic> jsonObject = {
    "queryInput": {
    "text": {
      "text": message
    },
    "languageCode": "es"
    },
    "queryParams": {
    "timeZone": "Spain/Madrid"
    }
    };
    String query = jsonEncode(jsonObject);
    AIResponse response = await _dialogflow.detectIntent(query);

    // Verificar que la respuesta no sea null y que contenga el mensaje
    if (response != null && response.getMessage() != null) {
      return response.getMessage() ?? "No entendí eso. ¿Puedes repetirlo?";
    } else {
      return "No obtuve una respuesta válida.";
    }
  } catch (e) {
    return "Ocurrió un error: $e";
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                bool isUser = message['sender'] == 'Usuario';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(fontSize: 16),
                    ),
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
                    decoration: InputDecoration(hintText: "Escribe un mensaje..."),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _sendMessage(_messageController.text);
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
