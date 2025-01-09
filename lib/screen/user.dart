import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/controllers/userListController.dart';
import 'package:inmoworld_web/widgets/userCard.dart';
import 'package:inmoworld_web/models/userModel.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserListController userListController = Get.put(UserListController());
    
    // Suponiendo que el idioma se pueda verificar de alguna manera
    // Por ejemplo, se puede obtener el idioma actual del contexto o de la configuración
    String language = 'es';  // Puedes hacer esta asignación dinámicamente según el idioma actual

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: PagedListView<int, UserModel>(
        pagingController: userListController.pagingController,
        builderDelegate: PagedChildBuilderDelegate<UserModel>(
          itemBuilder: (context, user, index) => UserCard(user: user),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: Text(language == 'es' ? 'Error cargando datos.' : 'Error loading data.'),
          ),
          newPageErrorIndicatorBuilder: (context) => Center(
            child: Text(language == 'es' 
                ? 'No se pudieron cargar más datos.' 
                : 'Failed to load more data.'),
          ),
          firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
