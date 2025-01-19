import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:inmoworld_web/screen/chat.dart';
import 'package:inmoworld_web/models/user_model.dart';
import 'package:get/get.dart';
import '../services/chat.dart';
import '../services/user.dart';
import '../services/storage.dart';
import '../controllers/chat_controller.dart';


class UserCard extends StatefulWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  IO.Socket? socket;
  String? lastMessage;
  DateTime? lastMessageTime;
  late final ChatService chatService;
  late UserService userService;
  final ChatController chatController = Get.put(ChatController());
  late UserModel user;

  @override
  void initState() {
    super.initState();
    // Inicializar servicios
    userService = UserService();
    chatService = ChatService(userService);
    chatService.connect();
    chatService.registerUser(StorageService.getId()); 
    chatService.getLastMessage(StorageService.getId());

    chatService.socket!.on('last-message-response', (data) {
    try {
      if (data != null) {
        List<dynamic> messages = data;

        for (var messageData in messages) {
          // Convertir ObjectId de sender a String para comparación
          String senderId = messageData['sender'].toString(); // Asegúrate de convertir a String
          // print("Sender Id: $senderId");
          String lastMessage = messageData['message'];
          DateTime lastMessageTime = DateTime.parse(messageData['timestamp']);
          // print("Last Message: $lastMessage");
          List<UserModel> userss = StorageService.getUserList();
          // Buscar usuario en la lista y actualizar su último mensaje
          final usery = StorageService.getUserList().firstWhere(
            (user) => user.id == senderId,
            orElse: () => UserModel( // Devolver un UserModel vacío si no se encuentra el usuario
              name: 'Desconocido', 
              email: 'No especificado',
              password: '',
              birthday: '',
              isAdmin: false,
            ),
          );

          // Si el usuario es un objeto válido, actualizamos su mensaje
          if (usery != null && usery.id != null && widget.user.name == usery.name) {
             setState(() {
              widget.user.setUser(
                name: usery.name,
                email: usery.email,
                password: usery.password,
                birthday: usery.birthday,
                isAdmin: usery.isAdmin,
                id: usery.id,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
              );
            });
            // print(user);
            // print("User last message: ${user.lastMessage}");
          }
        }
        
        userService.notifyListeners();  // Notificar a los listeners para que la UI se actualice
      } else {
        print('No se recibieron mensajes en la respuesta.');
      }
    } catch (e) {
      print('Error al procesar last-message-response: $e');
    }
    });

  }

  @override
  void dispose() {
    // Desconectar el socket al destruir el widget
    socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Formatear la hora del último mensaje
    final formattedLastMessageTime = lastMessageTime != null
        ? "${lastMessageTime!.hour.toString().padLeft(2, '0')}:${lastMessageTime!.minute.toString().padLeft(2, '0')}"
        : "";

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            widget.user.name[0].toUpperCase(), // Inicial del nombre
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
        title: Text(
          widget.user.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          widget.user.lastMessage ?? 'Sin mensajes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: widget.user.lastMessage != null ? Colors.black87 : Colors.grey,
          ),
        ),
        trailing: formattedLastMessageTime.isNotEmpty
            ? Text(
                formattedLastMessageTime,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: widget.user.id ?? '',
                userName: widget.user.name,
              ),
            ),
          );
        },
      ),
    );
  }
}