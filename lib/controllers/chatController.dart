import 'package:get/get.dart';
import '../models/chatModel.dart';

class ChatController extends GetxController {
  var chatMessages = <Chat>[].obs; // Lista observable de mensajes
   var isTyping = false.obs; // Variable para el indicador "escribiendo..."
}
