import 'package:flutter/material.dart';
import 'package:inmoworld_web/generated/l10n.dart';
import 'package:inmoworld_web/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lastMessageTime = user.lastMessageTime != null
        ? "${user.lastMessageTime!.hour.toString().padLeft(2, '0')}:${user.lastMessageTime!.minute.toString().padLeft(2, '0')}"
        : "";

    return ListTile(
      leading: CircleAvatar(
        child: Text(user.name[0]), // Inicial del nombre
      ),
      title: Text(user.name),
      subtitle: Text(
        user.lastMessage ?? S.current.SinMensajes,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        lastMessageTime,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      /* onTap: () {
        // Navegar a la pantalla de chat
        Navigator.push(
          context,
          /* MaterialPageRoute(
            builder: (context) => ChatScreen(
              userId: user.id ?? '',  // Aquí pasas el ID del usuario
              userName: user.name,     // Aquí pasas el nombre del usuario
            ),
          ), */
        );
      }, */
    );
  }
}
