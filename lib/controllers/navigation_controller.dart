import 'package:get/get.dart';
import 'package:inmoworld_web/services/storage.dart';
import 'package:inmoworld_web/services/chat.dart';
import 'package:inmoworld_web/services/user.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;
  var unreadMessages = 0.obs;

  final List<String> routes = [
    '/properties',
    '/chat',
    '/chatbot',
    '/usuarios',
    '/perfil', 
    '/home',
   // '/post',
    '/map'
  ];

  late ChatService chatService;
  late UserService userService;

 @override
  void onInit() {
    super.onInit();
    userService = UserService();
    chatService = ChatService(userService);
    _loadUnreadMessages();
    _listenForNewMessages(); // Escuchar mensajes entrantes
  }

  void navigateTo(int index) {
    selectedIndex.value = index;
    Get.offNamed(routes[index]);

    if (routes[index] == '/chat') {
      markMessagesAsRead(); // Resetear contador al abrir el chat
    }
  }

  void _loadUnreadMessages() async {
    final userId = StorageService.getId();
    if (userId != null) {
      chatService.getUnreadCount(userId); // Emite el evento `unread-count`
      chatService.socket?.on('unread-count-response', (data) {
        unreadMessages.value = data['unreadCount'] ?? 0;
      });
    }
  }

  void _listenForNewMessages() {
    chatService.connect(); // Asegurar conexión
    chatService.socket?.on('new-message', (data) {
      final senderId = data['sender'];
      final userId = StorageService.getId();

      if (senderId != userId) {
        unreadMessages.value += 1; // Incrementar contador de mensajes no leídos
      }
    });
  }

  void markMessagesAsRead() async {
    final userId = StorageService.getId();
    if (userId != null) {
      chatService.markAsRead(userId, userId); // Emitir evento `mark-as-read`
      unreadMessages.value = 0; // Resetear el contador local
    }
  }
}
