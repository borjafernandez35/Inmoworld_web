import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/models/property_model.dart';
import 'package:inmoworld_web/widgets/property_list.dart';
import 'package:inmoworld_web/widgets/search_bar.dart' as custom;
import 'package:inmoworld_web/controllers/property_controller.dart';
import 'package:inmoworld_web/services/user.dart';
import '../services/chat.dart';
import '../controllers/chat_controller.dart';
import '../services/storage.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({Key? key}) : super(key: key);

  @override
  _PropertyScreenState createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final PropertyController _propertyController = Get.put(PropertyController());
  final PagingController<int, PropertyModel> _pagingController =
      PagingController(firstPageKey: 1);
  final UserService _userService = UserService();
  late UserService userService;
  late final ChatService chatService;
  final ChatController chatController = Get.put(ChatController());
  
  @override
  void initState() {
    super.initState();
    // Inicializar servicios
    userService = UserService();
    chatService = ChatService(userService);
    chatService.connect();
    chatService.registerUser(StorageService.getId());
    print("Socket conectado: ${chatService.socket?.connected}");
    // Configuramos el listener para cargar las páginas
    _pagingController.addPageRequestListener(_fetchPage);
  }

  

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      await _propertyController.fetchProperties(page: pageKey,limit: 10,distance: 1000000000,sort: 'Price');
      final isLastPage = _propertyController.properties.length < 10;
      if (isLastPage) {
        _pagingController.appendLastPage(_propertyController.properties);
      } else {
        _pagingController.appendPage(_propertyController.properties, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/logo.png',
              height: 110,
            ),
          ),
          // Barra de búsqueda reutilizable
         custom.SearchBar(onSearchChanged: (query) {
            _propertyController.fetchProperties(page:1,limit: 10,distance: 1000000000,sort: query);
          }),
          // Lista de propiedades reutilizable
          Expanded(
            child: PropertyList(pagingController: _pagingController),
          ),
        ],
      ),
    );
  }
}




