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

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: PagedListView<int, UserModel>(
        pagingController: userListController.pagingController,
        builderDelegate: PagedChildBuilderDelegate<UserModel>(
          itemBuilder: (context, user, index) => UserCard(user: user),
          firstPageErrorIndicatorBuilder: (context) => Center(
            child: const Text('Error cargando datos.'),
          ),
          newPageErrorIndicatorBuilder: (context) => Center(
            child: const Text('No se pudieron cargar más datos.'),
          ),
          firstPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: const CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
}

