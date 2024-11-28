import 'package:get/get.dart';
import 'package:inmoworld_web/services/user.dart';
import 'package:inmoworld_web/models/userModel.dart';

class UserListController extends GetxController {
  var isLoading = true.obs;
  var userList = <UserModel>[].obs;
  final UserService userService = UserService();

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading(true);
      var users = await userService.getUsers();
      userList.assignAll(users);
      
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      isLoading(false);
    }
  }
}