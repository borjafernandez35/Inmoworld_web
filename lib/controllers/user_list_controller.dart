import 'package:get/get.dart';
import 'package:inmoworld_web/services/user.dart';
import 'package:inmoworld_web/models/user_model.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class UserListController extends GetxController {
  final PagingController<int, UserModel> pagingController =
      PagingController(firstPageKey: 1);
  final UserService userService = UserService();
  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    pagingController.addPageRequestListener((pageKey) {
      fetchUsers(pageKey);
    });
  }

  Future<void> fetchUsers(int pageKey) async {
    try {
      final users = await userService.getUsers(pageKey, pageSize);
      final isLastPage = users.length < pageSize;

      if (isLastPage) {
        pagingController.appendLastPage(users);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(users, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }
}