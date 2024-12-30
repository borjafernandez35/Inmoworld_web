import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:inmoworld_web/controllers/user_list_controller.dart';
import 'package:inmoworld_web/widgets/user_card.dart';
import 'package:inmoworld_web/models/user_model.dart';

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
            child: Text('Error loading data.'),
          ),
          newPageErrorIndicatorBuilder: (context) => Center(
            child: Text('Failed to load more data.'),
          ),
          firstPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
